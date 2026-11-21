import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/data/providers.dart';
import '../features/auth/presentation/account_screen.dart';
import '../features/auth/presentation/email_sign_in_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/onboarding/data/providers.dart';
import '../features/onboarding/presentation/about_you_screen.dart';
import '../features/onboarding/presentation/goal_level_screen.dart';
import '../features/onboarding/presentation/plan_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/schedule/presentation/cycle_editor_screen.dart';
import '../features/schedule/presentation/cycles_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import '../features/workout/presentation/template_editor_screen.dart';
import '../features/workout/presentation/workouts_screen.dart';
import 'shell.dart';

part 'router.g.dart';

abstract final class Routes {
  static const start = '/';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const onboardingAbout = '/onboarding/about';
  static const signIn = '/sign-in';
  static const signInEmail = '/sign-in/email';
  static const account = '/account';
  static const home = '/home';
  static const schedule = '/schedule';
  static const library = '/library';
  static const progress = '/progress';
  static const profile = '/profile';
  static const workouts = '/schedule/workouts';
  static const workoutNew = '/schedule/workouts/new';
  static String workoutEdit(String id) => '/schedule/workouts/$id';
  static String workoutCopy(String id) =>
      Uri(path: workoutNew, queryParameters: {'copyOf': id}).toString();
  static const onboardingPlan = '/onboarding/plan';
  static const cycles = '/schedule/cycles';
  static const cycleNew = '/schedule/cycles/new';
  static String cycleEdit(String id) => '/schedule/cycles/$id';
  static String cycleCopy(String id) =>
      Uri(path: cycleNew, queryParameters: {'copyOf': id}).toString();
}

// AUTH-01 AC1, ONB-01 AC1/AC2: both gates come from Drift, so they are known
// offline and without Firebase. While they load, the blank start route shows.
String? appRedirect(
  AsyncValue<bool> choiceMade,
  AsyncValue<bool> onboarded,
  String location,
) {
  bool loading(AsyncValue<bool> v) => v.isLoading && !v.hasValue;
  if (loading(choiceMade)) return null;
  final onWelcome = location == Routes.welcome;
  final onSignIn = location.startsWith(Routes.signIn);
  if (!(choiceMade.value ?? false)) {
    return onWelcome || onSignIn ? null : Routes.welcome;
  }
  if (loading(onboarded)) return null;
  final onOnboarding = location.startsWith(Routes.onboarding);
  // Account (09b) follows a sign-in, before or after onboarding.
  final onAccount = location == Routes.account;
  if (!(onboarded.value ?? false)) {
    // Sign in stays put while a just-finished sign-in moves on to Account.
    return onOnboarding || onAccount || onSignIn ? null : Routes.onboarding;
  }
  return location == Routes.start || onWelcome || onOnboarding
      ? Routes.home
      : null;
}

/// App router. `indexedStack` keeps every tab's state alive (FND-01 AC6).
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final gate = ValueNotifier(0);
  ref
    ..listen(authChoiceMadeProvider, (_, _) => gate.value++)
    ..listen(onboardingDoneProvider, (_, _) => gate.value++);
  final router = GoRouter(
    initialLocation: Routes.start,
    refreshListenable: gate,
    redirect: (context, state) => appRedirect(
      ref.read(authChoiceMadeProvider),
      ref.read(onboardingDoneProvider),
      state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: Routes.start,
        builder: (context, state) => const Scaffold(),
      ),
      GoRoute(
        path: Routes.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const GoalLevelScreen(),
        routes: [
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutYouScreen(),
          ),
          GoRoute(
            path: 'plan',
            builder: (context, state) => const PlanScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
        routes: [
          GoRoute(
            path: 'email',
            builder: (context, state) => const EmailSignInScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.schedule,
                builder: (context, state) => const ScheduleScreen(),
                routes: [
                  GoRoute(
                    path: 'cycles',
                    builder: (context, state) => const CyclesScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) => CycleEditorScreen(
                          copyOf: state.uri.queryParameters['copyOf'],
                        ),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) =>
                            CycleEditorScreen(id: state.pathParameters['id']),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'workouts',
                    builder: (context, state) => const WorkoutsScreen(),
                    routes: [
                      // Before ':id', so "new" is not read as an id.
                      GoRoute(
                        path: 'new',
                        builder: (context, state) => TemplateEditorScreen(
                          copyOf: state.uri.queryParameters['copyOf'],
                        ),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => TemplateEditorScreen(
                          id: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.progress,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    gate.dispose();
  });
  return router;
}
