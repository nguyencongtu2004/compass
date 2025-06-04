
*Sử dụng Flutter + Firebase, định tuyến bằng `go_router`, quản lý state với BLoC (flutter_bloc)*

---

## MỤC LỤC

1. [Giới thiệu chung & Mục tiêu](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#1-gi%E1%BB%9Bi-thi%E1%BB%87u-chung--m%E1%BB%A5c-ti%C3%AAu)
2. [Kiến trúc tổng quan & Công nghệ](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#2-ki%E1%BA%BFn-tr%C3%BAc-t%E1%BB%95ng-quan--c%C3%B4ng-ngh%E1%BB%87)
3. [Firebase – TODO Setup](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#3-firebase--todo-setup)
4. [Kiểu dữ liệu Firestore (Schema)](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#4-ki%E1%BB%83u-d%E1%BB%AF-li%E1%BB%87u-firestore-schema)
5. [Security Rules (Firestore)](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#5-security-rules-firestore)
6. [Cấu trúc dự án Flutter](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#6-c%E1%BA%A5u-tr%C3%BAc-d%E1%BB%B1-%C3%A1n-flutter)
7. [Định tuyến với go_router](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#7-%C4%91%E1%BB%8Bnh-tuy%E1%BA%BFn-v%E1%BB%9Bi-go_router)
8. [Thiết kế BLoC & Repository](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#8-thi%E1%BA%BFt-k%E1%BA%BF-bloc--repository)
    1. [AuthBloc & AuthRepository](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#81-authbloc--authrepository)
    2. [FriendBloc & FriendRepository](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#82-friendbloc--friendrepository)
    3. [LocationBloc & LocationRepository](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#83-locationbloc--locationrepository)
9. [Mô tả chi tiết các màn hình (Screens)](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#9-m%C3%B4-t%E1%BA%A3-chi-ti%E1%BA%BFt-c%C3%A1c-m%C3%A0n-h%C3%ACnh-screens)
    1. [LoginPage](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#91-loginpage)
    2. [RegisterPage](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#92-registerpage)
    3. [HomePage](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#93-homepage)
    4. [FriendListPage](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#94-friendlistpage)
    5. [FriendRequestPage](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#95-friendrequestpage)
    6. [CompassPage](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#96-compasspage)
    7. [ProfilePage (tuỳ chọn)](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#97-profilepage-tu%E1%BB%B3-ch%E1%BB%8Dn)
10. [Các bước triển khai chính (Checklist)](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#10-c%C3%A1c-b%C6%B0%E1%BB%9Bc-tri%E1%BB%83n-khai-ch%C3%ADnh-checklist)
11. [Kiểm thử (Testing)](https://chatgpt.com/c/683fbcdf-df24-8002-869e-fd23e578a745#11-ki%E1%BB%83m-th%E1%BB%AD-testing)

---

## 1. Giới thiệu chung & Mục tiêu

**CompassFriend** là một ứng dụng di động Flutter cho phép người dùng:

- Đăng ký/Đăng nhập (Firebase Authentication).
- Kết bạn: gửi yêu cầu, chấp nhận, từ chối.
- Cập nhật và đồng bộ vị trí hiện tại lên Firestore.
- Xem la bàn (Compass) để kim la bàn chỉ về:
    - Vị trí cố định do người dùng nhập (Fixed Mode).
    - Vị trí real-time của bạn bè đã chấp nhận (Friend Mode).

Tài liệu này hướng dẫn **đội code** (có thể bao gồm AI code) triển khai phần **Flutter + BLoC + go_router**. Mọi phần hướng dẫn trực tiếp cấu hình Firebase sẽ được giữ ở dạng **TODO**.

### Mục tiêu chính

1. **Quản lý Authentication** bằng BLoC → AuthBloc.
2. **Quản lý danh sách bạn bè** + friend requests → FriendBloc.
3. **Quản lý vị trí** (cập nhật & lắng nghe) → LocationBloc.
4. **Định tuyến** toàn bộ màn hình bằng `go_router`.
5. **Kết nối với Firestore** để lưu trữ và đọc dữ liệu user.
6. **Tích hợp cảm biến la bàn** (flutter_compass) và phép tính bearing (LocationUtils).

---

## 2. Kiến trúc tổng quan & Công nghệ

```
┌────────────────────────────────────────┐
│         Firebase Backend              │
│ ┌────────────┐  ┌───────────────────┐  │
│ │ Authentication │  │  Cloud Firestore  │ │
│ └────────────┘  └───────────────────┘  │
└───────────▲────────────────────────────┘
            │
            │  (1) Auth / (2) CRUD Users / (3) Realtime Listeners
            │
┌────────────────────────────────────────┐
│         Flutter Frontend              │
│ ┌───────────┐  ┌──────────┐  ┌────────┐│
│ │ go_router │  │  BLoC    │  │  UI    ││
│ └───────────┘  └──────────┘  └────────┘│
└────────────────────────────────────────┘

```

- **Frontend**: Flutter
    - **go_router**: quản lý hoàn toàn routing.
    - **flutter_bloc**: quản lý state (AuthBloc, FriendBloc, LocationBloc).
    - **flutter_compass** + **geolocator**: lấy hướng thiết bị & vị trí.
- **Backend**: Firebase
    - **Firebase Auth**: xử lý đăng ký/đăng nhập.
    - **Cloud Firestore**: lưu trữ collection `users`.
    - **Security Rules**: kiểm soát quyền truy cập dữ liệu.

### Công nghệ chính

- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- `go_router: ^6.0.0`
- `flutter_bloc: ^8.1.0`
- `geolocator: ^9.0.2`
- `flutter_compass: ^0.8.0`
- `firebase_auth: ^4.6.0`
- `cloud_firestore: ^4.8.0`

---

## 3. Firebase – TODO Setup

> TODO: Các bước thiết lập Firebase (Auth, Firestore, Rules, google-services.json, GoogleService-Info.plist)
> 
> - Tạo project Firebase.
> - Bật Email/Password Authentication.
> - Tạo Firestore database.
> - Triển khai Security Rules.
> - Cấu hình FlutterFire CLI.
> - Thêm `firebase_options.dart` vào project.

*(Đội dev có thể tham khảo tài liệu cũ hoặc nhân sự phụ trách để hoàn thiện bước này.)*

---

## 4. Kiểu dữ liệu Firestore (Schema)

Chỉ sử dụng một collection duy nhất: `users`. Mỗi document có ID bằng `uid` do Firebase Auth cấp.

```
Collection: users
 └── Document: {uid}
       ├── displayName       : String
       ├── email             : String
       ├── avatarUrl         : String (URL avatar, có thể để trống "")
       ├── createdAt         : Timestamp
       ├── currentLocation   : Map (nullable) {
       │      latitude       : Double,
       │      longitude      : Double,
       │      updatedAt      : Timestamp
       │   }
       ├── friends           : Array<String>   // [uid_friend1, uid_friend2, …]
       └── friendRequests    : Array<String>   // [uid_requester1, …]

```

- `displayName`: Tên hiển thị của user.
- `email`: Email đăng ký (đồng nhất với Firebase Auth).
- `avatarUrl`: Link ảnh đại diện (nếu dùng).
- `createdAt`: Timestamp tạo hồ sơ.
- `currentLocation`:
    - `latitude`, `longitude`: tọa độ thiết bị.
    - `updatedAt`: Timestamp lần cập nhật cuối.
- `friends`: Mảng chứa UID các user đã chấp nhận (state “accepted”).
- `friendRequests`: Mảng chứa UID các user đang chờ “pending” (đã gửi request nhưng chưa được chấp nhận/từ chối).

---

## 5. Security Rules (Firestore)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Chỉ áp dụng cho collection 'users'
    match /users/{userId} {
      allow read: if isAuthorizedToRead(userId);
      allow write: if isAuthorizedToWrite(userId) || canAddFriendRequest(userId);
    }

    // Hàm kiểm tra quyền đọc document users/{userId}
    function isAuthorizedToRead(userId) {
      return request.auth != null
             && (
                // User đang đọc chính tài liệu của họ
                request.auth.uid == userId
                // Hoặc đã là bạn bè (uid requester nằm trong 'friends' của userId)
                || request.auth.uid in get(/databases/$(database)/documents/users/$(userId)).data.friends
             );
    }

    // Hàm kiểm tra quyền ghi document users/{userId}
    function isAuthorizedToWrite(userId) {
      // Chỉ user chính chủ mới được ghi (update profile, location, friends)
      return request.auth != null && request.auth.uid == userId;
    }

    // Hàm cho phép user A thêm request vào mảng friendRequests của user B
    function canAddFriendRequest(userId) {
      return request.auth != null
             && request.auth.uid != userId
             // Chỉ được cập nhật riêng mảng 'friendRequests'
             && request.resource.data.keys().hasOnly(['friendRequests'])
             // UID requester (current user) phải có trong mảng gửi lên
             && request.auth.uid in request.resource.data.friendRequests;
    }
  }
}

```

- **Giải thích**:
    - `allow read`: user chỉ được đọc hồ sơ của chính họ hoặc hồ sơ của bạn bè.
    - `allow write`: user chính chủ có thể ghi lên document của họ (cập nhật location, friends).
    - `canAddFriendRequest`: cho phép user khác (không phải chính chủ) update duy nhất mảng `friendRequests` bằng cách thêm chính UID của họ.

---

## 6. Cấu trúc dự án Flutter

```
lib/
├── main.dart
├── firebase_options.dart         # (TODO: do flutterfire generate)
├── constants/
│   └── app_constants.dart        # Các hằng số (route names, color, text style)
├── models/
│   ├── user_model.dart           # UserModel, LocationModel
│   └── location_model.dart
├── repositories/
│   ├── auth_repository.dart      # Kết nối FirebaseAuth + Firestore người dùng
│   ├── friend_repository.dart    # CRUD friends, friendRequests
│   └── location_repository.dart  # Cập nhật & lắng nghe vị trí
├── blocs/
│   ├── auth/
│   │   ├── auth_bloc.dart        # AuthBloc, AuthState, AuthEvent
│   │   └── auth_repository.dart  # Implementation (liên kết AuthService)
│   ├── friend/
│   │   ├── friend_bloc.dart      # FriendBloc, FriendState, FriendEvent
│   │   └── friend_repository.dart
│   └── location/
│       ├── location_bloc.dart    # LocationBloc, LocationState, LocationEvent
│       └── location_repository.dart
├── services/
│   └── firebase_service.dart     # (TODO: Khởi tạo FirebaseApp nếu cần)
├── utils/
│   └── location_utils.dart       # Tính bearing giữa 2 tọa độ
├── router/
│   └── app_router.dart           # Cấu hình go_router
├── screens/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── friend/
│   │   ├── friend_list_page.dart
│   │   └── friend_request_page.dart
│   ├── compass/
│   │   └── compass_page.dart
│   └── profile/
│       └── profile_page.dart     # (tuỳ chọn)
├── widgets/
│   ├── custom_button.dart
│   ├── custom_textfield.dart
│   └── loading_indicator.dart
└── pubspec.yaml

```

- **main.dart**: khởi tạo `Firebase.initializeApp()`, cung cấp MultiBlocProvider và khởi chạy `GoRouter`.
- **firebase_options.dart**: file do FlutterFire CLI sinh ra (TODO).
- **constants/app_constants.dart**: chứa route names, primaryColor, textStyle chung.
- **models/**: định nghĩa `UserModel` và `LocationModel`.
- **repositories/**: implement các API gọi Firebase.
- **blocs/**: chứa các BLoC (AuthBloc, FriendBloc, LocationBloc).
- **services/firebase_service.dart**: (tuỳ chọn) khởi tạo FirebaseApp, có thể để trống.
- **utils/location_utils.dart**: hàm tính bearing.
- **router/app_router.dart**: tập trung cấu hình `GoRouter`.
- **screens/**: chứa từng màn hình (login, register, home, friend list, friend request, compass, profile).
- **widgets/**: các widget con dùng lại (CustomButton, CustomTextField, LoadingIndicator).

---

## 7. Định tuyến với go_router

### 7.1 Cài đặt

```yaml
dependencies:
  go_router: ^6.0.0
  flutter_bloc: ^8.1.0
  # ... các dependency khác

```

### 7.2 Định nghĩa `app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/home/home_page.dart';
import '../screens/friend/friend_list_page.dart';
import '../screens/friend/friend_request_page.dart';
import '../screens/compass/compass_page.dart';
import '../screens/profile/profile_page.dart';
import '../blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final isLoggedIn = authBloc.state is AuthAuthenticated;
        final goingToLogin = state.subloc == '/login' || state.subloc == '/register';
        if (!isLoggedIn && !goingToLogin) {
          return '/login';
        }
        if (isLoggedIn && goingToLogin) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'friend_list',
              builder: (context, state) => const FriendListPage(),
            ),
            GoRoute(
              path: 'friend_requests',
              builder: (context, state) => const FriendRequestPage(),
            ),
            GoRoute(
              path: 'compass',
              // Mong muốn truyền tham số targetLat, targetLng qua state.queryParams
              builder: (context, state) {
                final lat = double.tryParse(state.queryParams['lat'] ?? '');
                final lng = double.tryParse(state.queryParams['lng'] ?? '');
                if (lat == null || lng == null) {
                  return const Scaffold(
                    body: Center(child: Text('Thiếu tham số tọa độ')),
                  );
                }
                return CompassPage(targetLat: lat, targetLng: lng);
              },
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    );
  }
}

```

- **Giải thích**:
    - `refreshListenable`: lắng nghe `authBloc.stream` để tự động redirect khi state AuthBloc thay đổi (đăng nhập/đăng xuất).
    - `redirect`:
        - Nếu chưa đăng nhập và không phải đang đi đến `/login` hoặc `/register` → redirect về `/login`.
        - Nếu đã đăng nhập và đang ở `/login` hoặc `/register` → redirect về `/home`.
    - Các route phụ của `/home`:
        - `/home/friend_list` → FriendListPage
        - `/home/friend_requests` → FriendRequestPage
        - `/home/compass?lat=...&lng=...` → CompassPage
        - `/home/profile` → ProfilePage

### 7.3 Sử dụng trong `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'router/app_router.dart';
import 'services/firebase_service.dart'; // TODO: khởi tạo Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: await Firebase.initializeApp();
  final authBloc = AuthBloc(); // Khởi tạo AuthBloc
  runApp(
    MyApp(authBloc: authBloc),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'CompassFriend',
        routerConfig: AppRouter.router(authBloc),
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }
}

```

---

## 8. Thiết kế BLoC & Repository

### 8.1 AuthBloc & AuthRepository

### 8.1.1 `repositories/auth_repository.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Đăng ký mới
  Future<User?> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      // Tạo document user trong Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'email': email,
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'currentLocation': null,
        'friends': <String>[],
        'friendRequests': <String>[],
      });
    }
    return user;
  }

  /// Đăng nhập
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Stream lắng nghe AuthStateChanges
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// Lấy user hiện tại
  User? get currentUser => _firebaseAuth.currentUser;
}

```

### 8.1.2 `blocs/auth/auth_bloc.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// AuthEvent
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {}

/// AuthState
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// AuthBloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final Stream<User?> _authStateChanges;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial()) {
    _authStateChanges = _authRepository.user;
    // Khi bắt đầu, lắng nghe stream user
    _authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });

    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  /// Các hàm gọi login/register
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authRepository.login(email: email, password: password);
      // Khi login thành công, AuthStateChanges sẽ phát ra Authenticated
    } on FirebaseAuthException catch (e) {
      addError(e.message ?? 'Lỗi đăng nhập');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      // Khi register thành công, user cũng tự động được login
    } on FirebaseAuthException catch (e) {
      addError(e.message ?? 'Lỗi đăng ký');
    }
  }
}

```

`auth_event.dart`:

```dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {}

```

`auth_state.dart`:

```dart
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

```

---

### 8.2 FriendBloc & FriendRepository

### 8.2.1 `repositories/friend_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FriendRepository {
  final FirebaseFirestore _firestore;

  FriendRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách friend UIDs của user
  Future<List<String>> getFriendUids(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    return List<String>.from(data['friends'] as List<dynamic>? ?? []);
  }

  /// Lấy danh sách incoming friend requests UIDs của user
  Future<List<String>> getIncomingRequests(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    return List<String>.from(data['friendRequests'] as List<dynamic>? ?? []);
  }

  /// Lấy chi tiết UserModel theo list UIDs
  Future<List<UserModel>> getUsersByUids(List<String> uids) async {
    if (uids.isEmpty) return [];
    final snapshots = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    return snapshots.docs.map((doc) => UserModel.fromDocument(doc)).toList();
  }

  /// Gửi friend request (A -> B)
  Future<void> sendFriendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    await _firestore.collection('users').doc(toUid).update({
      'friendRequests': FieldValue.arrayUnion([fromUid]),
    });
  }

  /// Chấp nhận friend request (B chấp nhận A)
  Future<void> acceptFriendRequest({
    required String myUid,
    required String requesterUid,
  }) async {
    final myRef = _firestore.collection('users').doc(myUid);
    final reqRef = _firestore.collection('users').doc(requesterUid);

    await _firestore.runTransaction((tx) async {
      // Lấy snapshot B
      final mySnap = await tx.get(myRef);
      if (!mySnap.exists) throw Exception('User không tồn tại');
      tx.update(myRef, {
        'friendRequests': FieldValue.arrayRemove([requesterUid]),
        'friends': FieldValue.arrayUnion([requesterUid]),
      });
      // Lấy snapshot A
      final reqSnap = await tx.get(reqRef);
      if (!reqSnap.exists) throw Exception('User yêu cầu không tồn tại');
      tx.update(reqRef, {
        'friends': FieldValue.arrayUnion([myUid]),
      });
    });
  }

  /// Từ chối friend request (B từ chối A)
  Future<void> declineFriendRequest({
    required String myUid,
    required String requesterUid,
  }) async {
    final myRef = _firestore.collection('users').doc(myUid);
    await myRef.update({
      'friendRequests': FieldValue.arrayRemove([requesterUid]),
    });
  }
}

```

### 8.2.2 `blocs/friend/friend_bloc.dart`

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';
import '../../repositories/friend_repository.dart';

part 'friend_event.dart';
part 'friend_state.dart';

/// FriendEvent
abstract class FriendEvent extends Equatable {
  const FriendEvent();
  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendEvent {
  final String myUid;
  const LoadFriends(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class LoadFriendRequests extends FriendEvent {
  final String myUid;
  const LoadFriendRequests(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class SendFriendRequest extends FriendEvent {
  final String fromUid;
  final String toUid;
  const SendFriendRequest({required this.fromUid, required this.toUid});
  @override
  List<Object?> get props => [fromUid, toUid];
}

class AcceptFriendRequest extends FriendEvent {
  final String myUid;
  final String requesterUid;
  const AcceptFriendRequest({required this.myUid, required this.requesterUid});
  @override
  List<Object?> get props => [myUid, requesterUid];
}

class DeclineFriendRequest extends FriendEvent {
  final String myUid;
  final String requesterUid;
  const DeclineFriendRequest({required this.myUid, required this.requesterUid});
  @override
  List<Object?> get props => [myUid, requesterUid];
}

/// FriendState
abstract class FriendState extends Equatable {
  const FriendState();
  @override
  List<Object?> get props => [];
}

class FriendInitial extends FriendState {}

class FriendLoadInProgress extends FriendState {}

class FriendLoadSuccess extends FriendState {
  final List<UserModel> friends;
  const FriendLoadSuccess(this.friends);
  @override
  List<Object?> get props => [friends];
}

class FriendRequestLoadSuccess extends FriendState {
  final List<UserModel> requests;
  const FriendRequestLoadSuccess(this.requests);
  @override
  List<Object?> get props => [requests];
}

class FriendOperationFailure extends FriendState {
  final String message;
  const FriendOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// FriendBloc
class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final FriendRepository _friendRepo;

  FriendBloc({FriendRepository? friendRepository})
      : _friendRepo = friendRepository ?? FriendRepository(),
        super(FriendInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<DeclineFriendRequest>(_onDeclineFriendRequest);
  }

  Future<void> _onLoadFriends(
      LoadFriends event, Emitter<FriendState> emit) async {
    emit(FriendLoadInProgress());
    try {
      final uids = await _friendRepo.getFriendUids(event.myUid);
      final users = await _friendRepo.getUsersByUids(uids);
      emit(FriendLoadSuccess(users));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  Future<void> _onLoadFriendRequests(
      LoadFriendRequests event, Emitter<FriendState> emit) async {
    emit(FriendLoadInProgress());
    try {
      final uids = await _friendRepo.getIncomingRequests(event.myUid);
      final users = await _friendRepo.getUsersByUids(uids);
      emit(FriendRequestLoadSuccess(users));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  Future<void> _onSendFriendRequest(
      SendFriendRequest event, Emitter<FriendState> emit) async {
    try {
      await _friendRepo.sendFriendRequest(
        fromUid: event.fromUid,
        toUid: event.toUid,
      );
      // Có thể reload requests hoặc cư xử phù hợp
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  Future<void> _onAcceptFriendRequest(
      AcceptFriendRequest event, Emitter<FriendState> emit) async {
    try {
      await _friendRepo.acceptFriendRequest(
        myUid: event.myUid,
        requesterUid: event.requesterUid,
      );
      // Reload danh sách sau khi accept
      add(LoadFriends(event.myUid));
      add(LoadFriendRequests(event.myUid));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeclineFriendRequest(
      DeclineFriendRequest event, Emitter<FriendState> emit) async {
    try {
      await _friendRepo.declineFriendRequest(
        myUid: event.myUid,
        requesterUid: event.requesterUid,
      );
      // Chỉ reload friendRequests
      add(LoadFriendRequests(event.myUid));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }
}

```

`friend_event.dart`:

```dart
part of 'friend_bloc.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();
  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendEvent {
  final String myUid;
  const LoadFriends(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class LoadFriendRequests extends FriendEvent {
  final String myUid;
  const LoadFriendRequests(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class SendFriendRequest extends FriendEvent {
  final String fromUid;
  final String toUid;
  const SendFriendRequest({required this.fromUid, required this.toUid});
  @override
  List<Object?> get props => [fromUid, toUid];
}

class AcceptFriendRequest extends FriendEvent {
  final String myUid;
  final String requesterUid;
  const AcceptFriendRequest({required this.myUid, required this.requesterUid});
  @override
  List<Object?> get props => [myUid, requesterUid];
}

class DeclineFriendRequest extends FriendEvent {
  final String myUid;
  final String requesterUid;
  const DeclineFriendRequest({required this.myUid, required this.requesterUid});
  @override
  List<Object?> get props => [myUid, requesterUid];
}

```

`friend_state.dart`:

```dart
part of 'friend_bloc.dart';

abstract class FriendState extends Equatable {
  const FriendState();
  @override
  List<Object?> get props => [];
}

class FriendInitial extends FriendState {}

class FriendLoadInProgress extends FriendState {}

class FriendLoadSuccess extends FriendState {
  final List<UserModel> friends;
  const FriendLoadSuccess(this.friends);
  @override
  List<Object?> get props => [friends];
}

class FriendRequestLoadSuccess extends FriendState {
  final List<UserModel> requests;
  const FriendRequestLoadSuccess(this.requests);
  @override
  List<Object?> get props => [requests];
}

class FriendOperationFailure extends FriendState {
  final String message;
  const FriendOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

```

---

### 8.3 LocationBloc & LocationRepository

### 8.3.1 `repositories/location_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationRepository {
  final FirebaseFirestore _firestore;

  LocationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cập nhật vị trí của user (get vị trí hiện tại rồi ghi vào Firestore)
  Future<LocationModel> updateMyLocation(String uid) async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final data = {
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('users').doc(uid).update({
      'currentLocation': data,
    });
    return LocationModel(
      latitude: pos.latitude,
      longitude: pos.longitude,
      updatedAt: DateTime.now(),
    );
  }

  /// Lắng nghe stream vị trí của friend
  Stream<LocationModel?> friendLocationStream(String friendUid) {
    return _firestore
        .collection('users')
        .doc(friendUid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data()?['currentLocation'];
      if (data != null) {
        return LocationModel.fromMap(data as Map<String, dynamic>);
      }
      return null;
    });
  }
}

```

### 8.3.2 `blocs/location/location_bloc.dart`

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/location_model.dart';
import '../../repositories/location_repository.dart';

part 'location_event.dart';
part 'location_state.dart';

/// LocationEvent
abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

class UpdateMyLocation extends LocationEvent {
  final String myUid;
  const UpdateMyLocation(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class SubscribeFriendLocation extends LocationEvent {
  final String friendUid;
  const SubscribeFriendLocation(this.friendUid);
  @override
  List<Object?> get props => [friendUid];
}

class UnsubscribeFriendLocation extends LocationEvent {}

/// LocationState
abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoadInProgress extends LocationState {}

class LocationUpdateSuccess extends LocationState {
  final LocationModel myLocation;
  const LocationUpdateSuccess(this.myLocation);
  @override
  List<Object?> get props => [myLocation];
}

class FriendLocationUpdate extends LocationState {
  final LocationModel friendLocation;
  const FriendLocationUpdate(this.friendLocation);
  @override
  List<Object?> get props => [friendLocation];
}

class LocationOperationFailure extends LocationState {
  final String message;
  const LocationOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/// LocationBloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepo;
  StreamSubscription<LocationModel?>? _friendSub;

  LocationBloc({LocationRepository? locationRepository})
      : _locationRepo = locationRepository ?? LocationRepository(),
        super(LocationInitial()) {
    on<UpdateMyLocation>(_onUpdateMyLocation);
    on<SubscribeFriendLocation>(_onSubscribeFriendLocation);
    on<UnsubscribeFriendLocation>(_onUnsubscribeFriendLocation);
  }

  Future<void> _onUpdateMyLocation(
      UpdateMyLocation event, Emitter<LocationState> emit) async {
    emit(LocationLoadInProgress());
    try {
      final loc = await _locationRepo.updateMyLocation(event.myUid);
      emit(LocationUpdateSuccess(loc));
    } catch (e) {
      emit(LocationOperationFailure(e.toString()));
    }
  }

  void _onSubscribeFriendLocation(
      SubscribeFriendLocation event, Emitter<LocationState> emit) {
    _friendSub?.cancel();
    _friendSub = _locationRepo
        .friendLocationStream(event.friendUid)
        .listen((loc) {
      if (loc != null) {
        add(_FriendLocationUpdated(loc));
      }
    });
  }

  void _onUnsubscribeFriendLocation(
      UnsubscribeFriendLocation event, Emitter<LocationState> emit) {
    _friendSub?.cancel();
  }

  @override
  Future<void> close() {
    _friendSub?.cancel();
    return super.close();
  }
}

// Sự kiện nội bộ để cập nhật Location state
class _FriendLocationUpdated extends LocationEvent {
  final LocationModel loc;
  const _FriendLocationUpdated(this.loc);
  @override
  List<Object?> get props => [loc];
}

// Xử lý sự kiện nội bộ
extension on LocationBloc {
  void _onFriendLocationUpdated(
      _FriendLocationUpdated event, Emitter<LocationState> emit) {
    emit(FriendLocationUpdate(event.loc));
  }
}

```

`location_event.dart`:

```dart
part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

class UpdateMyLocation extends LocationEvent {
  final String myUid;
  const UpdateMyLocation(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class SubscribeFriendLocation extends LocationEvent {
  final String friendUid;
  const SubscribeFriendLocation(this.friendUid);
  @override
  List<Object?> get props => [friendUid];
}

class UnsubscribeFriendLocation extends LocationEvent {}

```

`location_state.dart`:

```dart
part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoadInProgress extends LocationState {}

class LocationUpdateSuccess extends LocationState {
  final LocationModel myLocation;
  const LocationUpdateSuccess(this.myLocation);
  @override
  List<Object?> get props => [myLocation];
}

class FriendLocationUpdate extends LocationState {
  final LocationModel friendLocation;
  const FriendLocationUpdate(this.friendLocation);
  @override
  List<Object?> get props => [friendLocation];
}

class LocationOperationFailure extends LocationState {
  final String message;
  const LocationOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

```

---

## 9. Mô tả chi tiết các màn hình (Screens)

### 9.1 LoginPage

**File**: `screens/auth/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../constants/app_constants.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final authBloc = context.read<AuthBloc>();
    try {
      await authBloc.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      // Nếu successful, AuthBloc sẽ emit Authenticated → go_router redirect tự động
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Đăng nhập')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CompassFriend',
                    style: AppConstants.headingStyle,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v != null && v.contains('@') ? null : 'Email không hợp lệ',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        v != null && v.length >= 6 ? null : 'Mật khẩu ít nhất 6 ký tự',
                  ),
                  const SizedBox(height: 24),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: AppConstants.primaryColor,
                          ),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.go(AppConstants.registerRoute);
                    },
                    child: const Text('Chưa có tài khoản? Đăng ký'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

**Chức năng**:

- Dùng `Form` + `TextFormField` để kiểm tra email, password.
- Khi bấm “Đăng nhập”, gọi `authBloc.login(...)`.
- Nếu có lỗi, hiển thị `SnackBar`.
- Sau khi login thành công, `GoRouter` tự redirect sang `/home`.

---

### 9.2 RegisterPage

**File**: `screens/auth/register_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../constants/app_constants.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final authBloc = context.read<AuthBloc>();
    try {
      await authBloc.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        displayName: _displayNameCtrl.text.trim(),
      );
      // Nếu thành công, AuthBloc emit Authenticated → go_router redirect
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Đăng ký')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tạo tài khoản',
                    style: AppConstants.headingStyle,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _displayNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên hiển thị',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Không được bỏ trống',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v != null && v.contains('@') ? null : 'Email không hợp lệ',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        v != null && v.length >= 6 ? null : 'Mật khẩu ít nhất 6 ký tự',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (v) => v == _passwordCtrl.text
                        ? null
                        : 'Mật khẩu xác nhận không khớp',
                  ),
                  const SizedBox(height: 24),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _onRegisterPressed,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: AppConstants.primaryColor,
                          ),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.go(AppConstants.loginRoute);
                    },
                    child: const Text('Đã có tài khoản? Đăng nhập'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

**Chức năng**:

- Form gồm: displayName, email, password, confirm password.
- Khi bấm “Đăng ký”, gọi `authBloc.register(...)`.
- Sau khi thành công, AuthBloc đổi state → go_router chuyển về `/home`.

---

### 9.3 HomePage

**File**: `screens/home/home_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';
import '../../blocs/location/location_bloc.dart';
import '../../constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../utils/location_utils.dart';

enum CompassMode { fixed, friend }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CompassMode _selectedMode = CompassMode.fixed;
  double? _fixedLat;
  double? _fixedLng;
  String? _selectedFriendUid;
  String? _selectedFriendName;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final myUid = authState.user.uid;
      context.read<FriendBloc>().add(LoadFriends(myUid));
      context.read<FriendBloc>().add(LoadFriendRequests(myUid));
    }
  }

  Future<void> _inputFixedLocation() async {
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhập tọa độ cố định'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latCtrl,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: lngCtrl,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latCtrl.text);
                final lng = double.tryParse(lngCtrl.text);
                if (lat == null || lng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tọa độ không hợp lệ')));
                  return;
                }
                setState(() {
                  _fixedLat = lat;
                  _fixedLng = lng;
                });
                Navigator.of(context).pop(true);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      // Đã lưu tọa độ
    }
  }

  void _pickFriend() {
    context.push('/home/friend_list').then((res) {
      if (res is Map<String, String>) {
        setState(() {
          _selectedFriendUid = res['uid'];
          _selectedFriendName = res['name'];
        });
        // Bắt đầu lắng nghe vị trí bạn bè
        context
            .read<LocationBloc>()
            .add(SubscribeFriendLocation(_selectedFriendUid!));
      }
    });
  }

  void _updateMyLocation() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<LocationBloc>().add(UpdateMyLocation(authState.user.uid));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang cập nhật vị trí...')),
      );
    }
  }

  void _viewCompass() {
    if (_selectedMode == CompassMode.fixed) {
      if (_fixedLat == null || _fixedLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng nhập tọa độ cố định')));
        return;
      }
      context.push(
        '/home/compass?lat=${_fixedLat!}&lng=${_fixedLng!}',
      );
    } else {
      if (_selectedFriendUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chọn bạn bè')));
        return;
      }
      final locState = context.read<LocationBloc>().state;
      if (locState is FriendLocationUpdate) {
        final lat = locState.friendLocation.latitude;
        final lng = locState.friendLocation.longitude;
        context.push('/home/compass?lat=$lat&lng=$lng');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang chờ vị trí bạn bè')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final friendState = context.watch<FriendBloc>().state;
    final locState = context.watch<LocationBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CompassFriend'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => context.push('/home/friend_requests'),
            tooltip: 'Lời mời kết bạn',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/home/profile'),
            tooltip: 'Hồ sơ',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Chọn chế độ
            RadioListTile<CompassMode>(
              title: const Text('Chế độ: Vị trí cố định'),
              value: CompassMode.fixed,
              groupValue: _selectedMode,
              onChanged: (val) {
                setState(() {
                  _selectedMode = val!;
                  // Huỷ lắng nghe bạn bè khi chuyển mode
                  context.read<LocationBloc>().add(UnsubscribeFriendLocation());
                  _selectedFriendUid = null;
                  _selectedFriendName = null;
                });
              },
            ),
            if (_selectedMode == CompassMode.fixed)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fixedLat != null && _fixedLng != null
                          ? '$_fixedLat, $_fixedLng'
                          : 'Chưa đặt tọa độ',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _inputFixedLocation,
                    child: const Text('Nhập'),
                  ),
                ],
              ),
            const Divider(),
            RadioListTile<CompassMode>(
              title: const Text('Chế độ: Theo dõi bạn bè'),
              value: CompassMode.friend,
              groupValue: _selectedMode,
              onChanged: (val) {
                setState(() {
                  _selectedMode = val!;
                });
              },
            ),
            if (_selectedMode == CompassMode.friend)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFriendName != null
                        ? 'Bạn: $_selectedFriendName'
                        : 'Chưa chọn bạn',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickFriend,
                    child: const Text('Chọn bạn'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Nút cập nhật vị trí của tôi
            ElevatedButton.icon(
              onPressed: _updateMyLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Cập nhật vị trí của tôi'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            // Nút xem la bàn
            ElevatedButton(
              onPressed: _viewCompass,
              child: const Text('Xem la bàn'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            // Danh sách bạn bè
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh sách bạn bè:',
                    style: AppConstants.labelStyle,
                  ),
                  const SizedBox(height: 8),
                  if (friendState is FriendLoadInProgress)
                    const Center(child: CircularProgressIndicator())
                  else if (friendState is FriendLoadSuccess)
                    Expanded(
                      child: ListView.builder(
                        itemCount: friendState.friends.length,
                        itemBuilder: (context, index) {
                          final u = friendState.friends[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: u.avatarUrl.isNotEmpty
                                  ? NetworkImage(u.avatarUrl)
                                  : null,
                              child: u.avatarUrl.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(u.displayName),
                            subtitle: Text(u.email),
                          );
                        },
                      ),
                    )
                  else
                    const Text('Bạn chưa có bạn bè nào'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

**Giải thích chi tiết**:

- Sử dụng `RadioListTile` để chọn chế độ (`fixed` hoặc `friend`).
- Khi đổi mode, nếu từ “friend” → “fixed”, **hủy lắng nghe** vị trí friend (gửi event `UnsubscribeFriendLocation`).
- Phần nhập tọa độ cố định mở Dialog, lưu vào `_fixedLat`, `_fixedLng`.
- Phần chọn bạn → điều hướng `/home/friend_list`, khi pop ra sẽ trả về `Map<String,String>{ 'uid': ..., 'name': ... }`. Sau đó, gọi `SubscribeFriendLocation`.
- Gọi `LocationBloc.updateMyLocation` để cập nhật vị trí hiện tại lên Firestore.
- Khi bấm “Xem la bàn”:
    - Nếu fixed mode: redirect `/home/compass?lat=...&lng=...`.
    - Nếu friend mode: kiểm tra xem `LocationBloc.state` có `FriendLocationUpdate` chưa, sau đó lấy tọa độ friend.

---

### 9.4 FriendListPage

**File**: `screens/friend/friend_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';
import '../../models/user_model.dart';
import 'package:go_router/go_router.dart';

class FriendListPage extends StatelessWidget {
  const FriendListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String myUid = '';
    if (authState is Authenticated) {
      myUid = authState.user.uid;
    }

    // Khi vào trang, đưa event để load friends
    context.read<FriendBloc>().add(LoadFriends(myUid));

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn bạn bè')),
      body: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          if (state is FriendLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FriendLoadSuccess) {
            final friends = state.friends;
            if (friends.isEmpty) {
              return const Center(child: Text('Bạn chưa có bạn bè'));
            }
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final u = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: u.avatarUrl.isNotEmpty
                        ? NetworkImage(u.avatarUrl)
                        : null,
                    child: u.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(u.displayName),
                  subtitle: Text(u.email),
                  onTap: () {
                    // Pop và trả về bạn được chọn
                    context.pop({'uid': u.uid, 'name': u.displayName});
                  },
                );
              },
            );
          } else if (state is FriendOperationFailure) {
            return Center(child: Text('Lỗi: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

```

**Chức năng**:

- Khi vào trang, gửi event `LoadFriends(myUid)` để BLoC lấy danh sách friend.
- Hiển thị `ListView` từ `FriendLoadSuccess`.
- Khi chọn 1 friend, `context.pop({...})` trả về map chứa `uid` và `name`.

---

### 9.5 FriendRequestPage

**File**: `screens/friend/friend_request_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';
import 'package:go_router/go_router.dart';

class FriendRequestPage extends StatelessWidget {
  const FriendRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String myUid = '';
    if (authState is Authenticated) {
      myUid = authState.user.uid;
    }

    // Load incoming requests
    context.read<FriendBloc>().add(LoadFriendRequests(myUid));

    return Scaffold(
      appBar: AppBar(title: const Text('Lời mời kết bạn')),
      body: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          if (state is FriendLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FriendRequestLoadSuccess) {
            final requests = state.requests;
            if (requests.isEmpty) {
              return const Center(child: Text('Không có lời mời'));
            }
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final u = requests[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: u.avatarUrl.isNotEmpty
                        ? NetworkImage(u.avatarUrl)
                        : null,
                    child: u.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(u.displayName),
                  subtitle: Text(u.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          context.read<FriendBloc>().add(
                                AcceptFriendRequest(
                                  myUid: myUid,
                                  requesterUid: u.uid,
                                ),
                              );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          context.read<FriendBloc>().add(
                                DeclineFriendRequest(
                                  myUid: myUid,
                                  requesterUid: u.uid,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is FriendOperationFailure) {
            return Center(child: Text('Lỗi: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

```

**Chức năng**:

- Gửi event `LoadFriendRequests(myUid)` ngay khi build.
- Khi `FriendRequestLoadSuccess`, hiển thị danh sách request.
- “Chấp nhận” → gửi event `AcceptFriendRequest`.
- “Từ chối” → gửi event `DeclineFriendRequest`.
- BLoC sẽ tự reload danh sách sau khi hành động.

---

### 9.6 CompassPage

**File**: `screens/compass/compass_page.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../blocs/location/location_bloc.dart';
import '../../constants/app_constants.dart';
import '../../utils/location_utils.dart';

class CompassPage extends StatefulWidget {
  final double targetLat;
  final double targetLng;
  const CompassPage({
    super.key,
    required this.targetLat,
    required this.targetLng,
  });
  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double _deviceHeading = 0;
  Position? _currentPosition;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe heading
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        setState(() => _deviceHeading = event.heading!);
      }
    });
    _updateAndUploadLocation();
  }

  Future<void> _updateAndUploadLocation() async {
    setState(() => _isUpdating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = pos);
      // Gọi BLoC để update Firestore
      final authBloc = context.read<AuthBloc>();
      if (authBloc.state is Authenticated) {
        final uid = (authBloc.state as Authenticated).user.uid;
        context.read<LocationBloc>().add(UpdateMyLocation(uid));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lấy vị trí')));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final bearing = LocationUtils.calculateBearing(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.targetLat,
      widget.targetLng,
    );
    final angle = ((bearing - _deviceHeading) * (pi / 180)) * -1;
    return Scaffold(
      appBar: AppBar(title: const Text('La bàn')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/compass.png',
              width: 300,
              height: 300,
            ),
            Transform.rotate(
              angle: angle,
              child: Image.asset(
                'assets/images/compass_needle.png',
                width: 250,
                height: 250,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateAndUploadLocation,
        child: _isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.my_location),
      ),
    );
  }
}

```

**Chức năng**:

- Lắng nghe `FlutterCompass.events` cập nhật `_deviceHeading`.
- Khi khởi động, gọi `_updateAndUploadLocation()` để:
    1. Lấy vị trí device (Geolocator).
    2. Gọi `LocationBloc(UpdateMyLocation(uid))` để update lên Firestore.
- Tính `bearing` giữa vị trí hiện tại và `(targetLat, targetLng)`.
- Tính `angle = (bearing – deviceHeading) * (π/180) * (-1)` để xoay kim.

---

### 9.7 ProfilePage (tuỳ chọn)

**File**: `screens/profile/profile_page.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../constants/app_constants.dart';
import '../services/friend_repository.dart'; // Nếu cần cập nhật profile
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _displayNameCtrl = TextEditingController();
  String _avatarUrl = '';
  bool _isLoading = false;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      // TODO: Upload lên Firebase Storage, lấy URL về
      setState(() => _avatarUrl = file.path);
    }
  }

  Future<void> _saveProfile() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    final uid = authState.user.uid;
    final newName = _displayNameCtrl.text.trim();
    if (newName.isEmpty && _avatarUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có thay đổi')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      // TODO: Cập nhật Firestore
      // final db = FirebaseFirestore.instance;
      final data = <String, dynamic>{};
      if (newName.isNotEmpty) data['displayName'] = newName;
      if (_avatarUrl.isNotEmpty) data['avatarUrl'] = _avatarUrl;
      // await db.collection('users').doc(uid).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _displayNameCtrl.text = authState.user.displayName ?? '';
      // TODO: Lấy avatarUrl từ Firestore về gán nếu có
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatarUrl.isNotEmpty
                    ? (_avatarUrl.startsWith('http')
                        ? NetworkImage(_avatarUrl)
                        : FileImage(File(_avatarUrl)) as ImageProvider)
                    : null,
                child: _avatarUrl.isEmpty
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _displayNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: AppConstants.primaryColor,
                    ),
                    child: const Text(
                      'Lưu thay đổi',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

```

**Chức năng (tuỳ chọn)**:

- Cho phép user đổi `displayName` và `avatarUrl`.
- TODO: Upload ảnh lên Firebase Storage, lấy về URL, cập nhật `users/{uid}.avatarUrl`.

---

## 10. Các bước triển khai chính (Checklist)

1. **Thiết lập Firebase (TODO)**
    - Tạo project Firebase, kích hoạt Auth + Firestore.
    - Triển khai Security Rules (đã có phần script).
    - Dùng FlutterFire CLI để tạo `firebase_options.dart`.
    - Thêm file cấu hình Android/iOS.
2. **Cài đặt dependencies**
    - `flutter pub get` với:
        
        ```
        firebase_core
        firebase_auth
        cloud_firestore
        go_router
        flutter_bloc
        equatable
        geolocator
        flutter_compass
        image_picker (nếu cần)
        
        ```
        
3. **Cấu trúc thư mục**
    - Tạo đúng thư mục: `models/`, `repositories/`, `blocs/`, `services/`, `utils/`, `router/`, `screens/`, `widgets/`.
4. **Triển khai Models**
    - `UserModel` (từ `user_model.dart`), `LocationModel` (từ `location_model.dart`).
5. **Triển khai Repositories**
    - `auth_repository.dart` (FirebaseAuth + tạo Firestore doc).
    - `friend_repository.dart` (CRUD friends, friendRequests).
    - `location_repository.dart` (cập nhật vị trí, listener friend).
6. **Triển khai BLoCs**
    - **AuthBloc** (AuthEvent, AuthState).
    - **FriendBloc** (FriendEvent, FriendState).
    - **LocationBloc** (LocationEvent, LocationState).
7. **Định tuyến**
    - Tạo `router/app_router.dart` như mẫu.
    - Sử dụng `GoRouter` trong `main.dart`.
8. **Màn hình (Screens)**
    - **LoginPage**, **RegisterPage**: form + call AuthBloc.
    - **HomePage**: lựa chọn mode, cập nhật location, xem la bàn, hiển thị danh sách bạn bè (dựa vào FriendBloc).
    - **FriendListPage**, **FriendRequestPage**: tương tác với FriendBloc.
    - **CompassPage**: lắng nghe FlutterCompass + dùng LocationBloc để update vị trí.
    - **ProfilePage (tuỳ chọn)**: cập nhật profile.
9. **Widgets dùng chung**
    - `CustomButton`, `CustomTextField`, `LoadingIndicator` để chuẩn hoá UI.
10. **Kiểm thử**
    - Manual test authentication, friend flow, location flow, compass UI.
    - Test Security Rules qua Firestore Emulator / Playground.
11. **Build & Release**
    - `flutter build apk --release`.
    - iOS: Archive & upload lên App Store.
    - Monitor usage Firestore, cài billing nếu cần.

---

## 11. Kiểm thử (Testing)

1. **Authentication**
    - Đăng ký tài khoản mới → kiểm tra Firestore có document.
    - Đăng nhập, đăng xuất → kiểm tra redirect đúng.
    - Gõ sai email/password → hiển thị lỗi.
2. **Friend Flow**
    - User A gửi request đến B → `users/{B.uid}.friendRequests` có A.uid.
    - B vào FriendRequestPage → nhận request, bấm “Chấp nhận” →
        - `users/{B.uid}.friends` có A.uid, `users/{A.uid}.friends` có B.uid.
    - Dòng “Từ chối” → `users/{B.uid}.friendRequests` remove A.uid.
3. **Cập nhật vị trí & Lắng nghe**
    - A bấm “Cập nhật vị trí của tôi” → Firestore `users/{A.uid}.currentLocation` thay đổi.
    - B (đang ở HomePage, chọn A làm friend) → `LocationBloc` nhận location của A.
    - B bấm “Xem la bàn” → kim la bàn chỉ đúng hướng.
4. **Compass UI**
    - Thử các cặp tọa độ xa/hai điểm khác vĩ độ → kim la bàn xoay đúng.
5. **Security Rules**
    - Test bằng Playground:
        - A đọc `users/{B.uid}` trước khi làm bạn → denied.
        - A cập nhật `friendRequests` trong document `users/{B.uid}` bằng cách push chính A.uid → allowed.
        - A cập nhật `friends` trong document `users/{B.uid}` → denied.
6. **Định tuyến (go_router)**
    - Khi chưa login → cố truy cập `/home` → redirect về `/login`.
    - Khi đã login → truy cập `/login` hoặc `/register` → redirect về `/home`.
    - Các route con `/home/friend_list`, `/home/friend_requests`, `/home/profile`, `/home/compass?lat=...&lng=...` đều truy cập đúng.

---

**Kết thúc tài liệu.**

Với hướng dẫn chi tiết này, đội code (hoặc AI code) có thể tự động sinh code Flutter, cấu hình BLoC, định tuyến go_router, và kết nối với Firestore một cách hệ thống. Chú ý bổ sung phần **TODO** để hoàn thiện cấu hình Firebase. Chúc các bạn thực hiện suôn sẻ!