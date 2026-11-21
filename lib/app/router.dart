import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/data/providers.dart';
import '../features/auth/presentation/email_sign_in_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import 'shell.dart';

part 'router.g.dart';

abstract final class Routes {
  static const start = '/';
  static const signIn = '/sign-in';
  static const signInEmail = '/sign-in/email';
  static const home = '/home';
  static const schedule = '/schedule';
  static const library = '/library';
  static const progress = '/progress';
  static const profile = '/profile';
}

// AC1: the gate comes from Drift, so it is known offline and without Firebase.
// While it loads, the blank start route shows for a few milliseconds.
String? authRedirect(AsyncValue<bool> choiceMade, String location) {
  if (choiceMade.isLoading && !choiceMade.hasValue) return null;
  final made = choiceMade.value ?? false;
  final onSignIn = location.startsWith(Routes.signIn);
  if (!made) return onSignIn ? null : Routes.signIn;
  return location == Routes.start ? Routes.home : null;
}

/// App router. `indexedStack` keeps every tab's state alive (FND-01 AC6).
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final gate = ValueNotifier(ref.read(authChoiceMadeProvider));
  ref.listen(authChoiceMadeProvider, (_, next) => gate.value = next);
  final router = GoRouter(
    initialLocation: Routes.start,
    refreshListenable: gate,
    redirect: (context, state) =>
        authRedirect(gate.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: Routes.start,
        builder: (context, state) => const Scaffold(),
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
