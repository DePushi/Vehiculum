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
    
    // Configura il ModelContext (chiamalo dal ContentView)
    func configure(with context: ModelContext) {
        self.modelContext = context
        loadCarsFromSwiftData()
        syncWithCloudKit()
    }
    
    // Carica auto da SwiftData locale
    private func loadCarsFromSwiftData() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Car>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            cars = try context.fetch(descriptor)
        } catch {
            print("Error loading from SwiftData: \(error)")
        }
    }
    
    // Sincronizza con CloudKit
    func syncWithCloudKit() {
        isSyncing = true
        
        cloudKitManager.fetchCars { [weak self] result in
            guard let self = self else { return }
            self.isSyncing = false
            
            switch result {
            case .success(let cloudCars):
                // Merge con i dati locali
                for cloudCar in cloudCars {
                    // Controlla se l'auto esiste già
                    if !self.cars.contains(where: { $0.id == cloudCar.id }) {
                        // Aggiungi nuova auto dal cloud
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
                
                // Nascondi messaggio dopo 2 secondi
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.successMessage = nil
                }
                
            case .failure(let error):
                self.errorMessage = "Sync error: \(error.localizedDescription)"
                print("CloudKit sync error: \(error)")
            }
        }
    }
    
    // Aggiungi auto (SwiftData + CloudKit)
    func addCar(_ car: Car) {
        // Salva localmente con SwiftData
        modelContext?.insert(car)
        cars.insert(car, at: 0)
        
        do {
            try modelContext?.save()
        } catch {
            print("Error saving to SwiftData: \(error)")
        }
        
        // Salva su CloudKit
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
                // Aggiorna con il recordName di CloudKit
                car.cloudKitRecordName = recordName
                try? self?.modelContext?.save()
                self?.successMessage = "Saved to iCloud"
                
                // Nascondi messaggio dopo 2 secondi
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.successMessage = nil
                }
                
            case .failure(let error):
                self?.errorMessage = "Save error: \(error.localizedDescription)"
                print("CloudKit save error: \(error)")
            }
        }
    }
    
    // Elimina auto (SwiftData + CloudKit)
    func deleteCar(_ car: Car) {
        // Rimuovi localmente
        modelContext?.delete(car)
        cars.removeAll { $0.id == car.id }
        
        do {
            try modelContext?.save()
        } catch {
            print("Error deleting from SwiftData: \(error)")
        }
        
        // Elimina da CloudKit
        if let recordName = car.cloudKitRecordName {
            cloudKitManager.deleteCar(recordName: recordName) { result in
                switch result {
                case .success:
                    print("Deleted from CloudKit")
                case .failure(let error):
                    print("CloudKit delete error: \(error)")
                }
            }
        }
    }
}
