import SwiftUI

struct ExerciseListView: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    
    var body: some View {
        NavigationView {
            ExerciseList(viewModel: viewModel)
                .searchable(text: $viewModel.searchText, prompt: "Search exercises...")
                .navigationTitle("Exercise Progress")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Exercise List
private struct ExerciseList: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    
    var body: some View {
        List(viewModel.filteredExercises, id: \.id) { exercise in
            ExerciseListItem(exercise: exercise, workoutSummaries: viewModel.workoutSummaries)
        }
    }
}

// MARK: - Exercise List Item
private struct ExerciseListItem: View {
    let exercise: Exercise
    let workoutSummaries: [WorkoutSummary]
    
    var body: some View {
        NavigationLink(destination:
            ExerciseDetailView(
                exercise: exercise,
                workoutSummaries: workoutSummaries
            )
        ) {
            ExerciseRow(exercise: exercise, workoutSummaries: workoutSummaries)
        }
    }
}

// MARK: - Exercise Row
struct ExerciseRow: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    init(exercise: Exercise, workoutSummaries: [WorkoutSummary]) {
        _exerciseViewModel = ObservedObject(initialValue: ExerciseViewModel(exercise: exercise, workoutSummaries: workoutSummaries))
    }
    
    var body: some View {
        HStack {
            ExerciseInfo(exerciseViewModel: exerciseViewModel)
            Spacer()
            ExerciseProgress(exerciseViewModel: exerciseViewModel)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Exercise Info
private struct ExerciseInfo: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ExerciseTitle(exerciseViewModel: exerciseViewModel)
            ExerciseMetrics(exerciseViewModel: exerciseViewModel)
            ExerciseMuscleGroups(exerciseViewModel: exerciseViewModel)
        }
    }
}

// MARK: - Exercise Title
private struct ExerciseTitle: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        Text(exerciseViewModel.displayName)
            .font(.headline)
            .lineLimit(2)
    }
}

// MARK: - Exercise Metrics
private struct ExerciseMetrics: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            ExerciseMetricLabel(icon: "calendar", text: "\(exerciseViewModel.totalSessions)")
            
            if let maxWeight = exerciseViewModel.maxWeightOptional, maxWeight > 0 {
                ExerciseMetricLabel(icon: "scalemass", text: String(format: "%.0f lbs", maxWeight))
            }
            
            if let maxReps = exerciseViewModel.maxReps, maxReps > 0 {
                ExerciseMetricLabel(icon: "repeat", text: "\(maxReps) reps")
            }
        }
    }
}

// MARK: - Exercise Muscle Groups
private struct ExerciseMuscleGroups: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        if let muscleGroups = exerciseViewModel.exercise.muscleGroups {
            Text(muscleGroups)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Exercise Progress
private struct ExerciseProgress: View {
    @ObservedObject var exerciseViewModel: ExerciseViewModel
    
    var body: some View {
        ProgressIndicator(
            icon: exerciseViewModel.progressIcon,
            description: exerciseViewModel.progressDescription,
            color: exerciseViewModel.progressColor
        )
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView()
    }
}

