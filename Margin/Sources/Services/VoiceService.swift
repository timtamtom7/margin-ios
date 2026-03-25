import Foundation
import AVFoundation
import Speech

@MainActor
final class VoiceService: ObservableObject {
    enum PermissionState: Equatable {
        case unknown
        case granted
        case denied
    }

    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    @Published var transcription: String = ""
    @Published var permissionState: PermissionState = .unknown
    @Published var permissionDeniedType: String = ""

    private var audioRecorder: AVAudioRecorder?
    private var audioEngine: AVAudioEngine?
    private var recordingURL: URL?

    init() {
        checkPermissions()
    }

    var hasPermission: Bool {
        permissionState == .granted
    }

    func checkPermissions() {
        let micStatus = AVAudioApplication.shared.recordPermission
        switch micStatus {
        case .granted:
            permissionState = .granted
        case .denied:
            permissionState = .denied
            permissionDeniedType = "microphone"
        case .undetermined:
            permissionState = .unknown
        @unknown default:
            permissionState = .unknown
        }
    }

    func requestPermissions() async -> Bool {
        let micStatus = await AVAudioApplication.requestRecordPermission()
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        await MainActor.run {
            if micStatus && speechStatus {
                self.permissionState = .granted
            } else {
                self.permissionState = .denied
                if !micStatus {
                    self.permissionDeniedType = "microphone"
                } else {
                    self.permissionDeniedType = "speech recognition"
                }
            }
        }
        return micStatus && speechStatus
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
            return
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        recordingURL = audioFilename

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            startMeteringTimer()
        } catch {
            print("Recording error: \(error)")
        }
    }

    func stopRecording() -> String? {
        audioRecorder?.stop()
        isRecording = false
        _timerRunning = false
        audioLevel = 0

        guard let url = recordingURL else { return nil }

        Task {
            let transcribed = await transcribeAudio(at: url)
            await MainActor.run {
                self.transcription = transcribed
            }
        }

        return url.path
    }

    private var meteringTimer: Timer?
    // Shared mutable state for timer callback (runs on main run loop, not @MainActor)
    private nonisolated(unsafe) var _meteringRecorder: AVAudioRecorder?
    private nonisolated(unsafe) var _timerRunning: Bool = false

    private func startMeteringTimer() {
        meteringTimer?.invalidate()
        guard let recorder = audioRecorder else { return }
        _meteringRecorder = recorder
        _timerRunning = true

        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            // Read shared nonisolated(unsafe) state set by stopRecording on MainActor
            if !self._timerRunning {
                timer.invalidate()
                return
            }
            self._meteringRecorder?.updateMeters()
            let level = self._meteringRecorder?.averagePower(forChannel: 0) ?? -160
            let normalized = max(0, (level + 50) / 50)
            Task { @MainActor in
                self.audioLevel = normalized
            }
        }
    }

    private func transcribeAudio(at url: URL) async -> String {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            return ""
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        return await withCheckedContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else if error != nil {
                    continuation.resume(returning: "")
                }
            }
        }
    }

    func deleteRecording(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
}
