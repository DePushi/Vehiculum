import SwiftUI

struct CollectionView: View {
    @ObservedObject var carManager: CarManager
    @State private var selectedCar: Car?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
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
                                    CarCard(car: car)
                                        .onTapGesture {
                                            selectedCar = car
                                        }
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        carManager.syncWithCloudKit()
                    }) {
                        Image(systemName: "arrow.clockwise.icloud")
                    }
                }
            }
            .sheet(item: $selectedCar) { car in
                CarDetailView(car: car, carManager: carManager)
            }
        }
    }
}

// Card nella griglia
struct CarCard: View {
    let car: Car
    
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
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    CollectionView(carManager: CarManager())
}



