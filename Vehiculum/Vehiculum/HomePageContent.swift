import SwiftUI

struct HomePageContent: View {
    @ObservedObject var carManager: CarManager
    @Binding var selectedTab: Int
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var capturedImage: UIImage?
    @State private var showingCarForm = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeroSection()
                
                StatsSection(carCount: carManager.cars.count)
                    .id(carManager.cars.count)
                
                QuickActionsSection(
                    onTakePhoto: { showingCamera = true },
                    onChoosePhoto: { showingGallery = true }
                )
                
                if !carManager.cars.isEmpty {
                    RecentCarsSection(
                        cars: Array(carManager.cars.prefix(5)),
                        carManager: carManager,
                        selectedTab: $selectedTab
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
                .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showingGallery) {
            ImagePicker(image: $capturedImage, sourceType: .photoLibrary)
        }
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
        .onChange(of: carManager.cars.count) { oldValue, newValue in
            if newValue > oldValue {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.6),
                                Color.blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                
                Image(systemName: "car.2.fill")
                    .font(.system(size: 45))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text("Vehiculum")
                    .font(.system(size: 36, weight: .bold))
                
                Text("Your digital car collection")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    let carCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Collection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    AnimatedCounter(value: carCount)
                    
                    Text(carCount == 1 ? "car" : "cars")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue.opacity(0.3))
        }
        .padding(24)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    let onTakePhoto: () -> Void
    let onChoosePhoto: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                PressableButton(
                    icon: "camera.fill",
                    iconColor: .blue,
                    title: "Take Photo",
                    subtitle: "Capture a new car",
                    action: onTakePhoto
                )
                
                PressableButton(
                    icon: "photo.fill",
                    iconColor: .green,
                    title: "Choose Photo",
                    subtitle: "Pick from your library",
                    action: onChoosePhoto
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 30)
    }
}

// MARK: - Pressable Button
struct PressableButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Press Button Style
struct PressButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Recent Cars Section
struct RecentCarsSection: View {
    let cars: [Car]
    @ObservedObject var carManager: CarManager
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        selectedTab = 1
                    }
                }) {
                    Text("See All")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cars) { car in
                        NavigationLink(destination: CarDetailView(car: car, carManager: carManager)) {
                            HoverableCarCard(car: car)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 30)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: cars.count)
    }
}

// MARK: - Hoverable Car Card
struct HoverableCarCard: View {
    let car: Car
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(uiImage: car.image)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 120)
                .clipped()
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(car.brand)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(car.model)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 160)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(isHovered ? 0.15 : 0.05), radius: isHovered ? 12 : 4, x: 0, y: isHovered ? 8 : 2)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            isHovered = pressing
        }, perform: {})
    }
}

#Preview {
    NavigationStack {
        HomePageContent(carManager: CarManager(), selectedTab: .constant(0))
    }
}
