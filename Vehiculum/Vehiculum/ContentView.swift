import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var carManager = CarManager()
    
    var body: some View {
        TabView {
            HomePage(carManager: carManager)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CollectionView(carManager: carManager)
                .tabItem {
                    Label("Collection", systemImage: "car.2.fill")
                }
        }
        .onAppear {
            carManager.configure(with: modelContext)
        }
    }
}
