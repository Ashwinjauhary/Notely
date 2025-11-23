# Monitor Flutter Download Progress
Write-Host "Flutter Download Monitor" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

$flutterDir = "C:\flutter"
$flutterZip = "$flutterDir\flutter.zip"
$expectedSize = 1000MB  # Approximate size of Flutter SDK

while ($true) {
    if (Test-Path $flutterZip) {
        $size = (Get-Item $flutterZip).Length
        $percent = [math]::Round(($size / $expectedSize) * 100, 1)
        
        Write-Host "Downloaded: $($size / 1MB)MB ($percent%)" -ForegroundColor Green
        
        if ($size -gt ($expectedSize * 0.9)) {
            Write-Host "Download nearly complete! Preparing for extraction..." -ForegroundColor Yellow
            break
        }
    }
    
    Start-Sleep -Seconds 5
}

# Check if extraction is needed
if (Test-Path "$flutterDir\flutter") {
    Write-Host "Flutter already extracted!" -ForegroundColor Green
} else {
    Write-Host "Waiting for extraction to start..." -ForegroundColor Blue
}

# Wait a bit for any ongoing processes
Start-Sleep -Seconds 10

# Try extraction if needed
if (!(Test-Path "$flutterDir\flutter") -and (Test-Path $flutterZip)) {
    Write-Host "Starting extraction..." -ForegroundColor Blue
    try {
        Expand-Archive -Path $flutterZip -DestinationPath $flutterDir -Force
        Write-Host "Extraction completed!" -ForegroundColor Green
        
        # Add to PATH
        $flutterBin = "$flutterDir\flutter\bin"
        $currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        
        if ($currentPath -notlike "*$flutterBin*") {
            [System.Environment]::SetEnvironmentVariable('Path', $currentPath + ";$flutterBin", 'User')
            Write-Host "Added to PATH!" -ForegroundColor Green
        }
        
        # Clean up
        Remove-Item $flutterZip -Force
        Write-Host "Cleanup complete!" -ForegroundColor Gray
        
        Write-Host "" -ForegroundColor White
        Write-Host "Installation complete!" -ForegroundColor Green
        Write-Host "Close PowerShell and reopen, then run:" -ForegroundColor Cyan
        Write-Host "flutter --version" -ForegroundColor White
        Write-Host "cd C:\Users\ashwi\CascadeProjects\notely" -ForegroundColor White
        Write-Host "flutter pub get" -ForegroundColor White
        Write-Host "flutter run" -ForegroundColor White
        
    } catch {
        Write-Host "Extraction failed: $_" -ForegroundColor Red
    }
}
