import SwiftData
import UIKit
import Foundation

@Model
class Car {
    @Attribute(.unique) var id: UUID
    var brand: String  
    var model: String
    var imageData: Data
    var date: Date
    var cloudKitRecordName: String?
    
    init(id: UUID = UUID(), brand: String, model: String, image: UIImage, date: Date = Date(), cloudKitRecordName: String? = nil) {
        self.id = id
        self.brand = brand
        self.model = model
        self.imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
        self.date = date
        self.cloudKitRecordName = cloudKitRecordName
    }
    
    // helper per ottenere UIImage dalla Data
    var image: UIImage {
        UIImage(data: imageData) ?? UIImage(systemName: "car.fill")!
    }
}
