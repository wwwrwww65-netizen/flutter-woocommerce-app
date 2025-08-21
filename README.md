<p align="center">
  <img width="200" height="125" src="https://woosignal.com/images/woosignal_logo_stripe_blue.png" alt="WooSignal logo">
</p>

# Mobile Troubleshooter (Flutter)

### Overview

This app has been upgraded to the latest stable Flutter and enhanced for mobile troubleshooting content with:

- RTL i18n (Arabic/English)
- Responsive layouts (phones/tablets)
- First-run device model selection
- Instant local full-text search (SQLite FTS5)
- Rich article pages (text, images, attachments) with offline save, bookmark, mark as solved
- AI Chat UI (Firebase Functions) with streaming-ready design and screenshot upload
- Google Sign-In (Firebase Auth)
- Monthly IAP gating with server-side receipt validation
- Ad scaffolding (AdMob + Facebook Audience Network) and GDPR consent flow
- Firebase integrations: Messaging, Analytics, Crashlytics, Remote Config
- Offline caching using local database

### Requirements

- Flutter 3.24+
- Android Studio/Xcode
- Firebase project (FlutterFire configured)

### Getting Started

1. flutter pub get
2. Configure Firebase using FlutterFire; add `google-services.json` and `GoogleService-Info.plist`
3. Replace placeholders in `.env` and native configs
4. Run: `flutter run`

Placeholders (replace in code and configs):

- <<PACKAGE_NAME>>, <<IOS_BUNDLE_ID>>, <<FIREBASE_PROJECT_ID>>, <<ADMOB_APP_ID_ANDROID>>, <<ADMOB_APP_ID_IOS>>, <<FAN_PLACEMENT_ID>>, <<IAP_PRODUCT_ID_MONTHLY>>

## Some features integrated

- App Store Ready
- Simple configuration
- Localized for en, ar
- Light and dark mode
- Google Sign-In, IAP, Ads
- Firebase Messaging, Analytics, Crashlytics, Remote Config

## Uploading to the app stores

- iOS - Deployment: https://flutter.dev/docs/deployment/ios
- Android - Deployment: https://flutter.dev/docs/deployment/android

## Licence
The app is open-sourced software licensed under the MIT license.