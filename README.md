# 🧭 Minecraft Compass - Social Location Sharing App

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg)](/)

Ứng dụng Flutter đa nền tảng cho phép chia sẻ vị trí, hình ảnh và chat real-time. Được xây dựng với Clean Architecture và các best practices hiện đại.

## ✨ **Tính năng chính**

### 📸 **Chia sẻ hình ảnh**
- Upload và chia sẻ ảnh với vị trí
- Tích hợp Cloudinary CDN
- Tối ưu hóa chất lượng và tốc độ tải

### 📍 **Chia sẻ vị trí real-time**
- Theo dõi vị trí bạn bè trực tiếp
- Bản đồ tương tác với markers
- Compass thông minh định hướng

### 💬 **Chat real-time**
- Nhắn tin tức thời với Firebase
- Trạng thái đã đọc/chưa đọc
- Thông báo tin nhắn mới

### 👥 **Quản lý bạn bè**
- Tìm kiếm và kết bạn
- Quản lý danh sách bạn bè
- Quyền riêng tư vị trí

## 🏗️ **Kiến trúc kỹ thuật**

### **Clean Architecture**
```
lib/
├── data/                     # Data layer - Repositories & Services
├── models/                   # Domain entities
├── presentation/             # UI layer - BLoC & Widgets
│   ├── auth/                # Authentication
│   ├── compass/             # Compass navigation
│   ├── messaging/           # Real-time chat
│   ├── newsfeed/            # Photo sharing
│   └── map/                 # Location sharing
├── di/                      # Dependency injection
└── router/                  # Navigation
```

### **Công nghệ sử dụng**
- **Flutter 3.24.0** - Framework đa nền tảng
- **BLoC Pattern** - Quản lý trạng thái với flutter_bloc
- **Firebase** - Backend (Auth, Firestore, Storage)
- **Cloudinary** - Xử lý hình ảnh & CDN
- **OpenStreetMap** - Bản đồ tương tác
- **Clean Architecture** - Cấu trúc code có thể mở rộng

### **Tính năng kỹ thuật**
- **Real-time synchronization** với Firebase Firestore
- **Background location tracking** được tối ưu hóa
- **Image optimization** và caching
- **Dependency injection** với get_it/injectable
- **Localization** hỗ trợ đa ngôn ngữ
- **SOLID principles** & **DRY** code

## 🚀 **Chạy dự án**

```powershell
# Clone repository
git clone <repository-url>
cd minecraft_compass

# Install dependencies
flutter pub get

# Setup Firebase
# - Add google-services.json (Android)
# - Add GoogleService-Info.plist (iOS)

# Run app
flutter run
```

## 📱 **Platforms**
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11+)  
- ✅ **Web** (Progressive Web App)

---

*Dự án này showcase khả năng phát triển ứng dụng Flutter enterprise-level với Clean Architecture, real-time features và modern development practices.*