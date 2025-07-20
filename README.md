# 📶 Wi-Fi Connect App

A Flutter app to scan, list, and manage Wi-Fi connections using platform capabilities like location permissions and network APIs.

---

## 🔗 Source Code

**GitHub Repository:**  
[Wi-Fi Connect App on GitHub](https://github.com/abhi2811mishra/Wi-Fi-Connect-App)

## 🎥 Demo Video

[![Watch Demo](https://img.shields.io/badge/Watch-Demo%20Video-blue?logo=google-drive)](https://drive.google.com/file/d/1BZUWCCjIA72riB_ZRjpCcnMNMfBPS_0Z/view?usp=sharing)

---

## 🧰 Tech Stack & Tools

- **IDE:** Visual Studio Code / Android Studio
- **Language:** Dart (Flutter Framework)
- **Plugins/Packages Used:**
  - [`wifi_iot`](https://pub.dev/packages/wifi_iot) – for Wi-Fi scanning and connection
  - [`geolocator`](https://pub.dev/packages/geolocator) – to handle location permissions
  - [`permission_handler`](https://pub.dev/packages/permission_handler) – manage runtime permissions
  - [`fluttertoast`](https://pub.dev/packages/fluttertoast) – for UI notifications

---

## ⚙️ Platform Limitations

| Platform | Status |
|----------|--------|
| **Android** | ✅ Fully supported (min SDK 21+) |
| **iOS** | ⚠️ Not supported (due to Wi-Fi connection restrictions by Apple) |

**Note:** iOS does not allow programmatic Wi-Fi connections due to security/privacy limitations. This app is currently Android-only.

---

## 🔐 Permissions Handling

- **Location Permission:** Required by Android to scan for Wi-Fi networks.
- **Handled with:**
  - `permission_handler` for requesting permissions
  - `geolocator` for checking and prompting location services
- **Location Services Check:** Ensures GPS is turned on before attempting Wi-Fi scans

---

## 🗃️ Database Logic

Currently, the app does **not use any local or remote database**. It performs real-time scanning and connection only.

Future enhancements could include:
- Storing scanned networks
- Remembering preferred connections
- Syncing usage history to Firebase or local SQLite

---

## ✨ Bonus Features / Notes

- Uses **foreground service** to maintain location updates while scanning
- UI built with Flutter's native components and responsive design
- Gracefully handles permission denial with user feedback
- Basic GitHub integration for version control

---

## 🛠️ Setup Instructions

1. Clone the repo:
   ```bash
   git clone https://github.com/abhi2811mishra/Wi-Fi-Connect-App.git
   cd Wi-Fi-Connect-App
