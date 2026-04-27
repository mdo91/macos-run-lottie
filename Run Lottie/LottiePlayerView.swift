import SwiftUI
#if os(macOS)
import AppKit
#endif
#if canImport(Lottie)
import Lottie

public struct LottiePlayerView: NSViewRepresentable {
    public let fileURL: URL
    public let isPlaying: Bool
    public let loop: Bool
    public let speed: Double
    public let onLoadError: ((String) -> Void)?

    public init(fileURL: URL, isPlaying: Bool, loop: Bool, speed: Double, onLoadError: ((String) -> Void)? = nil) {
        self.fileURL = fileURL
        self.isPlaying = isPlaying
        self.loop = loop
        self.speed = speed
        self.onLoadError = onLoadError
    }

    public class Coordinator {
        var animationView: LottieAnimationView?
        var lastURL: URL?
    }

    public func makeCoordinator() -> Coordinator { Coordinator() }

    public func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.wantsLayer = true

        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundBehavior = .pauseAndRestore

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        context.coordinator.animationView = animationView
        return container
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        guard let animationView = context.coordinator.animationView else { return }

        // Load animation if URL changed
        if context.coordinator.lastURL != fileURL {
            context.coordinator.lastURL = fileURL
            if let animation = LottieAnimation.filepath(fileURL.path) {
                animationView.animation = animation
            } else {
                animationView.animation = nil
                onLoadError?("Failed to load animation from \(fileURL.lastPathComponent). The file may not be a valid Lottie animation.")
            }
        }

        // Update playback settings
        animationView.loopMode = loop ? .loop : .playOnce
        animationView.animationSpeed = CGFloat(speed)

        // Play/pause according to state
        if isPlaying {
            animationView.play()
        } else {
            animationView.pause()
        }
    }
}

#else

public struct LottiePlayerView: View {
    public let fileURL: URL
    public let isPlaying: Bool
    public let loop: Bool
    public let speed: Double
    public let onLoadError: ((String) -> Void)?

    public init(fileURL: URL, isPlaying: Bool, loop: Bool, speed: Double, onLoadError: ((String) -> Void)? = nil) {
        self.fileURL = fileURL
        self.isPlaying = isPlaying
        self.loop = loop
        self.speed = speed
        self.onLoadError = onLoadError
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.yellow)
            Text("Lottie not installed")
                .font(.headline)
            Text("Add the Lottie Swift Package to play animations:\nhttps://github.com/airbnb/lottie-spm")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#endif


