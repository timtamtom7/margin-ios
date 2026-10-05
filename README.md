# Margin

Capture with an AI prompt bubble alongside — a menu bar and watch companion for getting thoughts down and having them shaped.

## Concept

- Fast capture with an AI prompt bubble
- Menu bar companion (`MarginMenuBar`)
- watchOS companion (`MarginWatch`)

## Targets

- iOS
- macOS menu bar
- watchOS

## Stack

- SwiftUI
- Apple Intelligence
- XcodeGen (`project.yml`)

## Structure

Three targets: `Margin/` (iOS), `MarginMenuBar/`, `MarginWatch/`. Key types: `AIPromptBubble`, `AIService`, `AppleIntelligenceService`, `CaptureButton`, `AppState`.

Version 1.0.

## Status

Apple-platform experiment built to explore what an AI coding agent could produce for a native app. Not actively maintained.

Xcode projects here were generated with XcodeGen (`project.yml`); open the `.xcodeproj` directly.
