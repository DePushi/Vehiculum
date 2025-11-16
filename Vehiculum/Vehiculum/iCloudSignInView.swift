import SwiftUI
import CloudKit

struct iCloudSignInView: View {
    @State private var isSigningIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Binding var isSignedIn: Bool
    @Binding var iCloudEnabled: Bool
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Hero section
                VStack(spacing: 30) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.8),
                                        Color.blue
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "icloud.and.arrow.up.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Sync with iCloud")
                            .font(.system(size: 34, weight: .bold))
                        
                        Text("Keep your car collection in sync across all your devices with iCloud.")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Features list
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "arrow.triangle.2.circlepath.icloud",
                        title: "Automatic Sync",
                        description: "Your cars sync automatically"
                    )
                    
                    FeatureRow(
                        icon: "lock.shield.fill",
                        title: "Private & Secure",
                        description: "End-to-end encrypted"
                    )
                    
                    FeatureRow(
                        icon: "arrow.clockwise.icloud.fill",
                        title: "Always Up to Date",
                        description: "Access from any device"
                    )
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 30)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: enableiCloudSync) {
                        HStack {
                            if isSigningIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            }
                            Text(isSigningIn ? "Checking..." : "Enable iCloud Sync")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isSigningIn)
                    
                    Button(action: continueWithoutSync) {
                        Text("Continue without iCloud")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    
                    Text("You can enable sync later in Settings")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .alert("iCloud Not Available", isPresented: $showError) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Continue Locally", role: .cancel) {
                continueWithoutSync()
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func enableiCloudSync() {
        isSigningIn = true
        
        // Verifica iCloud status
        checkiCloudAvailability { available in
            isSigningIn = false
            
            if available {
                // iCloud disponibile!
                iCloudEnabled = true
                isSignedIn = true
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                print("✅ iCloud sync enabled")
            } else {
                // iCloud NON disponibile
                errorMessage = "Please sign in to iCloud in Settings to enable sync across devices."
                showError = true
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
    
    private func continueWithoutSync() {
        iCloudEnabled = false
        isSignedIn = true
        
        print("📱 Continuing in local-only mode")
    }
    
    private func checkiCloudAvailability(completion: @escaping (Bool) -> Void) {
        // Verifica se l'utente è loggato con iCloud
        guard FileManager.default.ubiquityIdentityToken != nil else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        // Verifica anche l'accesso a CloudKit
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                completion(status == .available)
            }
        }
    }
}

// Feature row component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    iCloudSignInView(isSignedIn: .constant(false), iCloudEnabled: .constant(false))
}
