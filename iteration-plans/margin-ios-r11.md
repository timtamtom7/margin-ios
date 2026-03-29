# Margin iOS — Iteration R11

## Theme: Groups, Threads & Community Insights

## Status
**Completed**: Implemented  
**Commit**: `38c83be` — "Round 11: Groups, Threads, Insights — MarginR11Service (private groups, threaded discussions, community insights)"

---

## What's Built

### Core Models & Services
- [x] `MarginR11Service` — manages groups and community insights
- [x] `MarginGroup` model — name, members, moments, settings
- [x] `GroupMember` — name, avatar seed
- [x] `GroupSettings` — requireApproval, anonymousAllowed flags
- [x] `CommunityInsights` — totalMomentsThisWeek, topMoods, trendingTopics, weekOverWeekChange
- [x] Mood enum (happy, sad, anxious, peaceful, excited, neutral)

### Data Layer
- [x] `GroupThread` model (stored in DB via `threads` table)
- [x] `SharedMoment` model — anonymous social sharing
- [x] Thread CRUD via `DatabaseService.saveThread/fetchAllThreads/deleteThread`
- [x] Moment thread linking via `updateMomentThread()`
- [x] `isAbandonedThread` flag for threads not updated in 3+ days
- [x] `markAbandonedThreads()` cleanup task

### UI Integration
- [x] Groups tab in TabView
- [x] Thread view — chronological moment chain
- [x] Abandoned thread detection
- [x] Deep thought detection on moments

---

## Technical Notes

- Groups share `threads` table with existing MomentThread model
- Mood tags stored as raw strings in DB
- Community insights computed async on moment save

---

## Out of Scope (R12+)
- iPad layout
- Watch companion
- CloudKit sync
- Push notifications
