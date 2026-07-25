# Rumour

Anonymous room-code chat built with Flutter and Firebase Cloud Firestore.

---

## Codebase structure

```
lib/
├── main.dart                          # Firebase init + offline persistence
├── app.dart                           # MaterialApp, Riverpod, theme
├── firebase_options.dart              # FlutterFire config
│
├── core/
│   ├── constants/                     # App-wide constants
│   ├── theme/                         # Light / dark theme
│   ├── utils/                         # Room code generate / validate
│   └── error/                         # Failure types
│
├── domain/
│   ├── entities/                      # Room, ChatMessage, AnonymousIdentity
│   ├── repositories/                  # Abstract contracts
│   └── usecases/                      # Create/join room, identity, chat
│
├── data/
│   ├── models/                        # Firestore / API mapping
│   ├── datasources/
│   │   ├── local/                     # SharedPreferences identity cache
│   │   └── remote/                    # Firestore + RandomUser API
│   └── repositories/                  # Implementations
│
└── presentation/
    ├── providers/                     # Riverpod DI + controllers
    ├── router/                        # go_router
    ├── screens/                       # home, identity, chat
    └── widgets/                       # bubbles, room code slots, etc.
```

Architecture: clean architecture (domain / data / presentation) with Riverpod for state and DI.

---

## Firebase Cloud Firestore data structure

```
rooms/{roomCode}                       // document id == room code (e.g. K7P2QM)
  code: string
  createdAt: timestamp                 // server timestamp
  createdBy: string                    // device uuid (not a login)

  messages/{messageId}                 // auto-id
    text: string
    senderId: string                   // local identity id
    senderName: string                 // e.g. "Jane Doe"
    senderHandle: string               // e.g. janedoe
    senderAvatar: string               // RandomUser picture URL
    createdAt: timestamp               // FieldValue.serverTimestamp()
    clientCreatedAt: timestamp         // local clock for ordering while server time is pending
```

## Video Link : https://drive.google.com/file/d/1ouxBh9S6KnVmyvhYUnJ6BL5wiFfZKPbZ/view?usp=sharing
## APK Link: https://drive.google.com/file/d/1g0yyK1jmmy2iDGeYJgKFiLmOOLEz6h1u/view?usp=sharing
