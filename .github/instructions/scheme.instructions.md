Dưới đây là tài liệu schema Firestore đầy đủ:

---

## 1. Collection `users`

**Document ID:** `string` (UID người dùng hoặc tự sinh)

### Các field

| Trường            | Kiểu            | Nullable | Mô tả                                 |
| ----------------- | --------------- | :------: | ------------------------------------- |
| `uid`             | `string`        |     –    | ID người dùng (trùng với Document ID) |
| `avatarUrl`       | `string`        |     –    | URL ảnh đại diện                      |
| `displayName`     | `string`        |     –    | Tên hiển thị                          |
| `username`        | `string`        |     –    | Tên đăng nhập                         |
| `email`           | `string`        |     –    | Địa chỉ email                         |
| `createdAt`       | `Timestamp`     |     –    | Thời điểm tạo tài khoản               |
| `currentLocation` | `map`           |    Có    | Thông tin vị trí hiện tại             |
|   – `latitude`    | `number`        |     –    | Vĩ độ                                 |
|   – `longitude`   | `number`        |     –    | Kinh độ                               |
|   – `updatedAt`   | `Timestamp`     |     –    | Thời điểm cập nhật vị trí             |
| `friends`         | `array<string>` |     –    | Danh sách `uid` bạn bè                |
| `friendRequests`  | `array<string>` |     –    | Danh sách `uid` đã gửi lời mời        |

---

## 2. Collection `newsfeeds`

**Document ID:** `string` (tự sinh)

### Các field

| Trường             | Kiểu        | Nullable | Mô tả                                           |
| ------------------ | ----------- | :------: | ----------------------------------------------- |
| `id`               | `string`    |     –    | Document ID                                     |
| `userId`           | `string`    |     –    | UID người đăng                                  |
| `userDisplayName`  | `string`    |     –    | Tên hiển thị tại thời điểm đăng                 |
| `userAvatarUrl`    | `string`    |    Có    | URL avatar tại thời điểm đăng                   |
| `imageUrl`         | `string`    |     –    | URL ảnh chính                                   |
| `caption`          | `string`    |    Có    | Chú thích (nếu có)                              |
| `createdAt`        | `Timestamp` |     –    | Thời điểm tạo bài                               |
| `location`         | `map`       |    Có    | Thông tin vị trí (nếu có)                       |
|   – `latitude`     | `number`    |     –    | Vĩ độ                                           |
|   – `longitude`    | `number`    |     –    | Kinh độ                                         |
|   – `locationName` | `string`    |    Có    | Tên/mô tả vị trí                                |
|   – `updatedAt`    | `Timestamp` |     –    | Thời điểm cập nhật vị trí                       |
| `commentsCount`    | `number`    |     –    | Tổng số bình luận (cập nhật qua Cloud Function) |

### Sub-collection `comments`

**Path:** `newsfeeds/{postId}/comments/{commentId}`

| Trường            | Kiểu        | Nullable | Mô tả                                        |
| ----------------- | ----------- | :------: | -------------------------------------------- |
| `userId`          | `string`    |     –    | UID người comment                            |
| `userDisplayName` | `string`    |     –    | Tên hiển thị tại thời điểm comment           |
| `userAvatarUrl`   | `string`    |     –    | URL avatar tại thời điểm comment             |
| `content`         | `string`    |     –    | Nội dung bình luận                           |
| `createdAt`       | `Timestamp` |     –    | Thời điểm tạo bình luận                      |
| `parentCommentId` | `string`    |    Có    | ID comment cha (nếu support reply nhiều cấp) |

---

## 3. Collection `conversations`

**Document ID:** `string` cố định, ví dụ `"uidA_uidB"` (sắp xếp lexicographically hai UID)

### Các field

| Trường          | Kiểu                 | Nullable | Mô tả                                            |
| --------------- | -------------------- | :------: | ------------------------------------------------ |
| `participants`  | `array<string>`      |     –    | `[uidA, uidB]` (luôn 2 phần tử)                  |
| `lastMessage`   | `string`             |     –    | Nội dung tin nhắn cuối cùng                      |
| `lastUpdatedAt` | `Timestamp`          |     –    | Thời điểm tin nhắn cuối                          |
| `unreadCounts`  | `map<string,number>` |     –    | Số tin chưa đọc với mỗi user, ví dụ `{[uid]: 2}` |

### Sub-collection `messages`

**Path:** `conversations/{conversationId}/messages/{messageId}`

| Trường      | Kiểu        | Nullable | Mô tả                                |
| ----------- | ----------- | :------: | ------------------------------------ |
| `senderId`  | `string`    |     –    | UID người gửi                        |
| `content`   | `string`    |     –    | Nội dung tin nhắn                    |
| `createdAt` | `Timestamp` |     –    | Thời điểm gửi                        |
| `readAt`    | `Timestamp` |    Có    | Thời điểm bên kia đã đọc             |
| `type`      | `string`    |    Có    | Loại tin (ví dụ `"text"`, `"post"`)  |

---

## Ví dụ TypeScript-like

```ts
interface User {
  uid: string;
  avatarUrl: string;
  displayName: string;
  username: string;
  email: string;
  createdAt: firebase.firestore.Timestamp;
  currentLocation?: {
    latitude: number;
    longitude: number;
    updatedAt: firebase.firestore.Timestamp;
  };
  friends: string[];
  friendRequests: string[];
}

interface NewsfeedPost {
  id: string;
  userId: string;
  userDisplayName: string;
  userAvatarUrl?: string;
  imageUrl: string;
  caption?: string;
  createdAt: firebase.firestore.Timestamp;
  location?: {
    latitude: number;
    longitude: number;
    locationName?: string;
    updatedAt: firebase.firestore.Timestamp;
  };
  commentsCount: number;
}

interface Comment {
  userId: string;
  userDisplayName: string;
  userAvatarUrl: string;
  content: string;
  createdAt: firebase.firestore.Timestamp;
  parentCommentId?: string;
}

interface Conversation {
  participants: [string, string];
  lastMessage: string;
  lastUpdatedAt: firebase.firestore.Timestamp;
  unreadCounts: { [uid: string]: number };
}

interface Message {
  senderId: string;
  content: string;
  createdAt: firebase.firestore.Timestamp;
  readAt?: firebase.firestore.Timestamp;
  type?: string;
}
```

---

### Lưu ý & Best Practices

* **Indexing:**

  * `newsfeeds/{postId}/comments` theo `createdAt` để load comment theo thứ tự thời gian.
  * `conversations` theo `lastUpdatedAt` để hiển thị danh sách conversation mới nhất.

* **Query ví dụ:**

  ```js
  // Lấy comments của 1 post:
  db.collection('newsfeeds')
    .doc(postId)
    .collection('comments')
    .orderBy('createdAt', 'asc');

  // Lấy conversation của user:
  db.collection('conversations')
    .where('participants', 'array-contains', myUid)
    .orderBy('lastUpdatedAt', 'desc');
  ```

* **Security Rules:**

  * Với `comments`: chỉ cho phép authenticated user ghi comment.
  * Với `conversations` & `messages`: chỉ cho phép user trong `participants` đọc/ghi.

---
