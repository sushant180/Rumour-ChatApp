import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class RoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoomAppBar({
    super.key,
    required this.roomCode,
    this.memberCount,
    this.onBack,
    this.actions,
  });

  final String roomCode;
  final int? memberCount;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final membersLabel = memberCount == null
        ? null
        : '$memberCount member${memberCount == 1 ? '' : 's'}';

    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
      title: Column(
        children: [
          Text(
            'Room #$roomCode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          if (membersLabel != null)
            Text(
              membersLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
      actions: actions,
    );
  }
}
