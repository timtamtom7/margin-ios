# Margin iOS — Iteration R13

## Theme: Monetization, Retention & Premium

## Status
**Completed**: Core implemented  
**Commit**: `01ccbc0` — "MarginMac R13: App Store listing, paper texture polish, launch checklist"

---

## What's Built

### SubscriptionManager (`SubscriptionManager.swift`)
- [x] Three tiers: Free, Pro ($7.99/mo), Complete ($14.99/mo)
- [x] Free tier: 20 moments/month, basic patterns, 7-day history
- [x] Pro tier: Unlimited moments, advanced patterns, voice-to-moment, AI briefings, 30-day history
- [x] Complete tier: Everything in Pro, lifetime history, priority AI, data export, widgets
- [x] `checkCaptureAllowed()` — blocks capture at limit
- [x] `recordMomentCapture()` — decrements monthly counter
- [x] Monthly reset logic via `checkMonthlyReset()`
- [x] UserDefaults persistence for tier and counter
- [x] `showPaywall` binding for paywall presentation
- [x] `restorePurchases()` and `subscribeToPro()` stubs (StoreKit ready)
- [x] `SubscriptionManager.shared` singleton

### RetentionService (`RetentionService.swift`)
- [x] Day 1 milestone: first moment captured
- [x] Day 3 milestone: first pattern discovered
- [x] Day 7 milestone: first AI briefing viewed
- [x] `trackMilestone()` hook for analytics
- [x] UserDefaults persistence
- [x] `RetentionMilestone` enum with milestone labels
- [x] `currentMilestone` computed property

### MarginMac R13 Updates
- [x] App Store listing preparation
- [x] Paper texture polish for launch
- [x] Launch checklist complete
- [x] Accessibility labels audit

---

## What's Left

### Paywall UI
- [ ] `PaywallView` — full-screen paywall design
- [ ] Feature comparison table (Free vs Pro vs Complete)
- [ ] Monthly/annual toggle with discount
- [ ] Purchase button — initiates StoreKit flow
- [ ] Restore purchases button

### Subscription Gate
- [ ] Gate unlimited capture behind `isSubscribed` check
- [ ] Show "X moments remaining" banner when near limit
- [ ] Pattern insights locked for Free tier (show lock icon)
- [ ] Voice capture locked for Free tier
- [ ] History beyond 7 days locked for Free tier

### Retention UX
- [ ] Milestone celebration UI (confetti, badge)
- [ ] Onboarding tips for each milestone
- [ ] "Keep going!" nudge notifications
- [ ] Streak tracking (consecutive days with moment)

### Widgets (Complete tier)
- [ ] Home screen widget — today's moment count
- [ ] Lock screen widget — quick capture button
- [ ] Widget bundle with small/medium/large sizes

### Data Export (Complete tier)
- [ ] Export moments as JSON
- [ ] Export as CSV
- [ ] Export as PDF (formatted journal)

---

## Pricing
| Tier | Price | Capture | History | Patterns | Voice | Widgets |
|------|-------|---------|---------|----------|-------|---------|
| Free | $0 | 20/mo | 7 days | Basic | ✗ | ✗ |
| Pro | $7.99/mo | Unlimited | 30 days | Advanced | ✓ | ✗ |
| Complete | $14.99/mo | Unlimited | Lifetime | Advanced | ✓ | ✓ |

---

## Out of Scope
- Family sharing
- Android port
- Web app
