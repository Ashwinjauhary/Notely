# PowerShell Flutter Installation Script
Write-Host "Flutter Installation for Notely" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator for PATH updates to work properly." -ForegroundColor Yellow
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to continue anyway (PATH may not update automatically)"
}

# Define paths
$flutterDir = "C:\flutter"
$flutterZip = "$flutterDir\flutter.zip"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip"

# Create directory
if (!(Test-Path $flutterDir)) {
    New-Item -ItemType Directory -Path $flutterDir -Force | Out-Null
    Write-Host "Created directory: $flutterDir" -ForegroundColor Green
}

# Download Flutter if not already downloaded
if (!(Test-Path $flutterZip)) {
    Write-Host "Downloading Flutter SDK (this may take a while)..." -ForegroundColor Blue
    Write-Host "URL: $flutterUrl" -ForegroundColor Gray
    
    try {
        # Use System.Net.WebClient for better progress reporting
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($flutterUrl, $flutterZip)
        Write-Host "Download completed!" -ForegroundColor Green
    } catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "Flutter SDK already downloaded." -ForegroundColor Green
}

# Extract Flutter
if (!(Test-Path "$flutterDir\flutter")) {
    Write-Host "Extracting Flutter..." -ForegroundColor Blue
    try {
        Expand-Archive -Path $flutterZip -DestinationPath $flutterDir -Force
        Write-Host "Extraction completed!" -ForegroundColor Green
    } catch {
        Write-Host "Extraction failed: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "Flutter already extracted." -ForegroundColor Green
}

# Add to PATH
$flutterBin = "$flutterDir\flutter\bin"
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')

if ($currentPath -notlike "*$flutterBin*") {
    Write-Host "Adding Flutter to PATH..." -ForegroundColor Blue
    try {
        [System.Environment]::SetEnvironmentVariable('Path', $currentPath + ";$flutterBin", 'User')
        Write-Host "PATH updated successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to update PATH. You may need to add it manually." -ForegroundColor Yellow
        Write-Host "Add this to your PATH: $flutterBin" -ForegroundColor Yellow
    }
} else {
    Write-Host "Flutter already in PATH." -ForegroundColor Green
}

# Clean up
if (Test-Path $flutterZip) {
    Remove-Item $flutterZip -Force
    Write-Host "Cleaned up zip file." -ForegroundColor Gray
}

Write-Host "" -ForegroundColor White
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Close this PowerShell window" -ForegroundColor White
Write-Host "2. Open a new PowerShell window" -ForegroundColor White
Write-Host "3. Run: flutter --version" -ForegroundColor White
Write-Host "4. Run: cd C:\Users\ashwi\CascadeProjects\notely" -ForegroundColor White
Write-Host "5. Run: flutter pub get" -ForegroundColor White
Write-Host "6. Run: flutter run" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host
