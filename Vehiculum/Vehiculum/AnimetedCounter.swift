import SwiftUI

struct AnimatedCounter: View {
    let value: Int
    @State private var displayValue: Int = 0
    
    var body: some View {
        Text("\(displayValue)")
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(.primary)
            .onChange(of: value) { oldValue, newValue in
                animateCount(from: oldValue, to: newValue)
            }
            .onAppear {
                animateCount(from: 0, to: value)
            }
    }
    
    private func animateCount(from start: Int, to end: Int) {
        guard start != end else { return }
        
        let steps = min(abs(end - start), 30)
        let increment = (end - start) / steps
        let duration = 0.8 / Double(steps)
        
        var current = start
        
        for step in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(step)) {
                current += increment
                
                if step == steps - 1 {
                    displayValue = end
                } else {
                    displayValue = current
                }
                
                if step % 5 == 0 {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
    }
}
