import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genkit/genkit.dart' show GenerationUsage;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart'
    show PromptInputFileAttachment;

import 'attachments.dart';
import 'coach_chat.dart';
import 'coach_service.dart';
import 'history_view.dart';
import 'macros.dart';
import 'plan.dart';
import 'plan_body.dart';
import 'plan_export.dart';
import 'plan_request.dart';
import 'plan_store.dart';
import 'plan_view.dart';
import 'style.dart';

/// How the workspace renders the generation.
enum PlanMode {
  /// Structured output parsed into a typed plan.
  typed('Typed plan', Icons.view_week_outlined),

  /// Raw token stream rendered as it arrives.
  text('Live text', Icons.subject);

  const PlanMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Below this width the phone shell (AppBar + navigation bar) is used.
const double kOpenFitBreakpoint = 840;

/// One-tap starting points shown above the config cards.
final class _Preset {
  const _Preset({
    required this.title,
    required this.subtitle,
    required this.request,
  });

  final String title;
  final String subtitle;
  final PlanRequest request;
}

const _presets = <_Preset>[
  _Preset(
    title: 'First workout',
    subtitle: 'Beginner · 3-day full-body week',
    request: PlanRequest(
      goal: FitnessGoal.buildMuscle,
      level: ExperienceLevel.beginner,
      daysPerWeek: 3,
      sessionMinutes: 45,
      equipment: GymEquipment.fullGym,
      notes: 'Brand-new to lifting.',
    ),
  ),
  _Preset(
    title: 'Fat loss + food',
    subtitle: '4 days · sample food day',
    request: PlanRequest(
      goal: FitnessGoal.loseFat,
      level: ExperienceLevel.intermediate,
      daysPerWeek: 4,
      sessionMinutes: 45,
      equipment: GymEquipment.dumbbells,
      notes: 'Desk job, wants to keep muscle.',
    ),
  ),
  _Preset(
    title: 'Hotel room week',
    subtitle: 'No equipment · 30 min · 4 days',
    request: PlanRequest(
      goal: FitnessGoal.endurance,
      level: ExperienceLevel.beginner,
      daysPerWeek: 4,
      sessionMinutes: 30,
      equipment: GymEquipment.bodyweight,
      notes: 'Travel week, only a floor and a chair.',
    ),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.service, this.store});

  /// Overrides the live service (used by tests).
  final CoachService? service;

  /// Overrides the plan store (used by tests).
  final PlanStore? store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CoachService _service = widget.service ?? CoachService();
  late final PlanStore _store = widget.store ?? PlanStore();
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();
  final _weightController = TextEditingController(text: '80');
  final _heightController = TextEditingController(text: '178');
  final _ageController = TextEditingController(text: '30');

  // Streaming state lives in notifiers so token deltas and the elapsed ticker
  // never rebuild the config pane or the model dropdown.
  final _elapsed = ValueNotifier<Duration>(Duration.zero);
  final _streamText = ValueNotifier<String>('');
  final _receivedChars = ValueNotifier<int>(0);

  List<DropdownMenuEntry<CoachModel>> _modelEntries = const [];
  CoachModel? _model;
  String? _catalogError;
  bool _loadingModels = true;

  FitnessGoal _goal = FitnessGoal.buildMuscle;
  ExperienceLevel _level = ExperienceLevel.intermediate;
  int _days = 4;
  int _minutes = 45;
  GymEquipment _equipment = GymEquipment.fullGym;
  bool _nutrition = true;

  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  NutritionGoal _nutritionGoal = NutritionGoal.maintain;
  bool _targetsApplied = false;

  var _attachments = const <PickedAttachment>[];

  StreamSubscription<PlanEvent>? _subscription;
  Timer? _ticker;
  Stopwatch? _watch;
  bool _generating = false;
  String? _error;
  PlanCompleted? _completed;
  PlanMode _mode = PlanMode.typed;
  WorkoutPlan? _plan;
  GenerationUsage? _typedUsage;
  double? _typedLatencyMs;

  // Phone shell state.
  int _tab = 0;
  bool _isNarrow = false;

  // Ask Coach state.
  final _chatMessages = <CoachChatMessage>[];
  final _chatActivity = ValueNotifier<int>(0);
  StreamSubscription<CoachChatEvent>? _chatSubscription;
  bool _chatSending = false;
  bool _chatOpen = false;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _subscription?.cancel();
    _chatSubscription?.cancel();
    _notesController.dispose();
    _scrollController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _elapsed.dispose();
    _streamText.dispose();
    _receivedChars.dispose();
    _chatActivity.dispose();
    for (final message in _chatMessages) {
      message.dispose();
    }
    // Only the service this screen created is owned here; an injected service
    // belongs to whoever passed it in.
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  // Catalog ------------------------------------------------------------------

