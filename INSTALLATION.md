# Flutter Installation Guide for Notely

## Quick Installation Steps

### 1. Download Flutter SDK
1. Go to: https://flutter.dev/docs/get-started/install/windows
2. Download the Flutter SDK zip file (Flutter 3.16.0 or newer)
3. Extract it to: `C:\flutter`

### 2. Add Flutter to PATH
1. Press `Windows + R`, type `sysdm.cpl` and press Enter
2. Go to "Advanced" tab → "Environment Variables"
3. Under "User variables", find "Path" and click "Edit"
4. Click "New" and add: `C:\flutter\bin`
5. Click OK on all windows

### 3. Verify Installation
1. Close and reopen PowerShell
2. Run: `flutter --version`
3. Run: `flutter doctor`

### 4. Install Dependencies
1. In PowerShell, run: `flutter doctor --android-licenses`
2. Accept all licenses by typing "y"

### 5. Run Notely
1. Navigate to project: `cd C:\Users\ashwi\CascadeProjects\notely`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

## Alternative: Use Flutter from Microsoft Store
1. Open Microsoft Store
2. Search "Flutter SDK"
3. Install the official Flutter app
4. Restart PowerShell and continue with step 3 above

## Troubleshooting

### If "flutter command not found":
- Make sure you added `C:\flutter\bin` to your PATH
- Restart PowerShell after adding to PATH
- Try running `C:\flutter\bin\flutter.bat --version`

### If "flutter doctor" shows issues:
- Install Visual Studio Code with Flutter extension
- Install Git for Windows
- Install Android Studio (for mobile development)

### If dependencies fail:
- Run `flutter clean` then `flutter pub get`
- Check internet connection
- Try running PowerShell as Administrator

## Minimum Requirements
- Windows 10 or newer
- 2GB+ RAM
- 10GB+ free disk space
- Git for Windows

Once Flutter is installed, you'll be able to run the Notely app with all its features!
