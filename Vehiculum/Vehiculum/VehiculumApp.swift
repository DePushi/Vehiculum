import SwiftUI
import SwiftData

@main
struct VehiculumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Car.self)
    }
}
