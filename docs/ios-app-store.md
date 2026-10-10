# iOS and App Store release plan

REALITY BREAKER is being built in Godot 4 so its gameplay code can be shared across Windows and iOS. The current repository is an early prototype; an App Store build is not ready yet.

## What is required

- A macOS build environment with Xcode. A GitHub Actions macOS runner can be used for automated build steps.
- A supported Godot 4 release and its matching iOS export templates.
- A unique iOS bundle identifier chosen for this app (for example, a reverse-domain identifier under a domain/account the publisher controls).
- Apple signing credentials and provisioning configured securely for distribution. Never commit certificates, private keys, API keys, or passwords to this repository.
- An Apple Developer Program team/account and App Store Connect access to submit the signed build. A parent or guardian may need to handle account and payment requirements.
- App icon, launch/splash configuration, privacy details, age rating, screenshots, and a tested build that meets Apple's current review requirements.

## Release stages

1. Finish and test the core game on desktop; keep mobile controls and touch UI in mind.
2. Set the final bundle identifier and create a Godot iOS export preset.
3. Use macOS + Xcode to export the iOS project and test it on a real iPhone.
4. Configure signing outside source control, then create a signed archive/IPA.
5. Upload through Xcode or the supported App Store Connect upload workflow.
6. Complete App Store Connect metadata and submit for review.

## Important status

- This document is a plan, not an IPA build.
- The current prototype has not yet been verified on an iPhone.
- An unsigned IPA or an exported Xcode project is not an App Store-ready submission.
- Do not add signing secrets to GitHub files or commit a generated provisioning profile/certificate.
- Verify the exact current Apple and Godot requirements before release, as these can change.
