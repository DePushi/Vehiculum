import Foundation
import CloudKit
import UIKit

class CloudKitManager {
    private let container: CKContainer
    private let database: CKDatabase
    
    init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
    
    // Salva una macchina su CloudKit
    func saveCar(id: UUID, brand: String, model: String, imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let record = CKRecord(recordType: "Car")
        record["carID"] = id.uuidString
        record["brand"] = brand
        record["model"] = model
        
        // Salva l'immagine come asset
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(id.uuidString + ".jpg")
        do {
            try imageData.write(to: tempURL)
            record["image"] = CKAsset(fileURL: tempURL)
        } catch {
            completion(.failure(error))
            return
        }
        
        database.save(record) { savedRecord, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let savedRecord = savedRecord {
                    completion(.success(savedRecord.recordID.recordName))
                } else {
                    completion(.failure(NSError(domain: "CloudKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
    }
    
    // Carica tutte le macchine da CloudKit
    func fetchCars(completion: @escaping (Result<[(id: UUID, brand: String, model: String, imageData: Data, recordName: String)], Error>) -> Void) {
        let query = CKQuery(recordType: "Car", predicate: NSPredicate(value: true))
        // RIMOSSO: query.sortDescriptors - non serve più!
        
        database.fetch(withQuery: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let queryResult):
                    var cars: [(id: UUID, brand: String, model: String, imageData: Data, recordName: String)] = []
                    
                    for (_, recordResult) in queryResult.matchResults {
                        guard case .success(let record) = recordResult,
                              let carIDString = record["carID"] as? String,
                              let carID = UUID(uuidString: carIDString),
                              let brand = record["brand"] as? String,
                              let model = record["model"] as? String else {
                            continue
                        }
                        
                        var imageData = Data()
                        if let imageAsset = record["image"] as? CKAsset,
                           let imageURL = imageAsset.fileURL,
                           let data = try? Data(contentsOf: imageURL) {
                            imageData = data
                        }
                        
                        cars.append((id: carID, brand: brand, model: model, imageData: imageData, recordName: record.recordID.recordName))
                    }
                    
                    completion(.success(cars))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Elimina una macchina da CloudKit
    func deleteCar(recordName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let recordID = CKRecord.ID(recordName: recordName)
        
        database.delete(withRecordID: recordID) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
