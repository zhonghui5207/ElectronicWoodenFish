import SwiftUI
import Darwin

struct ParticleEffect: View {
    let position: CGPoint
    let colors: [Color]
    @State private var particles: [(id: Int, offset: CGSize, opacity: Double, color: Color)] = []
    
    init(position: CGPoint, colors: [Color] = [.yellow, .orange]) {
        self.position = position
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Image(systemName: "sparkle")
                    .foregroundStyle(particle.color)
                    .offset(particle.offset)
                    .opacity(particle.opacity)
            }
        }
        .position(position)
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        for i in 0..<12 {
            let angle = Double(i) * (360.0 / 12.0) * (.pi / 180.0)
            let distance: CGFloat = 50
            
            let offset = CGSize(
                width: CGFloat(Darwin.cos(angle)) * distance,
                height: CGFloat(Darwin.sin(angle)) * distance
            )
            
            let color = colors[i % colors.count]
            particles.append((id: i, offset: .zero, opacity: 1.0, color: color))
            
            withAnimation(.easeOut(duration: 0.5)) {
                particles[i].offset = offset
                particles[i].opacity = 0.0
            }
        }
    }
}
