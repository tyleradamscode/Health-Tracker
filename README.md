# HealthTracker

A SwiftUI-based iOS application for tracking exercise performance and visualizing workout progress over time.

## Architecture

### MVVM Pattern
- **Models**: Defines data structures for exercises, workouts, and performance metrics.
- **Views**: SwiftUI components with minimal business logic.
- **ViewModels**: Handles business logic, data processing, and state management.
- **Controllers**: Manages data loading and coordination.

### Project Structure
```
HealthTracker/
├── Models/                    # Data structures
├── Views/                     # SwiftUI Views
├── ViewModels/                # Business logic
├── Controllers/               # Data coordination
├── Helpers/                   # Utilities & extensions
└── Data/                      # JSON workout data
```

## Key Features

- **Performance Tracking**: Monitors weight, reps, duration, volume, and distance.
- **Progress Visualization**: Animated charts and color-coded indicators for showing progress trends.
- **Data-driven Design**: Comprehensive workout history and performance metrics.
- **User Experience**: Real-time search, responsive interface, and smooth animations.

### Requirements
- iOS 17.6+
- Xcode 16.0+
- Swift 5.9+

### Data Format
The app loads workout data from JSON files located in the `Data/summaries/` directory. Each JSON file represents a workout session.

## Demo

### Video Demo
[Watch Video Demo](./Video%20Demo.mp4)

### Screenshots

<div align="center">
  <img src="./Screenshots/1-light.png" width="250" alt="Exercise List Light Mode">
  <img src="./Screenshots/1-dark.png" width="250" alt="Exercise List Dark Mode">
</div>

<div align="center">
  <img src="./Screenshots/2-light.png" width="250" alt="Exercise Detail Light Mode">
  <img src="./Screenshots/2-dark.png" width="250" alt="Exercise Detail Dark Mode">
</div>

<div align="center">
  <img src="./Screenshots/3-light.png" width="250" alt="Performance Chart Light Mode">
  <img src="./Screenshots/3-dark.png" width="250" alt="Performance Chart Dark Mode">
</div>

<div align="center">
  <img src="./Screenshots/4-light.png" width="250" alt="Metrics View Light Mode">
  <img src="./Screenshots/4-dark.png" width="250" alt="Metrics View Dark Mode">
</div>

<div align="center">
  <img src="./Screenshots/5-light.png" width="250" alt="Search Feature Light Mode">
  <img src="./Screenshots/5-dark.png" width="250" alt="Search Feature Dark Mode">
</div>

<div align="center">
  <img src="./Screenshots/6-light.png" width="250" alt="Progress Tracking Light Mode">
  <img src="./Screenshots/6-dark.png" width="250" alt="Progress Tracking Dark Mode">
</div>

---

*Built with SwiftUI, following modern iOS development best practices and clean architecture principles.*