  Future<void> _loadModels() async {
    setState(() {
      _loadingModels = true;
      _catalogError = null;
    });
    try {
      final models = await _service.listModels();
      if (!mounted) return;
      setState(() {
        // Memoized once per catalog load; token deltas never rebuild it.
        _modelEntries = [
          for (final model in models)
            DropdownMenuEntry(
              value: model,
              label: model.id == model.label
                  ? model.id
                  : '${model.label} · ${model.id}',
            ),
        ];
        _loadingModels = false;
        _model = models.isEmpty
            ? null
            : models.firstWhere(
                (model) => model.id == kPreferredModelId,
                orElse: () => models.first,
              );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingModels = false;
        _catalogError = _cleanError(error);
      });
    }
  }

  // Request ------------------------------------------------------------------

  MacroTargets? get _targets {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    final age = int.tryParse(_ageController.text.trim());
    if (weight == null || height == null || age == null) return null;
    if (weight <= 0 || height <= 0 || age <= 0) return null;
    return computeMacros(
      weightKg: weight,
      heightCm: height,
      age: age,
      sex: _sex,
      activity: _activity,
      goal: _nutritionGoal,
    );
  }

  PlanRequest get _request => PlanRequest(
    goal: _goal,
    level: _level,
    daysPerWeek: _days,
    sessionMinutes: _minutes,
    equipment: _equipment,
    notes: _notesController.text,
    includeNutrition: _nutrition,
    nutritionTargets: _targetsApplied ? _targets?.promptLine : null,
  );

  List<PromptInputFileAttachment>? get _attachmentList => _attachments.isEmpty
      ? null
      : [for (final attachment in _attachments) attachment.attachment];

  // Generation ---------------------------------------------------------------

  void _generate({PlanRequest? request}) {
    final model = _model;
    if (model == null || _generating) return;
    final input = request ?? _request;
    if (request != null) {
      // A preset changed the form; reflect it in the UI.
      setState(() {
        _goal = input.goal;
        _level = input.level;
        _days = input.daysPerWeek;
        _minutes = input.sessionMinutes;
        _equipment = input.equipment;
        _nutrition = input.includeNutrition;
        _notesController.text = input.notes;
      });
    }
    setState(() {
      _generating = true;
      _error = null;
      _completed = null;
      _plan = null;
      _typedUsage = null;
      _typedLatencyMs = null;
      _streamText.value = '';
      _receivedChars.value = 0;
      _watch = Stopwatch()..start();
      _elapsed.value = Duration.zero;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _elapsed.value = _watch?.elapsed ?? Duration.zero;
    });

    _subscription?.cancel();
    if (_mode == PlanMode.typed) {
      unawaited(_generateTyped(model, input));
    } else {
      _subscription = _service
          .generatePlan(
            modelId: model.id,
            request: input,
            attachments: _attachmentList,
          )
          .listen(
            (event) {
              if (!mounted) return;
              switch (event) {
                case PlanText(:final text):
                  _streamText.value += text;
                  _scheduleAutoScroll();
                case PlanCompleted():
                  setState(() => _completed = event);
                  if (!event.cancelled && event.text.trim().isNotEmpty) {
                    unawaited(
                      _savePlan(
                        title: _planTitle(model, input),
                        markdown: event.text,
                        rawText: event.text,
                      ),
                    );
                  }
              }
            },
            onError: (Object error) {
              if (!mounted) return;
              setState(() => _error = _cleanError(error));
              _finishStream();
            },
            onDone: _finishStream,
          );
    }
  }

  /// Runs the typed (structured-output) generation.
  Future<void> _generateTyped(CoachModel model, PlanRequest input) async {
    try {
      final result = await _service.generateTypedPlan(
        modelId: model.id,
        request: input,
        attachments: _attachmentList,
        onProgress: (received) => _receivedChars.value = received,
      );
      if (!mounted) return;
      setState(() {
        _plan = result.plan;
        _typedUsage = result.usage;
        _typedLatencyMs = result.latencyMs;
      });
      // History is best-effort and must not delay the result on screen.
      unawaited(
        _savePlan(
          title: _planTitle(model, input),
          markdown: result.plan.toMarkdown(),
          structured: result.plan.toJson(),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _cleanError(error));
    } finally {
      _finishStream();
    }
  }

  Future<void> _savePlan({
    required String title,
    required String markdown,
    Map<String, dynamic>? structured,
    String? rawText,
  }) async {
    try {
      await _store.save(
        SavedPlan(
          id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
          createdAt: DateTime.now(),
          modelId: _model?.id ?? '',
          title: title,
          markdown: markdown,
          structured: structured,
          rawText: rawText,
        ),
      );
    } on Object {
      // History is best-effort.
    }
  }

  String _planTitle(CoachModel model, PlanRequest request) =>
      '${request.goal.label} · ${request.daysPerWeek} days · ${model.label}';

  String _cleanError(Object error) =>
      error.toString().replaceFirst(RegExp(r'^GenkitException: '), '');

  void _finishStream() {
    _watch?.stop();
    _ticker?.cancel();
    if (mounted) setState(() => _generating = false);
  }

  void _cancel() => _service.cancel();

  void _scheduleAutoScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels > 160) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // Ask Coach ----------------------------------------------------------------

