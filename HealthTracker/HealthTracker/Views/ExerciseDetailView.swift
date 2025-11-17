import SwiftUI
import Charts

struct ExerciseDetailView: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    init(exercise: Exercise, workoutSummaries: [WorkoutSummary]) {
        _exerciseViewModel = ObservedObject(initialValue: ExerciseViewModel(exercise: exercise, workoutSummaries: workoutSummaries))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressOverviewCard(exerciseViewModel: exerciseViewModel)
                
                if exerciseViewModel.hasWeightData {
                    AnimatedWeightChart(
                        exerciseViewModel: exerciseViewModel,
                        animationDelay: 1.0
                    )
                }
                
                PerformanceHistorySection(exerciseViewModel: exerciseViewModel)
            }
            .padding()
        }
        .navigationTitle(exerciseViewModel.displayName)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Progress Overview Card
private struct ProgressOverviewCard: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressStatusHeader(exerciseViewModel: exerciseViewModel)
            StatsGrid(exerciseViewModel: exerciseViewModel)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Progress Status Header
private struct ProgressStatusHeader: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: exerciseViewModel.progressIcon)
                    .foregroundColor(exerciseViewModel.progressColor)
                    .font(.title2)
                    .frame(width: 24, height: 24)
                Text(exerciseViewModel.progressDescription)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(exerciseViewModel.progressColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(exerciseViewModel.progressColor.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
        }
    }
}

// MARK: - Stats Grid
private struct StatsGrid: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            AnimatedStatCard(
                title: "Total Sessions", 
                value: "\(exerciseViewModel.totalSessions)", 
                icon: "calendar", 
                animationDelay: 0.0
            )
            
            if let avgWeight = exerciseViewModel.averageWeight {
                AnimatedStatCard(
                    title: "Avg Weight", 
                    value: String(format: "%.1f lbs", avgWeight), 
                    icon: "scalemass", 
                    animationDelay: 0.1
                )
            }
            
            if let maxWeight = exerciseViewModel.maxWeightOptional {
                AnimatedStatCard(
                    title: "Max Weight", 
                    value: String(format: "%.1f lbs", maxWeight), 
                    icon: "scalemass.fill", 
                    animationDelay: 0.2
                )
            }
            
            if let avgReps = exerciseViewModel.averageReps {
                AnimatedStatCard(
                    title: "Avg Reps", 
                    value: "\(avgReps)", 
                    icon: "repeat", 
                    animationDelay: 0.3
                )
            }
            
            if let maxReps = exerciseViewModel.maxReps {
                AnimatedStatCard(
                    title: "Max Reps", 
                    value: "\(maxReps)", 
                    icon: "repeat.1", 
                    animationDelay: 0.4
                )
            }
        }
    }
}

// MARK: - Performance History Section
private struct PerformanceHistorySection: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance History")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(exerciseViewModel.performanceHistory.reversed(), id: \.date) { data in
                    PerformanceRowView(
                        data: data,
                        allExerciseTypes: exerciseViewModel.exerciseTypes
                    )
                }
            }
        }
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: Exercise(id: "1", name: "Bicep Curls"), workoutSummaries: [])
    }
}

