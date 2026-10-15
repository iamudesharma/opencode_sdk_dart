import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'chat_models.dart';

/// Connection lifecycle of the app.
enum ChatConnection { idle, connecting, connected, failed }

/// Coordinates the OpenCode SDK, session state, and the live event stream.
class ChatController extends ChangeNotifier {
  /// Creates an unconnected controller; call [connect] to start.
  ChatController();

  OpenCodeClient? _client;
  StreamSubscription<OpenCodeEvent>? _events;
  Timer? _reconnectTimer;
  Timer? _sessionRefreshDebounce;
  bool _disposed = false;

  ChatConnection connection = ChatConnection.idle;
  String? connectionError;
  String? serverVersion;
  Uri? baseUrl;

  /// Sessions ordered newest first.
  List<SessionInfo> sessions = const [];

  /// The session currently shown in the transcript.
  SessionInfo? activeSession;

  /// Transcript of [activeSession].
  List<ChatMessage> messages = const [];

  /// Session ids with a running execution.
  final Set<String> busySessionIDs = <String>{};

  /// Latest usage per session id.
  final Map<String, ({MoneyUSD cost, TokenUsageInfo tokens})> usage = {};

  /// Pending permission requests for the active session.
  List<PermissionRequest> pendingPermissions = const [];

  /// Selectable agents, loaded after connecting.
  List<AgentInfo> agents = const [];

  /// Selectable models, loaded after connecting.
  List<ModelInfo> models = const [];

  /// Whether the transcript for [activeSession] is loading.
  bool loadingMessages = false;

  /// Whether a send request is in flight.
  bool sending = false;

  /// The underlying client, when connected.
  /// Notifies listeners unless the controller was disposed.
  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  OpenCodeClient? get client => _client;

  bool get isConnected => connection == ChatConnection.connected;

  /// Whether the active session is currently executing.
  bool get activeBusy =>
      activeSession != null && busySessionIDs.contains(activeSession!.id);

  // ---------------------------------------------------------------------------
  // Connection
  // ---------------------------------------------------------------------------

  /// Discovers (or starts) the local service and connects.
  Future<void> connectLocal() async {
    await _connect(discover: true);
  }

  /// Connects to an explicit server [url].
  Future<void> connectTo(Uri url, {Map<String, String>? headers}) async {
    await _connect(url: url, headers: headers, discover: false);
  }

  Future<void> _connect({
    Uri? url,
    Map<String, String>? headers,
    required bool discover,
  }) async {
    await _teardown();
    connection = ChatConnection.connecting;
    connectionError = null;
    _notify();
    try {
      if (discover) {
        final endpoint = await OpenCodeService.discover() ??
            await OpenCodeService.ensure();
        url = endpoint.url;
        headers = OpenCodeService.headers(endpoint);
      }
      final client = OpenCodeClient(baseUrl: url!, headers: headers);
      _client = client;
      baseUrl = client.transport.baseUrl;
      final info = await client.server.info();
      serverVersion = info.version;
      connection = ChatConnection.connected;
      debugPrint('OpenCode Chat connected to ${client.transport.baseUrl} '
          '(v${info.version})');
      _notify();
      _listen();
      await Future.wait<void>([
        refreshSessions(),
        _loadAgentsAndModels(),
      ]);
    } on Object catch (error) {
      connection = ChatConnection.failed;
      connectionError = _describe(error);
      _notify();
    }
  }

