
import SwiftUI
import AppKit // For NSPasteboard

@MainActor
class TeleprompterViewModel: ObservableObject {
    @Published var displayLines: [DisplayLine] = []
    @Published var isPlaying: Bool = false
    @Published var isError: Bool = false
    @Published var currentLineId: Int? = nil

    private var script: ScriptModel = ScriptModel(text: "")
    private var currentWordIndex: Int = -1
    private var totalWordCount: Int = 0
    
    private let speechSynchronizer = SpeechSynchronizer()

    init() {
        self.displayLines = []
        setupSpeechSync()
    }
    
    private func setupSpeechSync() {
        speechSynchronizer.requestAuthorization()
        
        speechSynchronizer.onWordRecognized = { [weak self] word in
            self?.processRecognizedWord(word)
        }
        
        speechSynchronizer.onError = { [weak self] error in
            self?.handleSpeechError(error)
        }
    }

    func togglePlayPause() {
        if displayLines.isEmpty { return }
        
        isPlaying.toggle()
        if isPlaying {
            do {
                try speechSynchronizer.start()
            } catch {
                handleSpeechError(error)
            }
        } else {
            speechSynchronizer.stop()
        }
    }

    func scrollUp() {
        if currentWordIndex > 0 {
            currentWordIndex -= 1
            updateHighlighting()
        }
    }

    func scrollDown() {
        if currentWordIndex < totalWordCount - 1 {
            currentWordIndex += 1
            updateHighlighting()
        } else {
            if isPlaying {
                togglePlayPause()
            }
        }
    }

    // MARK: - Script Loading

    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url,
           let text = try? String(contentsOf: url, encoding: .utf8) {
            loadScript(fromText: text)
        }
    }
    
    func pasteText() {
        if let pastedString = NSPasteboard.general.string(forType: .string) {
            loadScript(fromText: pastedString)
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
            guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            DispatchQueue.main.async {
                if let text = try? String(contentsOf: url, encoding: .utf8) {
                    self.loadScript(fromText: text)
                }
            }
        }
    }
    
    private func loadScript(fromText text: String) {
        script = ScriptModel(text: text)
        currentWordIndex = -1
        totalWordCount = script.words.count
        if isPlaying {
            togglePlayPause()
        }
        updateHighlighting()
    }
    
    // MARK: - Speech Recognition Logic
    
    private func processRecognizedWord(_ recognizedWord: String) {
        let cleanRecognizedWord = recognizedWord.lowercased().trimmingCharacters(in: .punctuationCharacters)
        
        // Define a search window of the next 7 words
        let searchWindowStart = currentWordIndex + 1
        let searchWindowEnd = min(searchWindowStart + 7, script.words.count)
        guard searchWindowStart < searchWindowEnd else { return }
        
        let searchSlice = script.words[searchWindowStart..<searchWindowEnd]
        
        // Find the best match in the window
        var bestMatchIndex = -1
        var bestMatchSimilarity = 0.6 // Require a minimum similarity

        for (index, scriptWord) in searchSlice.enumerated() {
            let cleanScriptWord = scriptWord.lowercased().trimmingCharacters(in: .punctuationCharacters)
            let similarity = stringSimilarity(a: cleanRecognizedWord, b: cleanScriptWord)
            if similarity > bestMatchSimilarity {
                bestMatchSimilarity = similarity
                bestMatchIndex = searchWindowStart + index
            }
        }
        
        // If a good match is found, advance to that word
        if bestMatchIndex != -1 {
            currentWordIndex = bestMatchIndex
            updateHighlighting()
        }
    }
    
    private func handleSpeechError(_ error: Error) {
        print("Speech recognition error: \(error.localizedDescription)")
        isError = true
        if isPlaying {
            togglePlayPause()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isError = false
        }
    }
    
    // MARK: - UI Updates

    private func updateHighlighting() {
        var wordCounter = 0
        var newDisplayLines: [DisplayLine] = []
        var currentLine: Int? = nil
        
        for (index, line) in script.lines.enumerated() {
            let lineWords = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            var newWords: [DisplayWord] = []
            var lineContainsCurrentWord = false
            for wordText in lineWords {
                var word = DisplayWord(text: wordText)
                word.isSpoken = wordCounter < currentWordIndex
                word.isCurrent = wordCounter == currentWordIndex
                if word.isCurrent {
                    lineContainsCurrentWord = true
                }
                newWords.append(word)
                wordCounter += 1
            }
            if lineContainsCurrentWord {
                currentLine = index
            }
            newDisplayLines.append(DisplayLine(id: index, words: newWords))
        }
        self.displayLines = newDisplayLines
        if let currentLine = currentLine {
            self.currentLineId = currentLine
        }
    }
    
    // MARK: - Helpers
    
    private func stringSimilarity(a: String, b: String) -> Double {
        let lenA = a.count
        let lenB = b.count
        if lenA == 0 || lenB == 0 { return 0.0 }
        let maxLen = max(lenA, lenB)
        let distance = levenshteinDistance(a: a, b: b)
        return Double(maxLen - distance) / Double(maxLen)
    }

    private func levenshteinDistance(a: String, b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        var dist = [[Int]]()
        for _ in 0...a.count {
            dist.append(Array(repeating: 0, count: b.count + 1))
        }
        for i in 1...a.count { dist[i][0] = i }
        for j in 1...b.count { dist[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i][j] = dist[i-1][j-1]
                } else {
                    dist[i][j] = min(dist[i-1][j] + 1, dist[i][j-1] + 1, dist[i-1][j-1] + 1)
                }
            }
        }
        return dist[a.count][b.count]
    }
}

// Helper for safe array access
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
