@echo on

REM Maven installation script
mkdir maven_temp 2>nul
cd maven_temp

echo Step 1: Downloading Maven 3.8.8...
powershell -Command "Invoke-WebRequest 'https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.zip' -OutFile 'maven.zip'"

echo Step 2: Checking download...
if exist maven.zip (
    echo Download successful!
    echo Step 3: Extracting Maven...
    powershell -Command "Expand-Archive 'maven.zip' -DestinationPath '.' -Force"
    
    echo Step 4: Installing Maven to E:\apache-maven-3.8.8...
    mkdir E:\apache-maven-3.8.8 2>nul
    xcopy apache-maven-3.8.8 E:\apache-maven-3.8.8 /E /I /Y
    
    echo Step 5: Creating local repository...
    mkdir E:\maven-repo 2>nul
    
    echo ============================
    echo Maven INSTALLATION COMPLETE!
    echo Installation path: E:\apache-maven-3.8.8
    echo Local repository: E:\maven-repo
    echo ============================
    echo.
    echo Please configure environment variables manually:
    echo 1. Set MAVEN_HOME = E:\apache-maven-3.8.8
    echo 2. Add %%MAVEN_HOME%%\bin to Path
    echo 3. Run 'mvn -v' in new cmd to verify
) else (
    echo Download failed! Check network connection.
)

cd ..
rd /s /q maven_temp 2>nul

echo Script execution finished!
pause