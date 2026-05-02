# Funcation

Funcation is an iOS app designed to simplify group travel planning by helping users collaboratively research, propose, vote on, and budget trip ideas.

## Features

- Create or join trips using invite codes
- Add and vote on trip desires, such as lodging, food, transport, and activities
- Budget calculation with total and per-person cost support
- AI-assisted research extraction from links
- Firebase-backed trip, desire, and vote storage

## Tech Stack

- SwiftUI
- Firebase Firestore
- Firebase Anonymous Authentication
- OpenAI API

## Setup Instructions

1. Clone the repository.

```bash
git clone https://github.com/robertpattinson-reina/funcation.git
cd funcation
```
2. Open the project in xcode
```bash
open Funcation.xcodeproj
```
3. Add Firebase configuration
   - Download GoogleService-Info.plist from Firebase Console
   - Place it inside the Funcation app folder in Xcode
4. Add OpenAI API Key
   - Create a file named Secrets.xcconfig in the project root
   - Add: OPENAI_API_KEY = your_openai_api_key_here
5. Run the app
