
import Foundation

class SettingsModel: ObservableObject {
    // As per the spec, the number of lines to display is a key setting.
    // Defaulting to 3 for now.
    @Published var lineCount: Int = 3

    // Future settings from the roadmap can be added here:
    // - Persisted window size/position
    // - Progress bar visibility
}
