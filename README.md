# NeutraFloater Dashboard

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen.svg)]()

An intuitive, real-time wireless dashboard application designed to monitor, control, and calibrate the **NeutraFloater** system. Utilizing robust Wi-Fi technology, this application bridges the gap between hardware telemetry and user control, providing seamless data visualization and micro-adjustments on the fly.

---

## Abstract

The **NeutraFloater Dashboard** serves as the primary control intelligence hub for the NeutraFloater hardware system. By establishing a dedicated local or networked Wi-Fi connection, the app continuously fetches telemetry data, monitors buoyancy/stabilization metrics, and allows operators to send instantaneous command overrides. This eliminates the need for restrictive physical tethering, enabling safe and flexible remote diagnostics.

---

## Key Features

* **Real-Time Telemetry Streaming:** Low-latency data visualization of pitch, roll, depth, and stabilization variables.
* **Wireless Control & Overrides:** Direct command transmission over Wi-Fi (via WebSockets / HTTP REST) for instant manual adjustments.
* **Dynamic Calibration Tools:** On-screen wizards to balance, tare, and zero the system sensors before deployment.
* **Historical Data Logging:** Local storage capabilities to review performance graphs, error logs, and operational trends.
* **Responsive UI:** Optimized for both field tablets and desktop control stations.

---

## System Architecture

The NeutraFloater ecosystem relies on a seamless hardware-to-software pipeline:


```

+---------------------------+               +----------------------------+
|   NeutraFloater Hardware  |  Wi-Fi Local  |    NeutraFloater App       |
|  (Sensors, ESP32/STM32,   | ------------> |  (Real-Time Dashboard,     |
|   Wi-Fi Module, Actuators)| <------------ |   Control UI & Graphs)     |
+---------------------------+   TCP/UDP/WS  +----------------------------+

```

1. **Hardware Layer:** The core floating unit handles physical stabilization and hosts a local Wi-Fi Access Point (AP) or connects to a designated network.
2. **Communication Protocol:** Employs lightweight data exchange formats (JSON over WebSockets or MQTT) to ensure rapid response times.
3. **Application Layer:** The dashboard parses incoming data packets into clean, scannable visual gauges.

---

## Getting Started

### Prerequisites

Before launching the dashboard, ensure you have the following installed:
* [Node.js](https://nodejs.org/) (v18.0 or higher recommended)
* [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/neutrafloater-dashboard.git](https://github.com/yourusername/neutrafloater-dashboard.git)
   cd neutrafloater-dashboard

```
```

2. **Install dependencies:**
```bash
npm install

```


3. **Configure Environment Variables:**
Create a `.env` file in the root directory and specify your hardware IP address:
```env
VITE_FLOATER_IP=11.22.33.44
VITE_WS_PORT=8080

```


4. **Run the Development Server:**
```bash
npm run dev

```


Open your browser and navigate to `http://localhost:5173` (or the port specified in your terminal).

---

## Connection Strategy (Wi-Fi)

To connect the application to the physical NeutraFloater device:

1. Power on the **NeutraFloater** hardware unit.
2. On your host device (PC/Tablet), connect to the Wi-Fi network: `NeutraFloater_AP_XXXX`.
3. Launch this dashboard application.
4. Check the top status bar to verify the connection indicator reads **CONNECTED**.

---

## Development Stack (Suggested)

* **Frontend Framework:** React.js / Vue.js / Svelte (via Vite)
* **Styling:** Tailwind CSS (for modern, highly responsive utility layouts)
* **Charts & Gauges:** Chart.js / Recharts (for fluid real-time data plotting)
* **Networking:** Axios (HTTP) & Native WebSockets (for continuous telemetry)

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

```
