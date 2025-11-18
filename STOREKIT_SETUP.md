# StoreKit Integration - Next Steps

## ✅ Code Integration Complete!

I've added:
1. **StoreManager.swift** - Handles all StoreKit operations
2. **Updated PaywallView** - Now uses real purchases
3. **Restore Purchases button** - Added below Continue button
4. **Real price loading** - Shows actual price from App Store

---

## 🔧 What YOU Need to Do in Xcode:

### Step 1: Add In-App Purchase Capability
1. Open your project in Xcode
2. Select target: **RawDogged**
3. Go to tab: **Signing & Capabilities**
4. Click **"+ Capability"**
5. Add: **"In-App Purchase"**

### Step 2: Add StoreManager.swift to Target
1. In Xcode, find **StoreManager.swift** in the file navigator
2. Make sure it's checked for target **RawDogged** (in File Inspector)

### Step 3: Build and Test
1. Build the project (Cmd+B)
2. Fix any compile errors if they appear
3. Run on a **real device** (Simulator doesn't support IAP)

---

## 📱 Testing on Device:

### Before Testing - Create Sandbox Tester:
1. Go to App Store Connect → Users and Access → Sandbox Testers
2. Create a test Apple ID (e.g., `test@example.com`)
3. **DON'T use your real Apple ID for testing!**

### Test Purchase:
1. On your iPhone: Settings → App Store → Sign out (if signed in)
2. Run app from Xcode
3. Open Profile → tap "Get Premium"
4. Select Weekly plan → tap "Continue"
5. iOS will ask to sign in → use your **Sandbox Tester** account
6. Complete the test purchase (it's free in sandbox)
7. Check if Premium is unlocked

### Test Restore:
1. Delete app from device
2. Reinstall and login
3. Open Paywall → tap "Restore Purchases"
4. Premium should be restored

---

## 🚀 Submit to App Store:

1. Archive your app (Product → Archive)
2. Distribute to App Store Connect
3. In App Store Connect:
   - Select your build
   - Make sure subscription is "Ready to Submit"
   - Submit for Review
4. Apple will review app + subscription together

---

## Product IDs Currently Configured:

- **Weekly**: `com.getcode.BeRaw.weekly` ✅

*If you add Yearly later, add it to StoreManager.swift productIDs array*

---

## Common Issues:

**"Product not found"**
- Wait 2-24 hours after creating product in App Store Connect
- Make sure product is "Ready to Submit" status
- Check Product ID matches exactly

**"Cannot connect to iTunes Store"**
- Use real device, not simulator
- Check internet connection
- Sign in with Sandbox Tester account

**Build errors**
- Make sure StoreKit is imported
- Check In-App Purchase capability is added
- Verify StoreManager.swift is in target

---

## Need Help?
Let me know what error you're seeing!
