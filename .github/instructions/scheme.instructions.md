---
applyTo: "**"
---

Dưới đây là mô tả schema (Firestore) cho collection `users`:

---

## Collection: `users`

### Document ID: `string` (tự sinh hoặc UID người dùng)

#### 1. Các field chính

- **avatarUrl** (_string_)
  – URL của ảnh đại diện (Cloudinary, v.v.)
- **createdAt** (_Timestamp_)
  – Thời điểm tạo tài khoản
- **displayName** (_string_)
  – Tên hiển thị của người dùng
- **email** (_string_)
  – Địa chỉ email

#### 2. Vị trí hiện tại (embedded map)

- **currentLocation** (_map_) gồm:

  - `latitude` (_number_) – Kinh độ
  - `longitude` (_number_) – Vĩ độ
  - `updatedAt` (_Timestamp_) – Thời điểm cập nhật vị trí

#### 3. Danh sách lời mời kết bạn

- **friendRequests** (_map\<string, any> hoặc array<string>_)
  – Key có thể là `userId` của người gửi, value là thông tin trạng thái (ví dụ `true` hoặc object chi tiết)

#### 4. Danh sách bạn bè

- **friends** (_map\<string, object>_)
  – Key là `friendId`, value là một object chứa thông tin cơ bản của bạn bè, ví dụ:

  ```js
  {
    [friendId]: {
      username: string
      // có thể bổ sung thêm: displayName, avatarUrl, lastActiveAt…
    },
    …
  }
  ```

---

### Ví dụ (TypeScript-like)

```ts
interface User {
  avatarUrl: string;
  createdAt: firebase.firestore.Timestamp;
  displayName: string;
  email: string;
  currentLocation: {
    latitude: number;
    longitude: number;
    updatedAt: firebase.firestore.Timestamp;
  };
  friendRequests: {
    [userId: string]: any;
  };
  friends: {
    [userId: string]: {
      username: string;
      // …các trường bổ sung nếu cần
    };
  };
}
```

Dưới đây là mô tả schema cho collection **`newsfeeds`** (Firestore):

---

## Collection: `newsfeeds`

### Document ID: `string`

#### Các field:

- **caption** (_string_)
  – Chú thích hoặc nội dung văn bản kèm ảnh.

- **createdAt** (_Timestamp_)
  – Thời điểm tạo bài đăng.

- **imageUrl** (_string_)
  – URL của ảnh chính trong bài (ví dụ lưu trên Cloudinary).

- **location** (_map_)

  - `latitude` (_number_) – Vĩ độ.
  - `longitude` (_number_) – Kinh độ.
  - `locationName` (_string_) – Tên hoặc mô tả vị trí (ví dụ `"Lat: 10.8528, Lng: 106.7936"`).
  - `updatedAt` (_Timestamp_) – Thời điểm cập nhật vị trí.

- **userId** (_string_)
  – ID người đăng (tham chiếu sang document trong `users`).

- **userDisplayName** (_string_)
  – Tên hiển thị của người đăng tại thời điểm lưu bài.

- **userAvatarUrl** (_string_)
  – URL ảnh đại diện của người đăng (để hiển thị nhanh mà không cần fetch thêm từ `users`).

---

### Ví dụ (TypeScript-like)

```ts
interface Newsfeed {
  caption: string;
  createdAt: firebase.firestore.Timestamp;
  imageUrl: string;
  location: {
    latitude: number;
    longitude: number;
    locationName: string;
    updatedAt: firebase.firestore.Timestamp;
  };
  userId: string;
  userDisplayName: string;
  userAvatarUrl: string;
}
```

> **Ghi chú:**
>
> - Việc lưu sẵn `userDisplayName` và `userAvatarUrl` giúp đỡ tải UI nhanh, tránh nhiều lần join/call đến `users`.
> - Nếu cần mở rộng, có thể thêm các trường như `likes`, `commentsCount`, hoặc sub-collection `comments`.
