import '../../../app/l10n/generated/app_localizations.dart';
import '../domain/exercise.dart';

enum MuscleGroup {
  chest({Muscle.chest}),
  back({Muscle.lats, Muscle.middleBack, Muscle.lowerBack, Muscle.traps}),
  shoulders({Muscle.shoulders}),
  legs({
    Muscle.quadriceps,
    Muscle.hamstrings,
    Muscle.glutes,
    Muscle.calves,
    Muscle.adductors,
    Muscle.abductors,
  }),
  arms({Muscle.biceps, Muscle.triceps, Muscle.forearms}),
  core({Muscle.abdominals});

  const MuscleGroup(this.muscles);
  final Set<Muscle> muscles;
}

String muscleGroupLabel(AppLocalizations l10n, MuscleGroup g) => switch (g) {
  MuscleGroup.chest => l10n.groupChest,
  MuscleGroup.back => l10n.groupBack,
  MuscleGroup.shoulders => l10n.groupShoulders,
  MuscleGroup.legs => l10n.groupLegs,
  MuscleGroup.arms => l10n.groupArms,
  MuscleGroup.core => l10n.groupCore,
};

String muscleLabel(AppLocalizations l10n, Muscle m) => switch (m) {
  Muscle.chest => l10n.muscleChest,
  Muscle.shoulders => l10n.muscleShoulders,
  Muscle.triceps => l10n.muscleTriceps,
  Muscle.biceps => l10n.muscleBiceps,
  Muscle.forearms => l10n.muscleForearms,
  Muscle.lats => l10n.muscleLats,
  Muscle.middleBack => l10n.muscleMiddleBack,
  Muscle.lowerBack => l10n.muscleLowerBack,
  Muscle.traps => l10n.muscleTraps,
  Muscle.abdominals => l10n.muscleAbdominals,
  Muscle.quadriceps => l10n.muscleQuadriceps,
  Muscle.hamstrings => l10n.muscleHamstrings,
  Muscle.glutes => l10n.muscleGlutes,
  Muscle.calves => l10n.muscleCalves,
  Muscle.adductors => l10n.muscleAdductors,
  Muscle.abductors => l10n.muscleAbductors,
  Muscle.neck => l10n.muscleNeck,
};

String equipmentLabel(AppLocalizations l10n, Equipment e) => switch (e) {
  Equipment.barbell => l10n.equipmentBarbell,
  Equipment.dumbbell => l10n.equipmentDumbbell,
  Equipment.cable => l10n.equipmentCable,
  Equipment.machine => l10n.equipmentMachine,
  Equipment.kettlebell => l10n.equipmentKettlebell,
  Equipment.bands => l10n.equipmentBands,
  Equipment.bodyOnly => l10n.equipmentBodyOnly,
  Equipment.ezBar => l10n.equipmentEzBar,
  Equipment.smithMachine => l10n.equipmentSmithMachine,
  Equipment.other => l10n.equipmentOther,
};
