import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genkit/genkit.dart' show GenerationUsage;

import 'coach_service.dart';
import 'macros.dart';
import 'plan.dart';
import 'plan_body.dart';
import 'plan_request.dart';
import 'plan_store.dart';
import 'plan_view.dart';

/// How the plan pane renders the generation.
enum PlanMode {
  /// Structured output parsed into a typed plan.
  typed('Typed plan', Icons.view_week_outlined),

  /// Raw token stream rendered as it arrives.
  text('Live text', Icons.subject);

  const PlanMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

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
  final _output = StringBuffer();

  List<CoachModel> _models = const [];
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

  StreamSubscription<PlanEvent>? _subscription;
  Timer? _ticker;
  Stopwatch? _watch;
  bool _generating = false;
  String? _error;
  PlanCompleted? _completed;

  PlanMode _mode = PlanMode.typed;
  WorkoutPlan? _plan;
  GenerationUsage? _typedUsage;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _subscription?.cancel();
    _notesController.dispose();
    _scrollController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadModels() async {
    setState(() {
      _loadingModels = true;
      _catalogError = null;
    });
    try {
      final models = await _service.listModels();
      if (!mounted) return;
      setState(() {
        _models = models;
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
        _catalogError = error
            .toString()
            .replaceFirst(RegExp(r'^GenkitException: '), '');
      });
    }
  }

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
      _output.clear();
      _watch = Stopwatch()..start();
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });

    _subscription?.cancel();
    if (_mode == PlanMode.typed) {
      unawaited(_generateTyped(model, input));
    } else {
      _subscription = _service
          .generatePlan(modelId: model.id, request: input)
          .listen(
            (event) {
              if (!mounted) return;
              switch (event) {
                case PlanText(:final text):
                  setState(() => _output.write(text));
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
      );
      if (!mounted) return;
      setState(() {
        _plan = result.plan;
        _typedUsage = result.usage;
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

  bool get _hasPlan => _plan != null || _output.isNotEmpty;

  String get _currentMarkdown {
    final plan = _plan;
    if (plan != null) return plan.toMarkdown();
    return _output.toString();
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
    final home = Platform.environment['HOME'] ?? Directory.systemTemp.path;
    var directory = Directory('$home/Downloads');
    if (!directory.existsSync()) directory = Directory(home);
    final file = File(
      '${directory.path}/gym_coach_plan_'
      '${DateTime.now().millisecondsSinceEpoch}.md',
    );
    try {
      await file.create(recursive: true);
      await file.writeAsString(markdown);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    }
  }

  Future<void> _openHistory() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _HistoryDialog(
        store: _store,
        onLoad: (saved) {
          setState(() {
            _error = null;
            _completed = null;
            _plan = null;
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
              _output
                ..clear()
                ..write(raw);
              _mode = PlanMode.text;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 340, child: _buildForm(theme)),
          VerticalDivider(
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(child: _buildPlan(theme)),
        ],
      ),
    );
  }

  // Form ---------------------------------------------------------------------

  Widget _buildForm(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gym Coach',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'streamed by LongCat 2.5 via OpenCode',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                _label(theme, 'Goal'),
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
                const SizedBox(height: 16),
                _label(theme, 'Experience'),
                SegmentedButton<ExperienceLevel>(
                  segments: [
                    for (final level in ExperienceLevel.values)
                      ButtonSegment(value: level, label: Text(level.label)),
                  ],
                  selected: {_level},
                  onSelectionChanged: _generating
                      ? null
                      : (selection) =>
                            setState(() => _level = selection.first),
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 4),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _label(theme, 'Days per week: $_days'),
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
                _label(theme, 'Session length'),
                Wrap(
                  spacing: 6,
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
                const SizedBox(height: 16),
                _label(theme, 'Equipment'),
                DropdownButtonFormField<GymEquipment>(
                  initialValue: _equipment,
                  isDense: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: [
                    for (final equipment in GymEquipment.values)
                      DropdownMenuItem(
                        value: equipment,
                        child: Text(equipment.label),
                      ),
                  ],
                  onChanged: _generating
                      ? null
                      : (value) => setState(
                          () => _equipment = value ?? _equipment,
                        ),
                ),
                const SizedBox(height: 16),
                _label(theme, 'Notes (injuries, preferences)'),
                TextField(
                  controller: _notesController,
                  enabled: !_generating,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'e.g. bad left knee, hates burpees',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _nutrition,
                  onChanged: _generating
                      ? null
                      : (value) => setState(() => _nutrition = value),
                  title: Text(
                    'Include food plan',
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    'Calories, protein target and a sample day',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _label(theme, 'Macro calculator'),
                _buildMacroCard(theme),
                const SizedBox(height: 16),
                _label(theme, 'Model'),
                _buildModelPicker(theme),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: _generating
                ? FilledButton.tonalIcon(
                    onPressed: _cancel,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop'),
                  )
                : FilledButton.icon(
                    onPressed: _model == null ? null : () => _generate(),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate plan'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelPicker(ThemeData theme) {
    if (_loadingModels) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
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
          const SizedBox(height: 4),
          Text(
            _catalogError!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loadModels,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      );
    }
    return DropdownMenu<CoachModel>(
      initialSelection: _model,
      enableFilter: true,
      enableSearch: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 420,
      label: const Text('Search 130+ models'),
      dropdownMenuEntries: [
        for (final model in _models)
          DropdownMenuEntry(
            value: model,
            label: model.id == model.label
                ? model.id
                : '${model.label} · ${model.id}',
          ),
      ],
      onSelected: _generating
          ? null
          : (model) => setState(() => _model = model),
    );
  }

  Widget _label(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall!.copyWith(
        letterSpacing: 0.8,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
  );

  // Macro calculator ----------------------------------------------------------

  Widget _buildMacroCard(ThemeData theme) {
    final targets = _targets;
    final compactButton = ButtonStyle(
      visualDensity: VisualDensity.compact,
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 4),
      ),
      textStyle: WidgetStatePropertyAll(
        theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            style: compactButton,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _macroField(theme, 'Weight kg', _weightController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _macroField(theme, 'Height cm', _heightController),
              ),
              const SizedBox(width: 8),
              Expanded(child: _macroField(theme, 'Age', _ageController)),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<ActivityLevel>(
            initialValue: _activity,
            isDense: true,
            decoration: const InputDecoration(
              labelText: 'Activity',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            items: [
              for (final activity in ActivityLevel.values)
                DropdownMenuItem(
                  value: activity,
                  child: Text('${activity.label} · ×${activity.factor}'),
                ),
            ],
            onChanged: _generating
                ? null
                : (value) =>
                      setState(() => _activity = value ?? _activity),
          ),
          const SizedBox(height: 10),
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
            style: compactButton,
          ),
          const SizedBox(height: 10),
          Text(
            targets?.summary ?? 'Enter weight, height and age.',
            style: theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: targets == null
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: _generating || targets == null
                  ? null
                  : () =>
                        setState(() => _targetsApplied = !_targetsApplied),
              icon: Icon(
                _targetsApplied ? Icons.check : Icons.calculate_outlined,
                size: 16,
              ),
              label: Text(
                _targetsApplied ? 'Targets added to plan' : 'Use in plan',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroField(
    ThemeData theme,
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      enabled: !_generating,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.bodySmall,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  // Plan pane ----------------------------------------------------------------

  Widget _buildPlan(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _buildStatus(theme)),
              const SizedBox(width: 12),
              SegmentedButton<PlanMode>(
                segments: [
                  for (final mode in PlanMode.values)
                    ButtonSegment(
                      value: mode,
                      label: Text(mode.label),
                      icon: Icon(mode.icon, size: 15),
                    ),
                ],
                selected: {_mode},
                onSelectionChanged: _generating
                    ? null
                    : (selection) => setState(() => _mode = selection.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(
                    theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'History',
                onPressed: _openHistory,
                icon: const Icon(Icons.history, size: 20),
              ),
              IconButton(
                tooltip: 'Export Markdown',
                onPressed: _hasPlan ? _exportPlan : null,
                icon: const Icon(Icons.ios_share, size: 20),
              ),
              IconButton(
                tooltip: 'Copy plan',
                onPressed: _hasPlan ? _copyPlan : null,
                icon: const Icon(Icons.copy_all_outlined, size: 20),
              ),
            ],
          ),
        ),
        Expanded(child: _buildBody(theme)),
      ],
    );
  }

  Widget _buildStatus(ThemeData theme) {
    final pieces = <String>[];
    final model = _model;
    if (model != null) pieces.add(model.label);
    if (_generating && _watch != null) {
      pieces.add('${(_watch!.elapsedMilliseconds / 1000).toStringAsFixed(1)}s');
    } else {
      final usage = _completed?.usage ?? _typedUsage;
      if (usage?.totalTokens != null) {
        pieces.add('${usage!.totalTokens} tokens');
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
      style: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final error = _error;
    if (error != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 34,
              ),
              const SizedBox(height: 12),
              Text('Generation failed', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }
    if (_generating && _plan == null && _output.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              'Drafting the plan…',
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    if (_output.isEmpty && _plan == null && !_generating) {
      return _buildEmptyState(theme);
    }
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: _plan != null
            ? PlanView(plan: _plan!)
            : PlanBody(text: _output.toString(), streaming: _generating),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final presets = <(String, String, PlanRequest)>[
      (
        'First workout',
        'A beginner-friendly 3-day full-body week',
        const PlanRequest(
          goal: FitnessGoal.buildMuscle,
          level: ExperienceLevel.beginner,
          daysPerWeek: 3,
          sessionMinutes: 45,
          equipment: GymEquipment.fullGym,
          notes: 'Brand-new to lifting.',
        ),
      ),
      (
        'Fat loss + food',
        '4-day plan with a sample food day',
        const PlanRequest(
          goal: FitnessGoal.loseFat,
          level: ExperienceLevel.intermediate,
          daysPerWeek: 4,
          sessionMinutes: 45,
          equipment: GymEquipment.dumbbells,
          notes: 'Desk job, wants to keep muscle.',
        ),
      ),
      (
        'Hotel room week',
        'No equipment, 30 minutes, 4 days',
        const PlanRequest(
          goal: FitnessGoal.endurance,
          level: ExperienceLevel.beginner,
          daysPerWeek: 4,
          sessionMinutes: 30,
          equipment: GymEquipment.bodyweight,
          notes: 'Travel week, only a floor and a chair.',
        ),
      ),
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pick a template or set the dials on the left.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Plans stream straight from the OpenCode server, '
              'token by token.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            for (final (title, subtitle, request) in presets)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _generating || _model == null
                        ? null
                        : () => _generate(request: request),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: theme.textTheme.titleSmall),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.play_arrow_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lists saved plans with load and delete actions.
class _HistoryDialog extends StatefulWidget {
  const _HistoryDialog({required this.store, required this.onLoad});

  final PlanStore store;
  final void Function(SavedPlan plan) onLoad;

  @override
  State<_HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<_HistoryDialog> {
  late Future<List<SavedPlan>> _plans = widget.store.list();

  void _reload() => setState(() => _plans = widget.store.list());

  Future<void> _delete(SavedPlan plan) async {
    await widget.store.delete(plan.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Plan history'),
      content: SizedBox(
        width: 520,
        height: 420,
        child: FutureBuilder<List<SavedPlan>>(
          future: _plans,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final plans = snapshot.data ?? const <SavedPlan>[];
            if (plans.isEmpty) {
              return Center(
                child: Text(
                  'No saved plans yet.\nGenerated plans are kept here '
                  'automatically.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView.separated(
              itemCount: plans.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final plan = plans[index];
                final stamp = plan.createdAt
                    .toLocal()
                    .toString()
                    .split('.')
                    .first;
                return ListTile(
                  dense: true,
                  title: Text(plan.title),
                  subtitle: Text(
                    '$stamp · ${plan.structured != null ? 'typed' : 'text'}',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onLoad(plan);
                  },
                  trailing: IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _delete(plan),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
