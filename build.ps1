# Build script for Lost Cities datapack
# Based on documentation: https://www.mcjty.eu/docs/mods/lost-cities/asset-datapack

Write-Host "Building Lost Cities datapack JAR..." -ForegroundColor Green

# Define variables
$projectRoot = $PSScriptRoot
$buildDir = Join-Path $projectRoot "build"
$jarName = "3008Cities.jar"
$jarPath = Join-Path $projectRoot $jarName

# Clean previous build
if (Test-Path $buildDir) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item $buildDir -Recurse -Force
}

# Create build directory
Write-Host "Creating build directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

# Copy required files to build directory
Write-Host "Copying files to build directory..." -ForegroundColor Cyan

# Copy pack.mcmeta
Copy-Item (Join-Path $projectRoot "pack.mcmeta") -Destination $buildDir -Force

# Copy META-INF
Copy-Item (Join-Path $projectRoot "META-INF") -Destination $buildDir -Recurse -Force

# Copy data folder
Copy-Item (Join-Path $projectRoot "data") -Destination $buildDir -Recurse -Force

# Create JAR file (which is just a ZIP file with .jar extension)
Write-Host "Creating JAR file..." -ForegroundColor Cyan

# Remove old JAR if it exists
if (Test-Path $jarPath) {
    Remove-Item $jarPath -Force
}

# Create the JAR (zip archive)
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($buildDir, $jarPath, $compressionLevel, $false)

# Clean up build directory
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item $buildDir -Recurse -Force

# Success message
Write-Host "`nBuild completed successfully!" -ForegroundColor Green
Write-Host "JAR file created: $jarPath" -ForegroundColor Green
Write-Host "`nYou can now place this JAR file in your mods folder." -ForegroundColor Cyan
