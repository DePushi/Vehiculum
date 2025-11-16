import SwiftUI

struct CarFormView: View {
    let image: UIImage
    @ObservedObject var carManager: CarManager
    @Environment(\.dismiss) var dismiss
    
    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var isDetecting = false
    @State private var detectionMessage: String = ""
    @State private var showDetectionAlert = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case brand, model
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(10)
                        .onTapGesture {
                            focusedField = nil
                        }
                } header: {
                    Text("Car Photo")
                }
                
                // SEZIONE DETECTION
                Section {
                    Button(action: detectMercedesLogo) {
                        HStack {
                            if isDetecting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Detecting...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("Detect Mercedes Logo")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(isDetecting ? .secondary : .blue)
                    }
                    .disabled(isDetecting)
                } header: {
                    Text("AI Detection")
                } footer: {
                    Text("Use AI to automatically detect Mercedes logo")
                }
                
                Section {
                    TextField("e.g., Ferrari, BMW, Fiat...", text: $brand)
                        .focused($focusedField, equals: .brand)
                        .autocapitalization(.words)
                    
                    TextField("e.g., 488 GTB, Series 3, Panda...", text: $model)
                        .focused($focusedField, equals: .model)
                        .autocapitalization(.words)
                } header: {
                    Text("Car Information")
                }
                
                Section {
                    Button(action: saveCar) {
                        HStack {
                            Spacer()
                            Text("Save Car")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(brand.isEmpty || model.isEmpty)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Detection Result", isPresented: $showDetectionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(detectionMessage)
            }
        }
    }
    
    private func detectMercedesLogo() {
        isDetecting = true
        focusedField = nil // Chiudi la tastiera
        
        MercedesDetectionService.shared.detectMercedesLogo(in: image) { success, message in
            isDetecting = false
            
            if success {
                // Logo Mercedes rilevato!
                brand = "Mercedes"
                detectionMessage = message ?? "Mercedes logo detected!"
                
                // Feedback tattile
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } else {
                // Logo non rilevato
                detectionMessage = message ?? "No Mercedes logo found. Please enter brand manually."
                
                // Feedback tattile
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
            
            showDetectionAlert = true
        }
    }
    
    private func saveCar() {
        let newCar = Car(
            id: UUID(),
            brand: brand,
            model: model,
            image: image,
            date: Date(),
            cloudKitRecordName: nil
        )
        carManager.addCar(newCar)
        dismiss()
    }
}

#Preview {
    CarFormView(image: UIImage(systemName: "car")!, carManager: CarManager())
}