  void _sendChat(String text, List<PickedAttachment> attachments) {
    setState(() {
      _chatOpen = true;
      _chatMessages.add(CoachChatMessage.user(text));
      _chatMessages.add(CoachChatMessage.coach()..streaming.value = true);
      _chatSending = true;
    });
    _chatActivity.value++;
    _chatSubscription?.cancel();
    _chatSubscription = _service
        .askCoach(
          text: text,
          attachments: attachments.isEmpty
              ? null
              : [for (final attachment in attachments) attachment.attachment],
        )
        .listen(
          (event) {
            if (!mounted || _chatMessages.isEmpty) return;
            final coach = _chatMessages.last;
            switch (event) {
              case CoachChatDelta(:final text):
                coach.streamed.value += text;
              case CoachChatReasoning(:final text):
                coach.reasoning.value += text;
              case CoachChatDone(:final text, :final cancelled):
                if (text.isNotEmpty) coach.text = text;
                coach.cancelled = cancelled;
                coach.streaming.value = false;
                setState(() => _chatSending = false);
            }
            _chatActivity.value++;
          },
          onError: (Object error) {
            if (!mounted || _chatMessages.isEmpty) return;
            final coach = _chatMessages.last;
            coach.text = 'Coach error: $error';
            coach.streaming.value = false;
            setState(() => _chatSending = false);
          },
          onDone: () {
            if (!mounted || !_chatSending || _chatMessages.isEmpty) return;
            _chatMessages.last.streaming.value = false;
            setState(() => _chatSending = false);
          },
        );
  }

  /// Appends the coach's note to the request notes and re-runs the typed plan.
  void _rebuildFromNote(String note) {
    final trimmed = note.trim();
    if (trimmed.isEmpty || _generating || _model == null) return;
    final existing = _notesController.text.trim();
    _notesController.text = existing.isEmpty ? trimmed : '$existing\n$trimmed';
    _mode = PlanMode.typed;
    setState(() => _tab = 1);
    _generate();
  }

  // History ------------------------------------------------------------------

  void _loadSavedPlan(SavedPlan saved) {
    setState(() {
      _error = null;
      _completed = null;
      _plan = null;
      _streamText.value = '';
      if (saved.structured case final structured?) {
        try {
          _plan = WorkoutPlan.fromJson(structured);
          _mode = PlanMode.typed;
        } on Object {
          _plan = null;
        }
      }
      final raw = saved.rawText;
      if (_plan == null && raw != null) {
        _streamText.value = raw;
        _mode = PlanMode.text;
      }
      _tab = 1;
    });
  }

