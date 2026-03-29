import SwiftUI
import AppKit

// MARK: - Menu Bar Controller

@MainActor
class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var captureWindow: NSWindow?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Margin")
            button.action = #selector(toggleMenu)
            button.target = self
        }
    }

    @objc private func toggleMenu() {
        if captureWindow != nil {
            closeCaptureWindow()
        } else {
            showQuickCapture()
        }
    }

    private func showQuickCapture() {
        let contentView = QuickCaptureMenuView(
            onSave: { [weak self] text in
                self?.saveMoment(text: text)
                self?.closeCaptureWindow()
            },
            onOpenApp: { [weak self] in
                self?.openMainApp()
            },
            onQuit: { [weak self] in
                self?.quit()
            }
        )

        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = NSColor(MarginColors.background)
        window.isReleasedWhenClosed = false
        window.level = .floating

        let button = statusItem?.button
        let buttonFrame = button?.window?.convertToScreen(button?.frame ?? .zero)

        if let frame = buttonFrame {
            let windowWidth: CGFloat = 300
            let windowHeight: CGFloat = 180
            let x = frame.midX - windowWidth / 2
            let y = frame.minY - windowHeight - 4
            window.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
        }

        window.makeKeyAndOrderFront(nil)
        captureWindow = window
    }

    private func closeCaptureWindow() {
        captureWindow?.close()
        captureWindow = nil
    }

    private func openMainApp() {
        closeCaptureWindow()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func quit() {
        NSApp.terminate(nil)
    }

    private func saveMoment(text: String) {
        NotificationCenter.default.post(name: .momentCaptured, object: text)
    }
}

extension Notification.Name {
    static let momentCaptured = Notification.Name("MarginMomentCaptured")
}

// MARK: - Quick Capture Menu View

struct QuickCaptureMenuView: View {
    let onSave: (String) -> Void
    let onOpenApp: () -> Void
    let onQuit: () -> Void

    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Capture a thought")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
                Spacer()
                Button(action: onOpenApp) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12))
                        .foregroundColor(MarginColors.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Expand to full app")
                .accessibilityHint("Open the main Margin application window")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()
                .background(MarginColors.divider)

            // Text field
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("What's on your mind?")
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.divider)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }

                TextField("", text: $text)
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.primaryText)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(MarginColors.surface)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(MarginColors.divider, lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Spacer()

            // Footer
            HStack {
                Button(action: onQuit) {
                    Text("Quit")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Quit")
                .accessibilityHint("Close the menu bar app")

                Spacer()

                Button(action: { onSave(text) }) {
                    Text("Save")
                        .font(MarginFonts.body)
                        .foregroundColor(text.isEmpty ? MarginColors.divider : MarginColors.surface)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(text.isEmpty ? MarginColors.divider.opacity(0.5) : MarginColors.accent)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .disabled(text.isEmpty)
                .accessibilityLabel("Save")
                .accessibilityHint(text.isEmpty ? "Enter some text first" : "Save this moment")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(width: 300, height: 180)
        .background(MarginColors.background)
        .onAppear {
            isFocused = true
        }
    }
}
