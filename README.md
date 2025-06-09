# CompassFriend - Minecraft Compass App

🧭 Ứng dụng la bàn kết nối với bạn bè, giúp bạn định hướng đến vị trí của người thân và chia sẻ khoảnh khắc.

## 🏗️ Cấu trúc Project

### 📁 Tổ chức thư mục

```
minecraft_compass/
├── android/                     # Cấu hình Android
├── ios/                        # Cấu hình iOS
├── linux/                      # Cấu hình Linux
├── macos/                      # Cấu hình macOS
├── web/                        # Cấu hình Web
├── windows/                    # Cấu hình Windows
├── assets/                     # Tài nguyên tĩnh
│   ├── icons/                  # Biểu tượng ứng dụng
│   └── images/                 # Hình ảnh (la bàn, v.v.)
└── lib/                        # Mã nguồn chính
    ├── main.dart              # Entry point
    ├── app/                   # Cấu hình ứng dụng
    ├── config/                # Cấu hình (Cloudinary, BLoC Observer)
    ├── data/                  # Tầng dữ liệu
    │   ├── repositories/      # Repository pattern
    │   └── services/          # Dịch vụ (HTTP, Location, SharedPrefs)
    ├── models/                # Data models
    ├── presentation/          # Tầng giao diện
    │   ├── auth/             # Đăng nhập/Đăng ký
    │   ├── compass/          # La bàn
    │   ├── core/             # Theme, widgets chung
    │   ├── friend/           # Quản lý bạn bè
    │   ├── home/             # Trang chủ
    │   ├── map/              # Bản đồ
    │   ├── newfeed/          # Newsfeed/Posts
    │   ├── profile/          # Hồ sơ người dùng
    │   └── splash/           # Splash screen
    ├── router/               # Định tuyến ứng dụng
    └── utils/                # Tiện ích (validation, khởi tạo)
```

### 🔧 Công nghệ sử dụng

#### **Frontend Framework**

- **Flutter 3.8.0+**: Framework đa nền tảng
- **Dart**: Ngôn ngữ lập trình chính

#### **State Management**

- **flutter_bloc 9.0.0**: BLoC pattern cho quản lý trạng thái
- **equatable**: So sánh objects trong BLoC

#### **Backend & Database**

- **Firebase Core**: Nền tảng backend
- **Firebase Auth**: Xác thực người dùng
- **Cloud Firestore**: Database NoSQL thời gian thực
- **Firebase Analytics**: Phân tích người dùng
- **Firebase Crashlytics**: Theo dõi lỗi
- **Firebase App Check**: Bảo mật ứng dụng

#### **Navigation & Routing**

- **go_router**: Định tuyến declarative

#### **Location & Map**

- **geolocator**: Lấy vị trí GPS
- **flutter_compass**: Cảm biến la bàn
- **flutter_map**: Hiển thị bản đồ tương tác
- **latlong2**: Xử lý tọa độ địa lý
- **flutter_map_animations**: Animation cho bản đồ

#### **Media & UI**

- **image_picker**: Chọn ảnh từ gallery/camera
- **cached_network_image**: Cache ảnh từ internet
- **flutter_native_splash**: Splash screen native

#### **Network & Storage**

- **dio**: HTTP client
- **shared_preferences**: Lưu trữ local
- **crypto**: Mã hóa dữ liệu

### 🎯 Kiến trúc ứng dụng

#### **Clean Architecture Pattern**

```
┌─ Presentation Layer ─────────────────┐
│  ├── Pages (UI)                      │
│  ├── Widgets                        │
│  └── BLoC (State Management)        │
├─ Domain Layer ──────────────────────┤
│  ├── Models                         │
│  └── Use Cases (Business Logic)     │
├─ Data Layer ────────────────────────┤
│  ├── Repositories                   │
│  ├── Data Sources                   │
│  └── Services                       │
└──────────────────────────────────────┘
```

#### **BLoC State Management**

- **AuthBloc**: Quản lý xác thực người dùng
- **ProfileBloc**: Hồ sơ và thông tin cá nhân
- **FriendBloc**: Danh sách bạn bè và yêu cầu kết bạn
- **CompassBloc**: Vị trí và định hướng la bàn
- **NewsfeedBloc**: Posts và feed content

