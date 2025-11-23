@echo off
echo Installing Flutter for Notely...
echo.

REM Create flutter directory if it doesn't exist
if not exist "C:\flutter" mkdir C:\flutter

echo Downloading Flutter SDK...
powershell -Command "Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'C:\flutter\flutter.zip'"

echo Extracting Flutter...
powershell -Command "Expand-Archive -Path 'C:\flutter\flutter.zip' -DestinationPath 'C:\flutter' -Force"

echo Adding to PATH...
setx PATH "%PATH%;C:\flutter\flutter\bin" /M

echo.
echo Flutter installation complete!
echo Please restart PowerShell and run:
echo   flutter --version
echo   cd C:\Users\ashwi\CascadeProjects\notely
echo   flutter pub get
echo   flutter run
pause
