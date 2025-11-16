import SwiftUI

struct CollectionViewContent: View {
    @ObservedObject var carManager: CarManager
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Titolo personalizzato
            Text("My Collection")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            ZStack {
                if carManager.isLoading {
                    ProgressView("Loading...")
                } else if carManager.cars.isEmpty {
                    // Messaggio quando non ci sono auto
                    VStack(spacing: 20) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("No cars saved")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Go to Home to add your first car")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if carManager.errorMessage != nil {
                            Button("Retry Sync") {
                                carManager.syncWithCloudKit()
                            }
                            .buttonStyle(.bordered)
                            .padding(.top)
                        }
                    }
                } else {
                    // Griglia di auto
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(carManager.cars) { car in
                                NavigationLink(destination: CarDetailView(car: car, carManager: carManager)) {
                                    CarCard(car: car)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                
                // Indicatore di sync in alto
                VStack {
                    if carManager.isSyncing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Syncing with iCloud...")
                                .font(.caption)
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 2)
                    } else if let success = carManager.successMessage {
                        HStack {
                            Image(systemName: "checkmark.icloud.fill")
                                .foregroundColor(.green)
                            Text(success)
                                .font(.caption)
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 2)
                    } else if let error = carManager.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.icloud.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 2)
                    }
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .toolbar {
            if carManager.iCloudSyncEnabled {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        carManager.syncWithCloudKit()
                    }) {
                        Image(systemName: "arrow.clockwise.icloud")
                    }
                }
            }
        }
    }
}

// MARK: - Car Card
struct CarCard: View {
    let car: Car
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(uiImage: car.image)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(car.brand)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(car.model)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(isPressed ? 0.15 : 0.1), radius: isPressed ? 8 : 5, x: 0, y: isPressed ? 4 : 2)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

#Preview {
    NavigationStack {
        CollectionViewContent(carManager: CarManager())
    }
}
