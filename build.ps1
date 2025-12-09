# Build script for Lost Cities datapack
# Based on documentation: https://www.mcjty.eu/docs/mods/lost-cities/asset-datapack

Write-Host "Building Lost Cities datapack JAR..." -ForegroundColor Green

# Define variables
$projectRoot = $PSScriptRoot
$buildDir    = Join-Path $projectRoot "build"
$jarName     = "3008Cities.jar"
$jarPath     = Join-Path $projectRoot $jarName

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

# pack.mcmeta
Copy-Item (Join-Path $projectRoot "pack.mcmeta") -Destination $buildDir -Force

# META-INF
Copy-Item (Join-Path $projectRoot "META-INF") -Destination $buildDir -Recurse -Force

# data folder
Copy-Item (Join-Path $projectRoot "data") -Destination $buildDir -Recurse -Force

# Remove old JAR if it exists (with retry logic)
if (Test-Path $jarPath) {
    try {
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Start-Sleep -Milliseconds 500
        Remove-Item $jarPath -Force -ErrorAction Stop
    } catch {
        Write-Warning "Could not remove old JAR file. It may be in use by another process."
        Write-Warning "Please close any programs that might have the JAR file open and try again."
        exit 1
    }
}

# Create the JAR (zip archive) with correct forward-slash paths
Write-Host "Creating JAR file..." -ForegroundColor Cyan

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

try {
    $zip = [System.IO.Compression.ZipFile]::Open($jarPath,
        [System.IO.Compression.ZipArchiveMode]::Create)

    Get-ChildItem -Path $buildDir -Recurse -File | ForEach-Object {
        # Relative path inside the JAR
        $relativePath = $_.FullName.Substring($buildDir.Length + 1)

        # IMPORTANT: normalize to forward slashes for Java/Forge
        $entryName = $relativePath -replace '\\','/'

        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            $_.FullName,
            $entryName,
            $compressionLevel
        ) | Out-Null
    }
}
catch {
    Write-Error "Failed to create JAR file: $_"
    if ($zip) { $zip.Dispose() }
    Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
finally {
    if ($zip) { $zip.Dispose() }
}

# Clean up build directory
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item $buildDir -Recurse -Force

# Success message
Write-Host "`nBuild completed successfully!" -ForegroundColor Green
Write-Host "JAR file created: $jarPath" -ForegroundColor Green
Write-Host "`nYou can now place this JAR file in your mods folder." -ForegroundColor Cyan