import SwiftUI

struct ExerciseMetricLabel: View {
    let icon: String
    let text: String
    
    var body: some View {
        Label {
            Text(text)
                .font(.caption)
        } icon: {
            Image(systemName: icon)
                .imageScale(.small)
        }
        .foregroundStyle(.secondary)
        .labelStyle(.titleAndIcon)
    }
}

#Preview {
    HStack {
        ExerciseMetricLabel(icon: "calendar", text: "12")
        ExerciseMetricLabel(icon: "scalemass", text: "135 lbs")
        ExerciseMetricLabel(icon: "repeat", text: "8 reps")
    }
    .padding()
}
