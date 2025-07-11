import Foundation

struct ScriptModel {
    let fullText: String
    let lines: [String]
    let words: [String]
    
    init(text: String) {
        self.fullText = text
        // Normalize line breaks
        let normalizedText = text.replacingOccurrences(of: "\r\n", with: "\n")
        // Split into paragraphs by double newlines
        let paragraphs = normalizedText.components(separatedBy: "\n\n")
        var displayLines: [String] = []
        var allWords: [String] = []
        for (idx, paragraph) in paragraphs.enumerated() {
            let paragraphWords = paragraph.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            allWords.append(contentsOf: paragraphWords)
            // Chunk paragraph into lines of up to 10 words
            var i = 0
            while i < paragraphWords.count {
                let lineWords = paragraphWords[i..<min(i+10, paragraphWords.count)]
                displayLines.append(lineWords.joined(separator: " "))
                i += 10
            }
            // Add a blank line to preserve paragraph breaks (except after the last paragraph)
            if idx < paragraphs.count - 1 {
                displayLines.append("")
            }
        }
        self.lines = displayLines
        self.words = allWords
    }
    
    // TODO: Add logic for chunking the script into displayable parts.
}
