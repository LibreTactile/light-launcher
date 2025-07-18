# Light Launcher

**Mobile Derivative of TOMAT Navigator**
*A tactile mobile launcher for nonlinear, accessible interaction*

**Light Launcher** brings the [TOMAT Navigator](https://github.com/LibreTactile/tomat) experience to Android/iOS. Paired with a 3D-printed tactile grid, it enables **nonlinear, multimodal navigation** through audio and haptic feedback—making apps, files, and settings more accessible to blind and visually impaired users.

Screen readers often force linear navigation. Light Launcher offers a **spatial, touch-based alternative**, enabling users to explore and jump between elements intuitively.

---

## ✨ Key Features

### 🔁 Core Interaction

* **Tactile navigation** using 3D-printed overlay and Godot-powered software
* **Multiscale views**: Zoom between categories and details (apps, files, links)

### ♿ Accessibility

* **Screen reader–compatible** (tested with NVDA)
* **Gesture & audio feedback**: Tap, double-tap, hold with contextual sounds

### 🛠️ Assistive UX Highlights

* **Haptic states**:

  * `INACTIVE`: No feedback
  * `ACTIVE`: Continuous vibration
  * `PULSATING`: Rhythmic pulses
* **Multi-touch detection** with adaptive feedback
* **Real-time updates**: Remote apps can change button states live
* **Low-vision friendly**: Non-visual interaction model with audio/tactile cues

---

## 🔧 Hardware + Software

| Component        | Description                                                                |
| ---------------- | -------------------------------------------------------------------------- |
| **App**          | [Godot-based app](https://github.com/LibreTactile/light-launcher/releases) |
| **Tactile Grid** | 3D-printed guide overlay ([STL files](hardware/3d-models))                 |
| **Peripherals**  | Optional: TOMAT, wearables, gamepads, HID devices                          |

> No hardware? Just print the grid for your phone. Get TOMAT’s benefits—no extra equipment required.

---

## 🚧 Roadmap

| Version  | Features                                                                                                                                          |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `v0.1`   | Minimal launcher                                                                                                                                  |
| `v0.1.1` | WebSocket server                                                                                                                                  |
| `v0.1.2` | Button grid                                                                                                                                       |
| `v0.1.3` | Vibration from model                                                                                                                              |
| `v0.2`   | Basic tactile I/O grid (TOMAT-Light), connects to [TOMAT-Navi extension](https://github.com/LibreTactile/tomat-navi-prototype/tree/com/websocket) |
| `v0.2.3`   | Websocket discovery service |


---

## 🚀 Getting Started

1. **Download app**: [Releases page](https://github.com/LibreTactile/light-launcher/releases)
2. **Print the grid (optional)**: [STL files here](hardware/3d-models)
3. **Building app**: check out the [build guide](docs/docs/build-guide.md).

---

## 🤲 About TOMAT

The [TOMAT Navigator](https://github.com/libretactile/tomat) is an open-source assistive device co-designed with blind users. It provides **touchable web maps** that make navigation faster, more intuitive, and spatially meaningful.

* **Touch, listen, navigate**: Explore headings, links, and sections with your fingers and screen reader
* **Break linearity**: Skip directly to key areas
* **Designed with users**: Refined over six rounds of blind user feedback
* **Part of an ecosystem**: Browser extension, IDE tools, smart device support

---

## 📄 License & Contributions

- **License**: for now: CC BY-NC-SA 4.0 (non-commercial use only), but planning to migrate to a fully permissive open source license like MIT. see more about [TOMAT's IP strategy](https://github.com/LibreTactile/tomat-navi-prototype?tab=readme-ov-file#intellectual-property-strategy). 
- **Contributions**: Open to issues/PRs! Please follow libretactile contribution guidelines.
- **Docs**: dont forget to read [these](docs/docs/light-launcher.md) 📖

---

## 🙏 Acknowledgments

Developed with visually impaired testers. Supported by [Axelys](https://axelys.com) for ethical IP strategy. See [LibreTactile partners](https://libretactile.org).