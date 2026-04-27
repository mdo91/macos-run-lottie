import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

struct AnimationSidebarView: View {
    @Binding var files: [URL]
    @Binding var selection: URL?
    @State private var showingImporter: Bool = false

    let onImport: ([URL]) -> Bool

    private var importTypes: [UTType] {
        var types: [UTType] = [.json]
        if let lottie = UTType(filenameExtension: "lottie") {
            types.append(lottie)
        }
        return types
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showingImporter = true
                } label: {
                    Label("Import", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 8)

                Spacer()

                if !files.isEmpty {
                    Button(role: .destructive) {
                        files.removeAll()
                        selection = nil
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            List(selection: $selection) {
                if files.isEmpty {
                    Text("Drop Lottie .json or .lottie files here")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(files, id: \.self) { url in
                        HStack {
                            Image(systemName: "film")
                            VStack(alignment: .leading, spacing: 2) {
                                Text(url.lastPathComponent)
                                Text(url.deletingLastPathComponent().path)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(url as URL?)
                        .contextMenu {
                            Button("Reveal in Finder") {
                                #if os(macOS)
                                NSWorkspace.shared.activateFileViewerSelecting([url])
                                #endif
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .background(.regularMaterial)
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: importTypes, allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                _ = onImport(urls)
            case .failure:
                break
            }
        }
    }
}

#Preview {
    @Previewable @State var files: [URL] = []
    @Previewable @State var selection: URL? = nil
    return AnimationSidebarView(files: $files, selection: $selection) { _ in false }
}
