import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/anonymous_identity.dart';
import '../providers/home_controller.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/identity/identity_screen.dart';

class AppRoutes {
  static const home = '/';
  static const identity = '/identity/:roomCode';
  static const chat = '/chat/:roomCode';

  static String identityPath(String roomCode) => '/identity/$roomCode';
  static String chatPath(String roomCode) => '/chat/$roomCode';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.identity,
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final ready = state.extra as HomeReady?;
        if (ready == null) {
          return const _MissingSessionScreen();
        }
        return IdentityScreen(
          roomCode: roomCode,
          identity: ready.identity,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final identity = state.extra as AnonymousIdentity?;
        if (identity == null) {
          return const _MissingSessionScreen();
        }
        return ChatScreen(roomCode: roomCode, identity: identity);
      },
    ),
  ],
);

class _MissingSessionScreen extends StatelessWidget {
  const _MissingSessionScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Open chat by creating or joining a room from the home screen.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
