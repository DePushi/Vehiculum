import SwiftUI
import Vision
import CoreML

struct CarFormView: View {
    let image: UIImage
    @ObservedObject var carManager: CarManager
    @Environment(\.dismiss) var dismiss
    
    @State private var brand = ""
    @State private var model = ""
    @State private var isDetecting = false
    @State private var showingLogoCamera = false
    @State private var logoImage: UIImage?
    @State private var detectionResult: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case brand, model
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Immagine dell'auto
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 16) {
                        // BRAND con detection button
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Brand", systemImage: "car.fill")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Pulsante per detection logo
                                Button(action: {
                                    showingLogoCamera = true
                                }) {
                                    Label("Detect Logo", systemImage: "camera.viewfinder")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .tint(.blue)
                                .disabled(isDetecting)
                            }
                            
                            TextField("Ex: Ferrari, Lamborghini, Mercedes-Benz...", text: $brand)
                                .focused($focusedField, equals: .brand)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.words)
                                .disabled(isDetecting)
                            
                            // Mostra risultato detection
                            if let result = detectionResult {
                                Label {
                                    Text("Detected: \(result)")
                                        .font(.subheadline)
                                } icon: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // MODEL
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Model", systemImage: "gearshape.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Ex: 488 GTB, 599 GTO, 812 Superfast...", text: $model)
                                .focused($focusedField, equals: .model)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.words)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Indicatore di caricamento
                    if isDetecting {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Detecting logo...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                    
                    // Pulsante salva
                    Button(action: saveCar) {
                        Label("Save Car", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 2)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canSave)
                }
                .padding()
            }
            .navigationTitle("New Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingLogoCamera) {
                LogoCameraView(
                    detectedBrand: $brand,
                    isDetecting: $isDetecting,
                    detectionResult: $detectionResult
                )
            }
            .alert("Detection Result", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var canSave: Bool {
        !brand.isEmpty && !model.isEmpty && !isDetecting
    }
    
    private func saveCar() {
        let newCar = Car(brand: brand, model: model, image: image)
        carManager.addCar(newCar)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

// MARK: - Logo Camera View (Object Detection)
struct LogoCameraView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var detectedBrand: String
    @Binding var isDetecting: Bool
    @Binding var detectionResult: String?
    
    @State private var capturedLogoImage: UIImage?
    @State private var showingCamera = true
    @State private var debugMessage = ""
    
    var body: some View {
        ZStack {
            if showingCamera {
                CarFormImagePicker(image: $capturedLogoImage, sourceType: .camera)
                    .ignoresSafeArea()
                    .overlay(alignment: .top) {
                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title2)
                                Text("Frame the car logo")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(12)
                            .padding(.top, 60)
                            
                            if !debugMessage.isEmpty {
                                Text(debugMessage)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.orange.opacity(0.9))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                    }
            } else {
                if let logoImage = capturedLogoImage {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("Analyzing logo...")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Image(uiImage: logoImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .cornerRadius(16)
                                .shadow(radius: 10)
                            
                            ProgressView()
                                .scaleEffect(1.2)
                                .padding()
                            
                            if !debugMessage.isEmpty {
                                Text(debugMessage)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        .padding()
                        
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: capturedLogoImage) { oldValue, newValue in
            if let logoImage = newValue {
                print("✅ Logo image captured: \(logoImage.size)")
                debugMessage = "Image captured"
                showingCamera = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    detectLogo(in: logoImage)
                }
            }
        }
    }
    
    private func detectLogo(in image: UIImage) {
        print("🔍 Starting OBJECT DETECTION...")
        isDetecting = true
        debugMessage = "Loading model..."
        
        guard let modelURL = findMLModel() else {
            print("❌ No ML model found")
            failedDetection(message: "Model not found")
            return
        }
        
        print("✅ Found model: \(modelURL.lastPathComponent)")
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            let model = try VNCoreMLModel(for: mlModel)
            
            print("✅ Model loaded successfully")
            print("📋 Model description:")
            print("  Input: \(mlModel.modelDescription.inputDescriptionsByName)")
            print("  Output: \(mlModel.modelDescription.outputDescriptionsByName)")
            
            performObjectDetection(with: model, image: image)
        } catch {
            print("❌ Failed to load model: \(error)")
            failedDetection(message: "Failed to load model")
        }
    }
    
    private func findMLModel() -> URL? {
        if let models = Bundle.main.urls(forResourcesWithExtension: "mlmodelc", subdirectory: nil),
           let firstModel = models.first {
            return firstModel
        }
        
        if let models = Bundle.main.urls(forResourcesWithExtension: "mlmodel", subdirectory: nil),
           let firstModel = models.first {
            return firstModel
        }
        
        return nil
    }
    
    private func performObjectDetection(with model: VNCoreMLModel, image: UIImage) {
        debugMessage = "Detecting objects..."
        
        let request = VNCoreMLRequest(model: model) { request, error in
            DispatchQueue.main.async {
                self.isDetecting = false
                
                if let error = error {
                    print("❌ Detection error: \(error)")
                    self.failedDetection(message: "Detection error")
                    return
                }
                
                print("📊 Results received")
                print("   Type: \(type(of: request.results))")
                
                if let detections = request.results as? [VNRecognizedObjectObservation] {
                    print("✅ Object Detection: \(detections.count) objects found")
                    
                    if detections.isEmpty {
                        print("⚠️ No objects detected in image")
                        self.failedDetection(message: "No logos detected")
                        return
                    }
                    
                    for (index, detection) in detections.enumerated() {
                        print("\n🎯 Object #\(index + 1):")
                        print("   Bounding box: \(detection.boundingBox)")
                        print("   Labels:")
                        for label in detection.labels {
                            print("     - \(label.identifier): \(Int(label.confidence * 100))%")
                        }
                    }
                    
                    if let bestDetection = detections.max(by: {
                        ($0.labels.first?.confidence ?? 0) < ($1.labels.first?.confidence ?? 0)
                    }),
                       let bestLabel = bestDetection.labels.first {
                        
                        print("\n✅ BEST MATCH: \(bestLabel.identifier) (\(Int(bestLabel.confidence * 100))%)")
                        
                        if bestLabel.confidence > 0.2 {
                            self.detectedBrand = bestLabel.identifier
                            self.detectionResult = "\(bestLabel.identifier) (\(Int(bestLabel.confidence * 100))%)"
                            
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.dismiss()
                            }
                        } else {
                            print("⚠️ Confidence too low: \(Int(bestLabel.confidence * 100))%")
                            self.failedDetection(message: "Low confidence: \(Int(bestLabel.confidence * 100))%")
                        }
                    } else {
                        print("❌ No valid labels found")
                        self.failedDetection(message: "No labels found")
                    }
                    
                } else {
                    print("❌ Results are not VNRecognizedObjectObservation")
                    if let results = request.results {
                        print("   Actual type: \(type(of: results))")
                        print("   Results: \(results)")
                    }
                    self.failedDetection(message: "Wrong result type")
                }
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        
        guard let ciImage = CIImage(image: image) else {
            print("❌ Failed to create CIImage")
            failedDetection(message: "Failed to process image")
            return
        }
        
        print("🖼️ Processing image: \(ciImage.extent.size)")
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                print("✅ Detection request completed")
            } catch {
                print("❌ Failed to perform: \(error)")
                DispatchQueue.main.async {
                    self.failedDetection(message: "Detection failed")
                }
            }
        }
    }
    
    private func failedDetection(message: String) {
        debugMessage = message
        detectionResult = "Logo not recognized"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
}

// MARK: - Image Picker specifico per CarForm
struct CarFormImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CarFormImagePicker
        
        init(_ parent: CarFormImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CarFormView(image: UIImage(systemName: "car")!, carManager: CarManager())
}
