import SwiftUI
import Foundation
import Combine
import SwiftData

class CarManager: ObservableObject {
    @Published var cars: [Car] = []
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let cloudKitManager = CloudKitManager()
    private var modelContext: ModelContext?
    
    
    var iCloudSyncEnabled: Bool = false
    
    
    func configure(with context: ModelContext, iCloudEnabled: Bool) {
        self.modelContext = context
        self.iCloudSyncEnabled = iCloudEnabled
        
        loadCarsFromSwiftData()
        
        
        if iCloudEnabled {
            syncWithCloudKit()
        } else {
            print("📱 Running in local-only mode (no iCloud sync)")
        }
    }
    
    
    private func loadCarsFromSwiftData() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Car>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            cars = try context.fetch(descriptor)
            print("✅ Loaded \(cars.count) cars from local storage")
        } catch {
            print("❌ Error loading from SwiftData: \(error)")
        }
    }
    
    
    func syncWithCloudKit() {
        guard iCloudSyncEnabled else {
            print("⚠️ iCloud sync disabled - skipping")
            return
        }
        
        isSyncing = true
        
        cloudKitManager.fetchCars { [weak self] result in
            guard let self = self else { return }
            self.isSyncing = false
            
            switch result {
            case .success(let cloudCars):
                
                for cloudCar in cloudCars {
                    
                    if !self.cars.contains(where: { $0.id == cloudCar.id }) {
                        
                        let newCar = Car(
                            id: cloudCar.id,
                            brand: cloudCar.brand,
                            model: cloudCar.model,
                            image: UIImage(data: cloudCar.imageData) ?? UIImage(systemName: "car.fill")!,
                            date: Date(),
                            cloudKitRecordName: cloudCar.recordName
                        )
                        self.modelContext?.insert(newCar)
                        self.cars.append(newCar)
                    }
                }
                
                try? self.modelContext?.save()
                self.successMessage = "Synced with iCloud"
                
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.successMessage = nil
                }
                
            case .failure(let error):
                self.errorMessage = "Sync error: \(error.localizedDescription)"
                print("❌ CloudKit sync error: \(error)")
            }
        }
    }
    
    
    func addCar(_ car: Car) {
        
        modelContext?.insert(car)
        cars.insert(car, at: 0)
        
        do {
            try modelContext?.save()
            print("✅ Car saved locally")
        } catch {
            print("❌ Error saving to SwiftData: \(error)")
        }
        

        if iCloudSyncEnabled {
            isSyncing = true
            cloudKitManager.saveCar(
                id: car.id,
                brand: car.brand,
                model: car.model,
                imageData: car.imageData
            ) { [weak self] result in
                self?.isSyncing = false
                
                switch result {
                case .success(let recordName):
                    
                    car.cloudKitRecordName = recordName
                    try? self?.modelContext?.save()
                    self?.successMessage = "Saved to iCloud"
                    
                    print("☁️ Car synced to iCloud")
                    
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.successMessage = nil
                    }
                    
                case .failure(let error):
                    self?.errorMessage = "Save error: \(error.localizedDescription)"
                    print("❌ CloudKit save error: \(error)")
                }
            }
        } else {
            print("📱 Car saved locally only (iCloud sync disabled)")
        }
    }
    
    
    func deleteCar(_ car: Car) {
        
        modelContext?.delete(car)
        cars.removeAll { $0.id == car.id }
        
        do {
            try modelContext?.save()
            print("✅ Car deleted locally")
        } catch {
            print("❌ Error deleting from SwiftData: \(error)")
        }
        
        
        if iCloudSyncEnabled, let recordName = car.cloudKitRecordName {
            cloudKitManager.deleteCar(recordName: recordName) { result in
                switch result {
                case .success:
                    print("☁️ Car deleted from iCloud")
                case .failure(let error):
                    print("❌ CloudKit delete error: \(error)")
                }
            }
        }
    }
}
