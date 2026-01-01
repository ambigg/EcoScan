import AVFoundation
import SwiftUI
import Combine

class BarcodeScanner: NSObject, ObservableObject {
    @Published var scannedCode: String?
    @Published var errorMessage: String?
    @Published var isScanning = false
    @Published var hasCameraPermission = false
    
    private(set) var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var isProcessingCode = false
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.hasCameraPermission = granted
                completion(granted)
            }
        }
    }
    
    private func setupCaptureSession() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            errorMessage = "Camera access denied. Please enable camera access in Settings."
            return
        }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            errorMessage = "Your device doesn't support scanning"
            return
        }
        
        do {
            if let existingSession = captureSession, existingSession.isRunning {
                existingSession.stopRunning()
            }
            
            let session = AVCaptureSession()
            self.captureSession = session
            
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                errorMessage = "Cannot add video input"
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .qr]
            } else {
                errorMessage = "Cannot add metadata output"
                return
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func startScanning() {
        guard hasCameraPermission else {
            errorMessage = "Camera permission required"
            return
        }
        
        scannedCode = nil
        isProcessingCode = false
        errorMessage = nil
        
        if captureSession == nil {
            setupCaptureSession()
        }
        
        guard let session = captureSession else {
            errorMessage = "Failed to create capture session"
            return
        }
        
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                session.startRunning()
                DispatchQueue.main.async {
                    self?.isScanning = true
                    print("Scanner started successfully")
                }
            }
        }
    }
    
    func stopScanning() {
        guard let session = captureSession, session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            session.stopRunning()
            DispatchQueue.main.async {
                self?.isScanning = false
                print("Scanner stopped")
            }
        }
    }
    
    func resetForNewScan() {
        isProcessingCode = false
        scannedCode = nil
        
        if let session = captureSession, !session.isRunning {
            startScanning()
        }
    }
    
    func cleanup() {
        stopScanning()
        captureSession = nil
        previewLayer = nil
    }
}

extension BarcodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {
        
        guard !isProcessingCode else { return }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            isProcessingCode = true
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            scannedCode = stringValue
            
            stopScanning()
            
            print("Code detected and processed: \(stringValue)")
        }
    }
}
