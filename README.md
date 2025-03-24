# Light Launcher
(Mobile Derivative of TOMAT Navigator)  
*A tactile Android launcher for nonlinear, accessible interaction*

**Light Launcher** is an Android app paired with a 3D-printed tactile guide, designed to replicate the [TOMAT Navigator](https://github.com/LibreTactile/tomat) interaction experience on mobile devices. It enables **nonlinear, multimodal and contextual navigation** of apps, files, and settings through audio-tactile feedback, prioritizing accessibility for visually impaired users.

---

## Key Features  
**Core Interaction**  
- 🖐️ **Tactile and Contextual Interactions**: Use the 3D-printed grid or pair with TOMAT derivatives hardware for gesture-based navigation. 
- 📱 **Nonlinear Android Launcher**: Navigate apps/files in nonlinear hierarchies, extending traditional menus.  
- 🔍 **Multiscale Views**: Zoom between high-level overviews (e.g., app categories) and granular details (e.g., individual files, annotations).  

**Accessibility**  
- 🔊 **Screen Reader Integration**: Works seamlessly with TalkBack (CoiceOver planned for the future).  
- 🎮 **Gesture & Audio Feedback**: Double-tap, swipe, and press-and-hold gestures with contextual audio cues.  

**Advanced Tools**  
- 🕸️ **Graph-Based Modeling**: Visualize relationships between apps/files as interactive graphs. Use SPARQL to query "meaninfully search" the graph.  
- 🧩 **Custom Perspectives**: Create "viewports"/"windows" for workflows (e.g., "Work Mode," "Entertainment Mode").  

---

## Hardware + Software  
| Component              | Description                                                                 |  
|------------------------|-----------------------------------------------------------------------------|  
| **Android App**        | Built with Godot (pending v0.3: minimal graph launcher POC). [~~Download APK~~](link-to-apk) |  
| **3D-Printed Grid**    | Tactile overlay for phones/tablets. [~~STL Files~~](hardware/3d-models) (pending phase 2)         |  
| Peripherials| TOMAT;Wearable sensations; bluetooth/usb gamepad; hid devices, etc...  |

---

## Roadmap  
**Phase 1: Core Functionality (v0.1–v0.3)**  
- `v0.1`: Minimal launcher  
  - `v0.1.1` websocket server 
  - `v0.1.2` buttons grid
  - `v0.1.3` vibration patterns from recieved model 
- `v0.2`: "Light TOMAT" mode (basic tactile feedback grid)  
- `v0.3`: Graph visualization of text and metadata annotations (basic gestures)  
- `v0.4`: Editable metadata tagging for media and markdown files 

**Phase 2: TOMAT Integration (v0.4–v0.6)**  
- `v0.5`: Hierarchy mode (group apps/files into custom clusters) to show different perspectives/windows  
- `v0.6`: Expose Android Accessibility features
- `v0.7`: Full TOMAT mode (advanced tactile patterns, AI-driven navigation, screen reader interaction)  

**Phase 3: Semantic Queries (v0.7–v0.10)**  
- `v0.8–v0.9`: App/file relationship graphs  
- `v0.10–v0.11`: SPARQL endpoint integration for natural language queries, open linked data and semantic web (i.e. europeana, gallica, semantic wikimedia)  

---


Not yet planned  
---

**Phase 4: Plugin Ecosystem**  
- Introduce **Light Plugins**—extend functionality via external repositories (e.g., custom gestures, app integrations, or accessibility tools).  

**Phase 5: Universal Accessibility Interface**  
- Expand compatibility to act as a **TOMAT Navigator for other devices** (e.g., PCs, smart TVs, IoT devices).  
- Develop a **Universal Accessibility Protocol** for Android, enabling apps to render processes, settings, and data accessible via nonlinear, multimodal navigation (e.g., tactile, audio, gesture).  

---

## Get Started  
1. **Install the APK**: Download from the release page ~~or the google playstore~~.  
2. **Get the hardware (optional)**: Use [3D models](hardware/3d-models) to print the guide, contact your local FabLab.  
3. **Enable Accessibility**: Activate Light Launcher in Android’s accessibility settings.  

---

## License & Contribution  
- **License**: for now: CC BY-NC-SA 4.0 (non-commercial use only), but planning to migrate to a fully permissive open source license like MIT.
- **Contributions**: Open to issues/PRs! Please follow libretactile contribution guidelines.  

---

## About TOMAT Navigator  
The [TOMAT Navigator](https://github.com/libretactile/tomat) is an open-source assistive device co-designed with visually impaired users. It combines AI, tactile grids, and screen readers to make web navigation intuitive. Light Launcher extends this philosophy to mobile.  

---

**Acknowledgments**: Developed with feedback from visually impaired testers. Supported by [Axelys](https://axelys.com) for ethical IP strategy.  Check out libretactile's partners.
