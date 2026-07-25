import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/home_controller.dart';
import '../../router/app_router.dart';
import '../../widgets/room_code_slots.dart';
import '../../widgets/rumour_key_icon.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _slotsKey = GlobalKey<RoomCodeSlotsState>();
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _join(String code) async {
    final ready =
        await ref.read(homeControllerProvider.notifier).joinRoom(code);
    if (!mounted || ready == null) return;
    context.push(
      AppRoutes.identityPath(ready.room.code),
      extra: ready,
    );
  }

  Future<void> _create() async {
    final ready = await ref.read(homeControllerProvider.notifier).createRoom();
    if (!mounted || ready == null) return;
    // Show the new code briefly via snackbar, then identity screen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          'Room created: ${ready.room.code}',
          style: const TextStyle(color: AppColors.accent),
        ),
      ),
    );
    context.push(
      AppRoutes.identityPath(ready.room.code),
      extra: ready,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final loading = state is HomeLoading ? state : null;
    final error = state is HomeError ? state.message : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _entrance,
                  child: const RumourKeyIcon(size: 36),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _entrance,
                    curve: const Interval(0.15, 1, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entrance,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Join A Room',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter the code to join the anon chat room.',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                        ),
                        const SizedBox(height: 48),
                        RoomCodeSlots(
                          key: _slotsKey,
                          onCompleted: (code) {
                            if (loading == null) _join(code);
                          },
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        if (loading != null) ...[
                          const SizedBox(height: 28),
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                TextButton(
                  onPressed: loading != null ? null : _create,
                  child: const Text('Create a new room'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
