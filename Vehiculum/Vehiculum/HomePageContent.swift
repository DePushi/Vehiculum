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
                        cars: carManager.cars,
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
        VStack(spacing: 12) {
            Text("Vehiculum")
                .font(.system(size: 40, weight: .bold, design: .rounded))
            
            HStack(spacing: 6) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text("Your digital car collection")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 40)
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    let carCount: Int
    @State private var barsPressed = false
    
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
            
            // Icona interattiva con le 3 barre basate sul numero di auto
            DynamicBarsIcon(carCount: carCount, isPressed: $barsPressed)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        barsPressed = true
                    }
                    
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            barsPressed = false
                        }
                    }
                }
        }
        .padding(24)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

// MARK: - Dynamic Bars Icon
struct DynamicBarsIcon: View {
    let carCount: Int
    @Binding var isPressed: Bool
    @State private var animatedBar1: CGFloat = 0
    @State private var animatedBar2: CGFloat = 0
    @State private var animatedBar3: CGFloat = 0
    
    // Calcola l'altezza delle barre in base al numero di auto
    private var bar1Height: CGFloat {
        min(CGFloat(carCount) / 30.0, 1.0) // Max a 30 auto = 100%
    }
    
    private var bar2Height: CGFloat {
        min(CGFloat(carCount) / 20.0, 1.0) // Max a 20 auto = 100%
    }
    
    private var bar3Height: CGFloat {
        min(CGFloat(carCount) / 10.0, 1.0) // Max a 10 auto = 100%
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            // Barra 1 (più bassa - cresce più lentamente)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            carCount > 0 ? .blue : .gray.opacity(0.3),
                            carCount > 0 ? .blue.opacity(0.7) : .gray.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 40 * max(animatedBar1, 0.2)) // Minimo 20%
                .scaleEffect(isPressed ? 0.9 : 1.0)
            
            // Barra 2 (media - cresce a velocità media)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            carCount > 0 ? .blue : .gray.opacity(0.3),
                            carCount > 0 ? .blue.opacity(0.7) : .gray.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 40 * max(animatedBar2, 0.4)) // Minimo 40%
                .scaleEffect(isPressed ? 0.9 : 1.0)
            
            // Barra 3 (più alta - cresce più velocemente)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            carCount > 0 ? .blue : .gray.opacity(0.3),
                            carCount > 0 ? .blue.opacity(0.7) : .gray.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 40 * max(animatedBar3, 0.6)) // Minimo 60%
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .frame(height: 40)
        .onChange(of: carCount) { oldValue, newValue in
            animateBars()
        }
        .onAppear {
            animateBars()
        }
    }
    
    private func animateBars() {
        // Animazione sequenziale delle barre
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            animatedBar1 = bar1Height
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedBar2 = bar2Height
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedBar3 = bar3Height
            }
        }
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
                    ForEach(cars.sorted(by: { $0.date > $1.date }).prefix(5)) { car in
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
    @State private var isPressed = false
    
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
        .shadow(color: .black.opacity(isPressed ? 0.15 : 0.05), radius: isPressed ? 12 : 4, x: 0, y: isPressed ? 8 : 2)
        .scaleEffect(isPressed ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Animated Counter
struct AnimetedCounter: View {
    let value: Int
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .contentTransition(.numericText())
    }
}

#Preview {
    NavigationStack {
        HomePageContent(carManager: CarManager(), selectedTab: .constant(0))
    }
}
