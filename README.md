# middle_paint

A new **Flutter** project  **MiddlePaint**, designed to bring creativity and simplicity together in a modern mobile drawing app. It allows users to create, edit, and manage artworks directly on their iOS devices - integrating seamless Firebase connectivity, secure user authentication, and cloud storage.

The app focuses on delivering a smooth and intuitive drawing experience with  local notifications, and easy image export and sharing.

---

## 🎯 Project Overview

**MiddlePaint** enables users to draw, import, and edit images on a digital canvas with smooth, intuitive controls. Each artwork can be saved, shared, and stored securely using Firebase. The app includes features such as authentication, notifications, and file export - all wrapped in a clean and modern UI.

### 🧩 Key Features

- **User Authentication (Email/Password)** via Firebase Auth
- **Drawing Canvas** with brush, eraser, and color palette
- **Image Import** from the photo gallery
- **Artwork Export & Sharing** via native Share popup
- **Cloud Storage Integration** with Firebase for image uploads and metadata
- **Local Notifications** to inform users about successful saves
- **Image Gallery Screen** showing all artworks stored in Firebase
- **Clean Architecture & State Management** for maintainable and scalable code
- **Support** for multiple drawing layers

---

## ⚙️ Technical Stack

- **Platform:** iOS (iPhone)
- **Language:** Dart 3.7.2
- **Framework:** Flutter 3.29.3&#x20;
- **Backend & Storage:** Firebase (Auth, Firestore, Storage)
- **Notifications:** flutter\_local\_notifications
- **Design Source:** Figma layouts&#x20;

---

## 📱 iOS Permission Requirements

To ensure the app correctly accesses device features, the following permissions must be added to your **Info.plist** file:

### 🖼️ Media & Camera Access

- **📷 Privacy - Photo Library Usage (********`NSPhotoLibraryUsageDescription`********)**

  - **Purpose:** To select existing images from the gallery for editing and painting.
  - **Package(s):** `image_picker`

- **💾 Privacy - Photo Library Additions (********`NSPhotoLibraryAddUsageDescription`********)**

  - **Purpose:** To save the final artwork back to the user's photo gallery.
  - **Package(s):** `image_gallery_saver`

- **📸 Privacy - Camera Usage (********`NSCameraUsageDescription`********)**

  - **Purpose:** Required by the official documentation for the `image_picker` package.
  - **Package(s):** `image_picker`

- **🎙️ Privacy - Microphone Usage (********`NSMicrophoneUsageDescription`********)**

  - **Purpose:** Required by the official documentation for the `image_picker` package.
  - **Package(s):** `image_picker`

---

### 🔥 Background & Sharing Configuration

- **🕐 Background Modes: Remote Notifications**

  - **Purpose:** To receive and handle push notifications (FCM) when the app is in the background.
  - **Package(s):** `firebase_core`, `flutter_local_notifications`
  - **Note:** Enable *Remote notifications* capability in **Xcode**.

- **🔗 URL Types (********`CFBundleURLTypes`********)**

  - **Purpose:** Required for deep link callbacks when using **Google Sign-In** via Firebase Auth.
  - **Package(s):** `firebase_auth`

- **📄 Document Types (********`CFBundleDocumentTypes`********)**

  - **Purpose:** Declares support for sharing specific file formats such as **PNG** files.
  - **Package(s):** `share_plus`

---


