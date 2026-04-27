import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @State private var files: [URL] = []
    @State private var selection: URL? = nil

    @State private var isPlaying: Bool = true
    @State private var loop: Bool = true
    @State private var speed: Double = 1.0

    @State private var isTargeted: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingError: Bool = false

    private let allowedExtensions: Set<String> = ["json", "lottie"]
    
    var body: some View {
        NavigationSplitView {
            AnimationSidebarView(files: $files, selection: $selection, onImport: handleDrop)
        } detail: {
            AnimationPlayerAreaView(selection: selection, files: files, isPlaying: $isPlaying, loop: $loop, speed: $speed, isTargeted: $isTargeted) { message in
                errorMessage = message
                showingError = true
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 900, minHeight: 560)
        .dropDestination(for: URL.self) { items, _ in
            handleDrop(items)
        } isTargeted: { targeted in
            isTargeted = targeted
        }
        .alert("Unable to load animation", isPresented: $showingError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "The file may not be a valid Lottie animation.")
        })
    }

    @discardableResult
    private func handleDrop(_ urls: [URL]) -> Bool {
        let newOnes: [URL] = urls
            .filter { allowedExtensions.contains($0.pathExtension.lowercased()) }
            .map { $0.standardizedFileURL }

        guard !newOnes.isEmpty else { return false }

        // Start security-scoped access if needed (drag & drop usually provides it implicitly)
        // We optimistically add; failures to load will simply not play.
        var set = Set(files.map(\.path))
        for u in newOnes where !set.contains(u.path) {
            files.append(u)
            set.insert(u.path)
        }
        if selection == nil { selection = files.first }
        return true
    }
}

#Preview {
    ContentView()
}
