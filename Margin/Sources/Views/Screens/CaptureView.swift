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

    // R2: Detected mood
    @State private var detectedMood: MoodTag?
    @State private var showMoodSelector = false

    // R2.5: Permission denial state
    @State private var showPermissionDenied = false
    @State private var permissionDeniedMessage = ""

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

                if !showReflectionPrompt && !isProcessing && !textInput.isEmpty || (captureMode == .voice && !voiceTranscription.isEmpty) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            submitMoment()
                        }
                        .foregroundColor(MarginColors.accent)
                        .fontWeight(.medium)
                    }
                }
            }
            .alert("Permission Required", isPresented: $showPermissionDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(permissionDeniedMessage)
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
                .onChange(of: textInput) { _, newValue in
                    // R2: Real-time mood detection
                    if !newValue.isEmpty {
                        detectedMood = appState.aiService.detectMood(from: newValue)
                    }
                }

            // R2: Mood indicator
            if let mood = detectedMood {
                HStack(spacing: MarginSpacing.sm) {
                    Text("Detected mood:")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                    Text(mood.emoji)
                        .font(.system(size: 14))
                    Text(mood.displayName)
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accentSecondary)

                    Spacer()

                    Button {
                        showMoodSelector = true
                    } label: {
                        Text("Change")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
                .padding(MarginSpacing.sm)
                .background(MarginColors.accentSecondary.opacity(0.1))
                .cornerRadius(8)
            }

            Text("Don't think too hard. Just jot down whatever crossed your mind.")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
                .italic()
        }
        .sheet(isPresented: $showMoodSelector) {
            MoodSelectorSheet(selectedMood: $detectedMood)
        }
        .sheet(isPresented: Binding(
            get: { appState.subscriptionManager.showPaywall },
            set: { appState.subscriptionManager.showPaywall = $0 }
        )) {
            PaywallView(subscriptionManager: appState.subscriptionManager)
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
                VStack(spacing: MarginSpacing.sm) {
                    Text("\"\(voiceTranscription)\"")
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.primaryText)
                        .padding()
                        .background(MarginColors.surface)
                        .cornerRadius(12)

                    // R2: Show detected mood from transcription
                    if let mood = detectedMood {
                        HStack {
                            Text(mood.emoji)
                                .font(.system(size: 14))
                            Text(mood.displayName)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.accentSecondary)
                        }
                    }
                }
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
                MomentCard(moment: moment, showThreadIndicator: moment.threadId != nil)
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
            } else {
                await MainActor.run {
                    let deniedType = appState.voiceService.permissionDeniedType
                    if deniedType == "microphone" {
                        permissionDeniedMessage = "Microphone access is needed to record voice notes. Please enable it in Settings."
                    } else {
                        permissionDeniedMessage = "Speech recognition access is needed to transcribe your voice notes. Please enable it in Settings."
                    }
                    showPermissionDenied = true
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
                    // R2: Detect mood from transcription
                    detectedMood = appState.aiService.detectMood(from: voiceTranscription)
                }
            }
        }
    }

    private func submitMoment() {
        guard !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // R10: Check subscription tier limit before saving
        if !appState.subscriptionManager.checkCaptureAllowed() {
            appState.subscriptionManager.showPaywall = true
            return
        }

        isProcessing = true
        let context = appState.contextService.inferContext(from: Date())

        // R2: Detect deep thought
        let isDeep = appState.aiService.isDeepThought(text: textInput)

        // R2: Detect mood
        let mood = detectedMood ?? appState.aiService.detectMood(from: textInput)

        // R2: Detect thread (best effort, errors are non-fatal)
        var threadId: UUID? = nil
        var previousMomentId: UUID? = nil
        do {
            let recentMoments = try appState.databaseService.fetchRecentMoments()
            if let thread = appState.aiService.detectThread(
                moment: Moment(text: textInput, timestamp: Date(), timeOfDay: context.timeOfDay, dayOfWeek: context.dayOfWeek),
                recentMoments: recentMoments
            ) {
                threadId = thread.threadId
                previousMomentId = thread.previousMomentId
            }
        } catch {
            print("Thread detection error: \(error)")
        }

        let moment = Moment(
            text: textInput.trimmingCharacters(in: .whitespacesAndNewlines),
            voicePath: nil,
            timestamp: Date(),
            timeOfDay: context.timeOfDay,
            dayOfWeek: context.dayOfWeek,
            contextType: context.context,
            locationType: appState.contextService.currentLocationType,
            isDeepThought: isDeep,
            moodTag: mood,
            threadId: threadId,
            previousMomentId: previousMomentId
        )

        Task {
            do {
                try await appState.databaseService.saveMoment(moment)

                // R10: Record this moment against the free tier
                appState.subscriptionManager.recordMomentCapture()

                // R2: If this started a new thread, save it
                if let tid = threadId, previousMomentId == nil {
                    let thread = MomentThread(
                        id: tid,
                        momentIds: [moment.id],
                        lastUpdatedAt: Date(),
                        isActive: true
                    )
                    try await appState.databaseService.saveThread(thread)
                } else if let tid = threadId, let _ = previousMomentId {
                    // Update existing thread
                    do {
                        let allThreads = try await appState.databaseService.fetchAllThreads()
                        if var existingThread = allThreads.first(where: { $0.id == tid }) {
                            existingThread.momentIds.append(moment.id)
                            existingThread.lastUpdatedAt = Date()
                            try await appState.databaseService.saveThread(existingThread)
                        }
                    } catch {
                        print("Thread update error: \(error)")
                    }
                }

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

// R2: Mood selector sheet
struct MoodSelectorSheet: View {
    @Binding var selectedMood: MoodTag?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: MarginSpacing.md) {
                        ForEach(MoodTag.allCases, id: \.self) { mood in
                            moodButton(mood)
                        }
                    }
                    .padding(MarginSpacing.lg)
                }
            }
            .navigationTitle("How do you feel?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(MarginColors.accent)
                }
            }
        }
    }

    private func moodButton(_ mood: MoodTag) -> some View {
        let isSelected = selectedMood == mood
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMood = isSelected ? nil : mood
            }
        } label: {
            VStack(spacing: MarginSpacing.sm) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                Text(mood.displayName)
                    .font(MarginFonts.caption)
                    .foregroundColor(isSelected ? MarginColors.accent : MarginColors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(MarginSpacing.md)
            .background(isSelected ? MarginColors.accent.opacity(0.15) : MarginColors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? MarginColors.accent : MarginColors.divider, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    CaptureView()
        .environmentObject(AppState())
}
