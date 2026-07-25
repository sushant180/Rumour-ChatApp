import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/chat_message.dart';

sealed class ChatListItem {
  const ChatListItem();
}

class DateSeparatorItem extends ChatListItem {
  const DateSeparatorItem(this.label);

  final String label;
}

class MessageItem extends ChatListItem {
  const MessageItem(this.message);

  final ChatMessage message;
}

List<ChatListItem> buildChatListItems(List<ChatMessage> newestFirst) {
  if (newestFirst.isEmpty) return const [];

  final chronological = newestFirst.reversed.toList();
  final items = <ChatListItem>[];
  DateTime? lastDay;

  for (final message in chronological) {
    final time = message.createdAt;
    if (time != null) {
      final day = DateTime(time.year, time.month, time.day);
      if (lastDay == null || day != lastDay) {
        items.add(DateSeparatorItem(_formatDayLabel(day)));
        lastDay = day;
      }
    }
    items.add(MessageItem(message));
  }

  return items.reversed.toList();
}

String _formatDayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  if (day == today) return 'Today';
  if (day == yesterday) return 'Yesterday';
  return DateFormat('EEE, MMM d').format(day);
}

class DateSeparatorChip extends StatelessWidget {
  const DateSeparatorChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt == null
        ? ''
        : DateFormat('HH:mm').format(message.createdAt!);

    final bubbleColor =
        isMine ? AppColors.bubbleMine : AppColors.bubbleOther;
    final textColor =
        isMine ? AppColors.onAccent : AppColors.textPrimary;
    final timeColor = textColor.withValues(alpha: 0.65);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMine ? 48 : 16,
            4,
            isMine ? 16 : 48,
            4,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    message.atHandle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 18),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          message.text,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    height: 1.35,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: timeColor,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
