import SwiftUI

struct ProgressIndicator: View {
    let icon: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(description)
                .foregroundColor(color)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        ProgressIndicator(icon: "arrow.up.circle.fill", description: "Improving", color: .green)
        ProgressIndicator(icon: "minus.circle.fill", description: "Stable", color: .orange)
        ProgressIndicator(icon: "arrow.down.circle.fill", description: "Declining", color: .red)
    }
    .padding()
}
