import SwiftUI

struct HomePage: View {
    @ObservedObject var carManager: CarManager
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var capturedImage: UIImage?
    @State private var showingCarForm = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "car.2.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Vehiculum")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your cars collection")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Statistiche
                HStack(spacing: 40) {
                    VStack {
                        Text("\(carManager.cars.count)")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Saved cars")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
                
                Spacer()
                
                // Bottoni
                VStack(spacing: 20) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Take Photos")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    
                    Button(action: {
                        showingGallery = true
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                            Text("Choose from the Gallery")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            // FOTOCAMERA
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(
                    image: $capturedImage,
                    sourceType: .camera
                )
                .ignoresSafeArea(.all)
            }
            // GALLERIA
            .sheet(isPresented: $showingGallery) {
                ImagePicker(
                    image: $capturedImage,
                    sourceType: .photoLibrary
                )
            }
            // FORM
            .fullScreenCover(isPresented: $showingCarForm, onDismiss: {
                capturedImage = nil
            }) {
                if let image = capturedImage {
                    CarFormView(image: image, carManager: carManager)
                }
            }
            .onChange(of: capturedImage) { oldValue, newValue in
                if newValue != nil {
                    showingCarForm = true
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    HomePage(carManager: CarManager())
}
