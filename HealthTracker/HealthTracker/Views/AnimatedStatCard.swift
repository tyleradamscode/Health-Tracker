import SwiftUI

struct AnimatedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let animationDelay: Double
    
    @State private var animatedValue: Double = 0
    @State private var hasAppeared = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    // Extract numeric value for animation
    private var numericValue: Double {
        let cleanValue = value.replacingOccurrences(of: " lbs", with: "")
            .replacingOccurrences(of: " reps", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(cleanValue) ?? 0
    }
    
    private var isNumeric: Bool {
        numericValue > 0
    }
    
    private var displayValue: String {
        if isNumeric && hasAppeared {
            let suffix = value.contains("lbs") ? " lbs" : (value.contains("reps") ? " reps" : "")
            if value.contains(".") {
                return String(format: "%.1f%@", animatedValue, suffix)
            } else {
                return "\(Int(animatedValue))\(suffix)"
            }
        }
        return hasAppeared ? value : "0"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(displayValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentTransition(.numericText())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            hasAppeared = true
            
            // Animate appearance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(animationDelay)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Animate number counting
            if isNumeric {
                withAnimation(.easeOut(duration: 1.5).delay(animationDelay + 0.3)) {
                    animatedValue = numericValue
                }
            }
        }
    }
}

struct AnimatedStatCard_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedStatCard(title: "Total Sessions", value: "16", icon: "calendar", animationDelay: 0.0)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
