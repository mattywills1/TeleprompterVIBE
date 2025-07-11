
import SwiftUI

// MARK: - Placeholder View
struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Teleprompter VIBE!")
                .font(.system(size: 48, weight: .bold))
            Text("""
            Drag-and-drop a .txt file,\nPaste text (⌘V),\nor choose Script ▸ Open Script… (⌘O) from the menu above.
            """)
                .multilineTextAlignment(.center)
                .font(.system(size: 28))
        }
        .padding()
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = TeleprompterViewModel()

    // View-specific constants
    private let backgroundColor = Color(hex: "#2B2B2B")
    private let textColor = Color(hex: "#D0D0D0")
    private let highlightColor = Color(hex: "#FFD700")
    private let font = Font.system(size: 36)
    private let lineHeight: CGFloat = 1.5

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(isPlaying: viewModel.isPlaying, toggleAction: viewModel.togglePlayPause)

            ZStack {
                if viewModel.displayLines.isEmpty {
                    PlaceholderView()
                } else {
                    ScriptScrollView(viewModel: viewModel,
                                     font: font,
                                     lineHeight: lineHeight,
                                     highlightColor: highlightColor,
                                     textColor: textColor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(backgroundColor)
        .foregroundColor(textColor)
        .border(viewModel.isError ? Color.red : Color.clear, width: 2)
        .onReceive(NotificationCenter.default.publisher(for: .open)) { _ in viewModel.openFile() }
        .onReceive(NotificationCenter.default.publisher(for: .paste)) { _ in viewModel.pasteText() }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            viewModel.handleDrop(providers: providers)
            return true
        }
        .background(
            ZStack {
                Button(action: viewModel.togglePlayPause) {}.keyboardShortcut(" ", modifiers: [])
                Button(action: viewModel.scrollUp) {}.keyboardShortcut(.upArrow, modifiers: [])
                Button(action: viewModel.scrollDown) {}.keyboardShortcut(.downArrow, modifiers: [])
            }
        )
    }
}

// MARK: - Subviews

struct HeaderView: View {
    let isPlaying: Bool
    let toggleAction: () -> Void

    var body: some View {
        HStack {
            Button(action: toggleAction) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title)
            }
            .padding()
            Spacer()
        }
        .frame(height: 60)
    }
}

struct ScriptScrollView: View {
    @ObservedObject var viewModel: TeleprompterViewModel
    let font: Font
    let lineHeight: CGFloat
    let highlightColor: Color
    let textColor: Color
    let fontSize: CGFloat = 36

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: fontSize * (lineHeight - 1)) {
                    ForEach(viewModel.displayLines) { line in
                        LineView(line: line, font: font, highlightColor: highlightColor, textColor: textColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .onChange(of: viewModel.currentLineId) { newLineId in
                if let id = newLineId {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(id, anchor: .top)
                    }
                }
            }
        }
    }
}

struct LineView: View {
    let line: DisplayLine
    let font: Font
    let highlightColor: Color
    let textColor: Color

    var body: some View {
        HStack(spacing: 0) {
            ForEach(line.words) { word in
                Text(word.text + " ")
                    .font(font)
                    .foregroundColor(word.isCurrent ? highlightColor : textColor)
                    .opacity(word.isSpoken ? 0.4 : 1.0)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(line.id)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
