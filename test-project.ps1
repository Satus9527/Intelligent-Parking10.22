# Parking System Project Verification Script
# This script checks the basic structure and configuration of the project

Write-Host "=== Parking System Project Verification Started ===" -ForegroundColor Green

# Check Java version
Write-Host "\n1. Checking Java version..."
try {
    $javaVersion = java -version 2>&1
    Write-Host "Java is installed: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "Java is not installed or environment variables are not configured" -ForegroundColor Red
    exit 1
}

# Check project directory structure
Write-Host "\n2. Checking project directory structure..."
$requiredDirs = @(
    "src/main/java",
    "src/main/resources",
    "src/test/java"
)

$hasDirError = $false
foreach ($dir in $requiredDirs) {
    if (-not (Test-Path "$PSScriptRoot\$dir")) {
        Write-Host "Directory not found: $dir" -ForegroundColor Red
        $hasDirError = $true
    }
}

if (-not $hasDirError) {
    Write-Host "Project directory structure is complete" -ForegroundColor Green
} else {
    Write-Host "Some directories are missing" -ForegroundColor Red
}

# Check key files
Write-Host "\n3. Checking key files..."
$requiredFiles = @(
    "pom.xml",
    ".env.example",
    "src/main/java/com/parking/ParkingApplication.java",
    "src/main/resources/application.yml"
)

$hasFileError = $false
foreach ($file in $requiredFiles) {
    if (-not (Test-Path "$PSScriptRoot\$file")) {
        Write-Host "File not found: $file" -ForegroundColor Red
        $hasFileError = $true
    }
}

if (-not $hasFileError) {
    Write-Host "Key files exist" -ForegroundColor Green
} else {
    Write-Host "Some key files are missing" -ForegroundColor Red
}

# Check main Java classes
Write-Host "\n4. Checking main Java classes..."
$requiredClasses = @(
    "src/main/java/com/parking/controller/ParkingController.java",
    "src/main/java/com/parking/service/ParkingService.java",
    "src/main/java/com/parking/service/impl/ParkingServiceImpl.java",
    "src/main/java/com/parking/config/RedisConfig.java"
)

$hasClassError = $false
foreach ($class in $requiredClasses) {
    if (-not (Test-Path "$PSScriptRoot\$class")) {
        Write-Host "Class file not found: $class" -ForegroundColor Yellow
        $hasClassError = $true
    }
}

if (-not $hasClassError) {
    Write-Host "Main Java classes exist" -ForegroundColor Green
} else {
    Write-Host "Some Java classes are missing" -ForegroundColor Yellow
}

# Final summary
Write-Host "\n=== Parking System Project Verification Completed ===" -ForegroundColor Green
if ($hasDirError -or $hasFileError) {
    Write-Host "\nErrors found. Please check and fix the issues before building the project." -ForegroundColor Red
} else {
    Write-Host "\nBasic project structure and configuration check passed!" -ForegroundColor Green
    Write-Host "\nSince Maven is not installed, we cannot build the project directly. To run the project, you need to:" -ForegroundColor Yellow
    Write-Host "1. Install Maven 3.6.0+ and configure environment variables"
    Write-Host "2. Install MySQL 8.0+ and Redis 6.2+"
    Write-Host "3. Create a .env file based on .env.example and configure database and Redis connections"
    Write-Host "4. Run: mvn clean install to build the project"
    Write-Host "5. Run: mvn spring-boot:run to start the application"
}