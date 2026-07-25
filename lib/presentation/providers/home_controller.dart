import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/anonymous_identity.dart';
import '../../domain/entities/room.dart';
import 'dependency_providers.dart';

sealed class HomeUiState {
  const HomeUiState();
}

class HomeIdle extends HomeUiState {
  const HomeIdle();
}

class HomeLoading extends HomeUiState {
  const HomeLoading({required this.message});

  final String message;
}

class HomeReady extends HomeUiState {
  const HomeReady({
    required this.room,
    required this.identity,
  });

  final Room room;
  final AnonymousIdentity identity;
}

class HomeError extends HomeUiState {
  const HomeError(this.message);

  final String message;
}

class HomeController extends Notifier<HomeUiState> {
  @override
  HomeUiState build() => const HomeIdle();

  Future<HomeReady?> createRoom() async {
    state = const HomeLoading(message: 'Creating room…');
    try {
      final room = await ref.read(createRoomUseCaseProvider)(
        createdBy: const Uuid().v4(),
      );
      final identity =
          await ref.read(getOrCreateIdentityUseCaseProvider)(room.code);
      final ready = HomeReady(room: room, identity: identity);
      state = ready;
      return ready;
    } on Failure catch (e) {
      state = HomeError(e.message);
      return null;
    } catch (_) {
      state = const HomeError('Failed to create room.');
      return null;
    }
  }

  Future<HomeReady?> joinRoom(String code) async {
    state = const HomeLoading(message: 'Joining room…');
    try {
      final room = await ref.read(joinRoomUseCaseProvider)(code);
      final identity =
          await ref.read(getOrCreateIdentityUseCaseProvider)(room.code);
      final ready = HomeReady(room: room, identity: identity);
      state = ready;
      return ready;
    } on Failure catch (e) {
      state = HomeError(e.message);
      return null;
    } catch (_) {
      state = const HomeError('Failed to join room.');
      return null;
    }
  }

  void reset() => state = const HomeIdle();
}

final homeControllerProvider =
    NotifierProvider<HomeController, HomeUiState>(HomeController.new);
