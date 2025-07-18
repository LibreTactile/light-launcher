# Light Launcher Build Guide - Android & iOS

## Prerequisites

### General Requirements
- **Godot Engine 4.4+** installed
- Access to the Light Launcher project files
- Internet connection for downloading export templates

### Platform-Specific Requirements

#### Android
- Android SDK with build tools
- Java Development Kit (JDK) 17+
- Android device or emulator for testing

#### iOS
- **macOS computer** (required for iOS builds)
- **Xcode** installed from the Mac App Store
- **Apple Developer Account** (for device deployment and App Store)
- iOS device for testing (optional but recommended)

---

## Step 1: Download Godot Export Templates

1. Open the Godot Editor
2. Navigate to **Editor > Manage Export Templates**
3. Click **Download and Install** to get the official export templates for your Godot version
4. Wait for the download to complete

---

## Step 2: Android APK Build

### Configure Android Export Preset

1. Open your Light Launcher project in Godot
2. Go to **Project > Export**
3. Click **Add...** and select **Android**
4. Configure the preset:
   - **Name**: `Android_Launcher` (or your preferred name)
   - **Export Path**: `../builds/light-launcher/LightLauncher-v0.2.3.apk`
   - **Package Name**: `com.libretactile.lightLauncher`
   - **Version Code**: `1`
   - **Version Name**: `0.2.3`

### Required Permissions
Ensure these permissions are enabled in the export preset:
- ✅ **Internet** (required for WebSocket server functionality)
- ✅ **Vibrate** (for tactile feedback)
- ✅ **Access Network State** (recommended for network connectivity checks)

### Build the APK

1. In the Export window, select your Android preset
2. Click **Export Project**
3. Choose your export path and filename
4. Click **Save** to generate the APK

### Testing
- Install the APK on your Android device: `adb install LightLauncher-v0.2.3.apk`
- Enable the launcher in **Settings > Apps > Default Apps > Home App**
- Test WebSocket connectivity and tactile features

---

## Step 3: iOS IPA Build

### Configure iOS Export Preset

1. In **Project > Export**, click **Add...** and select **iOS**
2. Configure the preset:
   - **Name**: `iOS`
   - **Export Path**: `../builds/light-launcher/light-launcher-v0.2.3.ipa`
   - **Bundle Identifier**: `com.libretactile.lightlauncher`
   - **App Store Team ID**: `ABCDE12XYZ` (replace with your 10-character team ID)
   - **Version**: `0.2.3`
   - **Min iOS Version**: `14.0`

### Required Capabilities
Enable these in the export preset:
- ✅ **Access WiFi** (for local network features)

### Export to Xcode Project

1. Select your iOS preset
2. Click **Export Project** (not Export PCK/ZIP)
3. Choose an **empty folder** for the Xcode project
4. Set **File** name to `LightLauncher` (avoid spaces)
5. Click **Save**

> Checkout this tutorial:  https://www.youtube.com/watch?v=BovBnO07h80&ab_channel=ACB_Gamez

### Configure Xcode Project

1. Open `LightLauncher.xcodeproj` in Xcode
2. Select your project in the navigator
3. Go to **Info** tab
4. Add the following entry to **Custom iOS Target Properties**:
   ```xml
   <key>NSLocalNetworkUsageDescription</key>
   <string>Light Launcher uses local network to connect with TOMAT Navigator and provide tactile feedback for accessible navigation.</string>
   ```

### Build and Deploy

1. Connect your iOS device
2. Select your device as the build target
3. In Xcode, go to **Product > Archive**
4. Use **Distribute App** to create an IPA for distribution
5. For App Store: Choose **App Store Connect**
6. For testing: Choose **Development** or **Ad Hoc**

---

## Troubleshooting

### Common Android Issues
- **Build fails**: Ensure Android SDK path is configured in Godot
- **Permission denied**: Check that required permissions are enabled
- **WebSocket not working**: Verify `internet` permission is enabled

### Common iOS Issues
- **Export fails**: Verify App Store Team ID is exactly 10 characters
- **Local network blocked**: Ensure `NSLocalNetworkUsageDescription` is added
- **Signing issues**: Check that your Apple Developer account is properly configured

### General Issues
- **Export templates missing**: Re-download templates via **Editor > Manage Export Templates**
- **Project won't open**: Verify you're using Godot 4.4+ as specified in `project.godot`
