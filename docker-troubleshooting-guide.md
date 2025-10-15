# Docker Desktop Troubleshooting Guide

## Issue Analysis

Based on the command prompt output, I can see that:
- Docker is installed (version 28.5.1)
- Docker Compose is installed (version v2.40.0-desktop.1)
- However, `docker run hello-world` fails with a 500 Internal Server Error

This indicates that Docker Desktop is installed but the Docker daemon is not running correctly or there's an issue with the WSL 2 integration.

## Troubleshooting Steps

### Step 1: Restart Docker Desktop

1. Right-click on the Docker Desktop icon in the system tray
2. Select "Quit Docker Desktop"
3. Wait a few seconds
4. Restart Docker Desktop from the Start menu
5. Wait for Docker Desktop to fully start (the icon should turn green)
6. Try running the hello-world container again:

```bash
docker run hello-world
```

### Step 2: Check WSL 2 Integration

1. Open PowerShell as Administrator
2. Run the following commands to verify WSL:

```powershell
wsl --status
wsl --list --verbose
```

3. If WSL is not running or not installed, run:

```powershell
wsl --install
```

4. Restart your computer after installation

### Step 3: Reset Docker Desktop to Factory Settings

1. Open Docker Desktop
2. Click on the gear icon (Settings)
3. Go to "Reset"
4. Click on "Reset to factory defaults"
5. Confirm the reset
6. Restart Docker Desktop

### Step 4: Check Windows Features

1. Press `Win + R`, type `optionalfeatures.exe` and press Enter
2. Make sure the following features are enabled:
   - Virtual Machine Platform
   - Windows Subsystem for Linux
3. If they are not enabled, check the boxes and click OK
4. Restart your computer

### Step 5: Run Docker Desktop as Administrator

1. Right-click on Docker Desktop shortcut
2. Select "Run as administrator"
3. Try running the hello-world container again

## Alternative Approach: Use Docker with Hyper-V

If WSL 2 integration continues to cause issues, you can switch Docker Desktop to use Hyper-V instead:

1. Open Docker Desktop
2. Go to Settings > General
3. Uncheck "Use the WSL 2 based engine"
4. Check "Use Hyper-V"
5. Restart Docker Desktop

## Verify the Fix

After completing the troubleshooting steps, verify that Docker is working correctly:

```bash
docker run hello-world
docker info
```

You should see the "Hello from Docker!" message and detailed system information.

## Next Steps

Once Docker is working correctly, proceed with the project setup:

1. Navigate to the project directory:
   ```bash
   cd d:\Park（Wechat）
   ```

2. Start the required services:
   ```bash
   docker-compose up -d
   ```

3. Check container status:
   ```bash
   docker-compose ps
   ```

If you continue to experience issues, please refer to the official Docker Desktop documentation or consider reinstalling Docker Desktop.

Good luck with your project!