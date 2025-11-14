import SwiftUI

struct CarFormView: View {
    let image: UIImage
    @ObservedObject var carManager: CarManager
    @Environment(\.dismiss) var dismiss
    
    @State private var brand: String = ""
    @State private var model: String = ""
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
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } header: {
                    Text("Car Photo")
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
            .onAppear {
                focusedField = .brand
            }
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
