# Flutter Setup Script for Notely
Write-Host "🚀 Setting up Flutter for Notely..." -ForegroundColor Green

# Check if Flutter is already installed
try {
    flutter --version
    Write-Host "✅ Flutter is already installed!" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "❌ Flutter not found. Installing Flutter..." -ForegroundColor Yellow
}

# Download Flutter
Write-Host "📥 Downloading Flutter SDK..." -ForegroundColor Blue
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip"
$flutterZip = "$env:TEMP\flutter.zip"
$flutterDir = "C:\flutter"

# Create directory if it doesn't exist
if (!(Test-Path $flutterDir)) {
    New-Item -ItemType Directory -Path $flutterDir -Force
}

# Download Flutter
Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip

# Extract Flutter
Write-Host "📦 Extracting Flutter..." -ForegroundColor Blue
Expand-Archive -Path $flutterZip -DestinationPath $flutterDir -Force

# Add to PATH
Write-Host "🔧 Adding Flutter to PATH..." -ForegroundColor Blue
$flutterBin = "$flutterDir\flutter\bin"
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
if ($currentPath -notlike "*$flutterBin*") {
    [System.Environment]::SetEnvironmentVariable('Path', $currentPath + ";$flutterBin", 'User')
}

# Clean up
Remove-Item $flutterZip -Force

Write-Host "Flutter installation complete!" -ForegroundColor Green
Write-Host "Please restart PowerShell and run 'flutter --version' to verify." -ForegroundColor Yellow
Write-Host "Then run 'flutter pub get' in the notely directory." -ForegroundColor Cyan
