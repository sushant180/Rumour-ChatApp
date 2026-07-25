import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/identity_local_data_source.dart';
import '../../data/datasources/remote/firestore_remote_data_source.dart';
import '../../data/datasources/remote/random_user_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/identity_repository_impl.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/identity_repository.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../domain/usecases/create_room.dart';
import '../../domain/usecases/get_or_create_identity.dart';
import '../../domain/usecases/join_room.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final identityLocalDataSourceProvider = Provider<IdentityLocalDataSource>(
  (ref) => IdentityLocalDataSource(),
);

final randomUserRemoteDataSourceProvider = Provider<RandomUserRemoteDataSource>(
  (ref) => RandomUserRemoteDataSource(),
);

final firestoreRemoteDataSourceProvider = Provider<FirestoreRemoteDataSource>(
  (ref) => FirestoreRemoteDataSource(firestore: ref.watch(firestoreProvider)),
);

final identityRepositoryProvider = Provider<IdentityRepository>(
  (ref) => IdentityRepositoryImpl(
    local: ref.watch(identityLocalDataSourceProvider),
    remote: ref.watch(randomUserRemoteDataSourceProvider),
  ),
);

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepositoryImpl(ref.watch(firestoreRemoteDataSourceProvider)),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(ref.watch(firestoreRemoteDataSourceProvider)),
);

final getOrCreateIdentityUseCaseProvider = Provider(
  (ref) => GetOrCreateIdentityUseCase(ref.watch(identityRepositoryProvider)),
);

final createRoomUseCaseProvider = Provider(
  (ref) => CreateRoomUseCase(ref.watch(roomRepositoryProvider)),
);

final joinRoomUseCaseProvider = Provider(
  (ref) => JoinRoomUseCase(ref.watch(roomRepositoryProvider)),
);

final watchMessagesUseCaseProvider = Provider(
  (ref) => WatchMessagesUseCase(ref.watch(chatRepositoryProvider)),
);

final loadOlderMessagesUseCaseProvider = Provider(
  (ref) => LoadOlderMessagesUseCase(ref.watch(chatRepositoryProvider)),
);

final sendMessageUseCaseProvider = Provider(
  (ref) => SendMessageUseCase(ref.watch(chatRepositoryProvider)),
);
