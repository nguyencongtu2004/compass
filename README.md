# CompassFriend - Minecraft Compass App

🧭 Ứng dụng la bàn kết nối với bạn bè, giúp bạn định hướng đến vị trí của người thân.

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
