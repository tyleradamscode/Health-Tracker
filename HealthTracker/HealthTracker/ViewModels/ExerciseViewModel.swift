import SwiftUI
import Foundation

struct ExercisePerformanceData {
    let date: Date
    let weight: Float?
    let reps: Int?
    let timeSpentActive: Int?
    let startedAt: Date?
    let distance: Double?
    let exerciseType: ExerciseSetType
    let intensity: String?
    let isTwoDumbbells: Bool?
    let position: Int?
    
    // Calculated properties
    var volume: Float? {
        guard let weight = weight, let reps = reps else { return nil }
        return weight * Float(reps)
    }
    
    var setDuration: TimeInterval? {
        guard let startedAt = startedAt else { return nil }
        return date.timeIntervalSince(startedAt)
    }
    
    var averageTimePerRep: Double? {
        guard let timeActive = timeSpentActive, let reps = reps, reps > 0 else { return nil }
        return Double(timeActive) / Double(reps)
    }
    
    var intensityDisplayName: String? {
        guard let intensity = intensity, !intensity.isEmpty else { return nil }
        return Intensity(rawValue: intensity)?.displayName
    }
}

class ExerciseViewModel: ObservableObject {
    let exercise: Exercise
    @Published var performanceHistory: [ExercisePerformanceData] = []
    @Published var progressTrend: ProgressTrend = .stable
    
    enum ProgressTrend {
        case improving
        case declining
        case stable
    }
    
    init(exercise: Exercise, workoutSummaries: [WorkoutSummary]) {
        self.exercise = exercise
        loadPerformanceHistory(from: workoutSummaries)
        calculateProgressTrend()
    }
    
    private func loadPerformanceHistory(from workoutSummaries: [WorkoutSummary]) {
        var history: [ExercisePerformanceData] = []
        
        for summary in workoutSummaries.sortedByStartedAtDate() {
            for setSummary in summary.setSummaries {
                if let exerciseSet = setSummary.exerciseSet,
                   let exerciseFromSet = exerciseSet.exercise,
                   exerciseFromSet.id == exercise.id,
                   let completedAt = setSummary.completedAt {
                    
                    let performanceData = ExercisePerformanceData(
                        date: completedAt,
                        weight: setSummary.weightUsed,
                        reps: setSummary.repsCompleted,
                        timeSpentActive: setSummary.timeSpentActive,
                        startedAt: setSummary.startedAt,
                        distance: exerciseSet.distance,
                        exerciseType: exerciseSet.type,
                        intensity: exerciseSet.intensity,
                        isTwoDumbbells: exerciseSet.isTwoDumbbells,
                        position: exerciseSet.position
                    )
                    history.append(performanceData)
                }
            }
        }
        
        self.performanceHistory = history
    }
    
    private func calculateProgressTrend() {
        guard performanceHistory.count >= 2 else {
            progressTrend = .stable
            return
        }
        
        // Calculate trend based on weight progression
        let recentPerformances = Array(performanceHistory.suffix(3))
        let earlierPerformances = Array(performanceHistory.prefix(3))
        
        let recentAvgWeight = recentPerformances.compactMap { $0.weight }.reduce(0, +) / Float(max(1, recentPerformances.compactMap { $0.weight }.count))
        let earlierAvgWeight = earlierPerformances.compactMap { $0.weight }.reduce(0, +) / Float(max(1, earlierPerformances.compactMap { $0.weight }.count))
        
        if recentAvgWeight > earlierAvgWeight + 2.5 { // 2.5 lbs improvement threshold
            progressTrend = .improving
        } else if recentAvgWeight < earlierAvgWeight - 2.5 { // 2.5 lbs decline threshold
            progressTrend = .declining
        } else {
            progressTrend = .stable
        }
    }
    
    // MARK: - Computed Properties
    
    var displayName: String {
        var name = exercise.name ?? "Unknown Exercise"
        if let sideDisplayName = exercise.sideDisplayName {
            name += " (\(sideDisplayName))"
        }
        return name
    }
    
    var totalSessions: Int {
        performanceHistory.count
    }
    
    var averageWeight: Float? {
        let weights = performanceHistory.compactMap { $0.weight }
        guard !weights.isEmpty else { return nil }
        return weights.reduce(0, +) / Float(weights.count)
    }
    
    var maxWeightOptional: Float? {
        performanceHistory.compactMap { $0.weight }.max()
    }
    
    var averageReps: Int? {
        let reps = performanceHistory.compactMap { $0.reps }
        guard !reps.isEmpty else { return nil }
        return reps.reduce(0, +) / reps.count
    }
    
    var maxReps: Int? {
        performanceHistory.compactMap { $0.reps }.max()
    }
    
    var averageVolume: Float? {
        let volumes = performanceHistory.compactMap { $0.volume }
        guard !volumes.isEmpty else { return nil }
        return volumes.reduce(0, +) / Float(volumes.count)
    }
    
    var maxVolume: Float? {
        performanceHistory.compactMap { $0.volume }.max()
    }
    
    var totalDistance: Double? {
        let distances = performanceHistory.compactMap { $0.distance }
        guard !distances.isEmpty else { return nil }
        return distances.reduce(0, +)
    }
    
    var averageSetDuration: Double? {
        let durations = performanceHistory.compactMap { $0.setDuration }
        guard !durations.isEmpty else { return nil }
        return durations.reduce(0, +) / Double(durations.count)
    }
    
    var exerciseTypes: Set<ExerciseSetType> {
        Set(performanceHistory.map { $0.exerciseType })
    }
    
    // MARK: - Chart Data Properties
    
    var weightData: [ExercisePerformanceData] {
        performanceHistory
            .filter { $0.weight != nil && $0.weight! > 0 }
            .sorted { $0.date < $1.date }
    }
    
    var chartTitle: String {
        let types = exerciseTypes
        if types.contains(.distance) {
            return "Distance Progress"
        } else if types.contains(.duration) {
            return "Duration Progress"
        } else {
            return "Weight Progress"
        }
    }
    
    var actualProgress: Float {
        guard let firstWeight = weightData.first?.weight,
              let lastWeight = weightData.last?.weight else { return 0 }
        return lastWeight - firstWeight
    }
    
    var minWeight: Float {
        weightData.compactMap { $0.weight }.min() ?? 0
    }
    
    var maxWeight: Float {
        weightData.compactMap { $0.weight }.max() ?? 0
    }
    
    var weightRange: Float {
        maxWeight - minWeight
    }
    
    var yAxisRange: ClosedRange<Float> {
        let padding = max(weightRange * 0.15, 5.0)
        return (minWeight - padding)...(maxWeight + padding)
    }
    
    var hasWeightData: Bool {
        !weightData.isEmpty
    }
    
    var progressIcon: String {
        switch progressTrend {
        case .improving:
            return "arrow.up.circle.fill"
        case .declining:
            return "arrow.down.circle.fill"
        case .stable:
            return "minus.circle.fill"
        }
    }
    
    var progressColor: Color {
        switch progressTrend {
        case .improving:
            return .green
        case .declining:
            return .red
        case .stable:
            return .orange
        }
    }
    
    var progressDescription: String {
        switch progressTrend {
        case .improving:
            return "Improving"
        case .declining:
            return "Declining"
        case .stable:
            return "Stable"
        }
    }
}