  Future<void> _openHistory() async {
    if (_isNarrow) {
      setState(() => _tab = 3);
      return;
    }
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Insets.xl,
                  Insets.lg,
                  Insets.sm,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Plan history',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: PlanHistoryList(
                  store: _store,
                  onLoad: (plan) {
                    Navigator.of(dialogContext).pop();
                    _loadSavedPlan(plan);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Clipboard / export -------------------------------------------------------

  bool get _hasPlan => _plan != null || _streamText.value.isNotEmpty;

  String get _currentMarkdown {
    final plan = _plan;
    if (plan != null) return plan.toMarkdown();
    return _streamText.value;
  }

  Future<void> _copyPlan() async {
    await Clipboard.setData(ClipboardData(text: _currentMarkdown));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan copied to the clipboard')),
    );
  }

  Future<void> _exportPlan() async {
    final markdown = _currentMarkdown.trim();
    if (markdown.isEmpty) return;
    try {
      final message = await exportPlanMarkdown(markdown: markdown);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  // Attachments --------------------------------------------------------------

  Future<void> _pickAttachment() async {
    PickedAttachment? picked;
    try {
      picked = await pickAttachment();
    } on Object {
      picked = null;
    }
    if (!mounted) return;
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attachments need the LAN host (dart run tool/lan_host.dart).',
          ),
        ),
      );
      return;
    }
    setState(() => _attachments = [..._attachments, picked!]);
  }

  void _removeAttachment(PickedAttachment attachment) {
    setState(() {
      _attachments = [
        for (final kept in _attachments)
          if (kept != attachment) kept,
      ];
    });
  }

  // Shell --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= kOpenFitBreakpoint;
        _isNarrow = !wide;
        return wide ? _buildWide(context) : _buildNarrow(context);
      },
    );
  }

  Widget _buildWide(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.fit;
    return Scaffold(
      backgroundColor: tokens.bg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 396, child: _buildConfigPane(theme)),
          VerticalDivider(width: 1, color: tokens.line),
          Expanded(child: _buildWorkspace(theme)),
        ],
      ),
    );
  }

  Widget _buildNarrow(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.fit;
    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: Insets.lg,
        backgroundColor: tokens.bg,
        title: Row(
          children: [
            const FitLogo(size: 32),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'OpenFit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontSize: 24,
                      letterSpacing: -0.4,
                    ),
                  ),
                  _statusLine(theme),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _modeToggle(theme, compact: true),
          IconButton(
            tooltip: 'History',
            onPressed: _openHistory,
            icon: const Icon(Icons.history, size: 20),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_horiz_rounded, size: 20),
            onSelected: (value) {
              if (value == 'export') {
                _exportPlan();
              } else {
                _copyPlan();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                enabled: _hasPlan,
                child: Row(
                  children: [
                    const Icon(Icons.ios_share, size: 17),
                    const SizedBox(width: Insets.sm),
                    const Text('Export Markdown'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy',
                enabled: _hasPlan,
                child: Row(
                  children: [
                    const Icon(Icons.copy_all_outlined, size: 17),
                    const SizedBox(width: Insets.sm),
                    const Text('Copy plan'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: Insets.xs),
        ],
      ),
      body: IndexedStack(
        key: const ValueKey('tabs'),
        index: _tab,
        children: [
          _buildBuildTab(theme),
          _buildWorkoutTab(theme),
          CoachChatPanel(
            messages: _chatMessages,
            sending: _chatSending,
            activity: _chatActivity,
            onSend: _sendChat,
            onStop: _cancel,
            onRebuildPlan: _rebuildFromNote,
          ),
          _buildHistoryTab(theme),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Build',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Coach',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildBuildTab(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.xl,
              Insets.xl,
              Insets.xl,
              Insets.sm,
            ),
            children: [
              const SectionLabel('Quick start'),
              const SizedBox(height: Insets.md),
              _presetStrip(theme, horizontal: true),
              const SizedBox(height: Insets.xxl),
              ..._configCards(theme),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.xl,
              Insets.sm,
              Insets.xl,
              Insets.md,
            ),
            child: _generateButton(theme, expanded: true),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTab(ThemeData theme) =>
      _workspaceBody(theme, padded: true);

  Widget _buildHistoryTab(ThemeData theme) {
    final tokens = context.fit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            Insets.xl,
            Insets.xl,
            Insets.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Library'),
              const SizedBox(height: Insets.sm),
              Text(
                'Saved plans',
                style: theme.textTheme.headlineSmall!.copyWith(
                  color: tokens.text,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PlanHistoryList(store: _store, onLoad: _loadSavedPlan),
        ),
      ],
    );
  }

  // Config pane (wide) / Build tab (narrow) ----------------------------------

  Widget _buildConfigPane(ThemeData theme) {
    final tokens = context.fit;
    return Material(
      color: tokens.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.xxl,
              Insets.xxl,
              Insets.xl,
              Insets.lg,
            ),
            child: Row(
              children: [
                const FitLogo(size: 38),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OpenFit',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontSize: 27,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'AI STRENGTH & NUTRITION',
                        style: theme.textTheme.labelSmall!.copyWith(
                          fontSize: 8.5,
                          letterSpacing: 1.9,
                          color: tokens.dim,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
            child: Container(height: 1, color: tokens.line),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Insets.xxl,
                Insets.xl,
                Insets.xxl,
                Insets.lg,
              ),
              children: [
                _presetStrip(theme, horizontal: false),
                const SizedBox(height: Insets.xxl),
                ..._configCards(theme),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: tokens.surface,
              border: Border(top: BorderSide(color: tokens.line)),
            ),
            padding: const EdgeInsets.fromLTRB(
              Insets.xxl,
              Insets.lg,
              Insets.xxl,
              Insets.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _generateButton(theme, expanded: true),
                const SizedBox(height: Insets.sm),
                Text(
                  'Plans are saved on this device.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall!.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.6,
                    color: tokens.dim,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _configCards(ThemeData theme) => [
    _goalCard(theme),
    const SizedBox(height: Insets.lg),
    _scheduleCard(theme),
    const SizedBox(height: Insets.lg),
    _equipmentCard(theme),
    const SizedBox(height: Insets.lg),
    _notesCard(theme),
    const SizedBox(height: Insets.lg),
    _foodCard(theme),
    const SizedBox(height: Insets.lg),
    _macroCard(theme),
    const SizedBox(height: Insets.lg),
    _modelCard(theme),
  ];

  Widget _goalCard(ThemeData theme) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Goal & experience'),
        const SizedBox(height: Insets.md),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final goal in FitnessGoal.values)
              ChoiceChip(
                label: Text(goal.label),
                selected: _goal == goal,
                onSelected: _generating
                    ? null
                    : (_) => setState(() => _goal = goal),
              ),
          ],
        ),
        const SizedBox(height: Insets.md),
        SegmentedButton<ExperienceLevel>(
          segments: [
            for (final level in ExperienceLevel.values)
              ButtonSegment(value: level, label: Text(level.label)),
          ],
          selected: {_level},
          onSelectionChanged: _generating
              ? null
              : (selection) => setState(() => _level = selection.first),
          showSelectedIcon: false,
          style: _compactSegments(theme),
        ),
      ],
    ),
  );

  Widget _scheduleCard(ThemeData theme) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: SectionLabel('Schedule')),
            StatChip(label: '$_days days · $_minutes min'),
          ],
        ),
        Slider(
          value: _days.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          label: '$_days days',
          onChanged: _generating
              ? null
              : (value) => setState(() => _days = value.round()),
        ),
        const SizedBox(height: Insets.xs),
        Text(
          'Session length',
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Insets.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final minutes in const [30, 45, 60, 90])
              ChoiceChip(
                label: Text('$minutes min'),
                selected: _minutes == minutes,
                onSelected: _generating
                    ? null
                    : (_) => setState(() => _minutes = minutes),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _equipmentCard(ThemeData theme) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Equipment'),
        const SizedBox(height: Insets.md),
        DropdownButtonFormField<GymEquipment>(
          initialValue: _equipment,
          isDense: true,
          isExpanded: true,
          items: [
            for (final equipment in GymEquipment.values)
              DropdownMenuItem(value: equipment, child: Text(equipment.label)),
          ],
          onChanged: _generating
              ? null
              : (value) => setState(() => _equipment = value ?? _equipment),
        ),
      ],
    ),
  );

  Widget _notesCard(ThemeData theme) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Notes & attachments'),
        const SizedBox(height: Insets.md),
        TextField(
          controller: _notesController,
          enabled: !_generating,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'e.g. bad left knee, hates burpees',
            suffixIcon: IconButton(
              key: const ValueKey('notes_attach'),
              tooltip: 'Attach file',
              onPressed: _generating ? null : _pickAttachment,
              icon: const Icon(Icons.attach_file, size: 20),
            ),
          ),
        ),
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: Insets.sm),
          AttachmentChips(
            attachments: _attachments,
            onRemove: _removeAttachment,
          ),
        ],
      ],
    ),
  );

  Widget _foodCard(ThemeData theme) {
    final tokens = context.fit;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: SectionLabel('Food plan')),
              Switch(
                value: _nutrition,
                onChanged: _generating
                    ? null
                    : (value) => setState(() => _nutrition = value),
              ),
            ],
          ),
          const SizedBox(height: Insets.xs),
          Text(
            'Calories, protein target and a sample day',
            style: theme.textTheme.bodySmall!.copyWith(color: tokens.muted),
          ),
          if (_targetsApplied && _targets != null) ...[
            const SizedBox(height: Insets.md),
            Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                StatChip(
                  label: '${_targets!.calories} KCAL',
                  dot: tokens.ember,
                ),
                StatChip(
                  label: '${_targets!.proteinG} G PROTEIN',
                  dot: tokens.sage,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _macroCard(ThemeData theme) {
    final tokens = context.fit;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Macro calculator'),
          const SizedBox(height: Insets.md),
          SegmentedButton<Sex>(
            segments: [
              for (final sex in Sex.values)
                ButtonSegment(value: sex, label: Text(sex.label)),
            ],
            selected: {_sex},
            onSelectionChanged: _generating
                ? null
                : (selection) => setState(() => _sex = selection.first),
            showSelectedIcon: false,
            style: _compactSegments(theme),
          ),
          const SizedBox(height: Insets.md),
          Row(
            children: [
              Expanded(
                child: _macroField('Weight', _weightController, suffix: 'kg'),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: _macroField('Height', _heightController, suffix: 'cm'),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(child: _macroField('Age', _ageController)),
            ],
          ),
          const SizedBox(height: Insets.md),
          DropdownButtonFormField<ActivityLevel>(
            initialValue: _activity,
            isDense: true,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Activity'),
            style: theme.textTheme.bodySmall!.copyWith(color: tokens.text),
            items: [
              for (final activity in ActivityLevel.values)
                DropdownMenuItem(
                  value: activity,
                  child: Text('${activity.label} · ×${activity.factor}'),
                ),
            ],
            onChanged: _generating
                ? null
                : (value) => setState(() => _activity = value ?? _activity),
          ),
          const SizedBox(height: Insets.md),
          SegmentedButton<NutritionGoal>(
            segments: [
              for (final goal in NutritionGoal.values)
                ButtonSegment(value: goal, label: Text(goal.shortLabel)),
            ],
            selected: {_nutritionGoal},
            onSelectionChanged: _generating
                ? null
                : (selection) =>
                      setState(() => _nutritionGoal = selection.first),
            showSelectedIcon: false,
            style: _compactSegments(theme),
          ),
          const SizedBox(height: Insets.md),
          Container(
            padding: const EdgeInsets.all(Insets.md),
            decoration: BoxDecoration(
              color: tokens.bg,
              borderRadius: Radii.control,
              border: Border.all(color: tokens.line),
            ),
            child: Text(
              _targets?.summary ?? 'Enter weight, height and age.',
              style: kFitMonoStyle.copyWith(
                fontSize: 10.5,
                height: 1.45,
                letterSpacing: 0.1,
                color: _targets == null ? tokens.dim : tokens.accent,
              ),
            ),
          ),
          const SizedBox(height: Insets.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: _generating || _targets == null
                  ? null
                  : () => setState(() => _targetsApplied = !_targetsApplied),
              icon: Icon(
                _targetsApplied
                    ? Icons.check_rounded
                    : Icons.calculate_outlined,
                size: 15,
              ),
              label: Text(
                _targetsApplied ? 'Targets added to plan' : 'Use in plan',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 38),
                backgroundColor: tokens.accent.withValues(alpha: 0.12),
                foregroundColor: tokens.accent,
                disabledBackgroundColor: Colors.transparent,
                disabledForegroundColor: tokens.dim,
                textStyle: theme.textTheme.labelMedium,
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.md,
                  vertical: Insets.sm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modelCard(ThemeData theme) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Model'),
        const SizedBox(height: Insets.md),
        _buildModelPicker(theme),
      ],
    ),
  );

  Widget _macroField(
    String label,
    TextEditingController controller, {
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      enabled: !_generating,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  ButtonStyle _compactSegments(ThemeData theme) => ButtonStyle(
    visualDensity: VisualDensity.compact,
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
    textStyle: WidgetStatePropertyAll(
      theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
    ),
  );

  Widget _buildModelPicker(ThemeData theme) {
    if (_loadingModels) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Insets.sm),
          Text('Loading models…', style: theme.textTheme.bodySmall),
        ],
      );
    }
    if (_catalogError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OpenCode server unreachable',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: Insets.xs),
          Text(
            _catalogError!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Insets.sm),
          OutlinedButton.icon(
            onPressed: _loadModels,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      );
    }
    return DropdownMenu<CoachModel>(
      key: const ValueKey('model_picker'),
      initialSelection: _model,
      enableFilter: true,
      enableSearch: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 420,
      label: const Text('Search 130+ models'),
      dropdownMenuEntries: _modelEntries,
      onSelected: _generating
          ? null
          : (model) => setState(() => _model = model),
    );
  }

  Widget _presetStrip(ThemeData theme, {required bool horizontal}) {
    if (horizontal) {
      return SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _presets.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: Insets.sm),
          itemBuilder: (context, index) => SizedBox(
            width: 208,
            child: _presetCard(theme, _presets[index], index),
          ),
        ),
      );
    }
    final tokens = context.fit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Quick start'),
        const SizedBox(height: Insets.md),
        Material(
          color: tokens.raised,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: Radii.card,
            side: BorderSide(color: tokens.line),
          ),
          child: Column(
            children: [
              for (var index = 0; index < _presets.length; index++)
                _presetRow(theme, _presets[index], index),
            ],
          ),
        ),
      ],
    );
  }

  Widget _presetRow(ThemeData theme, _Preset preset, int index) {
    final tokens = context.fit;
    return InkWell(
      onTap: _generating || _model == null
          ? null
          : () => _generate(request: preset.request),
      hoverColor: tokens.accent.withValues(alpha: 0.045),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: index == 0 ? BorderSide.none : BorderSide(color: tokens.line),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.md,
        ),
        child: Row(
          children: [
            Text(
              '0${index + 1}',
              style: kFitMonoStyle.copyWith(
                fontSize: 10,
                letterSpacing: 0.6,
                color: tokens.dim,
              ),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tokens.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 11,
                      color: tokens.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Insets.sm),
            Icon(Icons.north_east_rounded, size: 15, color: tokens.dim),
          ],
        ),
      ),
    );
  }

  Widget _presetCard(ThemeData theme, _Preset preset, int index) {
    final tokens = context.fit;
    return AppCard(
      padding: const EdgeInsets.all(Insets.md),
      onTap: _generating || _model == null
          ? null
          : () => _generate(request: preset.request),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '0${index + 1}',
                style: kFitMonoStyle.copyWith(
                  fontSize: 9,
                  letterSpacing: 0.6,
                  color: tokens.dim,
                ),
              ),
              const Spacer(),
              Icon(Icons.north_east_rounded, color: tokens.accent, size: 15),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                preset.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall!.copyWith(
                  fontSize: 11,
                  color: tokens.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _generateButton(ThemeData theme, {required bool expanded}) {
    final tokens = context.fit;
    final button = _generating
        ? OutlinedButton.icon(
            key: const ValueKey('generate_button'),
            onPressed: _cancel,
            icon: const Icon(Icons.stop_rounded, size: 17),
            label: const Text('Stop'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              side: BorderSide(color: tokens.lineStrong),
              foregroundColor: tokens.text,
            ),
          )
        : FilledButton.icon(
            key: const ValueKey('generate_button'),
            onPressed: _model == null ? null : () => _generate(),
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: const Text('Generate plan'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: tokens.accent,
              foregroundColor: tokens.onAccent,
              disabledBackgroundColor: tokens.line,
              disabledForegroundColor: tokens.dim,
              textStyle: theme.textTheme.labelLarge!.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              shape: const RoundedRectangleBorder(borderRadius: Radii.control),
              elevation: 0,
            ),
          );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  // Workspace ----------------------------------------------------------------

  Widget _buildWorkspace(ThemeData theme) {
    final tokens = context.fit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.xxl,
            Insets.xl,
            Insets.xl,
            Insets.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY',
                      style: theme.textTheme.labelSmall!.copyWith(
                        fontSize: 8.5,
                        letterSpacing: 2,
                        color: tokens.dim,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _plan != null || _streamText.value.isNotEmpty
                          ? 'Your plan'
                          : 'Training journal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium!.copyWith(
                        fontSize: 28,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _statusLine(theme),
                  ],
                ),
              ),
              const SizedBox(width: Insets.md),
              _modeToggle(theme, compact: false),
              const SizedBox(width: Insets.sm),
              IconButton(
                tooltip: 'History',
                onPressed: _openHistory,
                icon: const Icon(Icons.history, size: 19),
              ),
              IconButton(
                tooltip: 'Export Markdown',
                onPressed: _hasPlan ? _exportPlan : null,
                icon: const Icon(Icons.ios_share, size: 19),
              ),
              IconButton(
                tooltip: 'Copy plan',
                onPressed: _hasPlan ? _copyPlan : null,
                icon: const Icon(Icons.copy_all_outlined, size: 19),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: tokens.line),
        Expanded(child: _workspaceBody(theme, padded: false)),
        _chatDock(theme),
      ],
    );
  }

  /// The collapsible Ask Coach dock at the bottom of the desktop workspace.
  Widget _chatDock(ThemeData theme) {
    final tokens = context.fit;
    final questions = _chatMessages.where((m) => m.fromUser).length;
    return Material(
      color: tokens.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1, color: tokens.line),
          InkWell(
            onTap: () => setState(() => _chatOpen = !_chatOpen),
            hoverColor: tokens.accent.withValues(alpha: 0.03),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.xxl,
                vertical: Insets.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Icon(
                      Icons.forum_outlined,
                      size: 15,
                      color: tokens.accent,
                    ),
                  ),
                  const SizedBox(width: Insets.md),
                  Text(
                    'Ask Coach',
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: Insets.sm),
                  if (_chatMessages.isNotEmpty)
                    StatChip(
                      label: '$questions question${questions == 1 ? '' : 's'}',
                      dot: tokens.accent,
                    ),
                  const Spacer(),
                  if (_chatSending)
                    Padding(
                      padding: const EdgeInsets.only(right: Insets.md),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.4,
                              color: tokens.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'answering',
                            style: theme.textTheme.labelSmall!.copyWith(
                              fontSize: 9,
                              letterSpacing: 0.4,
                              color: tokens.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Icon(
                    _chatOpen
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: tokens.dim,
                  ),
                ],
              ),
            ),
          ),
          if (_chatOpen)
            SizedBox(
              height: 300,
              child: CoachChatPanel(
                messages: _chatMessages,
                sending: _chatSending,
                activity: _chatActivity,
                onSend: _sendChat,
                onStop: _cancel,
                onRebuildPlan: _rebuildFromNote,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusLine(ThemeData theme) {
    return ValueListenableBuilder<Duration>(
      valueListenable: _elapsed,
      builder: (context, elapsed, _) => ValueListenableBuilder<int>(
        valueListenable: _receivedChars,
        builder: (context, received, _) {
          final pieces = <String>[];
          final model = _model;
          if (model != null) pieces.add(model.label);
          if (_generating) {
            pieces.add(
              '${(elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s',
            );
            if (_mode == PlanMode.typed && received > 0) {
              pieces.add('$received chars');
            }
          } else {
            final usage = _completed?.usage ?? _typedUsage;
            if (usage?.totalTokens != null) {
              pieces.add('${usage!.totalTokens} tokens');
            }
            final latency = _typedLatencyMs;
            if (latency != null) {
              pieces.add('${(latency / 1000).toStringAsFixed(1)}s');
            }
            if (_completed?.cancelled ?? false) pieces.add('stopped');
            final done =
                !_generating &&
                (_completed != null || _plan != null) &&
                !(_completed?.cancelled ?? false);
            if (done) pieces.add('done');
          }
          return Text(
            pieces.isEmpty ? 'Ready' : pieces.join('  ·  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }

  Widget _modeToggle(ThemeData theme, {required bool compact}) {
    return SegmentedButton<PlanMode>(
      segments: [
        for (final mode in PlanMode.values)
          ButtonSegment(
            value: mode,
            icon: Icon(mode.icon, size: 16),
            label: compact ? null : Text(mode.label),
            tooltip: mode.label,
          ),
      ],
      selected: {_mode},
      onSelectionChanged: _generating
          ? null
          : (selection) => setState(() => _mode = selection.first),
      showSelectedIcon: false,
      style: compact
          ? _compactSegments(theme)
          : ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
              ),
            ),
    );
  }

  Widget _workspaceBody(ThemeData theme, {required bool padded}) {
    final body = ValueListenableBuilder<String>(
      valueListenable: _streamText,
      builder: (context, streamText, _) {
        final error = _error;
        if (error != null) {
          final tokens = context.fit;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(Insets.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tokens.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: tokens.danger,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: Insets.lg),
                    Text(
                      'Generation failed',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: Insets.sm),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: tokens.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final plan = _plan;
        if (plan != null) {
          return _scrollable(
            theme,
            padded: padded,
            child: PlanView(
              plan: plan,
              targets: _targetsApplied ? _targets : null,
            ),
          );
        }
        if (streamText.isNotEmpty) {
          return _scrollable(
            theme,
            padded: padded,
            child: PlanBody(text: streamText, streaming: _generating),
          );
        }
        if (_generating) {
          return _mode == PlanMode.typed
              ? _draftingPanel(theme)
              : _spinnerPanel(theme);
        }
        return _emptyState(theme);
      },
    );
    return body;
  }

  Widget _scrollable(
    ThemeData theme, {
    required bool padded,
    required Widget child,
  }) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          padded ? Insets.xl : Insets.xxl,
          Insets.xl,
          padded ? Insets.xl : Insets.xxl,
          Insets.huge,
        ),
        child: child,
      ),
    );
  }

  Widget _draftingPanel(ThemeData theme) {
    final tokens = context.fit;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(Insets.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Writing your plan.',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall!.copyWith(fontSize: 34),
              ),
              const SizedBox(height: Insets.sm),
              Text(
                'The model drafts the full document, then OpenFit turns it '
                'into an interactive plan.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: tokens.muted,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: Insets.xxl),
              SizedBox(
                width: 190,
                child: ClipRRect(
                  borderRadius: Radii.pillRadius,
                  child: const LinearProgressIndicator(minHeight: 3),
                ),
              ),
              const SizedBox(height: Insets.lg),
              ValueListenableBuilder<Duration>(
                valueListenable: _elapsed,
                builder: (context, elapsed, _) => ValueListenableBuilder<int>(
                  valueListenable: _receivedChars,
                  builder: (context, received, _) => Text(
                    '${(elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s'
                    '  ·  $received chars',
                    style: kFitMonoStyle.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      color: tokens.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spinnerPanel(ThemeData theme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.fit.accent,
          ),
        ),
        const SizedBox(height: Insets.md),
        Text(
          'Drafting the plan…',
          style: theme.textTheme.bodySmall!.copyWith(color: context.fit.muted),
        ),
      ],
    ),
  );

  Widget _emptyState(ThemeData theme) {
    final tokens = context.fit;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(Insets.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.line),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tokens.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 24,
                      color: tokens.onAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Insets.xl),
              Text(
                'Train with intent.',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall!.copyWith(fontSize: 38),
              ),
              const SizedBox(height: Insets.md),
              Text(
                _isNarrow
                    ? 'Pick a quick start or set the dials in Build, then '
                          'generate a plan.'
                    : 'Set the dials on the left, or start from a template. '
                          'Every plan is yours to edit, run and keep.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: tokens.muted,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: Insets.xl),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Insets.sm,
                runSpacing: Insets.sm,
                children: const [
                  StatChip(label: 'TYPED PLANS', dot: Color(0xFFC9F26B)),
                  StatChip(label: 'LIVE TEXT', dot: Color(0xFF9BC4A5)),
                  StatChip(label: 'LOCAL MODELS', dot: Color(0xFFF1A45E)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
