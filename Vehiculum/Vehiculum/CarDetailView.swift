import SwiftUI
import SwiftData

struct CarDetailView: View {
    @Bindable var car: Car
    @ObservedObject var carManager: CarManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditing = false
    @State private var editedBrand: String = ""
    @State private var editedModel: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case brand, model
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(uiImage: car.image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        // BRAND
                        HStack {
                            Label("Brand", systemImage: "car.fill")
                                .foregroundColor(.secondary)
                            Spacer()
                            
                            if isEditing {
                                TextField("Brand", text: $editedBrand)
                                    .focused($focusedField, equals: .brand)
                                    .textFieldStyle(.plain)
                                    .multilineTextAlignment(.trailing)
                                    .autocapitalization(.words)
                                    .fontWeight(.semibold)
                            } else {
                                Text(car.brand)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Divider()
                        
                        // MODEL
                        HStack {
                            Label("Model", systemImage: "gearshape.fill")
                                .foregroundColor(.secondary)
                            Spacer()
                            
                            if isEditing {
                                TextField("Model", text: $editedModel)
                                    .focused($focusedField, equals: .model)
                                    .textFieldStyle(.plain)
                                    .multilineTextAlignment(.trailing)
                                    .autocapitalization(.words)
                                    .fontWeight(.semibold)
                            } else {
                                Text(car.model)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Divider()
                        
                        // DATE (non modificabile)
                        HStack {
                            Label("Date", systemImage: "calendar")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(car.date.formatted(date: .long, time: .shortened))
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(car.brand)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Cancel" : "Close") {
                        if isEditing {
                            editedBrand = car.brand
                            editedModel = car.model
                            isEditing = false
                            focusedField = nil
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                        .fontWeight(.semibold)
                        .disabled(editedBrand.isEmpty || editedModel.isEmpty)
                    } else {
                        Menu {
                            Button(action: {
                                editedBrand = car.brand
                                editedModel = car.model
                                isEditing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    focusedField = .brand
                                }
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                carManager.deleteCar(car)
                                dismiss()
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .onAppear {
                editedBrand = car.brand
                editedModel = car.model
            }
        }
    }
    
    private func saveChanges() {
        car.brand = editedBrand
        car.model = editedModel
        
        do {
            try modelContext.save()
            isEditing = false
            focusedField = nil
        } catch {
            print("Error saving: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Car.self, configurations: config)
    let car = Car(brand: "Ferrari", model: "488 GTB", image: UIImage(systemName: "car")!)
    container.mainContext.insert(car)
    
    return CarDetailView(car: car, carManager: CarManager())
        .modelContainer(container)
}
