import SwiftUI
import AVFoundation

struct ScannerCameraView: UIViewRepresentable {
    @ObservedObject var scanner: BarcodeScanner
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupPreviewLayer(for: view)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let previewLayer = self.scanner.previewLayer {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                previewLayer.frame = uiView.bounds
                CATransaction.commit()
            }
        }
    }
    
    private func setupPreviewLayer(for view: UIView) {
        guard let session = scanner.captureSession else {
            return
        }
        
        scanner.previewLayer?.removeFromSuperlayer()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        
        view.layer.addSublayer(previewLayer)
        scanner.previewLayer = previewLayer
        
        print("Preview layer: \(view.bounds)")
    }
}

