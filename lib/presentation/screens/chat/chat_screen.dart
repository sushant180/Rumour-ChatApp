import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/anonymous_identity.dart';
import '../../providers/chat_controller.dart';
import '../../router/app_router.dart';
import '../../widgets/chat_widgets.dart';
import '../../widgets/room_app_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.roomCode,
    required this.identity,
    this.memberCount,
  });

  final String roomCode;
  final AnonymousIdentity identity;
  final int? memberCount;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  ChatArgs get _args => ChatArgs(
        roomCode: widget.roomCode,
        identity: widget.identity,
      );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80) {
      ref.read(chatControllerProvider(_args).notifier).loadOlder();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text;
    _messageController.clear();
    await ref.read(chatControllerProvider(_args).notifier).send(text);
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.roomCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          'Room code copied',
          style: TextStyle(color: AppColors.accent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(_args));
    final items = buildChatListItems(state.messages);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: RoomAppBar(
          roomCode: widget.roomCode,
          memberCount: widget.memberCount,
          onBack: () => context.go(AppRoutes.home),
          actions: [
            IconButton(
              tooltip: 'Copy room code',
              onPressed: _copyCode,
              icon: const Icon(Icons.ios_share_rounded, size: 20),
            ),
          ],
        ),
        body: Column(
          children: [
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet.\nSay hello anonymously.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: items.length + (state.isLoadingOlder ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (state.isLoadingOlder && index == items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          );
                        }

                        final item = items[index];
                        return switch (item) {
                          DateSeparatorItem(:final label) =>
                            DateSeparatorChip(label: label),
                          MessageItem(:final message) => MessageBubble(
                              message: message,
                              isMine: message.senderId == widget.identity.id,
                            ),
                        };
                      },
                    ),
            ),
            _Composer(
              controller: _messageController,
              isSending: state.isSending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => isSending ? null : onSend(),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: AppColors.accent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isSending ? null : onSend,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onAccent,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.onAccent,
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
