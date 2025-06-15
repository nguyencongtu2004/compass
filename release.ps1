# Function to increment build number in pubspec.yaml
function Update-BuildNumber {
    $pubspecPath = "pubspec.yaml"
    
    # Read pubspec.yaml content
    $content = Get-Content $pubspecPath -Raw
    
    # Extract current version using regex
    if ($content -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
        $versionName = $matches[1]  # e.g., "1.0.0"
        $buildNumber = [int]$matches[2]  # e.g., 6
        $newBuildNumber = $buildNumber + 1
        $newVersion = "$versionName+$newBuildNumber"
        
        Write-Host "Current version: $versionName+$buildNumber" -ForegroundColor Yellow
        Write-Host "New version: $newVersion" -ForegroundColor Green
        
        # Replace version in content
        $newContent = $content -replace "version:\s*\d+\.\d+\.\d+\+\d+", "version: $newVersion"
        
        # Write back to file
        Set-Content -Path $pubspecPath -Value $newContent -NoNewline
        
        Write-Host "[SUCCESS] Version updated successfully!" -ForegroundColor Green
        return $newVersion
    }
    else {
        Write-Error "[ERROR] Could not find version pattern in pubspec.yaml"
        exit 1
    }
}

# Main build process
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting build process..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Update build number
Write-Host "[STEP 1] Updating build number..." -ForegroundColor Cyan
$newVersion = Update-BuildNumber
Write-Host ""

# Step 2: Build runner
Write-Host "[STEP 2] Running build_runner..." -ForegroundColor Cyan
dart run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] build_runner failed"
    exit 1
}
Write-Host "[SUCCESS] build_runner completed" -ForegroundColor Green
Write-Host ""

# Step 3: Generate localizations
Write-Host "[STEP 3] Generating localizations..." -ForegroundColor Cyan
flutter gen-l10n
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] gen-l10n failed"
    exit 1
}
Write-Host "[SUCCESS] Localizations generated" -ForegroundColor Green
Write-Host ""

# Step 4: Build app bundle
Write-Host "[STEP 4] Building app bundle..." -ForegroundColor Cyan
flutter build appbundle
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] App bundle build failed"
    exit 1
}
Write-Host "[SUCCESS] App bundle built successfully" -ForegroundColor Green
Write-Host ""

# Step 5: Move to desktop
Write-Host "[STEP 5] Moving bundle to Desktop..." -ForegroundColor Cyan
$sourcePath = "C:\Flutter\flutter_projects\minecraft_compass\build\app\outputs\bundle\release\app-release.aab"
$destinationPath = "D:\Desktop\minecraft_compass_$newVersion.aab"

if (Test-Path $sourcePath) {
    Move-Item -Path $sourcePath -Destination $destinationPath -Force
    Write-Host "[SUCCESS] App bundle moved to: $destinationPath" -ForegroundColor Green
}
else {
    Write-Error "[ERROR] App bundle not found at: $sourcePath"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "BUILD COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "New version: $newVersion" -ForegroundColor Yellow
Write-Host "Location: $destinationPath" -ForegroundColor Yellow