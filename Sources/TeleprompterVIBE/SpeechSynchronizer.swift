import Foundation
import Speech
import AVFoundation

class SpeechSynchronizer {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var lastRecognizedWord: String = ""

    var onWordRecognized: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                if authStatus != .authorized {
                    print("Speech recognition not authorized.")
                }
            }
        }
    }

    func start() throws {
        // Ensure any previous task is cancelled and resources are released
        stop()

        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object.")
        }
        recognitionRequest.shouldReportPartialResults = true

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result, !result.bestTranscription.formattedString.isEmpty {
                let currentText = result.bestTranscription.formattedString
                let words = currentText.split(separator: " ").map { String($0) }
                if let latestWord = words.last, latestWord.lowercased() != self.lastRecognizedWord.lowercased() {
                    self.lastRecognizedWord = latestWord
                    self.onWordRecognized?(latestWord)
                }
            }

            if let error = error {
                print("Recognition task error: \(error)")
                self.onError?(error)
                self.stop()
            }
            
            if result?.isFinal == true {
                self.stop()
            }
        }
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        lastRecognizedWord = ""
    }
}