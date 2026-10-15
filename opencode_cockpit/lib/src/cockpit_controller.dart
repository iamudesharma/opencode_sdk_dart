import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'models.dart';
import 'services/persistent_terminal.dart';
import 'terminal_session.dart';

/// Connection lifecycle of the cockpit.
enum CockpitConnection { idle, connecting, connected, failed }

/// What the explorer column shows.
enum ExplorerTab { sessions, files, git, terminals, stats }

/// What the inspector column shows.
enum InspectorTab { none, file, diff, changes }

/// A session plus its lazily loaded children.
final class SessionNode {
  SessionNode(this.info, {this.depth = 0});

  SessionInfo info;
  final int depth;
  final List<SessionNode> children = [];
  bool expanded = false;
  bool loadingChildren = false;
  bool childrenLoaded = false;

  String get id => info.id;
}

/// The cockpit: everything the workbench UI reads and mutates.
class CockpitController extends ChangeNotifier {
  CockpitController();

  OpenCodeClient? _client;
  StreamSubscription<OpenCodeEvent>? _events;
  Timer? _reconnectTimer;
  Timer? _sessionsDebounce;
  Timer? _messagesDebounce;
  Timer? _fileSearchDebounce;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Connection
  // ---------------------------------------------------------------------------

  CockpitConnection connection = CockpitConnection.idle;
  String? connectionError;
  String? serverVersion;
  Uri? baseUrl;

  ThemeMode themeMode = ThemeMode.dark;

  /// Test seam: overrides the HTTP client used for new connections.
  @visibleForTesting
  http.Client Function()? httpClientFactory;

  OpenCodeClient? get client => _client;

  bool get isConnected => connection == CockpitConnection.connected;

  Future<void> connectLocal() => _connect(discover: true);

  Future<void> connectTo(Uri url, {Map<String, String>? headers}) =>
      _connect(url: url, headers: headers, discover: false);

  Future<void> _connect({
    Uri? url,
    Map<String, String>? headers,
    required bool discover,
  }) async {
    await _teardown();
    connection = CockpitConnection.connecting;
    connectionError = null;
    _notify();
    try {
      if (discover) {
        final endpoint =
            await OpenCodeService.discover() ?? await OpenCodeService.ensure();
        url = endpoint.url;
        headers = OpenCodeService.headers(endpoint);
      }
      final client = OpenCodeClient(
        baseUrl: url!,
        headers: headers,
        clientFactory: httpClientFactory,
      );
      _client = client;
      baseUrl = client.transport.baseUrl;
      final info = await client.server.info();
      serverVersion = info.version;
      connection = CockpitConnection.connected;
      debugPrint(
        'OpenCode Cockpit connected to ${client.transport.baseUrl} '
        '(v${info.version})',
      );
      _notify();
      _listen();
      await Future.wait<void>([loadProjects(), loadAgentsAndModels()]);
    } on Object catch (error) {
      connection = CockpitConnection.failed;
      connectionError = describe(error);
      _notify();
    }
  }

  static String describe(Object error) {
    return switch (error) {
      OpenCodeStatusException(:final message) => message,
      OpenCodeTransportException(:final cause) =>
        'Cannot reach the server ($cause)',
      OpenCodeDecodeException(:final message) =>
        'Unexpected response: $message',
      _ => '$error',
    };
  }

