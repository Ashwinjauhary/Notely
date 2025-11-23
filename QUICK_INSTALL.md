# Quick Flutter Installation for Notely

## 🚀 Easiest Method: Microsoft Store

1. **Open Microsoft Store**
2. **Search for "Flutter SDK"**
3. **Click "Install"** (it's free)
4. **Wait for installation to complete**
5. **Close and reopen PowerShell**

### ✅ Verify Installation

```powershell
flutter --version
```

### 📱 Run Notely App

```powershell
cd C:\Users\ashwi\CascadeProjects\notely
flutter pub get
flutter run
```

---

## 🔄 Alternative: Manual Download

If Microsoft Store doesn't work:

1. **Download Flutter manually:**
   - Go to: https://flutter.dev/docs/get-started/install/windows
   - Download: `flutter_windows_3.16.0-stable.zip`

2. **Extract to:** `C:\flutter`

3. **Add to PATH:**
   - Press `Windows + R`
   - Type: `sysdm.cpl`
   - Go to "Advanced" → "Environment Variables"
   - Edit "Path" → Add `C:\flutter\bin`

4. **Restart PowerShell**

---

## 🎯 Once Flutter is Working

```powershell
# Test Flutter
flutter --version

# Go to Notely project
cd C:\Users\ashwi\CascadeProjects\notely

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📱 What to Expect

Notely will open with:
- Beautiful splash screen with animations
- Home screen with notes grid
- Rich text editor
- 5 beautiful themes
- Offline functionality
- Search and filters
- Bookmarks system

## 🔧 If Issues Occur

Run: `flutter doctor` to check for missing dependencies

Common fixes:
- Install Visual Studio Code with Flutter extension
- Install Git for Windows
- Accept Android licenses: `flutter doctor --android-licenses`

Enjoy your Notely app! 🎉
