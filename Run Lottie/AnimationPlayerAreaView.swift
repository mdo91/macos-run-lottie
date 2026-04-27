import SwiftUI
#if os(macOS)
import AppKit
#endif

struct AnimationPlayerAreaView: View {
    let selection: URL?
    let files: [URL]

    @Binding var isPlaying: Bool
    @Binding var loop: Bool
    @Binding var speed: Double

    @Binding var isTargeted: Bool

    let onLoadError: (String) -> Void

    var body: some View {
        ZStack {
            if let url = selection ?? files.first {
                VStack(spacing: 0) {
                    LottiePlayerView(fileURL: url, isPlaying: isPlaying, loop: loop, speed: speed) { message in
                        onLoadError(message)
                    }
                        .background(Color(nsColor: .windowBackgroundColor))
                        .overlay(alignment: .bottom) { controls }
                }
            } else {
                emptyState
            }

            if isTargeted { dropOverlay }
        }
        .background(.thinMaterial)
    }

    private var controls: some View {
        VStack {
            Divider()
            HStack(spacing: 16) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                }
                .keyboardShortcut(.space, modifiers: [])

                Toggle(isOn: $loop) {
                    Image(systemName: loop ? "repeat" : "repeat")
                }
                .toggleStyle(.button)
                .help("Loop")

                HStack(spacing: 8) {
                    Image(systemName: "tortoise")
                    Slider(value: $speed, in: 0.1...3.0, step: 0.1)
                        .frame(maxWidth: 240)
                    Image(systemName: "hare")
                }
                Text(String(format: "%.1fx", speed))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Spacer()

                if let sel = selection {
                    Button {
                        #if os(macOS)
                        NSWorkspace.shared.activateFileViewerSelecting([sel])
                        #endif
                    } label: {
                        Label("Show in Finder", systemImage: "folder")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Drop Lottie animations here")
                .font(.title3)
            Text("Supports .json (Lottie JSON) and .lottie packages. You can also click Import.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var dropOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.blue, style: StrokeStyle(lineWidth: 2, dash: [8]))
                )
            VStack(spacing: 8) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.blue)
                Text("Drop to add")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
        }
        .padding(24)
    }
}

#Preview {
    @Previewable @State var files: [URL] = []
    @Previewable @State var selection: URL? = nil
    @Previewable @State var isPlaying = true
    @Previewable @State var loop = true
    @Previewable @State var speed = 1.0
    @Previewable @State var isTargeted = false

    return AnimationPlayerAreaView(selection: selection, files: files, isPlaying: $isPlaying, loop: $loop, speed: $speed, isTargeted: $isTargeted) { _ in }
}
