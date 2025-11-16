import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var carManager = CarManager()
    @AppStorage("hasCompletediCloudSignIn") private var hasCompletedSignIn = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if hasCompletedSignIn {
                MainTabView(carManager: carManager, selectedTab: $selectedTab)
                    .onAppear {
                        carManager.configure(with: modelContext, iCloudEnabled: iCloudSyncEnabled)
                    }
            } else {
                iCloudSignInView(isSignedIn: $hasCompletedSignIn, iCloudEnabled: $iCloudSyncEnabled)
            }
        }
    }
}

struct MainTabView: View {
    @ObservedObject var carManager: CarManager
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomePageContent(carManager: carManager, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack {
                CollectionViewContent(carManager: carManager)
            }
            .tabItem {
                Label("Collection", systemImage: "car.2.fill")
            }
            .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Car.self)
}
