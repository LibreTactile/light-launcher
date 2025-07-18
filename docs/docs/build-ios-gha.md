# 📲 iOS Build GitHub Action for Godot

This GitHub Action builds an **iOS Xcode project** from a Godot 4.4 project. It can be run **manually** and works with or without code signing.

## 🚀 Usage

This workflow is triggered manually via the GitHub UI:

```yaml
on:
  workflow_dispatch:
```

---

## ✅ Unsigned Builds (No Setup Needed)

By default, this workflow:

* Runs without secrets or certificates
* Generates an `.xcodeproj` and builds an `.ipa` for testing or CI
* Helps test the build process and export pipeline

No additional configuration is needed.

---

## 🔐 Signed Builds (Optional)

To enable **code signing**, follow these steps:

### 1. Set Repository Variable

Go to: **Settings → Variables and secrets → Variables**

Add:

```
ENABLE_CODE_SIGNING = true
```

### 2. Add Secrets

Go to: **Settings → Variables and secrets → Secrets**

Add:

| Name                              | Description                               |
| --------------------------------- | ----------------------------------------- |
| `APPLE_DEVELOPER_TEAM_ID`         | Your 10-character Apple Team ID           |
| `IOS_CERTIFICATE_BASE64`          | Base64 of your `.p12` signing certificate |
| `IOS_CERTIFICATE_PASSWORD`        | Password for the `.p12` certificate       |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of your `.mobileprovision` profile |

---

## 📁 Output

After a successful run, you’ll get:

* `LightLauncher.ipa` (unsigned or signed, depending on setup)
* `LightLauncher.xcodeproj` (for manual use or further customization)

Artifacts are saved to GitHub and can be downloaded from the Actions tab.

---

## ⚙️ Requirements

* Godot export preset named **"iOS"** must exist in `export_presets.cfg`
* Valid bundle ID and team ID set for signed builds

---

## 🧰 Notes

* The workflow sets `IPHONEOS_DEPLOYMENT_TARGET = 14.0`
* Adds `NSLocalNetworkUsageDescription` for local network permissions

