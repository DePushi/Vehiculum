import Vision
import CoreML
import UIKit

class MercedesDetectionService {
    
    static let shared = MercedesDetectionService()
    
    private init() {}
    
    // Rileva il logo Mercedes nell'immagine
    func detectMercedesLogo(in image: UIImage, completion: @escaping (Bool, String?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(false, nil)
            return
        }
        
        // Carica il modello MercedesDetector
        guard let model = try? VNCoreMLModel(for: MercedesDetector(configuration: MLModelConfiguration()).model) else {
            print("Errore: impossibile caricare MercedesDetector")
            completion(false, "Model loading failed")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.processDetections(request: request, error: error, completion: completion)
        }
        
        // Configurazione della request
        request.imageCropAndScaleOption = .scaleFill
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Errore nella detection: \(error)")
                DispatchQueue.main.async {
                    completion(false, "Detection failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func processDetections(request: VNRequest, error: Error?, completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.main.async {
            guard error == nil else {
                completion(false, "Error: \(error!.localizedDescription)")
                return
            }
            
            guard let results = request.results as? [VNRecognizedObjectObservation],
                  !results.isEmpty else {
                completion(false, "No Mercedes logo detected")
                return
            }
            
            // Prendi la detection con la confidence più alta
            let bestDetection = results.max(by: { $0.confidence < $1.confidence })
            
            if let detection = bestDetection, detection.confidence > 0.5 {
                // Logo Mercedes trovato!
                let confidencePercent = Int(detection.confidence * 100)
                completion(true, "Mercedes detected (\(confidencePercent)% confidence)")
            } else {
                completion(false, "Low confidence detection")
            }
        }
    }
}