  void _listen() {
    _events?.cancel();
    _events = _client!.event.subscribe().listen(
      handleEvent,
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;
        connectionError = 'Event stream lost; reconnecting\u2026';
        _notify();
        _scheduleReconnect();
      },
      onDone: () {
        if (_disposed || !isConnected) return;
        _scheduleReconnect();
      },
    );
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      if (_disposed || !isConnected) return;
      connectionError = null;
      _notify();
      _listen();
    });
  }

  Future<void> _teardown() async {
    _reconnectTimer?.cancel();
    _sessionsDebounce?.cancel();
    _messagesDebounce?.cancel();
    _fileSearchDebounce?.cancel();
    await _events?.cancel();
    _events = null;
    await terminal?.dispose();
    terminal = null;
    _client?.close();
    _client = null;
    projects = const [];
    activeProject = null;
    rootSessions = const [];
    activeSession = null;
    messages = const [];
    sessionChanges = const [];
    fileEntries = const [];
    selectedFilePath = null;
    selectedFileText = null;
    selectedFileBytes = null;
    inspectDiff = null;
    gitChanges = const [];
    gitDiffFiles = const [];
    branches = const [];
    vcsInfo = null;
    worktrees = const [];
    stats = null;
    pendingPermissions = const [];
    busySessionIDs.clear();
    usage.clear();
  }

  // ---------------------------------------------------------------------------
  // Server catalogs
  // ---------------------------------------------------------------------------

  List<Project> projects = const [];
  Project? activeProject;
  List<AgentInfo> agents = const [];
  List<ModelInfo> models = const [];

  Future<void> loadProjects() async {
    final client = _client;
    if (client == null || !isConnected || _disposed) return;
    try {
      projects = await client.project.list();
      if (activeProject == null && projects.isNotEmpty) {
        activeProject = projects.first;
      }
    } on Object catch (error) {
      debugPrint('project.list failed: ${describe(error)}');
    }
    _notify();
    await loadSessions();
  }

  Future<void> loadAgentsAndModels() async {
    final client = _client;
    if (client == null || _disposed) return;
    try {
      agents = (await client.agent.list()).data;
    } on Object {
      // Optional.
    }
    try {
      models =
          (await client.model.list()).data
              .where((model) => model.enabled)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    } on Object {
      // Optional.
    }
    _notify();
  }

  LocationRef get activeLocation {
    final project = activeProject;
    if (project != null) return LocationRef.directory(project.canonical);
    final session = activeSession;
    if (session != null && session.location.directory != null) {
      return LocationRef.directory(session.location.directory!);
    }
    return const LocationRef();
  }

  // ---------------------------------------------------------------------------
  // Explorer / tabs
  // ---------------------------------------------------------------------------

  ExplorerTab explorerTab = ExplorerTab.sessions;
  InspectorTab inspectorTab = InspectorTab.none;
  bool terminalVisible = false;

  void selectExplorerTab(ExplorerTab tab) {
    explorerTab = tab;
    _notify();
    switch (tab) {
      case ExplorerTab.files:
        unawaited(loadDirectory(fileRoot));
      case ExplorerTab.git:
        unawaited(loadGit());
      case ExplorerTab.stats:
        unawaited(loadStats());
      case ExplorerTab.terminals:
        unawaited(loadPersistentTerminals());
      case ExplorerTab.sessions:
        break;
    }
  }

  void showInspector(InspectorTab tab) {
    inspectorTab = tab;
    _notify();
  }

  void toggleTerminal() {
    terminalVisible = !terminalVisible;
    _notify();
    if (terminalVisible) unawaited(ensureTerminal());
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _notify();
  }

  void selectProject(Project project) {
    if (activeProject?.id == project.id) return;
    activeProject = project;
    activeSession = null;
    messages = const [];
    sessionChanges = const [];
    rootSessions = const [];
    fileEntries = const [];
    fileRoot = '';
    selectedFilePath = null;
    _notify();
    unawaited(loadSessions());
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  List<SessionNode> rootSessions = const [];
  bool loadingSessions = false;
  String sessionFilter = '';

  List<SessionNode> get visibleRoots {
    final filter = sessionFilter.trim().toLowerCase();
    if (filter.isEmpty) return rootSessions;
    bool matches(SessionNode node) =>
        (node.info.title ?? '').toLowerCase().contains(filter) ||
        node.id.toLowerCase().contains(filter);
    bool anyInTree(SessionNode node) =>
        matches(node) || node.children.any(anyInTree);
    return [
      for (final node in rootSessions)
        if (anyInTree(node)) node,
    ];
  }

  Future<void> loadSessions() async {
    final client = _client;
    if (client == null || !isConnected || _disposed) return;
    loadingSessions = true;
    _notify();
    try {
      final directory = activeProject?.canonical;
      final response = await client.session.list(
        limit: '80',
        order: SessionListOrder.desc,
        parentID: 'null',
        directory: directory == null ? null : AbsolutePath(directory),
      );
      rootSessions = [for (final info in response.data) SessionNode(info)];
      if (activeSession != null) {
        final refreshed = findNode(activeSession!.id);
        if (refreshed != null) activeSession = refreshed.info;
      }
    } on Object catch (error) {
      connectionError = describe(error);
    } finally {
      loadingSessions = false;
      _notify();
    }
  }

  SessionNode? findNode(String id, [List<SessionNode>? nodes]) {
    for (final node in nodes ?? rootSessions) {
      if (node.id == id) return node;
      final found = findNode(id, node.children);
      if (found != null) return found;
    }
    return null;
  }

  Future<void> toggleNode(SessionNode node) async {
    if (node.expanded) {
      node.expanded = false;
      _notify();
      return;
    }
    node.expanded = true;
    _notify();
    if (node.childrenLoaded) return;
    node.loadingChildren = true;
    _notify();
    try {
      final client = _client!;
      final response = await client.session.list(
        limit: '50',
        order: SessionListOrder.desc,
        parentID: SessionID(node.id),
      );
      node.children
        ..clear()
        ..addAll([
          for (final info in response.data)
            SessionNode(info, depth: node.depth + 1),
        ]);
      node.childrenLoaded = true;
    } on Object catch (error) {
      debugPrint('child sessions failed: ${describe(error)}');
    } finally {
      node.loadingChildren = false;
      _notify();
    }
  }

  SessionInfo? activeSession;
  List<ChatMessage> messages = const [];
  bool loadingMessages = false;
  final Set<String> busySessionIDs = <String>{};
  final Map<String, ({MoneyUSD cost, TokenUsageInfo tokens})> usage = {};

  List<PermissionRequest> pendingPermissions = const [];

  bool get activeBusy =>
      activeSession != null && busySessionIDs.contains(activeSession!.id);

  Future<void> openSession(SessionInfo session) async {
    activeSession = session;
    messages = const [];
    sessionChanges = const [];
    inboxItems = const [];
    sessionForms = const [];
    activeForm = null;
    olderMessagesCursor = null;
    loadingMessages = true;
    _notify();
    await Future.wait<void>([
      loadMessages(),
      loadSessionChanges(),
      loadInbox(),
      loadForms(),
    ]);
    if (activeSession?.id == session.id) {
      unawaited(loadStats());
      if (explorerTab == ExplorerTab.terminals) {
        unawaited(loadPersistentTerminals());
      }
    }
  }

  Future<void> loadMessages() async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null || _disposed) return;
    loadingMessages = true;
    _notify();
    try {
      final response = await client.session.message.list(
        sessionID: session.id,
        limit: '200',
      );
      final loaded = <ChatMessage>[];
      for (final item in response.data) {
        final message = ChatMessage.fromApi(item);
        if (message != null && !message.isEmpty) loaded.add(message);
      }
      if (activeSession?.id == session.id) {
        messages = loaded;
        olderMessagesCursor = response.cursor.previous;
      }
    } on Object catch (error) {
      connectionError = describe(error);
    } finally {
      loadingMessages = false;
      _notify();
    }
  }

  Future<SessionInfo?> newSession({String? title}) async {
    final client = _client;
    if (client == null || !isConnected) return null;
    try {
      final location = activeLocation;
      final session = await client.session.create(
        title: title,
        location: location.directory == null ? null : location,
      );
      await loadSessions();
      await openSession(session);
      return session;
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
      return null;
    }
  }

  Future<void> renameSession(SessionInfo session, String title) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.session.update(sessionID: session.id, title: title);
      final node = findNode(session.id);
      if (node != null) node.info = _withTitle(node.info, title);
      if (activeSession?.id == session.id) {
        activeSession = _withTitle(activeSession!, title);
      }
      _notify();
      await loadSessions();
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  static SessionInfo _withTitle(SessionInfo session, String title) =>
      SessionInfo.fromJson(session.toJson()..['title'] = title);

  Future<void> deleteSession(SessionInfo session) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.session.remove(sessionID: session.id);
    } on Object catch (error) {
      connectionError = describe(error);
    }
    if (activeSession?.id == session.id) {
      activeSession = null;
      messages = const [];
      sessionChanges = const [];
      inspectorTab = InspectorTab.none;
    }
    _notify();
    await loadSessions();
  }

  Future<void> forkSession(SessionInfo session) async {
    final client = _client;
    if (client == null) return;
    try {
      final forked = await client.session.fork(sessionID: session.id);
      await loadSessions();
      await openSession(forked);
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  Future<void> switchAgent(String agentID) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      await client.session.switchAgent(
        sessionID: session.id,
        agent: AgentID(agentID),
      );
      await loadSessions();
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  Future<void> switchModel(ModelRef model) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      await client.session.switchModel(sessionID: session.id, model: model);
      await loadSessions();
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  // ---------------------------------------------------------------------------
  // Prompting
  // ---------------------------------------------------------------------------

  final TextEditingController composer = TextEditingController();
  bool sending = false;

  Future<void> send(String text) async {
    var session = activeSession;
    session ??= await newSession();
    final target = session;
    if (target == null) return;
    final client = _client;
    if (client == null) return;
    sending = true;
    final optimistic = ChatMessage(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      time: DateTime.now(),
      text: text,
    );
    if (activeSession?.id == target.id) {
      messages = [...messages, optimistic];
      _notify();
    }
    try {
      await client.session.prompt(sessionID: target.id, text: text);
      final sentSessionID = target.id;
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (activeSession?.id == sentSessionID) return loadMessages();
          return Future<void>.value();
        }),
      );
    } on Object catch (error) {
      connectionError = describe(error);
    } finally {
      sending = false;
      _notify();
    }
  }

  /// Inserts an `@path` reference into the composer.
  void insertReference(String relativePath) {
    final text = composer.text;
    final selection = composer.selection;
    final mention = '@$relativePath ';
    if (selection.isValid && selection.start >= 0) {
      final updated = text.replaceRange(
        selection.start,
        selection.end,
        mention,
      );
      composer.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(
          offset: selection.start + mention.length,
        ),
      );
    } else {
      composer.text = '$text$mention';
    }
    referenceCandidates = const [];
    referenceQuery = null;
    _notify();
  }

  Future<void> interrupt() async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      await client.session.interrupt(sessionID: session.id);
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  Future<void> replyPermission(
    PermissionRequest request,
    PermissionReply decision,
  ) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.permission.reply(
        sessionID: request.sessionID,
        requestID: request.id,
        decision: decision,
      );
      pendingPermissions = [
        for (final candidate in pendingPermissions)
          if (candidate.id != request.id) candidate,
      ];
    } on Object catch (error) {
      connectionError = describe(error);
    }
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Files panel
  // ---------------------------------------------------------------------------

  String fileRoot = '';
  List<FileSystemEntry> fileEntries = const [];
  bool loadingFiles = false;
  String? selectedFilePath;
  Uint8List? selectedFileBytes;
  String? selectedFileText;
  bool selectedFileIsImage = false;
  bool selectedFileIsBinary = false;

  List<FileSystemEntry> referenceCandidates = const [];
  String? referenceQuery;

  Future<void> loadDirectory(String path) async {
    final client = _client;
    if (client == null || !isConnected || _disposed) return;
    loadingFiles = true;
    fileRoot = path;
    _notify();
    try {
      final response = await client.filesystem.list(
        location: activeLocation,
        path: path.isEmpty ? null : path,
      );
      final entries = response.data.toList()
        ..sort((a, b) {
          final aDir = a.type == FileSystemEntryType.directory;
          final bDir = b.type == FileSystemEntryType.directory;
          if (aDir != bDir) return aDir ? -1 : 1;
          return a.path.compareTo(b.path);
        });
      fileEntries = entries;
    } on Object catch (error) {
      connectionError = describe(error);
    } finally {
      loadingFiles = false;
      _notify();
    }
  }

  Future<void> openFile(String relativePath) async {
    final client = _client;
    if (client == null) return;
    selectedFilePath = relativePath;
    selectedFileBytes = null;
    selectedFileText = null;
    selectedFileIsBinary = false;
    selectedFileIsImage = false;
    inspectorTab = InspectorTab.file;
    _notify();
    try {
      final bytes = await client.filesystem.read(path: relativePath);
      selectedFileBytes = bytes;
      final text = _decodeText(bytes);
      if (text != null) {
        selectedFileText = text;
      } else {
        selectedFileIsBinary = true;
        selectedFileIsImage = _looksLikeImage(relativePath, bytes);
      }
    } on Object catch (error) {
      connectionError = describe(error);
    }
    _notify();
  }

  static String? _decodeText(Uint8List bytes) {
    if (bytes.contains(0)) return null;
    try {
      final text = utf8.decode(bytes);
      final control = text.runes.where(
        (rune) => rune < 32 && rune != 9 && rune != 10 && rune != 13,
      );
      if (control.length > text.length ~/ 50) return null;
      return text;
    } on FormatException {
      return utf8.decode(bytes, allowMalformed: true).contains('\uFFFD')
          ? null
          : utf8.decode(bytes, allowMalformed: true);
    }
  }

  static bool _looksLikeImage(String path, Uint8List bytes) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp')) {
      return true;
    }
    return bytes.length > 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
  }

  /// Called by the composer when the text after an `@` changes.
  void updateReferenceQuery(String? query) {
    referenceQuery = query;
    _fileSearchDebounce?.cancel();
    if (query == null || query.isEmpty) {
      referenceCandidates = const [];
      _notify();
      return;
    }
    _fileSearchDebounce = Timer(const Duration(milliseconds: 150), () {
      unawaited(_searchFiles(query));
    });
  }

  Future<void> _searchFiles(String query) async {
    final client = _client;
    if (client == null || _disposed) return;
    try {
      final response = await client.filesystem.find(
        location: activeLocation,
        query: query,
        limit: '12',
      );
      if (referenceQuery != query) return;
      referenceCandidates = response.data;
    } on Object {
      referenceCandidates = const [];
    }
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Git panel and diffs
  // ---------------------------------------------------------------------------

  VcsInfo? vcsInfo;
  List<VcsFileStatus> gitChanges = const [];
  List<FileDiffInfo> gitDiffFiles = const [];
  List<String> branches = const [];
  List<WorktreeDirectory> worktrees = const [];
  bool loadingGit = false;
  FileDiffInfo? inspectDiff;

  Future<void> loadGit() async {
    final client = _client;
    if (client == null || !isConnected || _disposed) return;
    loadingGit = true;
    _notify();
    final location = activeLocation;
    try {
      vcsInfo = (await client.vcs.get(location: location)).data;
      gitChanges = (await client.vcs.status(location: location)).data;
      gitDiffFiles = (await client.vcs.diff(
        location: location,
        mode: VcsMode.working,
      )).data;
      branches = (await client.vcs.branchList(location: location)).data;
      final projectID = activeProject?.id;
      if (projectID != null) {
        worktrees = await client.worktree.list(projectID: ProjectID(projectID));
      }
    } on Object catch (error) {
      connectionError = describe(error);
    } finally {
      loadingGit = false;
      _notify();
    }
  }

  void inspectFileDiff(String file) {
    for (final diff in gitDiffFiles) {
      if (diff.file == file) {
        inspectDiff = diff;
        inspectorTab = InspectorTab.diff;
        _notify();
        return;
      }
    }
    inspectDiff = null;
    _notify();
  }

  List<FileDiffInfo> sessionChanges = const [];

  Future<void> loadSessionChanges() async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null || _disposed) return;
    try {
      final response = await client.session.diff(sessionID: session.id);
      if (activeSession?.id == session.id) sessionChanges = response;
    } on Object {
      sessionChanges = const [];
    }
    _notify();
  }

  void inspectSessionDiff(FileDiffInfo diff) {
    inspectDiff = diff;
    inspectorTab = InspectorTab.diff;
    _notify();
  }

  Future<void> createWorktree(String name) async {
    final client = _client;
    final project = activeProject;
    if (client == null || project == null) return;
    try {
      await client.worktree.create(
        projectID: ProjectID(project.id),
        name: name,
      );
      await loadGit();
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  Future<void> removeWorktree(String directory) async {
    final client = _client;
    final project = activeProject;
    if (client == null || project == null) return;
    try {
      await client.worktree.remove(
        projectID: ProjectID(project.id),
        directory: AbsolutePath(directory),
        force: false,
      );
      await loadGit();
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  // ---------------------------------------------------------------------------
  // Stats panel
  // ---------------------------------------------------------------------------

  SessionStatsInfo? stats;
  bool loadingStats = false;

  Future<void> loadStats() async {
    final client = _client;
    if (client == null || !isConnected || _disposed) return;
    loadingStats = true;
    _notify();
    try {
      stats = await client.session.stats(
        tools: ExperimentalSessionStatsTools.detail,
      );
    } on Object catch (error) {
      debugPrint('stats failed: ${describe(error)}');
    } finally {
      loadingStats = false;
      _notify();
    }
  }

  // ---------------------------------------------------------------------------
  // Forms (agent-authored questions)
  // ---------------------------------------------------------------------------

  List<FormInfo> sessionForms = const [];
  FormDetail? activeForm;
  bool loadingForms = false;

  Future<void> loadForms() async {
    if (_disposed) return;
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    loadingForms = true;
    _notify();
    try {
      sessionForms = await client.session.form.list(sessionID: session.id);
    } on Object {
      sessionForms = const [];
    } finally {
      loadingForms = false;
      _notify();
    }
  }

  Future<void> openForm(FormInfo info) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      activeForm = await client.session.form.get(
        sessionID: session.id,
        formID: info.id,
      );
    } on Object catch (error) {
      connectionError = describe(error);
    }
    _notify();
  }

  void closeForm() {
    activeForm = null;
    _notify();
  }

  Future<void> replyForm(Map<String, Object?> answer) async {
    final client = _client;
    final session = activeSession;
    final form = activeForm;
    if (client == null || session == null || form == null) return;
    try {
      await client.session.form.reply(
        sessionID: session.id,
        formID: form.id,
        answer: answer,
      );
      activeForm = null;
    } on Object catch (error) {
      connectionError = describe(error);
    }
    _notify();
    await loadForms();
  }

  Future<void> cancelActiveForm() async {
    final client = _client;
    final session = activeSession;
    final form = activeForm;
    if (client == null || session == null || form == null) return;
    try {
      await client.session.form.cancel(sessionID: session.id, formID: form.id);
      activeForm = null;
    } on Object catch (error) {
      connectionError = describe(error);
    }
    _notify();
    await loadForms();
  }

  // ---------------------------------------------------------------------------
  // Inbox (queued and steering inputs)
  // ---------------------------------------------------------------------------

  List<SessionInboxInfo> inboxItems = const [];
  Timer? _inboxDebounce;

  Future<void> loadInbox() async {
    if (_disposed) return;
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      inboxItems = await client.session.inbox.list(sessionID: session.id);
    } on Object {
      inboxItems = const [];
    }
    _notify();
  }

  Future<void> cancelInboxItem(SessionInboxInfo item) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      await client.session.inbox.cancel(
        sessionID: session.id,
        inboxID: item.id,
      );
    } on Object catch (error) {
      connectionError = describe(error);
    }
    await loadInbox();
  }

  Future<void> setInboxDelivery(
    SessionInboxInfo item,
    SessionInboxDelivery delivery,
  ) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      await client.session.inbox.update(
        sessionID: session.id,
        inboxID: item.id,
        delivery: delivery,
      );
    } on Object catch (error) {
      connectionError = describe(error);
    }
    await loadInbox();
  }

  void _debounceInbox() {
    _inboxDebounce?.cancel();
    _inboxDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!_disposed) unawaited(loadInbox());
    });
  }

  Timer? _formsDebounce;

  void _debounceForms() {
    _formsDebounce?.cancel();
    _formsDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!_disposed) unawaited(loadForms());
    });
  }

  // ---------------------------------------------------------------------------
  // Message pagination (large transcripts)
  // ---------------------------------------------------------------------------

  String? olderMessagesCursor;
  bool loadingOlderMessages = false;

  /// Prepends the previous page of messages, keeping scroll data intact.
  Future<void> loadOlderMessages() async {
    final client = _client;
    final session = activeSession;
    final cursor = olderMessagesCursor;
    if (client == null ||
        session == null ||
        cursor == null ||
        loadingOlderMessages ||
        _disposed) {
      return;
    }
    loadingOlderMessages = true;
    _notify();
    try {
      final response = await client.session.message.list(
        sessionID: session.id,
        limit: '80',
        cursor: cursor,
      );
      if (activeSession?.id == session.id) {
        final known = {for (final message in messages) message.id};
        final older = <ChatMessage>[];
        for (final item in response.data) {
          final message = ChatMessage.fromApi(item);
          if (message == null || message.isEmpty) continue;
          if (known.add(message.id)) older.add(message);
        }
        if (older.isNotEmpty) messages = [...older, ...messages];
        olderMessagesCursor = response.cursor.previous;
      }
    } on Object catch (error) {
      connectionError = describe(error);
    } finally {
      loadingOlderMessages = false;
      _notify();
    }
  }

  // ---------------------------------------------------------------------------
  // Session transfer (export / import)
  // ---------------------------------------------------------------------------

  /// Writes the active session transcript as pretty JSON to [path].
  Future<String> exportActiveSessionTo(String path) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) {
      throw StateError('No active session to export');
    }
    final data = await client.session.exportSession(sessionID: session.id);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data.toJson()),
    );
    return file.path;
  }

  /// Reads an exported transcript from [path] and imports it as a new session.
  Future<SessionInfo?> importSessionFrom(String path) async {
    final client = _client;
    if (client == null) return null;
    try {
      final decoded = jsonDecode(await File(path).readAsString());
      final data = SessionTransferData.fromJson(asJsonMap(decoded));
      final imported = await client.session.importSession(
        info: data.info,
        messages: data.messages,
      );
      await loadSessions();
      await openSession(imported);
      return imported;
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Persistent terminals
  // ---------------------------------------------------------------------------

  List<PersistentPtyInfo> persistentTerminals = const [];
  PersistentTerminalSession? persistentTerminalSession;
  PtyID? selectedPersistentID;
  bool loadingPersistentTerminals = false;

  Future<void> loadPersistentTerminals() async {
    if (_disposed) return;
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    loadingPersistentTerminals = true;
    _notify();
    try {
      persistentTerminals = await client.persistentPty.list(
        sessionID: session.id,
      );
      final selected = selectedPersistentID;
      if (selected != null &&
          !persistentTerminals.any((terminal) => terminal.id == selected)) {
        selectedPersistentID = null;
        final attached = persistentTerminalSession;
        persistentTerminalSession = null;
        await attached?.detach();
      }
    } on Object catch (error) {
      connectionError = describe(error);
    } finally {
      loadingPersistentTerminals = false;
      _notify();
    }
  }

  Future<void> createPersistentTerminal() async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      final now = DateTime.now();
      final info = await client.persistentPty.create(
        sessionID: session.id,
        title:
            'shell ${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}',
        args: const [],
        env: const {},
      );
      persistentTerminals = [...persistentTerminals, info];
      _notify();
      await attachPersistentTerminal(info);
    } on Object catch (error) {
      connectionError = describe(error);
      _notify();
    }
  }

  Future<void> attachPersistentTerminal(PersistentPtyInfo info) async {
    final client = _client;
    if (client == null) return;
    var session = persistentTerminalSession;
    if (session == null) {
      session = PersistentTerminalSession()..onChanged = _notify;
      persistentTerminalSession = session;
    } else if (session.info?.id != info.id) {
      await session.detach();
    }
    selectedPersistentID = info.id;
    terminalVisible = true;
    _notify();
    await session.attach(client, info);
    _notify();
  }

  Future<void> killPersistentTerminal(PersistentPtyInfo info) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.persistentPty.remove(ptyID: info.id);
    } on Object catch (error) {
      connectionError = describe(error);
    }
    if (selectedPersistentID == info.id) {
      final attached = persistentTerminalSession;
      persistentTerminalSession = null;
      selectedPersistentID = null;
      await attached?.detach();
    }
    await loadPersistentTerminals();
  }

  /// Pulls the server-side screen snapshot into the attached terminal.
  Future<void> snapshotPersistentTerminal() async {
    final client = _client;
    final id = selectedPersistentID;
    final session = persistentTerminalSession;
    if (client == null || id == null || session == null) return;
    try {
      final snapshot = await client.persistentPty.snapshot(ptyID: id);
      session.applySnapshotText(
        '\r\n\x1b[2m[snapshot]\x1b[0m\r\n${snapshot.text}\r\n',
      );
    } on Object catch (error) {
      connectionError = describe(error);
    }
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Terminal
  // ---------------------------------------------------------------------------

  TerminalSession? terminal;

  Future<void> ensureTerminal() async {
    final client = _client;
    if (client == null) return;
    var session = terminal;
    if (session == null) {
      session = TerminalSession()..onStatusChanged = () async => _notify();
      terminal = session;
      _notify();
    }
    if (session.status == TerminalStatus.idle ||
        session.status == TerminalStatus.failed) {
      await session.start(client, location: activeLocation, title: 'cockpit');
      _notify();
    }
  }

  Future<void> restartTerminal() async {
    final session = terminal;
    if (session == null) return;
    if (session.status == TerminalStatus.exited) {
      await session.recreate();
    } else {
      await session.restart();
    }
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Live events
  // ---------------------------------------------------------------------------

  @visibleForTesting
  void handleEvent(OpenCodeEvent event) {
    if (_disposed) return;
    final sessionID = event.data['sessionID'];
    final session = sessionID is String ? sessionID : null;
    final isActive = session != null && session == activeSession?.id;

    switch (event.type) {
      case 'server.connected':
        connectionError = null;
        _debounceSessions();
      case 'session.created':
      case 'session.deleted':
      case 'session.renamed':
      case 'session.moved':
      case 'session.agent.selected':
      case 'session.model.selected':
        _debounceSessions();
      case 'session.usage.updated':
        if (session != null &&
            event.data['cost'] is num &&
            event.data['tokens'] is Map) {
          usage[session] = (
            cost: MoneyUSD.fromJson(event.data['cost']),
            tokens: TokenUsageInfo.fromJson(asJsonMap(event.data['tokens'])),
          );
        }
        _debounceSessions();
      case 'session.execution.started':
        if (session != null) busySessionIDs.add(session);
      case 'session.execution.succeeded':
      case 'session.execution.failed':
      case 'session.execution.interrupted':
        if (session != null) busySessionIDs.remove(session);
        if (isActive) {
          unawaited(loadMessages());
          unawaited(loadSessionChanges());
        }
        _debounceSessions();
      case 'session.inbox.delivered':
        if (isActive) _debounceMessages();
        _debounceInbox();
      case 'session.inbox.enqueued':
      case 'session.inbox.cancelled':
      case 'session.inbox.delivery.changed':
        _debounceInbox();
      case 'form.created':
        _debounceForms();
      case 'form.replied':
      case 'form.cancelled':
        final formID = event.data['id'];
        if (activeForm != null && '$formID' == '${activeForm!.id}') {
          activeForm = null;
        }
        _debounceForms();
      case 'session.step.started':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          message
            ..streaming = true
            ..agent = event.data['agent'] as String?
            ..model = switch (event.data['model']) {
              final Map map => ModelRef.fromJson(asJsonMap(map)),
              _ => message.model,
            };
          return message;
        });
      case 'session.step.streamed':
        break;
      case 'session.step.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          message.streaming = false;
          final finish = event.data['finish'];
          if (finish is String) message.finish = finish;
          final cost = event.data['cost'];
          if (cost is num) message.cost = MoneyUSD.fromJson(cost);
          final tokens = event.data['tokens'];
          if (tokens is Map) {
            message.tokens = TokenUsageInfo.fromJson(asJsonMap(tokens));
          }
          for (final part in message.parts) {
            if (part is ChatTextPart) part.done = true;
            if (part is ChatReasoningPart) part.done = true;
          }
          return message;
        });
      case 'session.step.failed':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          message.streaming = false;
          final error = event.data['error'];
          if (error is Map) {
            message.errorMessage = '${error['message'] ?? error}';
          }
          return message;
        });
      case 'session.text.started':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          if (!message.parts.any(
            (part) => part is ChatTextPart && part.ordinal == ordinal,
          )) {
            message.parts.add(ChatTextPart(ordinal: ordinal));
          }
          return message;
        });
      case 'session.text.delta':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final part = _textPart(message, _ordinalOf(event));
          part.text += '${event.data['delta'] ?? ''}';
          return message;
        });
      case 'session.text.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final part = _textPart(message, _ordinalOf(event));
          final text = event.data['text'];
          if (text is String) part.text = text;
          part.done = true;
          return message;
        });
      case 'session.reasoning.started':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          if (!message.parts.any(
            (part) => part is ChatReasoningPart && part.ordinal == ordinal,
          )) {
            message.parts.add(ChatReasoningPart(ordinal: ordinal));
          }
          return message;
        });
      case 'session.reasoning.delta':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final part = _reasoningPart(message, _ordinalOf(event));
          part.text += '${event.data['delta'] ?? ''}';
          return message;
        });
      case 'session.reasoning.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final part = _reasoningPart(message, _ordinalOf(event));
          final text = event.data['text'];
          if (text is String) part.text = text;
          part.done = true;
          return message;
        });
      case 'session.tool.input.started':
        if (!isActive) return;
        _upsertTool(event, (tool) => tool);
      case 'session.tool.input.delta':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          if (tool.status == ChatToolStatus.streaming) {
            tool.input += '${event.data['delta'] ?? ''}';
          }
          return tool;
        });
      case 'session.tool.input.ended':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          if (tool.status == ChatToolStatus.streaming) {
            final text = event.data['text'];
            if (text is String) tool.input = text;
          }
          return tool;
        });
      case 'session.tool.called':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          tool.status = ChatToolStatus.running;
          final input = event.data['input'];
          if (input is Map) tool.inputJson = asJsonMap(input);
          return tool;
        });
      case 'session.tool.progress':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          final metadata = event.data['metadata'];
          if (metadata is Map) tool.metadata = asJsonMap(metadata);
          return tool;
        });
      case 'session.tool.success':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          tool.status = ChatToolStatus.completed;
          final metadata = event.data['metadata'];
          if (metadata is Map) tool.metadata = asJsonMap(metadata);
          tool.output = toolOutputPreview(event.data['content']);
          return tool;
        });
      case 'session.tool.failed':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          tool.status = ChatToolStatus.failed;
          final error = event.data['error'];
          tool.error = error is Map ? '${error['message'] ?? error}' : '$error';
          final metadata = event.data['metadata'];
          if (metadata is Map) tool.metadata = asJsonMap(metadata);
          tool.output = toolOutputPreview(event.data['content']);
          return tool;
        });
      case 'permission.asked':
        if (event.data['id'] is String &&
            !pendingPermissions.any((item) => item.id == event.data['id'])) {
          final request = PermissionRequest.fromJson(event.data);
          if (request.sessionID == activeSession?.id) {
            pendingPermissions = [...pendingPermissions, request];
          }
        }
      case 'permission.replied':
        pendingPermissions = [
          for (final request in pendingPermissions)
            if (request.id != event.data['requestID']) request,
        ];
    }
    _notify();
  }

  static String? toolOutputPreview(Object? content) {
    if (content is! List) return null;
    final decoded = <ToolContent>[];
    for (final item in content) {
      if (item is! Map) continue;
      try {
        decoded.add(ToolContent.fromJson(asJsonMap(item)));
      } on Object {
        // Ignore malformed tool content during streaming.
      }
    }
    if (decoded.isEmpty) return null;
    final preview = toolContentPreview(decoded);
    return preview.isEmpty ? null : preview;
  }

  int _ordinalOf(OpenCodeEvent event) {
    final ordinal = event.data['ordinal'];
    if (ordinal is int) return ordinal;
    if (ordinal is num) return ordinal.toInt();
    return 0;
  }

  void _upsertAssistant(
    OpenCodeEvent event,
    ChatMessage Function(ChatMessage message) mutate,
  ) {
    final id = '${event.data['assistantMessageID']}';
    var index = messages.indexWhere((message) => message.id == id);
    if (index == -1) {
      final message = ChatMessage(
        id: id,
        role: ChatRole.assistant,
        time: _eventTime(event),
        streaming: true,
      );
      messages = [...messages, message];
      index = messages.length - 1;
    } else {
      messages = List<ChatMessage>.of(messages);
    }
    messages[index] = mutate(messages[index]);
  }

  void _upsertTool(
    OpenCodeEvent event,
    ChatPart Function(ChatToolPart tool) mutate,
  ) {
    final id = '${event.data['id']}';
    _upsertAssistant(event, (message) {
      for (final part in message.parts) {
        if (part is ChatToolPart && part.id == id) {
          mutate(part);
          return message;
        }
      }
      final name = event.data['name'];
      final tool = ChatToolPart(id: id, name: name is String ? name : 'tool');
      message.parts.add(mutate(tool));
      message.toolCount = message.parts.whereType<ChatToolPart>().length;
      return message;
    });
  }

  ChatTextPart _textPart(ChatMessage message, int ordinal) {
    for (final part in message.parts) {
      if (part is ChatTextPart && part.ordinal == ordinal) return part;
    }
    final part = ChatTextPart(ordinal: ordinal);
    message.parts.add(part);
    return part;
  }

  ChatReasoningPart _reasoningPart(ChatMessage message, int ordinal) {
    for (final part in message.parts) {
      if (part is ChatReasoningPart && part.ordinal == ordinal) return part;
    }
    final part = ChatReasoningPart(ordinal: ordinal);
    message.parts.add(part);
    return part;
  }

  static DateTime _eventTime(OpenCodeEvent event) {
    final created = event.raw['created'];
    if (created is num) {
      return DateTime.fromMillisecondsSinceEpoch(created.round());
    }
    return DateTime.now();
  }

  void _debounceSessions() {
    _sessionsDebounce?.cancel();
    _sessionsDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!_disposed) unawaited(loadSessions());
    });
  }

  void _debounceMessages() {
    _messagesDebounce?.cancel();
    _messagesDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!_disposed) unawaited(loadMessages());
    });
  }

  // ---------------------------------------------------------------------------
  // Command palette
  // ---------------------------------------------------------------------------

  bool paletteVisible = false;

  /// Context-owning actions installed by the shell (dialogs need a
  /// BuildContext, which the controller does not hold).
  void Function()? onShowConnections;
  void Function()? onShowExport;
  void Function()? onShowImport;
  void Function()? onShowForms;

  List<PaletteCommand> get commands => [
    PaletteCommand('New session', Icons.add_comment_outlined, () {
      unawaited(newSession());
    }),
    PaletteCommand('Refresh sessions', Icons.refresh_rounded, () {
      unawaited(loadSessions());
    }),
    PaletteCommand('Toggle terminal', Icons.terminal_rounded, toggleTerminal),
    PaletteCommand('Show session changes', Icons.difference_outlined, () {
      showInspector(InspectorTab.changes);
      unawaited(loadSessionChanges());
    }),
    PaletteCommand('Show git changes', Icons.account_tree_outlined, () {
      selectExplorerTab(ExplorerTab.git);
    }),
    PaletteCommand('Browse files', Icons.folder_open_outlined, () {
      selectExplorerTab(ExplorerTab.files);
    }),
    PaletteCommand('Session statistics', Icons.insights_outlined, () {
      selectExplorerTab(ExplorerTab.stats);
    }),
    PaletteCommand('Fork session', Icons.call_split_rounded, () {
      final session = activeSession;
      if (session != null) unawaited(forkSession(session));
    }),
    PaletteCommand('Persistent terminals', Icons.dns_outlined, () {
      selectExplorerTab(ExplorerTab.terminals);
    }),
    PaletteCommand('Connections and settings', Icons.tune_rounded, () {
      onShowConnections?.call();
    }),
    PaletteCommand('Load older messages', Icons.history_rounded, () {
      unawaited(loadOlderMessages());
    }),
    PaletteCommand('Export session\u2026', Icons.ios_share_rounded, () {
      onShowExport?.call();
    }),
    PaletteCommand('Import session\u2026', Icons.file_download_outlined, () {
      onShowImport?.call();
    }),
    PaletteCommand('Pending forms', Icons.assignment_outlined, () {
      onShowForms?.call();
    }),
    PaletteCommand('Toggle theme', Icons.contrast_rounded, toggleTheme),
    PaletteCommand('Reconnect', Icons.link_rounded, () {
      unawaited(connectLocal());
    }),
    PaletteCommand('Focus composer', Icons.keyboard_outlined, () {
      composerFocus.requestFocus();
    }),
  ];

  final FocusNode composerFocus = FocusNode(debugLabel: 'cockpit-composer');

  void showPalette() {
    paletteVisible = true;
    _notify();
  }

  void hidePalette() {
    paletteVisible = false;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final events = _events;
    _events = null;
    final client = _client;
    _client = null;
    _reconnectTimer?.cancel();
    _sessionsDebounce?.cancel();
    _messagesDebounce?.cancel();
    _inboxDebounce?.cancel();
    _formsDebounce?.cancel();
    _fileSearchDebounce?.cancel();
    unawaited(events?.cancel());
    unawaited(terminal?.dispose());
    unawaited(persistentTerminalSession?.detach());
    client?.close();
    composer.dispose();
    composerFocus.dispose();
    super.dispose();
  }
}

/// One command palette entry.
final class PaletteCommand {
  const PaletteCommand(this.label, this.icon, this.run);

  final String label;
  final IconData icon;
  final void Function() run;
}
