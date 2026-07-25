import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/anonymous_identity.dart';
import '../../router/app_router.dart';
import '../../widgets/room_app_bar.dart';

class IdentityScreen extends StatelessWidget {
  const IdentityScreen({
    super.key,
    required this.roomCode,
    required this.identity,
    this.memberCount,
  });

  final String roomCode;
  final AnonymousIdentity identity;
  final int? memberCount;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: RoomAppBar(
          roomCode: roomCode,
          memberCount: memberCount,
          onBack: () => context.go(AppRoutes.home),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text(
                  'For this room, you are',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 36,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      identity.displayName,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'This is your anonymous identifier, visible only to others in this room.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                ),
                const Spacer(flex: 3),
                FilledButton(
                  onPressed: () {
                    context.pushReplacement(
                      AppRoutes.chatPath(roomCode),
                      extra: identity,
                    );
                  },
                  child: const Text('Acknowledge and continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
