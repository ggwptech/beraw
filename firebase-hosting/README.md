# Firebase Hosting Setup

## Files Created
- `public/.well-known/apple-app-site-association` - Universal Links configuration
- `public/index.html` - Main landing page
- `public/challenge/index.html` - Challenge share page
- `firebase.json` - Firebase Hosting configuration

## Setup Instructions

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase (in firebase-hosting folder)
```bash
cd firebase-hosting
firebase init hosting
```

Select:
- Use an existing project or create new one
- Public directory: `public`
- Configure as single-page app: No
- Set up automatic builds: No

### 4. Deploy
```bash
firebase deploy --only hosting
```

### 5. Get Your Domain
After deployment, you'll get a URL like:
`https://your-project.web.app`

### 6. Update Code
Update domain in `DynamicLinksManager.swift`:
```swift
private let universalLinkDomain = "your-project.web.app"
```

Update in `RawDogged.entitlements`:
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:your-project.web.app</string>
</array>
```

### 7. Test
- Deploy to Firebase
- Open link on real device: `https://your-project.web.app/challenge/YOUR-UUID`
- Should open app if installed, or show landing page

## What Each File Does

### apple-app-site-association
- Tells iOS that your domain is associated with your app
- Contains your Team ID and Bundle ID
- Must be accessible at `/.well-known/apple-app-site-association`

### challenge/index.html
- Landing page for challenge links
- Tries to open app via custom scheme
- Falls back to App Store after 3 seconds
- Beautiful UI with animation

### index.html
- Main landing page for your app
- Simple, clean design
- Link to App Store

### firebase.json
- Configures Firebase Hosting
- Sets correct Content-Type for apple-app-site-association
- Rewrites all /challenge/* URLs to challenge page
