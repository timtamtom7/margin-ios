import SwiftUI

struct CaptureView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var captureMode: CaptureMode = .text
    @State private var textInput: String = ""
    @State private var isProcessing = false
    @State private var showReflectionPrompt = false
    @State private var reflectionPrompt: String = ""
    @State private var reflectionAnswer: String = ""
    @State private var savedMoment: Moment?
    @State private var voiceTranscription: String = ""

    enum CaptureMode {
        case voice
        case text
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                VStack(spacing: MarginSpacing.lg) {
                    if isProcessing {
                        processingView
                    } else if showReflectionPrompt {
                        reflectionView
                    } else {
                        inputView
                    }
                }
                .padding(MarginSpacing.lg)
            }
            .navigationTitle(showReflectionPrompt ? "Reflect" : "Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(MarginColors.secondaryText)
                }

                if !showReflectionPrompt && !isProcessing && !textInput.isEmpty || (captureMode == .voice && voiceTranscription.isEmpty == false) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            submitMoment()
                        }
                        .foregroundColor(MarginColors.accent)
                        .fontWeight(.medium)
                    }
                }
            }
        }
    }

    private var inputView: some View {
        VStack(spacing: MarginSpacing.xl) {
            Picker("Mode", selection: $captureMode) {
                Text("Text").tag(CaptureMode.text)
                Text("Voice").tag(CaptureMode.voice)
            }
            .pickerStyle(.segmented)
            .padding(.top, MarginSpacing.lg)

            if captureMode == .voice {
                voiceInputView
            } else {
                textInputView
            }

            Spacer()
        }
    }

    private var textInputView: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            Text("What are you thinking?")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            TextEditor(text: $textInput)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
                .scrollContentBackground(.hidden)
                .background(MarginColors.surface)
                .frame(minHeight: 150)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MarginColors.divider, lineWidth: 1)
                )

            Text("Don't think too hard. Just jot down whatever crossed your mind.")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
                .italic()
        }
    }

    private var voiceInputView: some View {
        VStack(spacing: MarginSpacing.xl) {
            Spacer()

            if appState.voiceService.isRecording {
                VStack(spacing: MarginSpacing.md) {
                    Image(systemName: "waveform")
                        .font(.system(size: 64))
                        .foregroundColor(MarginColors.accent)
                        .symbolEffect(.variableColor.iterative, options: .repeating)

                    Text("Listening...")
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)

                    Text("Tap anywhere to stop")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    stopVoiceRecording()
                }
            } else {
                VStack(spacing: MarginSpacing.md) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 64))
                        .foregroundColor(MarginColors.accent.opacity(0.3))

                    Text("Hold to record")
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)

                    Text("or tap to start")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    startVoiceRecording()
                }
            }

            if !voiceTranscription.isEmpty {
                Text("\"\(voiceTranscription)\"")
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.primaryText)
                    .padding()
                    .background(MarginColors.surface)
                    .cornerRadius(12)
            }

            Spacer()
        }
    }

    private var processingView: some View {
        VStack(spacing: MarginSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(MarginColors.accent)

            Text("Thinking...")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.secondaryText)
        }
    }

    private var reflectionView: some View {
        VStack(spacing: MarginSpacing.lg) {
            if let moment = savedMoment {
                MomentCard(moment: moment)
            }

            AIPromptBubble(
                prompt: reflectionPrompt,
                answer: $reflectionAnswer,
                onSubmit: submitReflection
            )

            Button("Skip for now") {
                dismiss()
            }
            .font(MarginFonts.caption)
            .foregroundColor(MarginColors.secondaryText)
            .padding(.top, MarginSpacing.md)

            Spacer()
        }
    }

    private func startVoiceRecording() {
        Task {
            let granted = await appState.voiceService.requestPermissions()
            if granted {
                await MainActor.run {
                    appState.voiceService.startRecording()
                }
            }
        }
    }

    private func stopVoiceRecording() {
        _ = appState.voiceService.stopRecording()

        // Poll for transcription
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                if !appState.voiceService.transcription.isEmpty {
                    voiceTranscription = appState.voiceService.transcription
                    textInput = voiceTranscription
                }
            }
        }
    }

    private func submitMoment() {
        guard !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isProcessing = true
        let context = appState.contextService.inferContext(from: Date())

        let moment = Moment(
            text: textInput.trimmingCharacters(in: .whitespacesAndNewlines),
            voicePath: nil,
            timestamp: Date(),
            timeOfDay: context.timeOfDay,
            dayOfWeek: context.dayOfWeek,
            contextType: context.context
        )

        Task {
            do {
                try await appState.databaseService.saveMoment(moment)
                await MainActor.run {
                    savedMoment = moment
                    reflectionPrompt = appState.aiService.generateReflectionPrompt()
                    isProcessing = false
                    showReflectionPrompt = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                }
                print("Save error: \(error)")
            }
        }
    }

    private func submitReflection() {
        guard let moment = savedMoment else { return }

        Task {
            do {
                try await appState.databaseService.updateMomentReflection(
                    momentId: moment.id,
                    prompt: reflectionPrompt,
                    answer: reflectionAnswer.isEmpty ? nil : reflectionAnswer
                )
            } catch {
                print("Reflection save error: \(error)")
            }
        }

        dismiss()
    }
}

#Preview {
    CaptureView()
        .environmentObject(AppState())
}
