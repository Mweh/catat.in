import SwiftUI
import AVFoundation

/// A SwiftUI view that renders a live AVCaptureSession video preview.
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        uiView.updateOrientation()
    }

    // MARK: - Custom UIView with AVCaptureVideoPreviewLayer
    class PreviewUIView: UIView {
        var session: AVCaptureSession? {
            didSet {
                guard let session else { return }
                previewLayer.session = session
            }
        }

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
            previewLayer.videoGravity = .resizeAspectFill
            updateOrientation()
        }

        func updateOrientation() {
            guard let connection = previewLayer.connection,
                  connection.isVideoRotationAngleSupported(0) else { return }
            // Keep portrait
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                switch scene.interfaceOrientation {
                case .landscapeLeft:  connection.videoRotationAngle = 180
                case .landscapeRight: connection.videoRotationAngle = 0
                default:              connection.videoRotationAngle = 90
                }
            }
        }
    }
}
