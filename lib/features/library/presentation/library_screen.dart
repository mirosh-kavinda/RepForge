import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../../logger/data/providers.dart';
import '../data/providers.dart';
import '../domain/exercise.dart';
import 'exercise_filters.dart';
import 'exercise_search.dart';
import 'muscle_groups.dart';

// Screen 04 (EXL-01): browse, search and filter the catalog.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  static const searchKey = ValueKey('library.search');
  static const clearKey = ValueKey('library.clear');
  static const newKey = ValueKey('library.new');

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _search = TextEditingController();
  MuscleGroup? _group;
  Equipment? _equipment;
  List<Exercise>? _results;
  var _generation = 0;

  bool get _browsing =>
      _search.text.trim().isEmpty && _group == null && _equipment == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_results == null) _run();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final generation = ++_generation;
    final repo = await ref.read(exerciseCatalogProvider.future);
    if (!mounted) return;
    final results = await runSearch(
      repo,
      AppLocalizations.of(context),
      text: _search.text,
      group: _group,
      equipment: _equipment,
    );
    // A slower earlier search must not overwrite a newer one.
    if (mounted && generation == _generation) {
      setState(() => _results = results);
    }
  }

  // EXL-03 AC1: a new exercise opens its detail.
  Future<void> _create() async {
    final id = await context.push<String>(Routes.exerciseNew);
    if (id != null && mounted) await context.push(Routes.exercise(id));
  }

  void _clear() {
    _search.clear();
    setState(() {
      _group = null;
      _equipment = null;
    });
    _run();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final results = _results;
    final recent = _browsing ? _recent() : const <Exercise>[];
    // EXL-03: my exercises changed (added, edited, deleted, restored).
    ref.listen(customExercisesProvider, (_, _) => _run());

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(0, RfSpace.s16, 0, RfSpace.s8),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: t.overline.copyWith(color: c.textMuted),
        ),
      ),
    );

    final Widget list;
    if (results == null) {
      list = const Center(child: CircularProgressIndicator());
    } else if (results.isEmpty) {
      list = Center(
        child: Padding(
          padding: const EdgeInsets.all(RfSpace.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.libraryNoMatch,
                textAlign: TextAlign.center,
                style: t.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: RfSpace.s12),
              RfButton(
                key: LibraryScreen.clearKey,
                label: l10n.libraryClear,
                variant: RfButtonVariant.secondary,
                size: RfButtonSize.md,
                onPressed: _clear,
              ),
            ],
          ),
        ),
      );
    } else {
      // [Recent header, recent…, All header, all…]; built lazily (NFR-01).
      final items = <Object>[
        if (recent.isNotEmpty) ...[l10n.libraryRecent, ...recent],
        if (recent.isNotEmpty) l10n.libraryAll,
        ...results,
      ];
      list = ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          RfSpace.s20,
          0,
          RfSpace.s20,
          RfSpace.s16,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => switch (items[i]) {
          final String h => header(h),
          final Exercise e => Padding(
            padding: const EdgeInsets.only(top: RfSpace.s8),
            child: ExerciseRow(exercise: e),
          ),
          _ => const SizedBox.shrink(),
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabLibrary),
        actions: [
          IconButton(
            key: LibraryScreen.newKey,
            tooltip: l10n.customNew,
            constraints: const BoxConstraints(
              minWidth: RfSize.minTarget,
              minHeight: RfSize.minTarget,
            ),
            icon: const Icon(Icons.add),
            onPressed: _create,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                RfSpace.s8,
                RfSpace.s20,
                0,
              ),
              child: TextField(
                key: LibraryScreen.searchKey,
                controller: _search,
                decoration: InputDecoration(
                  labelText: l10n.pickerSearch,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (_) {
                  setState(() {});
                  _run();
                },
              ),
            ),
            ExerciseFilters(
              group: _group,
              equipment: _equipment,
              onGroup: (g) {
                setState(() => _group = g);
                _run();
              },
              onEquipment: (e) {
                setState(() => _equipment = e);
                _run();
              },
            ),
            Expanded(child: list),
          ],
        ),
      ),
    );
  }

  // AC1: recent ids resolved against the catalog; unknown ids skipped.
  List<Exercise> _recent() {
    final ids = ref.watch(recentExercisesProvider).value ?? const <String>[];
    final all = _results ?? const <Exercise>[];
    final byId = {for (final e in all) e.id: e};
    return [for (final id in ids) ?byId[id]];
  }
}

// EXL-01 AC4: one exercise; opens its detail.
class ExerciseRow extends StatelessWidget {
  const ExerciseRow({required this.exercise, super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final meta = exerciseMeta(l10n, exercise);
    void open() => context.push(Routes.exercise(exercise.id));

    return Semantics(
      button: true,
      label: [l10n.libraryOpen(exercise.name), meta].join(', '),
      onTap: open,
      excludeSemantics: true,
      child: RfTappable(
        radius: RfRadius.lg,
        onTap: open,
        child: Container(
          constraints: const BoxConstraints(minHeight: RfSize.minTarget),
          padding: const EdgeInsets.all(RfSpace.s12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(RfRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: t.labelStrong),
                    const SizedBox(height: RfSpace.s4),
                    Text(meta, style: t.label.copyWith(color: c.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
