import SwiftUI

// MARK: - Main HUD Overlay
struct ScanOverlayView: View {
    @ObservedObject var viewModel: ScanOverlayViewModel

    // Scan line animation
    @State private var scanLineOffset: CGFloat = 0
    @State private var scanLineOpacity: Double = 1.0

    // Corner pulse (idle)
    @State private var cornerOpacity: Double = 1.0

    // Feedback states
    @State private var frameColor: Color = ScanHUDConstants.accentColor
    @State private var frameScale: CGFloat = 1.0
    @State private var shakeOffset: CGFloat = 0

    private let frameWidth: CGFloat = UIScreen.main.bounds.width * ScanHUDConstants.frameWidthRatio
    private let frameHeight: CGFloat = UIScreen.main.bounds.width * ScanHUDConstants.frameWidthRatio * ScanHUDConstants.frameAspectRatio

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Dimmed background with cutout
                DimmedOverlayShape(
                    frameSize: CGSize(width: frameWidth, height: frameHeight),
                    center: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                )
                // eoFill: true punches a transparent hole in the inner rect — camera shows through clearly
                .fill(Color.black.opacity(ScanHUDConstants.dimAlpha), style: FillStyle(eoFill: true))
                .ignoresSafeArea()

                // 2. Scan frame + animated elements
                ZStack {
                    // Scan line (only in scanning/detecting)
                    if viewModel.state == .scanning || viewModel.state == .detecting {
                        scanLine
                    }

                    // 4 Corner guides
                    cornersView
                        .opacity(cornerOpacity)
                        .scaleEffect(frameScale)
                }
                .frame(width: frameWidth, height: frameHeight)
                .offset(shakeOffset: shakeOffset)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Instruction label removed — HUD animations communicate state visually
            }
        }
        .onChange(of: viewModel.state) { newState in
            applyState(newState)
        }
        .onAppear {
            applyState(viewModel.state)
        }
    }

    // MARK: - Scan Line
    private var scanLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        ScanHUDConstants.accentColor.opacity(0.7),
                        ScanHUDConstants.accentColor,
                        ScanHUDConstants.accentColor.opacity(0.7),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2.5)
            .shadow(color: ScanHUDConstants.accentColor.opacity(0.8), radius: 6, x: 0, y: 0)
            .opacity(scanLineOpacity)
            .offset(y: scanLineOffset)
    }

    // MARK: - Corners
    private var cornersView: some View {
        ZStack {
            // Top-left
            CornerBracket()
                .stroke(frameColor, style: StrokeStyle(lineWidth: ScanHUDConstants.cornerLineWidth, lineCap: .round))
                .frame(width: ScanHUDConstants.cornerLength, height: ScanHUDConstants.cornerLength)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            // Top-right
            CornerBracket()
                .stroke(frameColor, style: StrokeStyle(lineWidth: ScanHUDConstants.cornerLineWidth, lineCap: .round))
                .frame(width: ScanHUDConstants.cornerLength, height: ScanHUDConstants.cornerLength)
                .rotationEffect(.degrees(90))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // Bottom-left
            CornerBracket()
                .stroke(frameColor, style: StrokeStyle(lineWidth: ScanHUDConstants.cornerLineWidth, lineCap: .round))
                .frame(width: ScanHUDConstants.cornerLength, height: ScanHUDConstants.cornerLength)
                .rotationEffect(.degrees(-90))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            // Bottom-right
            CornerBracket()
                .stroke(frameColor, style: StrokeStyle(lineWidth: ScanHUDConstants.cornerLineWidth, lineCap: .round))
                .frame(width: ScanHUDConstants.cornerLength, height: ScanHUDConstants.cornerLength)
                .rotationEffect(.degrees(180))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }

    // MARK: - State Animations
    private func applyState(_ state: ScanHUDState) {
        // Reset
        withAnimation(.easeInOut(duration: 0.3)) {
            frameColor = ScanHUDConstants.accentColor
            frameScale = 1.0
            shakeOffset = 0
        }

        switch state {
        case .idle:
            stopScanLine()
            startCornerPulse()

        case .scanning:
            stopCornerPulse()
            startScanLine()

        case .detecting:
            // Pause line, flash corners white
            stopScanLine()
            withAnimation(.easeInOut(duration: 0.25).repeatCount(2, autoreverses: true)) {
                frameColor = .white
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation { frameColor = ScanHUDConstants.accentColor }
            }

        case .success:
            stopScanLine()
            stopCornerPulse()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                frameColor = ScanHUDConstants.accentColor
                frameScale = 1.06
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    frameScale = 1.0
                }
            }
            // Haptic
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        case .failed:
            stopScanLine()
            withAnimation(.easeInOut(duration: 0.25)) {
                frameColor = .red
            }
            performShake()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { frameColor = ScanHUDConstants.accentColor }
            }
            // Haptic
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    private func startScanLine() {
        let halfHeight = frameHeight / 2
        scanLineOffset = -halfHeight
        scanLineOpacity = 1.0
        withAnimation(
            .easeInOut(duration: ScanHUDConstants.scanLineDuration)
            .repeatForever(autoreverses: true)
        ) {
            scanLineOffset = halfHeight
        }
    }

    private func stopScanLine() {
        withAnimation(.easeOut(duration: 0.2)) {
            scanLineOpacity = 0
        }
    }

    private func startCornerPulse() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            cornerOpacity = 0.35
        }
    }

    private func stopCornerPulse() {
        withAnimation(.easeIn(duration: 0.2)) {
            cornerOpacity = 1.0
        }
    }

    private func performShake() {
        let values: [CGFloat] = [0, -12, 12, -8, 8, -4, 4, 0]
        var delay = 0.0
        for value in values {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.06)) {
                    shakeOffset = value
                }
            }
            delay += 0.06
        }
    }
}

// MARK: - Dimmed Overlay (cutout mask)
struct DimmedOverlayShape: Shape {
    var frameSize: CGSize
    var center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        let cutout = CGRect(
            x: center.x - frameSize.width / 2,
            y: center.y - frameSize.height / 2,
            width: frameSize.width,
            height: frameSize.height
        )
        path.addRoundedRect(in: cutout, cornerSize: CGSize(width: 16, height: 16))
        return path
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(center.x, center.y) }
        set { center = CGPoint(x: newValue.first, y: newValue.second) }
    }
}

// fillEvenOdd is needed to create the transparent hole
extension ScanOverlayView {
    // No-op as the Shape uses path(in:) with even-odd rule via the ZStack
}

// MARK: - Corner Bracket Shape
struct CornerBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Draws an L shape: top edge + left edge
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

// MARK: - Shake offset extension
extension View {
    func offset(shakeOffset: CGFloat) -> some View {
        self.offset(x: shakeOffset)
    }
}

// MARK: - Constants
enum ScanHUDConstants {
    static let cornerLength: CGFloat = 28
    static let cornerLineWidth: CGFloat = 3.5
    static let accentColor: Color = Color(red: 0.204, green: 0.780, blue: 0.349) // #34C759
    static let dimAlpha: Double = 0.62
    static let scanLineDuration: TimeInterval = 2.0
    static let frameWidthRatio: CGFloat = 0.72
    static let frameAspectRatio: CGFloat = 1.28
}
