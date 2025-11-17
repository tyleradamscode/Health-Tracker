import SwiftUI
import Combine

class ExerciseListViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var searchText: String = ""
    var workoutSummaries: [WorkoutSummary]
    
    // Computed property for filtered and sorted exercises
    var filteredExercises: [Exercise] {
        let filtered = searchText.isEmpty ? exercises : exercises.filter { exercise in
            (exercise.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (exercise.muscleGroups?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        return filtered
    }

    init() {
        // Load workout summaries
        let workoutsController = WorkoutsController()
        self.workoutSummaries = workoutsController.workoutSummaries

        // Extract exercises from workout summaries
        loadExercises()
    }

    private func loadExercises() {
        var exerciseSet: [Exercise] = []
        for summary in workoutSummaries {
            let sortedSetSummaries = summary.setSummaries.sorted { $0.startedAt ?? Date.distantPast < $1.startedAt ?? Date.distantPast }
            for setSummary in sortedSetSummaries {
                if let exercise = setSummary.exerciseSet?.exercise {
                    guard !exerciseSet.contains(exercise) else { continue }
                    exerciseSet.append(exercise)
                }
            }
        }
        self.exercises = exerciseSet
    }
}