### 🔄 Luồng hoạt động chính

#### **1. Khởi động ứng dụng**

```
SplashPage → AuthBloc check → (Login|Home)
```

#### **2. Xác thực người dùng**

```
LoginPage → Firebase Auth → ProfileBloc init → HomePage
```

#### **3. Navigation Structure**

```
HomePage (PageView)
├─ ProfilePage (trái)
├─ MainContent (giữa)
│  ├─ MapPage ↕️
│  └─ NewFeedPage
└─ FriendListPage (phải)
```

#### **4. Cập nhật vị trí**

```
CompassBloc → LocationService → Firebase → FriendBloc update
```

## 🚀 Hướng dẫn phát triển

### 📋 Yêu cầu hệ thống

- **Flutter SDK**: 3.8.0 trở lên
- **Dart SDK**: 3.0.0 trở lên
- **Android Studio** / **VS Code** với Flutter extension
- **Firebase CLI** cho cấu hình Firebase
- **Git** cho version control

### 🔧 Cài đặt và chạy

#### **1. Clone repository**

```bash
git clone https://github.com/your-repo/minecraft_compass.git
cd minecraft_compass
```

#### **2. Cài đặt dependencies**

```bash
flutter pub get
```

#### **3. Cấu hình Firebase**

- Tạo project trên [Firebase Console](https://console.firebase.google.com)
- Bật các services: Authentication, Firestore, Analytics, Crashlytics
- Download và đặt file cấu hình:
  - `android/app/google-services.json` (Android)
  - `ios/Runner/GoogleService-Info.plist` (iOS)
  - `web/firebase-config.js` (Web)

#### **4. Chạy ứng dụng**

```bash
# Debug mode
flutter run

# Specific platform
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d android       # Android
```

### 🏗️ Build production

#### **Android APK**

```bash
flutter build apk --release
```

#### **Windows**

```bash
flutter build windows --release
```

#### **Web**

```bash
flutter build web --release
```

### 🧪 Testing

```bash
# Chạy tất cả tests
flutter test

# Test với coverage
flutter test --coverage
```

### 📦 Build Runner (Code generation)

```bash
# Generate code cho assets, models, etc.
dart run build_runner build --delete-conflicting-outputs
```

## 📱 Hướng dẫn sử dụng

### 🔑 Đăng ký / Đăng nhập

1. Mở ứng dụng
2. Chọn **Đăng ký** nếu chưa có tài khoản
3. Nhập thông tin: Tên hiển thị, Email, Mật khẩu
4. Hoặc **Đăng nhập** với tài khoản đã có

### 👥 Thêm bạn bè

1. Vào trang **Bạn bè** (vuốt sang phải)
2. Nhấn nút **+** để thêm bạn
3. Nhập email của người bạn muốn kết bạn
4. Gửi lời mời kết bạn

### 📍 Chia sẻ vị trí

1. Cấp quyền truy cập vị trí cho ứng dụng
2. Vị trí sẽ tự động cập nhật và chia sẻ với bạn bè
3. Xem vị trí bạn bè trên **Bản đồ** (vuốt lên từ trang chính)

### 🧭 Sử dụng la bàn

1. Chọn một người bạn từ danh sách
2. La bàn sẽ tự động chỉ hướng đến vị trí của họ
3. Theo mũi tên để tìm đường đến bạn

### 📝 Tạo bài viết

1. Vào trang **Newsfeed** (trang chính)
2. Nhấn nút **+** để tạo bài viết mới
3. Thêm ảnh, nội dung và vị trí
4. Chia sẻ với bạn bè

## 🔧 Cấu hình phát triển

### 🌍 Environment Variables

Tạo file `.env` trong thư mục gốc:

```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### 🔥 Firebase Configuration

#### **Firestore Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Allow reading other users for friend features
    }

    // Posts collection
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && request.auth.uid == resource.data.authorId;
    }

    // Friend requests collection
    match /friend_requests/{requestId} {
      allow read, write: if request.auth != null &&
        (request.auth.uid == resource.data.senderId || request.auth.uid == resource.data.receiverId);
    }
  }
}
```

#### **Security Rules**

```javascript
// Storage rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /posts/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 📱 Platform-specific Configuration

#### **Android**

- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Permissions: Location, Camera, Storage

#### **iOS**

- Deployment target: iOS 12.0
- Permissions: Location, Camera, Photo Library

#### **Web**

- PWA ready
- Service Worker cho caching
- Responsive design

## 🐛 Troubleshooting

### ❌ Lỗi thường gặp

#### **1. Build failed - Missing Google Services**

```bash
# Đảm bảo đã đặt file cấu hình Firebase đúng vị trí
# Android: android/app/google-services.json
# iOS: ios/Runner/GoogleService-Info.plist
```

#### **2. Location permission denied**

```dart
// Kiểm tra quyền trong cài đặt điện thoại
// Hoặc reset permissions trong app settings
```

#### **3. BLoC state not updating**

```dart
// Đảm bảo đã wrap widget với BlocProvider
// Kiểm tra equatable implementation trong state classes
```

### 🔄 Reset app state

```bash
# Clear cache và build
flutter clean
flutter pub get
flutter run
```

## 📖 Mô tả

CompassFriend là một ứng dụng Flutter cho phép bạn:

- **Kết nối với bạn bè**: Gửi lời mời kết bạn, chấp nhận/từ chối yêu cầu
- **Chia sẻ vị trí**: Cập nhật và đồng bộ vị trí thời gian thực với Firebase
- **La bàn thông minh**: Sử dụng la bàn để tìm đường đến:
  - Vị trí cố định do bạn nhập (Fixed Mode)
  - Vị trí thời gian thực của bạn bè (Friend Mode)
- **Xác thực an toàn**: Hệ thống đăng ký/đăng nhập với Firebase Authentication

## ✨ Tính năng chính

### 🔐 Xác thực người dùng

- Đăng ký tài khoản mới với email/password
- Đăng nhập bảo mật
- Quản lý phiên đăng nhập tự động

### 👥 Quản lý bạn bè

- Tìm kiếm người dùng theo email
- Gửi/nhận lời mời kết bạn
- Xem danh sách bạn bè
- Quản lý yêu cầu kết bạn đang chờ

### 📍 Chia sẻ vị trí

- Cập nhật vị trí GPS thời gian thực
- Chia sẻ vị trí với bạn bè
- Theo dõi vị trí bạn bè (với sự đồng ý)

### 🧭 La bàn định hướng

- **Chế độ vị trí cố định**: Nhập tọa độ lat/lng để định hướng
- **Chế độ theo bạn bè**: Tự động cập nhật hướng đến vị trí bạn bè
- Hiển thị khoảng cách đến đích
- La bàn với kim chỉ phương hướng chính xác

## 🛠️ Công nghệ sử dụng

### Framework & Ngôn ngữ

- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language

### Backend Services

- **Firebase Core**: Platform initialization
- **Firebase Authentication**: User authentication
- **Cloud Firestore**: NoSQL database
- **Firebase Crashlytics**: Crash reporting
- **Firebase Analytics**: User analytics
- **Firebase App Check**: Security

### State Management & Navigation

- **Flutter BLoC**: State management pattern
- **GoRouter**: Declarative routing

### Location & Sensors

- **Geolocator**: GPS location services
- **Flutter Compass**: Device compass sensor
- **Flutter Map**: Interactive map display
- **LatLng2**: Geographic coordinate handling

### UI & Media

- **Image Picker**: Camera and gallery access
- **Cached Network Image**: Efficient image loading
- **Flutter Native Splash**: Native splash screens

### Storage & Network

- **Dio**: HTTP client
- **Shared Preferences**: Local data storage
- **Crypto**: Data encryption utilities

## 📊 Cấu trúc Database

### 🔥 Firestore Collections

#### **users** Collection

```javascript
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "avatarUrl": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "currentLocation": {
    "latitude": "number",
    "longitude": "number",
    "updatedAt": "timestamp"
  },
  "isLocationSharingEnabled": "boolean",
  "friends": ["uid1", "uid2", ...],
  "bio": "string"
}
```

#### **posts** Collection

```javascript
{
  "id": "string",
  "authorId": "string",
  "content": "string",
  "imageUrl": "string",
  "location": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "likes": ["uid1", "uid2", ...],
  "comments": [
    {
      "id": "string",
      "authorId": "string",
      "content": "string",
      "createdAt": "timestamp"
    }
  ]
}
```

#### **friend_requests** Collection

```javascript
{
  "id": "string",
  "senderId": "string",
  "receiverId": "string",
  "status": "pending|accepted|rejected",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 📱 Screenshots

### 🔐 Authentication

| Login                           | Register                              | Splash                            |
| ------------------------------- | ------------------------------------- | --------------------------------- |
| ![Login](screenshots/login.png) | ![Register](screenshots/register.png) | ![Splash](screenshots/splash.png) |

### 🏠 Main Features

| Home/Compass                  | Map View                    | Friends                             |
| ----------------------------- | --------------------------- | ----------------------------------- |
| ![Home](screenshots/home.png) | ![Map](screenshots/map.png) | ![Friends](screenshots/friends.png) |

### 📱 Additional Features

| Profile                             | Newsfeed                      | Create Post                            |
| ----------------------------------- | ----------------------------- | -------------------------------------- |
| ![Profile](screenshots/profile.png) | ![Feed](screenshots/feed.png) | ![Create](screenshots/create_post.png) |

## 🧪 Testing Strategy

### 🔬 Unit Tests

```bash
# Model tests
test/models/
├── user_model_test.dart
├── location_model_test.dart
└── post_model_test.dart

# BLoC tests
test/blocs/
├── auth_bloc_test.dart
├── profile_bloc_test.dart
├── friend_bloc_test.dart
└── compass_bloc_test.dart

# Service tests
test/services/
├── location_service_test.dart
├── http_service_test.dart
└── shared_preferences_service_test.dart
```

### 🔄 Integration Tests

```bash
integration_test/
├── app_test.dart
├── auth_flow_test.dart
├── friend_management_test.dart
└── location_sharing_test.dart
```

### 📊 Test Coverage

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔒 Security Features

### 🛡️ Firebase Security

- **App Check**: Protect against abuse
- **Firestore Rules**: Fine-grained access control
- **Authentication**: Secure user management
- **Crashlytics**: Error monitoring without PII

### 🔐 Data Protection

- **Location Privacy**: User-controlled sharing
- **Data Encryption**: Sensitive data protection
- **Input Validation**: Prevent injection attacks
- **Rate Limiting**: API abuse prevention

### 🔍 Privacy Controls

- **Location Sharing Toggle**: On/off control
- **Friend Visibility**: Granular permissions
- **Data Retention**: Automatic cleanup
- **User Data Export**: GDPR compliance

## 🚀 Performance Optimization

### ⚡ App Performance

- **BLoC State Management**: Efficient state updates
- **Image Caching**: Reduce network requests
- **Lazy Loading**: Paginated data loading
- **Keep Alive**: Preserve expensive widget states

### 📱 Platform Optimization

- **Android**: ProGuard obfuscation
- **iOS**: App Store optimization
- **Web**: Service Worker caching
- **Desktop**: Native window management

### 🔧 Development Tools

- **Flutter Inspector**: UI debugging
- **Performance Overlay**: Frame rate monitoring
- **Memory Profiling**: Memory leak detection
- **Network Profiling**: API call optimization

## 👥 Đóng góp

### 🤝 Quy trình đóng góp

1. Fork repository
2. Tạo feature branch: `git checkout -b feature/AmazingFeature`
3. Commit changes: `git commit -m 'Add some AmazingFeature'`
4. Push to branch: `git push origin feature/AmazingFeature`
5. Tạo Pull Request

### 📝 Coding Standards

- Tuân thủ [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Sử dụng `flutter_lints` rules
- Viết documentation cho public APIs
- Thêm tests cho features mới

### 🐛 Báo cáo lỗi

- Sử dụng GitHub Issues
- Cung cấp thông tin chi tiết về lỗi
- Kèm theo logs và screenshots nếu có

## 📞 Liên hệ & Hỗ trợ

- **Email**: your-email@example.com
- **GitHub Issues**: [Báo cáo lỗi](https://github.com/your-repo/minecraft_compass/issues)
- **Discussions**: [Thảo luận](https://github.com/your-repo/minecraft_compass/discussions)

## 📄 License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) - Framework tuyệt vời
- [Firebase](https://firebase.google.com/) - Backend services
- [OpenStreetMap](https://www.openstreetmap.org/) - Map data
- [Flutter Community](https://github.com/fluttercommunity) - Packages hữu ích

## 🔮 Roadmap

### 📅 Version 1.1.0 (Planned)

- [ ] Chat realtime giữa bạn bè
- [ ] Thông báo push notifications
- [ ] Dark/Light theme toggle
- [ ] Multi-language support (English, Vietnamese)

### 📅 Version 1.2.0 (Future)

- [ ] Nhóm bạn bè (Groups)
- [ ] Chia sẻ location history
- [ ] Offline mode support
- [ ] Apple Watch & Wear OS companion app

### 📅 Version 1.3.0 (Future)

- [ ] AR compass view
- [ ] Voice navigation
- [ ] Third-party map providers
- [ ] Advanced privacy controls

---

<div align="center">
  <b>⭐ Nếu project này hữu ích, hãy star để ủng hộ! ⭐</b>
</div>

- **Geolocator**: GPS location services
- **Flutter Compass**: Device compass sensor

### UI/UX

- **Material Design**: Google's design system
- **Custom widgets**: Reusable UI components

## 📱 Cấu trúc ứng dụng

```
lib/
├── app/                     # App configuration
├── blocs/                   # BLoC state management
│   ├── auth/               # Authentication logic
│   ├── friend/             # Friend management
│   └── location/           # Location services
├── core/                   # Core utilities & models
├── presentation/           # UI screens & widgets
│   ├── auth/              # Login/Register screens
│   ├── friend/            # Friend management UI
│   ├── location/          # Compass & location UI
│   └── profile/           # User profile
├── repositories/          # Data layer
├── router/               # App navigation
└── main.dart            # Entry point
```

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống

- Flutter SDK ≥ 3.8.0
- Dart SDK tương thích
- Android Studio / Xcode (cho development)
- Firebase project đã được cấu hình

### Bước 1: Clone repository

```bash
git clone <repository-url>
cd minecraft_compass
```

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase

1. Tạo Firebase project mới
2. Bật Authentication với Email/Password
3. Tạo Firestore database
4. Thêm Android/iOS apps vào project
5. Tải file cấu hình:
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)

### Bước 4: Chạy ứng dụng

```bash
flutter run
```

## 🗄️ Cấu trúc Database (Firestore)

### Collection: `users`

```javascript
{
  "uid": "string",
  "displayName": "string",
  "email": "string",
  "avatarUrl": "string",
  "createdAt": "timestamp",
  "currentLocation": {
    "latitude": "number",
    "longitude": "number",
    "updatedAt": "timestamp"
  },
  "friends": ["uid1", "uid2", ...],
  "friendRequests": ["uid1", "uid2", ...]
}
```

## 🔒 Quy tắc bảo mật (Firestore Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if isOwner(userId) || isFriend(userId);
      allow write: if isOwner(userId);
      allow update: if canAddFriendRequest(userId);
    }
  }
}
```

## 📖 Hướng dẫn sử dụng

### 1. Đăng ký/Đăng nhập

- Mở ứng dụng và tạo tài khoản mới
- Hoặc đăng nhập bằng tài khoản có sẵn

### 2. Thêm bạn bè

- Vào "Danh sách bạn bè"
- Nhập email của người bạn muốn kết bạn
- Gửi lời mời kết bạn

### 3. Sử dụng la bàn

- Chọn chế độ "Vị trí cố định" hoặc "Theo bạn bè"
- Với chế độ cố định: nhập tọa độ lat/lng
- Với chế độ bạn bè: chọn bạn từ danh sách
- La bàn sẽ chỉ hướng đến đích

## 🧪 Testing

### Authentication Flow

```bash
# Test đăng ký
# Test đăng nhập/đăng xuất
# Test validation form
```

### Friend Management

```bash
# Test gửi lời mời kết bạn
# Test chấp nhận/từ chối lời mời
# Test tìm kiếm user
```

### Location & Compass

```bash
# Test cập nhật vị trí
# Test lắng nghe vị trí bạn bè
# Test tính toán bearing & distance
```

## 🤝 Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Tạo Pull Request

## 📄 License

Dự án này được phân phối dưới MIT License. Xem file `LICENSE` để biết thêm thông tin.

## 📞 Liên hệ

- Email: [congtu2132004@gmail.com]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- Material Design for UI guidelines
- Community contributors
