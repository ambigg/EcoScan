import SwiftUI

struct ScannerOverlay: View {
    @State private var scanLinePosition: CGFloat = 0
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            let frameSize = min(geometry.size.width, geometry.size.height) * 0.7
            
            ZStack {
                Color.black.opacity(0.5)
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: frameSize, height: frameSize)
                    .blendMode(.destinationOut)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: frameSize, height: frameSize)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0),
                                Color.green,
                                Color.green.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: frameSize * 0.8, height: 4)
                    .offset(y: -frameSize/2 + scanLinePosition)
                
                cornerIndicators(frameSize: frameSize)
            }
            .compositingGroup()
            .onAppear {
                startScanAnimation(frameSize: frameSize)
            }
        }
    }
    
    private func cornerIndicators(frameSize: CGFloat) -> some View {
        ZStack {
            ForEach(0..<4) { index in
                let rotation = Double(index) * 90
                let xOffset = (index % 2 == 0 ? -1 : 1) * (frameSize/2 - 20)
                let yOffset = (index < 2 ? -1 : 1) * (frameSize/2 - 20)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 30, height: 4)
                    .rotationEffect(.degrees(rotation))
                    .offset(x: xOffset, y: yOffset)
            }
        }
    }
    
    private func startScanAnimation(frameSize: CGFloat) {
        withAnimation(
            Animation.linear(duration: 2)
                .repeatForever(autoreverses: false)
        ) {
            scanLinePosition = frameSize
        }
        
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            isAnimating = true
        }
    }
}

