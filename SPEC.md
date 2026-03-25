# Margin — Product Specification

## 1. Concept & Vision

Margin captures the micro-moments — waiting in line, coffee brewing, red light, elevator. It turns dead time into intentional micro-reflections. The AI notices what you think about when you're bored, surfacing patterns across time and context. The experience feels like flipping through a worn, personal notebook: unhurried, quiet, and deeply yours.

## 2. Design Language

### Aesthetic Direction
Paper-and-pencil notebook. Not digital. Not clean. Feels hand-touched, slightly imperfect, warm. Inspired by Field Notes, Muji, and indie sketchbooks.

### Color Palette
- **Background:** `#F5F2EB` (warm off-white, like aged paper)
- **Surface:** `#FDFCF8` (bright paper white)
- **Primary Text:** `#2C2A26` (soft charcoal)
- **Secondary Text:** `#7A776F` (pencil gray)
- **Accent:** `#C4A882` (warm caramel / aged ink)
- **Accent Secondary:** `#9AAEAB` (muted sage)
- **Destructive:** `#C0736A` (soft terracotta)
- **Divider:** `#E0DDD4` (faint pencil line)

### Typography
- **Headings:** `Georgia` — classic serif, bookish warmth
- **Body:** `System` (SF Pro) — clean readability
- **Captions:** `System` Light — sparse, quiet
- **Handwritten feel:** Use `system` with slight italic or custom letterSpacing where needed

### Spatial System
- Generous margins: 24pt on sides, 16pt between cards
- Cards have subtle shadow and slight corner roundness (8pt)
- Lots of whitespace — content breathes

### Motion Philosophy
- Subtle and organic: 200-400ms ease-in-out transitions
- Cards fade and slide in softly (like turning a page)
- Capture button has a gentle pulse animation when idle
- No harsh snapping — everything eases

### Visual Assets
- SF Symbols for icons (thin weight, pencil-sketch feel)
- No harsh borders — use subtle shadows and divider lines
- Divider lines are hand-drawn-feeling (slightly uneven opacity)

## 3. Layout & Structure

### Screen Architecture
1. **HomeView** — Central hub. Shows today's moments, daily digest preview, quick capture button.
2. **CaptureView** — Full-screen capture experience. Voice or text input. AI prompt appears after.
3. **MomentStreamView** — Scrollable timeline of all moments. Grouped by day.
4. **MomentDetailView** — Single moment view with full AI reflection and context.
5. **PatternAnalysisView** — AI-generated pattern insights. "You think about X when Y."
6. **DailyDigestView** — End-of-day summary: total dead time, top thoughts, context breakdown.
7. **SettingsView** — CloudKit sync toggle, notification preferences, data export.

### Navigation
- TabView at bottom with 3 tabs: Home, Stream, Patterns
- Settings accessible from Home via gear icon
- Capture is a full-screen modal from floating button

### Responsive Strategy
- iPhone-only for Round 1 (no iPad)
- Portrait orientation locked for simplicity

## 4. Features & Interactions

### Moment Capture
- Floating action button (bottom-right, subtle)
- Tap → full-screen capture sheet slides up
- Choose: **Voice** or **Text**
- **Voice:** Hold to record, release to stop. Waveform visualization.
- **Text:** Simple text field, keyboard appears
- On submit: timestamp, time-of-day context, and a gentle AI prompt appears
- Context auto-captured: hour of day, day of week, estimated activity type (based on time patterns)
- Location context (if permitted): type of place (work, home, transit, etc.)

### Micro-Reflection Prompt
- After capturing, AI shows a gentle follow-up question
- Examples: "What were you just thinking about?", "Was that a worry or a hope?", "Did that thought surprise you?"
- User can answer or skip
- AI uses Apple Intelligence (on-device) when available

### Moment Stream
- Chronological list, newest first
- Grouped by day with day headers ("Tuesday, March 24")
- Each card shows: time, truncated thought, context tag
- Tap → MomentDetailView
- Swipe to delete (with confirmation)
- Pull-to-refresh for AI re-analysis

### Pattern Analysis
- "Insights" tab in bottom nav
- AI-generated summaries based on aggregated moments
- Examples: "At traffic lights you think about relationships. In line at coffee shops you think about work."
- Show as handwritten-feeling cards
- Tap insight for more detail (what moments contributed)

### Daily Digest
- Appears on Home at ~9PM or on demand
- Shows: total moments captured, total dead time (estimated), top thought category, top context
- Card at top of Home stream
- Gentle notification at end of day

### Error States
- Empty stream: "No moments yet. Tap + to capture your first."
- No patterns yet: "Keep capturing — patterns emerge over time."
- Offline: "Working offline. Moments saved locally."

## 5. Component Inventory

### MomentCard
- States: default, expanded (detail), deleting
- Shows: time badge, thought text (2-line truncated), context pill
- Subtle shadow, cream background, slight rotation (-0.5° to +0.5°)

### CaptureButton
- States: idle (gentle pulse), recording, processing
- Circular, accent color, "+" icon
- Pulse: scale 1.0 → 1.05, 2s loop

### ContextPill
- Small rounded rectangle
- Shows: icon + label ("☕ Coffee shop", "🚦 Traffic light")
- Accent secondary background

### AIPromptBubble
- Appears below captured moment
- Question in slightly smaller, italicized text
- User response field below

### PatternCard
- Handwritten-feeling header
- Body text explains the pattern
- Tap to expand

### DailyDigestCard
- Prominent on home screen
- Shows: today's stats in a hand-drawn aesthetic table
- Subtle decorative elements (squiggles, dots)

## 6. Technical Approach

### Framework
- SwiftUI (iOS 26)
- Minimum deployment: iOS 26
- Architecture: MVVM with Observable

### Data Persistence
- **SQLite.swift** for local storage
- Tables: `moments`, `reflections`, `patterns`, `daily_digests`
- All data stored locally first; CloudKit optional sync later

### AI / Apple Intelligence
- Use `AppleIntelligence` framework for on-device analysis
- Fallback: `文生` (local model) for analysis when Apple Intelligence not available
- Prompt generation: gentle, curious, non-judgmental tone
- Pattern analysis: aggregate reflection on batches of moments

### CloudKit (Future Round 2)
- Optional sync via CloudKit
- Private database, user owns their data
- Conflict resolution: last-write-wins with merge for text fields

### Models
```
Moment:
  - id: UUID
  - text: String (transcribed if voice)
  - voicePath: String? (local file reference)
  - timestamp: Date
  - timeOfDay: String (morning/afternoon/evening/night)
  - dayOfWeek: String
  - contextType: String? (transit/waiting/elevator/coffee/other)
  - locationType: String? (work/home/outdoor/indoor)
  - reflectionPrompt: String?
  - reflectionAnswer: String?
  - createdAt: Date

DailyDigest:
  - id: UUID
  - date: Date
  - totalMoments: Int
  - estimatedDeadTimeMinutes: Int
  - topThoughtCategory: String?
  - topContext: String?
  - summary: String (AI-generated)
  - createdAt: Date

Pattern:
  - id: UUID
  - trigger: String (e.g., "traffic lights")
  - thoughtCategory: String
  - description: String
  - momentCount: Int
  - confidence: Double
  - createdAt: Date
```

### Services
- `DatabaseService` — SQLite.swift wrapper, CRUD operations
- `AIService` — Apple Intelligence integration, pattern analysis, prompt generation
- `ContextService` — Infers context from time/location (no GPS coordinates stored)
- `VoiceService` — Audio recording and transcription via Speech framework
