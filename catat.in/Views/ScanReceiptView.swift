import SwiftUI
import Combine
import AVFoundation

struct ScanReceiptView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var repo: ExpenseRepository

    @StateObject private var scannerVM = ReceiptScannerViewModel()
    @StateObject private var hudVM = ScanOverlayViewModel()
    @StateObject private var camera = CameraSession()

    @State private var showFilePicker = false
    @State private var showPhotoLibrary = false
    @State private var showPreview = false
    @State private var selectedImage: UIImage?
    @State private var isFlashOn = false

    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack {
            // ── 1. Live camera feed — true full-screen edge-to-edge ─────
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea(.all)

            // ── 2. Scan HUD overlay ─────────────────────────────────────────
            ScanOverlayView(viewModel: hudVM)
                .ignoresSafeArea()

            // ── 3. Chrome UI ────────────────────────────────────────────────
            VStack(spacing: 0) {

                // Top bar
                HStack {
                    Button(action: {
                        camera.stop()
                        onDismiss?()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        circleButton(icon: "xmark")
                    }

                    Spacer()

                    Text("Scan Struk")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: toggleFlash) {
                        circleButton(icon: isFlashOn ? "bolt.fill" : "bolt.slash.fill",
                                     tint: isFlashOn ? .yellow : .white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, UIApplication.shared.connectedScenes
                    .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
                    .first.map { $0 + 8 } ?? 56)

                Spacer()

                // Bottom controls
                VStack(spacing: 20) {
                    HStack(spacing: 44) {

                        // Gallery (left)
                        Button(action: { showPhotoLibrary = true }) {
                            iconAction(icon: "photo.on.rectangle", label: "Galeri")
                        }

                        // ── Main shutter ──────────────────────────────────
                        Button(action: capturePhoto) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 80, height: 80)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 66, height: 66)
                                // Shutter ring only — no camera icon
                                Circle()
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                    .frame(width: 54, height: 54)
                            }
                        }

                        // Upload from Files
                        Button(action: { showFilePicker = true }) {
                            iconAction(icon: "arrow.up.doc.fill", label: "Upload")
                        }
                    }

                    Text("AI akan mendeteksi nominal & kategori secara otomatis")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 28)
                .padding(.bottom, 48)
                .frame(maxWidth: .infinity)
                .background(
                    Color.black.opacity(0.55)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedCorner(radius: 36, corners: [.topLeft, .topRight]))
                )
            }

            // ── 4. Processing spinner (text removed — HUD communicates state) ──
            if case .processing = scannerVM.state {
                Color.black.opacity(0.55).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.8)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            camera.start()
            // Start scan line animation immediately on open
            hudVM.transition(to: .scanning)
        }
        .onDisappear {
            camera.stop()
        }
        // Gallery sheet (left button)
        .sheet(isPresented: $showPhotoLibrary) {
            CameraScannerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        // Files picker sheet (right button)
        .sheet(isPresented: $showFilePicker) {
            FileDocumentPickerView(selectedImage: $selectedImage)
        }
        // Image selected → OCR
        .onChange(of: selectedImage) { img in
            guard let img else { return }
            processImage(img)
        }
        // OCR result handling
        .onReceive(scannerVM.$state) { state in
            switch state {
            case .success:
                hudVM.transition(to: .success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showPreview = true
                }
            case .failed(let err):
                print("OCR failed:", err)
                hudVM.transition(to: .failed)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    hudVM.transition(to: .idle)
                    scannerVM.reset()
                    selectedImage = nil
                    camera.start()
                }
            default:
                break
            }
        }
        // Preview sheet
        .sheet(isPresented: Binding(
            get: { showPreview },
            set: { val in
                if !val {
                    hudVM.transition(to: .idle)
                    scannerVM.reset()
                    selectedImage = nil
                    camera.start()
                }
                showPreview = val
            }
        )) {
            if case .success(let data) = scannerVM.state {
                ExpensePreviewView(
                    merchant: data.merchant,
                    amount: String(format: "%.0f", data.totalAmount),
                    onSave: { expense in
                        repo.addExpense(expense)
                        showPreview = false
                        scannerVM.reset()
                        selectedImage = nil
                        onDismiss?()
                        presentationMode.wrappedValue.dismiss()
                    },
                    onCancel: {
                        showPreview = false
                        scannerVM.reset()
                        selectedImage = nil
                        hudVM.transition(to: .idle)
                        camera.start()
                    }
                )
            }
        }
    }

    // MARK: - Actions

    private func capturePhoto() {
        // Line is already animating — jump straight to detecting
        hudVM.transition(to: .detecting)
        camera.capturePhoto { image in
            guard let image else {
                // Fallback: open Files if capture fails (e.g. simulator)
                showFilePicker = true
                hudVM.transition(to: .scanning)
                return
            }
            processImage(image)
        }
    }

    private func processImage(_ image: UIImage) {
        camera.stop()
        // Go straight to detecting — no intermediate scanning delay
        hudVM.transition(to: .detecting)
        scannerVM.processImage(image)
    }

    private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            let isOn = device.torchMode == .on
            device.torchMode = isOn ? .off : .on
            isFlashOn = !isOn
            device.unlockForConfiguration()
        } catch {
            print("Torch error:", error)
        }
    }

    // MARK: - Helper sub-views

    @ViewBuilder
    private func circleButton(icon: String, tint: Color = .white) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 44, height: 44)
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(tint)
        }
    }

    @ViewBuilder
    private func iconAction(icon: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Camera Session Manager

@MainActor
class CameraSession: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
    }

    func start() {
        guard !session.isRunning else { return }
        Task.detached { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        guard session.isRunning else { return }
        Task.detached { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            Task { @MainActor in self.captureCompletion?(nil) }
            return
        }
        Task { @MainActor in self.captureCompletion?(image) }
    }
}

// MARK: - Shared shape helpers

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
