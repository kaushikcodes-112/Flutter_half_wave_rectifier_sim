# half_wave_rectifier

A new Flutter project.

# Half-Wave Rectifier Simulator

An interactive electrical engineering simulator built with Flutter and Dart to demonstrate the operation of a half-wave rectifier.

## Features

- Interactive circuit parameter controls
- Input AC waveform visualization
- Rectified output waveform visualization
- Adjustable input voltage and frequency
- Configurable load resistance and diode forward voltage
- Automated tests for basic simulation behavior

## Tech Stack

- Flutter
- Dart
- Flutter CustomPainter for circuit and waveform visualization
- Flutter Widget Testing

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (included with Flutter)

### Run the Application

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/half-wave-rectifier-simulator.git
cd half-wave-rectifier-simulator
```

Install dependencies:

```bash
flutter pub get
```

Run the web version (uses locally bundled Flutter web resources, avoiding runtime requests to Google's font and CanvasKit CDNs):

```bash
powershell -ExecutionPolicy Bypass -File tool/run_web.ps1
```

Build a release web bundle for hosting:

```bash
powershell -ExecutionPolicy Bypass -File tool/build_web.ps1
```

The release files are written to `build/web`. Keep the generated `canvaskit` directory with the rest of the web bundle when deploying.

## Run Tests

Execute the automated tests:

```bash
flutter test
```

## Project Status

Under development. The simulator is being tested and prepared for Android packaging.
