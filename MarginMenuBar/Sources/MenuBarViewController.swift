import AppKit
import SQLite

class MenuBarViewController: NSViewController {
    private var textField: NSTextField!
    private var submitButton: NSButton!
    private var todayCountLabel: NSTextField!
    private var lastMomentLabel: NSTextField!
    private var statusLabel: NSTextField!

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 280))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStats()
    }

    private func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 245/255, green: 242/255, blue: 235/255, alpha: 1.0).cgColor

        // Header
        let headerLabel = NSTextField(labelWithString: "Margin")
        headerLabel.font = NSFont.systemFont(ofSize: 18, weight: .medium)
        headerLabel.textColor = NSColor(red: 44/255, green: 42/255, blue: 38/255, alpha: 1.0)
        headerLabel.frame = NSRect(x: 16, y: 240, width: 100, height: 24)
        view.addSubview(headerLabel)

        let taglineLabel = NSTextField(labelWithString: "Capture a micro-thought")
        taglineLabel.font = NSFont.systemFont(ofSize: 11, weight: .light)
        taglineLabel.textColor = NSColor(red: 122/255, green: 119/255, blue: 111/255, alpha: 1.0)
        taglineLabel.frame = NSRect(x: 16, y: 218, width: 200, height: 16)
        view.addSubview(taglineLabel)

        // Stats section
        let statsBox = NSBox()
        statsBox.boxType = .custom
        statsBox.fillColor = NSColor.white
        statsBox.borderColor = NSColor(red: 224/255, green: 221/255, blue: 212/255, alpha: 1.0)
        statsBox.borderWidth = 1
        statsBox.cornerRadius = 8
        statsBox.frame = NSRect(x: 16, y: 160, width: 288, height: 48)
        view.addSubview(statsBox)

        todayCountLabel = NSTextField(labelWithString: "0 moments today")
        todayCountLabel.font = NSFont.systemFont(ofSize: 13)
        todayCountLabel.textColor = NSColor(red: 44/255, green: 42/255, blue: 38/255, alpha: 1.0)
        todayCountLabel.frame = NSRect(x: 24, y: 185, width: 130, height: 18)
        view.addSubview(todayCountLabel)

        lastMomentLabel = NSTextField(labelWithString: "Last: just now")
        lastMomentLabel.font = NSFont.systemFont(ofSize: 11, weight: .light)
        lastMomentLabel.textColor = NSColor(red: 122/255, green: 119/255, blue: 111/255, alpha: 1.0)
        lastMomentLabel.frame = NSRect(x: 160, y: 185, width: 130, height: 18)
        view.addSubview(lastMomentLabel)

        // Capture section
        let captureLabel = NSTextField(labelWithString: "What's on your mind?")
        captureLabel.font = NSFont.systemFont(ofSize: 12, weight: .light)
        captureLabel.textColor = NSColor(red: 122/255, green: 119/255, blue: 111/255, alpha: 1.0)
        captureLabel.frame = NSRect(x: 16, y: 132, width: 200, height: 16)
        view.addSubview(captureLabel)

        textField = NSTextField()
        textField.placeholderString = "Jot down a thought..."
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.bezelStyle = .roundedBezel
        textField.frame = NSRect(x: 16, y: 100, width: 288, height: 28)
        view.addSubview(textField)

        submitButton = NSButton(title: "Capture", target: self, action: #selector(submitMoment))
        submitButton.bezelStyle = .rounded
        submitButton.frame = NSRect(x: 16, y: 64, width: 80, height: 28)
        submitButton.contentTintColor = NSColor(red: 196/255, green: 168/255, blue: 130/255, alpha: 1.0)
        view.addSubview(submitButton)

        statusLabel = NSTextField(labelWithString: "")
        statusLabel.font = NSFont.systemFont(ofSize: 11, weight: .light)
        statusLabel.textColor = NSColor(red: 122/255, green: 119/255, blue: 111/255, alpha: 1.0)
        statusLabel.frame = NSRect(x: 104, y: 68, width: 200, height: 20)
        view.addSubview(statusLabel)

        // Open app button
        let openButton = NSButton(title: "Open Margin App", target: self, action: #selector(openMainApp))
        openButton.bezelStyle = .inline
        openButton.isBordered = false
        openButton.font = NSFont.systemFont(ofSize: 11, weight: .light)
        openButton.contentTintColor = NSColor(red: 154/255, green: 174/255, blue: 171/255, alpha: 1.0)
        openButton.frame = NSRect(x: 16, y: 28, width: 120, height: 20)
        view.addSubview(openButton)
    }

    private func loadStats() {
        // Load from shared SQLite database
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let marginDir = appSupportURL.appendingPathComponent("Margin")

        // Try to find the iOS app's database
        let possiblePaths = [
            marginDir.appendingPathComponent("margin.sqlite3"),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Documents/margin.sqlite3")
        ]

        for dbPath in possiblePaths {
            if fileManager.fileExists(atPath: dbPath.path) {
                loadStatsFromDB(at: dbPath)
                return
            }
        }

        // No DB found - use defaults
        todayCountLabel.stringValue = "Open app to sync"
        lastMomentLabel.stringValue = ""
    }

    private func loadStatsFromDB(at path: URL) {
        do {
            let db = try Connection(path.path)
            let moments = Table("moments")
            let timestampCol = Expression<Double>("timestamp")
            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: Date()).timeIntervalSince1970

            // Fetch all moments and filter in memory for safety
            var todayCount = 0
            var lastTimestamp: Double = 0

            for row in try db.prepare(moments) {
                let ts = row[timestampCol]
                if ts >= todayStart {
                    todayCount += 1
                }
                if ts > lastTimestamp {
                    lastTimestamp = ts
                }
            }

            todayCountLabel.stringValue = "\(todayCount) moment\(todayCount == 1 ? "" : "s") today"

            if lastTimestamp > 0 {
                let lastDate = Date(timeIntervalSince1970: lastTimestamp)
                let interval = Date().timeIntervalSince(lastDate)
                if interval < 60 {
                    lastMomentLabel.stringValue = "Last: just now"
                } else if interval < 3600 {
                    lastMomentLabel.stringValue = "Last: \(Int(interval/60))m ago"
                } else {
                    lastMomentLabel.stringValue = "Last: \(Int(interval/3600))h ago"
                }
            }
        } catch {
            todayCountLabel.stringValue = "0 moments today"
        }
    }

    @objc private func submitMoment() {
        let text = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let weekday = calendar.component(.weekday, from: now)

        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "morning"
        case 12..<17: timeOfDay = "afternoon"
        case 17..<21: timeOfDay = "evening"
        default: timeOfDay = "night"
        }
        let dayOfWeek = calendar.weekdaySymbols[weekday - 1]

        // Save to database
        saveMoment(text: text, timeOfDay: timeOfDay, dayOfWeek: dayOfWeek, timestamp: now)

        // Update UI
        statusLabel.stringValue = "✓ Captured!"
        textField.stringValue = ""

        // Refresh stats
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.statusLabel.stringValue = ""
            self?.loadStats()
        }
    }

    private func saveMoment(text: String, timeOfDay: String, dayOfWeek: String, timestamp: Date) {
        let fileManager = FileManager.default

        // Try to find or create the app's database in Documents
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dbPath = documentsURL.appendingPathComponent("margin.sqlite3")

        do {
            let db = try Connection(dbPath.path)

            let moments = Table("moments")
            let id = Expression<String>("id")
            let textCol = Expression<String>("text")
            let timestampCol = Expression<Double>("timestamp")
            let timeOfDayCol = Expression<String>("time_of_day")
            let dayOfWeekCol = Expression<String>("day_of_week")
            let createdAtCol = Expression<Double>("created_at")

            try db.run(moments.insert(
                id <- UUID().uuidString,
                textCol <- text,
                timestampCol <- timestamp.timeIntervalSince1970,
                timeOfDayCol <- timeOfDay,
                dayOfWeekCol <- dayOfWeek,
                createdAtCol <- timestamp.timeIntervalSince1970
            ))
        } catch {
            print("MenuBar: Failed to save moment: \(error)")
        }
    }

    @objc private func openMainApp() {
        // Open the iOS app via URL scheme
        if let url = URL(string: "margin://capture") {
            NSWorkspace.shared.open(url)
        }
    }
}
