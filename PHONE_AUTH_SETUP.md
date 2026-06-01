# Phone Authentication — Setup Checklist

The app now gates everything behind **Firebase Phone Authentication**: users
verify a phone number via SMS, then pick a display name, and that account
persists across launches and devices.

The Swift code is done. The steps below are external configuration that has to
be done in the Firebase / Apple consoles and in Xcode — they can't be committed.

## 1. Firebase Console
- **Authentication → Sign-in method → enable "Phone".**
- (Dev) Under Phone provider, add **test phone numbers** with fixed codes so you
  don't spend real SMS while developing (e.g. `+1 555-555-1234` → `123456`).
- Make sure a **Firestore** database exists (the app writes a `users` collection
  and reads/writes `trips`).

## 2. APNs (required — Phone Auth verifies the app with a silent push)
- In the **Apple Developer** portal, create an **APNs Authentication Key** (.p8).
- In **Firebase Console → Project Settings → Cloud Messaging**, upload that key
  (with its Key ID and your Team ID).

## 3. Xcode capabilities
- Target → **Signing & Capabilities**:
  - Add **Push Notifications**.
  - Add **Background Modes** → check **Remote notifications**.
- This pairs with the APNs hooks already wired up in `AppDelegate`
  (`FuncationApp.swift`).

## 4. reCAPTCHA fallback URL scheme (used when APNs is unavailable)
- Open your `GoogleService-Info.plist` and copy the **`REVERSED_CLIENT_ID`** value.
- In the target's **Info → URL Types**, add a URL scheme equal to that value.
  (`AppDelegate.application(_:open:options:)` already forwards it to Firebase.)

## 5. Testing notes
- Real SMS delivery + the silent push need a **physical device**. The simulator
  works only with the **test numbers** from step 1.
- Real SMS has per-message cost/quota — prefer test numbers during development.

## What the code does
- `AuthService` — `startPhoneVerification` / `confirmCode` / `signOut`.
- `UserService` — persists the `AppUser` account (display name + phone) in the
  `users` collection and resolves member names.
- `SessionStore` — drives the top-level routing: `loading → signedOut →
  needsProfile → active`. Firebase restores the session on launch automatically.
- Views — `PhoneAuthView` (number → code), `ProfileSetupView` (display name),
  and a new **Group** tab (`GroupView`) that shows the invite code and members
  by name.
