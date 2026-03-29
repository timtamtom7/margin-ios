# Margin iOS — Iteration R12

## Theme: Watch Companion & Expanded Platforms

## Status
**In Progress**: MarginMac companion built  
**Focus**: Apple Watch app, macOS layout, spatial features

---

## What's Built

### MarginMac (macOS Companion)
- [x] Full macOS app in `MarginMac/` directory
- [x] Standalone Xcode project (`MarginMac.xcodeproj`)
- [x] `MacContentView` — main content shell
- [x] `MacCaptureView` — moment capture UI
- [x] `MacTimelineView` — chronological moment stream
- [x] `MacInsightsView` — pattern visualization
- [x] `MacReflectionDetailView` — moment detail with AI reflections
- [x] `MacSettingsView` — preferences and sync options
- [x] Paper-and-pencil notebook aesthetic matching iOS app
- [x] Accessibility labels audit complete

### MarginWatch (watchOS App)
- [ ] Basic structure in `MarginWatch/` directory
- [ ] Watch-specific UI — simplified moment capture
- [ ] Glance complication showing today's moment count
- [ ] Watch haptic feedback on capture
- [ ] Sync with iPhone via WatchConnectivity

---

## What's Left

### MarginWatch
- [ ] Watch-specific UI — simplified moment capture
- [ ] Glance complication showing today's moment count
- [ ] Watch haptic feedback on capture
- [ ] Sync with iPhone via WatchConnectivity

### Spatial Features
- [ ] `SpatialGalleryView` refinement
- [ ] Share to Photos library (spatial photo export)
- [ ] Vision Pro support (future)

---

## Technical Notes

- MarginMac is a standalone project, NOT part of main Xcode workspace
- Shares database path with iOS app via App Group (when configured)
- watchOS uses separate database, synced via WatchConnectivity

---

## Dependencies
- WatchConnectivity (system framework)
- HealthKit (optional — step count as dead-time proxy)

---

## Out of Scope (R13)
- CloudKit sync
- Push notifications
- Subscription/paywall