  String _describe(Object error) {
    return switch (error) {
      OpenCodeStatusException(:final message) => message,
      OpenCodeTransportException(:final cause) =>
        'Cannot reach the server ($cause)',
      OpenCodeDecodeException(:final message) => 'Unexpected response: $message',
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
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 2), () {
          if (_disposed || !isConnected) return;
          connectionError = null;
          _notify();
          _listen();
        });
      },
      onDone: () {
        if (_disposed || !isConnected) return;
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 2), () {
          if (_disposed || !isConnected) return;
          _listen();
        });
      },
    );
  }

  Future<void> _teardown() async {
    _reconnectTimer?.cancel();
    _sessionRefreshDebounce?.cancel();
    await _events?.cancel();
    _events = null;
    _client?.close();
    _client = null;
    sessions = const [];
    activeSession = null;
    messages = const [];
    busySessionIDs.clear();
    usage.clear();
    pendingPermissions = const [];
    agents = const [];
    models = const [];
  }

  // ---------------------------------------------------------------------------
  // Sessions and messages
  // ---------------------------------------------------------------------------

  Future<void> refreshSessions() async {
    if (_disposed) return;
    final client = _client;
    if (client == null || !isConnected) return;
    try {
      final result = await client.session.list(
        limit: '60',
        order: SessionListOrder.desc,
      );
      sessions = result.data;
      if (activeSession != null) {
        final refreshed = _sessionById(activeSession!.id);
        if (refreshed != null) activeSession = refreshed;
      }
    } on Object {
      // Sidebar refresh failures are non-fatal.
    }
    _notify();
  }

  SessionInfo? _sessionById(String id) {
    for (final session in sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  Future<void> _loadAgentsAndModels() async {
    final client = _client;
    if (client == null) return;
    try {
      final agentResult = await client.agent.list();
      agents = agentResult.data;
    } on Object {
      // Agent list is optional.
    }
    try {
      final modelResult = await client.model.list();
      models = modelResult.data.where((model) => model.enabled).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } on Object {
      // Model list is optional.
    }
    _notify();
  }

  /// Opens [session] and loads its transcript.
  Future<void> openSession(SessionInfo session) async {
    activeSession = session;
    messages = const [];
    loadingMessages = true;
    _notify();
    await loadMessages();
  }

  /// Reloads the transcript of the active session.
  Future<void> loadMessages() async {
    if (_disposed) return;
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
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
      }
    } on Object catch (error) {
      connectionError = _describe(error);
    } finally {
      loadingMessages = false;
      _notify();
    }
  }

  /// Creates a new session and opens it.
  Future<SessionInfo?> newSession() async {
    final client = _client;
    if (client == null || !isConnected) return null;
    try {
      final session = await client.session.create();
      sessions = [session, ...sessions];
      _notify();
      await openSession(session);
      return session;
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
      return null;
    }
  }

  /// Deletes [sessionID] and clears it from the UI when active.
  Future<void> deleteSession(String sessionID) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.session.remove(sessionID: SessionID(sessionID));
    } on Object catch (error) {
      connectionError = _describe(error);
    }
    sessions = [
      for (final session in sessions)
        if (session.id != sessionID) session,
    ];
    if (activeSession?.id == sessionID) {
      activeSession = null;
      messages = const [];
    }
    _notify();
  }

  /// Renames the active session.
  Future<void> renameActiveSession(String title) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    await client.session.update(sessionID: session.id, title: title);
    activeSession = _copyWithTitle(session, title);
    sessions = [
      for (final candidate in sessions)
        if (candidate.id == session.id) _copyWithTitle(candidate, title) else candidate,
    ];
    _notify();
  }

  static SessionInfo _copyWithTitle(SessionInfo session, String title) {
    final json = session.toJson()..['title'] = title;
    return SessionInfo.fromJson(json);
  }

  /// Switches the agent of the active session.
  Future<void> switchAgent(String agent) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    await client.session.switchAgent(
      sessionID: session.id,
      agent: AgentID(agent),
    );
    await refreshSessions();
  }

  /// Switches the model of the active session.
  Future<void> switchModel(ModelRef model) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    await client.session.switchModel(sessionID: session.id, model: model);
    await refreshSessions();
  }

  // ---------------------------------------------------------------------------
  // Prompting
  // ---------------------------------------------------------------------------

  /// Sends [text] to the active session, creating one when needed.
  Future<void> send(String text) async {
    var session = activeSession;
    if (session == null) {
      session = await newSession();
      if (session == null) return;
    }
    final client = _client;
    if (client == null) return;
    sending = true;
    try {
      // Optimistic echo so the prompt appears immediately.
      final optimistic = ChatMessage(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}',
        role: ChatRole.user,
        time: DateTime.now(),
        text: text,
      );
      if (activeSession?.id == session.id) {
        messages = [...messages, optimistic];
        _notify();
      }
      final sentSessionID = session.id;
      await client.session.prompt(sessionID: sentSessionID, text: text);
      // The server admits the message; refresh shortly to replace the echo
      // with the recorded user message.
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (activeSession?.id == sentSessionID) return loadMessages();
          return Future<void>.value();
        }),
      );
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
    } finally {
      sending = false;
      _notify();
    }
  }

  /// Interrupts the active session execution.
  Future<void> interrupt() async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      await client.session.interrupt(sessionID: session.id);
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
    }
  }

  /// Replies to a pending permission request.
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
      _notify();
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
    }
  }

  // ---------------------------------------------------------------------------
  // Live events
  // ---------------------------------------------------------------------------

  /// Applies one server event to the UI state.
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
      case 'session.usage.updated':
        if (event.type == 'session.usage.updated' &&
            session != null &&
            event.data['cost'] is num &&
            event.data['tokens'] is Map) {
          usage[session] = (
            cost: MoneyUSD.fromJson(event.data['cost']),
            tokens: TokenUsageInfo.fromJson(
              asJsonMap(event.data['tokens']),
            ),
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
        }
        _debounceSessions();
      case 'session.inbox.delivered':
      case 'session.message.content.updated':
        if (isActive) _debounceMessages();
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
          final ordinal = _ordinalOf(event);
          final part = _textPart(message, ordinal);
          part.text += '${event.data['delta'] ?? ''}';
          return message;
        });
      case 'session.text.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          final part = _textPart(message, ordinal);
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
          final ordinal = _ordinalOf(event);
          final part = _reasoningPart(message, ordinal);
          part.text += '${event.data['delta'] ?? ''}';
          return message;
        });
      case 'session.reasoning.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          final part = _reasoningPart(message, ordinal);
          final text = event.data['text'];
          if (text is String) part.text = text;
          part.done = true;
          return message;
        });
      case 'session.tool.input.started':
        if (!isActive) return;
        _upsertTool(event, create: true, (tool) => tool);
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
          tool.output = _toolOutputPreview(event.data['content']);
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
          tool.output = _toolOutputPreview(event.data['content']);
          return tool;
        });
      case 'permission.asked':
        if (event.data['id'] is String &&
            !pendingPermissions.any((item) => item.id == event.data['id'])) {
          pendingPermissions = [
            ...pendingPermissions,
            PermissionRequest.fromJson(event.data),
          ];
        }
      case 'permission.replied':
        pendingPermissions = [
          for (final request in pendingPermissions)
            if (request.id != event.data['requestID']) request,
        ];
    }
    // Drop stale permissions from other sessions when switching.
    if (activeSession != null) {
      pendingPermissions = [
        for (final request in pendingPermissions)
          if (request.sessionID == activeSession!.id) request,
      ];
    }
    _notify();
  }

  int _ordinalOf(OpenCodeEvent event) {
    final ordinal = event.data['ordinal'];
    if (ordinal is int) return ordinal;
    if (ordinal is num) return ordinal.toInt();
    return 0;
  }

  ChatMessage _upsertAssistant(
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
    return messages[index];
  }

  ChatToolPart _upsertTool(
    OpenCodeEvent event,
    ChatPart Function(ChatToolPart tool) mutate, {
    bool create = false,
  }) {
    final id = '${event.data['id']}';
    _upsertAssistant(event, (message) {
      for (final part in message.parts) {
        if (part is ChatToolPart && part.id == id) {
          mutate(part);
          return message;
        }
      }
      final name = event.data['name'];
      final tool = ChatToolPart(
        id: id,
        name: name is String ? name : 'tool',
      );
      message.parts.add(mutate(tool));
      message.toolCount = message.parts.whereType<ChatToolPart>().length;
      return message;
    });
    final message =
        messages.lastWhere((message) => message.parts.any((p) => p is ChatToolPart && p.id == id));
    return message.parts.firstWhere((p) => p is ChatToolPart && p.id == id)
        as ChatToolPart;
  }

  static String? _toolOutputPreview(Object? content) {
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
    _sessionRefreshDebounce?.cancel();
    _sessionRefreshDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!_disposed) refreshSessions();
    });
  }

  void _debounceMessages() {
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (!_disposed) return loadMessages();
        return Future<void>.value();
      }),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    final events = _events;
    _events = null;
    final client = _client;
    _client = null;
    _reconnectTimer?.cancel();
    _sessionRefreshDebounce?.cancel();
    unawaited(events?.cancel());
    client?.close();
    super.dispose();
  }
}
