import SwiftUI

struct PerformanceRowView: View {
    let data: ExercisePerformanceData
    let allExerciseTypes: Set<ExerciseSetType>
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                PerformanceHeader(data: data, allExerciseTypes: allExerciseTypes, dateFormatter: dateFormatter)
                PrimaryMetricsRow(data: data)
                SecondaryMetricsRow(data: data)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // Only show type badge if there are multiple exercise types for this exercise
    private var shouldShowTypeBadge: Bool {
        allExerciseTypes.count > 1
    }
    
    // Helper function for exercise type colors
    private func typeColor(for type: ExerciseSetType) -> Color {
        switch type {
        case .reps:
            return .blue
        case .duration:
            return .green
        case .distance:
            return .purple
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Performance Header
private struct PerformanceHeader: View {
    let data: ExercisePerformanceData
    let allExerciseTypes: Set<ExerciseSetType>
    let dateFormatter: DateFormatter
    
    private var shouldShowTypeBadge: Bool {
        allExerciseTypes.count > 1
    }
    
    private func typeColor(for type: ExerciseSetType) -> Color {
        switch type {
        case .reps: return .blue
        case .duration: return .green
        case .distance: return .purple
        case .unknown: return .gray
        }
    }
    
    var body: some View {
        HStack {
            Text(dateFormatter.string(from: data.date))
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            // Only show exercise type badge if it's not the common "reps" type
            // or if there are multiple types for this exercise
            if data.exerciseType != .reps || shouldShowTypeBadge {
                ExerciseTypeBadge(exerciseType: data.exerciseType, color: typeColor(for: data.exerciseType))
            }
        }
    }
}

// MARK: - Exercise Type Badge
private struct ExerciseTypeBadge: View {
    let exerciseType: ExerciseSetType
    let color: Color
    
    var body: some View {
        Text(exerciseType.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
            )
    }
}

// MARK: - Primary Metrics Row
private struct PrimaryMetricsRow: View {
    let data: ExercisePerformanceData
    
    var body: some View {
        HStack(spacing: 12) {
            if let weight = data.weight, weight > 0 {
                MetricView(
                    icon: "scalemass", 
                    value: String(format: "%.1f", weight), 
                    unit: data.isTwoDumbbells == true ? "db" : "lbs"
                )
            }
            
            if let reps = data.reps, reps > 0 {
                MetricView(icon: "repeat", value: "\(reps)", unit: "reps")
            }
            
            if let timeActive = data.timeSpentActive, timeActive > 0 {
                MetricView(icon: "clock", value: "\(timeActive)", unit: "s")
            }
            
            if let volume = data.volume, volume > 0 {
                MetricView(icon: "gauge", value: String(format: "%.0f", volume), unit: "vol")
            }
            
            if let distance = data.distance, distance > 0 {
                MetricView(icon: "ruler", value: String(format: "%.1f", distance), unit: "m")
            }
        }
    }
}

// MARK: - Secondary Metrics Row
private struct SecondaryMetricsRow: View {
    let data: ExercisePerformanceData
    
    var body: some View {
        if data.setDuration != nil || data.intensityDisplayName != nil || data.averageTimePerRep != nil {
            HStack(spacing: 12) {
                if let setDuration = data.setDuration {
                    MetricView(icon: "stopwatch", value: String(format: "%.1f", setDuration), unit: "dur")
                }
                
                if let avgTimePerRep = data.averageTimePerRep {
                    MetricView(icon: "timer", value: String(format: "%.1f", avgTimePerRep), unit: "s/rep")
                }
                
                if let intensity = data.intensityDisplayName {
                    IntensityIndicator(intensity: intensity)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Intensity Indicator
private struct IntensityIndicator: View {
    let intensity: String
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "thermometer.sun")
                .foregroundColor(.orange)
                .font(.caption2)
            Text(intensity)
                .font(.caption2)
                .foregroundColor(.orange)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Reusable Metric View
struct MetricView: View {
    let icon: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct PerformanceRowView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceRowView(
            data: ExercisePerformanceData(
                date: Date(),
                weight: 35.0,
                reps: 12,
                timeSpentActive: 45,
                startedAt: Date().addingTimeInterval(-60),
                distance: 100.0,
                exerciseType: .reps,
                intensity: "weight_moderate",
                isTwoDumbbells: false,
                position: 1
            ),
            allExerciseTypes: [.reps]
        )
        .padding()
    }
}
