# MarginMac — Launch Checklist

## Pre-Launch (R13)

### App Store Setup
- [ ] Create Apple Developer account (if not already)
- [ ] Create App Store Connect listing
  - [ ] Enter tagline: "A moment to think."
  - [ ] Write description (see `Marketing/APPSTORE.md`)
  - [ ] Upload screenshots (5) — 1200×800, Retina
  - [ ] Record App Preview video (15s)
  - [ ] Fill keywords (see `Marketing/APPSTORE.md`)
  - [ ] Set category: Lifestyle / Productivity
  - [ ] Set pricing: Free
  - [ ] Add privacy policy URL
  - [ ] Add support URL
- [ ] Configure age rating (4+)
- [ ] Set up Banking & Tax info in App Store Connect
- [ ] Set up Export Compliance (no cryptography used)
- [ ] Select distribution: All territories

### Build & Signing
- [ ] Verify code signing certificate in Keychain
- [ ] Set correct Bundle ID: `com.margin.MarginMac`
- [ ] Set version: 1.0, build: 1
- [ ] Archive in Xcode: Product → Archive
- [ ] Validate with App Store Connect
- [ ] Distribute to App Store
- [ ] Wait for processing (~30–60 min)

### Marketing Assets
- [ ] App icon: 1024×1024 (from `Margin/Resources/Assets.xcassets/AppIcon.appiconset`)
- [ ] 5 screenshots ready (1200×800)
- [ ] Optional: App Preview video (15s)
- [ ] Press kit / landing page (optional)

### Legal
- [ ] Privacy Policy URL (host a simple page or use a privacy policy generator)
- [ ] Terms of Service (if needed)
- [ ] Confirm no user data is transmitted externally

### Pre-Launch Smoke Test
- [ ] Install from TestFlight or direct build
- [ ] Verify menu bar icon appears
- [ ] Verify capture flow works
- [ ] Verify timeline loads moments
- [ ] Verify settings persist
- [ ] Check for crashes on Intel and Apple Silicon

---

## Post-Launch

### Day One
- [ ] Monitor App Store Connect for processing status
- [ ] Check for Build Errors in Connect
- [ ] Confirm "Ready for Sale" appears
- [ ] Share on social media / HN / Product Hunt (if desired)

### Week One
- [ ] Monitor crash reports in App Store Connect
- [ ] Check first user reviews
- [ ] Address any immediate feedback

### Ongoing
- [ ] Push 1.0.1 bug fix if needed
- [ ] Consider feature roadmap: iCloud sync, iOS companion app, export
