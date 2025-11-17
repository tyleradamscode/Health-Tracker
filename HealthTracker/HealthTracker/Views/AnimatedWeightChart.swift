import SwiftUI
import Charts

struct AnimatedWeightChart: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    let animationDelay: Double
    
    @State private var chartOpacity: Double = 0
    @State private var chartScale: CGFloat = 0.8
    @State private var animationProgress: Double = 0
    @State private var selectedDataPoint: ExercisePerformanceData?
    @State private var scrollToMostRecent: Bool = true
    
    private var chartWidth: CGFloat {
        let minWidth: CGFloat = 350
        let dataPointWidth: CGFloat = 55
        let calculatedWidth = CGFloat(exerciseViewModel.weightData.count) * dataPointWidth
        return max(minWidth, calculatedWidth)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ChartHeader(exerciseViewModel: exerciseViewModel)
            
            if exerciseViewModel.weightData.isEmpty {
                ChartEmptyState()
            } else {
                ChartContent(
                    exerciseViewModel: exerciseViewModel,
                    chartWidth: chartWidth,
                    animationProgress: animationProgress,
                    selectedDataPoint: $selectedDataPoint,
                    scrollToMostRecent: scrollToMostRecent,
                    updateSelectedPoint: updateSelectedPoint
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
        )
        .scaleEffect(chartScale)
        .opacity(chartOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(animationDelay)) {
                chartScale = 1.0
                chartOpacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.8).delay(animationDelay + 0.2)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func updateSelectedPoint(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        guard let date = chartProxy.value(atX: location.x, as: Date.self) else { return }
        
        let closestPoint = exerciseViewModel.weightData.min { data1, data2 in
            abs(data1.date.timeIntervalSince(date)) < abs(data2.date.timeIntervalSince(date))
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDataPoint = closestPoint
        }
        
        // Apple-style haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Chart Header
private struct ChartHeader: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ChartTitleSection(exerciseViewModel: exerciseViewModel)
                Spacer()
                if exerciseViewModel.hasWeightData {
                    ChartProgressSection(exerciseViewModel: exerciseViewModel)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }
}

// MARK: - Chart Title Section
private struct ChartTitleSection: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exerciseViewModel.chartTitle)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("\(exerciseViewModel.weightData.count) data points")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Chart Progress Section
private struct ChartProgressSection: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: exerciseViewModel.actualProgress >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(exerciseViewModel.actualProgress >= 0 ? .green : .red)
                Text(String(format: "%.1f", abs(exerciseViewModel.actualProgress)))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(exerciseViewModel.hasWeightData ? "lbs" : "")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .offset(y: 2)
            }
            Text("Progress")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
    }
}

// MARK: - Chart Empty State
private struct ChartEmptyState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text("No Data Yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text("Start tracking your workouts to see\nyour weight progress over time")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Chart Content
private struct ChartContent: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    let chartWidth: CGFloat
    let animationProgress: Double
    @Binding var selectedDataPoint: ExercisePerformanceData?
    let scrollToMostRecent: Bool
    let updateSelectedPoint: (CGPoint, GeometryProxy, ChartProxy) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Chart {
                ForEach(Array(exerciseViewModel.weightData.enumerated()), id: \.element.date) { index, data in
                    // gradient area
                    AreaMark(
                        x: .value("Date", data.date),
                        yStart: .value("Min Weight", exerciseViewModel.yAxisRange.lowerBound),
                        yEnd: .value("Weight", data.weight!)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: exerciseViewModel.progressColor.opacity(0.4), location: 0),
                                .init(color: exerciseViewModel.progressColor.opacity(0.2), location: 0.5),
                                .init(color: exerciseViewModel.progressColor.opacity(0.05), location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(animationProgress)
                    
                    // Apple-style line
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Weight", data.weight!)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                exerciseViewModel.progressColor,
                                exerciseViewModel.progressColor.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.monotone)
                    .opacity(animationProgress)
                    
                    // Apple-style data points
                    PointMark(
                        x: .value("Date", data.date),
                        y: .value("Weight", data.weight!)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(selectedDataPoint?.date == data.date ? 140 : 100)
                    .opacity(selectedDataPoint?.date == data.date ? 1.0 : 0.9 * animationProgress)
                    .shadow(color: exerciseViewModel.progressColor.opacity(0.3), radius: 3)
                    
                    // Outer ring for data points
                    PointMark(
                        x: .value("Date", data.date),
                        y: .value("Weight", data.weight!)
                    )
                    .foregroundStyle(exerciseViewModel.progressColor)
                    .symbolSize(selectedDataPoint?.date == data.date ? 160 : 120)
                    .opacity(selectedDataPoint?.date == data.date ? 1.0 : 0.8 * animationProgress)
                }
                
                // Apple-style selection indicator
                if let selectedPoint = selectedDataPoint {
                    RuleMark(x: .value("Date", selectedPoint.date))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
                        .annotation(position: .top, alignment: .center, spacing: 12) {
                            VStack(spacing: 6) {
                                Text(String(format: "%.1f lbs", selectedPoint.weight ?? 0))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(exerciseViewModel.progressColor)
                                Text(selectedPoint.date, format: .dateTime.month(.abbreviated).day())
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                        }
                }
            }
            .frame(width: chartWidth, height: 240)
            .chartYScale(domain: exerciseViewModel.yAxisRange)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: max(7, exerciseViewModel.weightData.count / 4))) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.quaternary)
                    AxisValueLabel(anchor: .bottom) {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.tertiary)
                                .offset(y: -4)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.quaternary)
                    AxisValueLabel {
                        if let weight = value.as(Float.self) {
                            Text(String(format: "%.0f", weight))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .chartBackground { chartProxy in
                ChartInteractionBackground(chartProxy: chartProxy, updateSelectedPoint: updateSelectedPoint, selectedDataPoint: $selectedDataPoint)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 24)
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: .constant(scrollToMostRecent ? exerciseViewModel.weightData.last?.date : nil))
        .padding(.bottom, 24)
    }
}


// MARK: - Chart Interaction
private struct ChartInteractionBackground: View {
    let chartProxy: ChartProxy
    let updateSelectedPoint: (CGPoint, GeometryProxy, ChartProxy) -> Void
    @Binding var selectedDataPoint: ExercisePerformanceData?
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let location = value.location
                            updateSelectedPoint(location, geometry, chartProxy)
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.4)) {
                                selectedDataPoint = nil
                            }
                        }
                )
        }
    }
}

#Preview {
    let mockExercise = Exercise(id: "1", name: "Bicep Curls")
    let mockViewModel = ExerciseViewModel(exercise: mockExercise, workoutSummaries: [])
    
    AnimatedWeightChart(
        exerciseViewModel: mockViewModel,
        animationDelay: 0.0
    )
    .padding()
}
