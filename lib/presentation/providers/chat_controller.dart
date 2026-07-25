import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/anonymous_identity.dart';
import '../../domain/entities/chat_message.dart';
import 'dependency_providers.dart';

class ChatArgs extends Equatable {
  const ChatArgs({
    required this.roomCode,
    required this.identity,
  });

  final String roomCode;
  final AnonymousIdentity identity;

  @override
  List<Object?> get props => [roomCode, identity];
}

class ChatUiState {
  const ChatUiState({
    this.liveMessages = const [],
    this.olderMessages = const [],
    this.isLoadingOlder = false,
    this.hasMore = true,
    this.isSending = false,
    this.error,
  });

  final List<ChatMessage> liveMessages;
  final List<ChatMessage> olderMessages;
  final bool isLoadingOlder;
  final bool hasMore;
  final bool isSending;
  final String? error;

  /// Newest-first combined list for reverse ListView.
  List<ChatMessage> get messages {
    final map = <String, ChatMessage>{};
    for (final m in [...liveMessages, ...olderMessages]) {
      map[m.id] = m;
    }
    // Pending serverTimestamp writes briefly have null createdAt. Treat those
    // as newest so they stay at the bottom (reverse ListView) instead of
    // jumping to the top until Firestore resolves the timestamp.
    final now = DateTime.now();
    final list = map.values.toList()
      ..sort((a, b) {
        final aPending = a.createdAt == null;
        final bPending = b.createdAt == null;
        if (aPending != bPending) return aPending ? -1 : 1;
        final aTime = a.createdAt ?? now;
        final bTime = b.createdAt ?? now;
        final byTime = bTime.compareTo(aTime);
        if (byTime != 0) return byTime;
        return b.id.compareTo(a.id);
      });
    return list;
  }

  ChatUiState copyWith({
    List<ChatMessage>? liveMessages,
    List<ChatMessage>? olderMessages,
    bool? isLoadingOlder,
    bool? hasMore,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ChatUiState(
      liveMessages: liveMessages ?? this.liveMessages,
      olderMessages: olderMessages ?? this.olderMessages,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends Notifier<ChatUiState> {
  ChatController(this.args);

  final ChatArgs args;
  StreamSubscription<List<ChatMessage>>? _subscription;

  @override
  ChatUiState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    _subscription = ref
        .read(watchMessagesUseCaseProvider)(args.roomCode)
        .listen(
          (messages) {
            state = state.copyWith(liveMessages: messages, clearError: true);
          },
          onError: (Object e) {
            state = state.copyWith(error: e.toString());
          },
        );

    return const ChatUiState();
  }

  Future<void> loadOlder() async {
    if (state.isLoadingOlder || !state.hasMore) return;
    final messages = state.messages;
    if (messages.isEmpty) return;

    final oldest = messages.last;
    state = state.copyWith(isLoadingOlder: true, clearError: true);
    try {
      final older = await ref.read(loadOlderMessagesUseCaseProvider)(
        roomCode: args.roomCode,
        before: oldest,
      );
      state = state.copyWith(
        olderMessages: [...state.olderMessages, ...older],
        isLoadingOlder: false,
        hasMore: older.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingOlder: false,
        error: e.toString(),
      );
    }
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.isSending) return;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      await ref.read(sendMessageUseCaseProvider)(
        roomCode: args.roomCode,
        text: text,
        identity: args.identity,
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}

final chatControllerProvider =
    NotifierProvider.family<ChatController, ChatUiState, ChatArgs>(
  ChatController.new,
);
