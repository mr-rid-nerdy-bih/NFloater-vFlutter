# NeutraFloater Control App

[![Flutter](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A real-time, cross-platform mobile application built with Flutter to monitor, calibrate, and control the **NeutraFloater** hardware system. Operating over a direct Wi-Fi connection, this app provides fluid data visualization and instant manual overrides directly from any Android or iOS device.

---

## Abstract

The **NeutraFloater Control App** serves as the mobile command center for the NeutraFloater hardware unit. By establishing a dedicated local Wi-Fi link with the hardware, the app continuously processes streaming telemetry packets, monitors real-time stabilization/buoyancy metrics, and transmits zero-latency command configurations. This untethers operators from physical hardware lines, allowing safe and efficient field diagnostics.

---

## Key Features

* **Real-Time Telemetry Graphs:** Smooth, multi-axis rendering of pitch, roll, depth, and stabilization variables via hardware streams.
* **Wireless Command Overrides:** Low-latency manual controls over Wi-Fi (via WebSockets or UDP) for rapid adjustments.
* **On-Field Calibration Suite:** Interactive setup wizards to balance, tare, and zero system sensors prior to deployment.
* **Local Session Logging:** Keeps a local history of run logs, performance metrics, and system errors for offline diagnostics.
* **Native Performance:** Fully compiled native UI ensuring smooth 60fps/120fps rendering on both iOS and Android.

---

## Core Architecture (Mobile-to-Hardware)

The application establishes a direct network socket pipeline with the floating unit:


```

+---------------------------+               +----------------------------+
|   NeutraFloater Hardware  |  Local Wi-Fi  |   Flutter Mobile App       |
|  (Sensors, ESP32/STM32,   | ------------> |  (StreamBuilder UI,        |
|   Wi-Fi Module, Actuators)| <------------ |   fl_chart Telemetry)      |
+---------------------------+  Sockets/WS   +----------------------------+

```

1. **Hardware Layer:** The physical unit acts as a local Wi-Fi Access Point (AP) or connects to a shared field router.
2. **Data Pipeline:** Continuous data packets are broadcast as JSON strings over WebSockets or raw UDP packets.
3. **Application Layer:** Flutter consumes the data stream using a `StreamBuilder` or state management provider, repainting the UI seamlessly as packets arrive.

---

## Technical Stack

* **Framework:** Flutter (Dart)
* **State Management:** Provider / Riverpod / BLoC (for clean telemetry stream distribution)
* **Real-time Sockets:** `web_socket_channel` or native Dart `RawDatagramSocket` (UDP)
* **HTTP Networking:** `dio` or `http` (for initial device handshakes/firmware checks)
* **Data Visualization:** `fl_chart` (for high-performance real-time telemetry plotting)

---

## Getting Started (Development)

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable version)
* Android Studio (for Android toolchain) / Xcode (for iOS toolchain, macOS required)

### Setup & Run

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/neutrafloater-app.git](https://github.com/yourusername/neutrafloater-app.git)
   cd neutrafloater-app

```
```

2. **Fetch dependencies:**
```bash
flutter pub get

```


3. **Run on a connected device/emulator:**
```bash
flutter run

```



---

## Field Connection Protocol

1. Power on the **NeutraFloater** hardware unit.
2. Open your mobile device's Wi-Fi settings and connect to the network: `NeutraFloater_AP_XXXX`.
3. Launch the app. The system will auto-detect the gateway IP and transition from **"Searching for Device..."** to **"Connected"**.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

```
