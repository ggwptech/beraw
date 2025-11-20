# Custom Domain Setup for Firebase Hosting

## Option 1: Through Firebase Console (Recommended)

### Step 1: Add Custom Domain
1. Go to Firebase Console: https://console.firebase.google.com/project/rawdogapp-403a2/hosting/sites
2. Click "Add custom domain"
3. Enter your domain (e.g., `beraw.app` or `share.beraw.app`)
4. Click "Continue"

### Step 2: Verify Ownership (if required)
Firebase might ask you to verify domain ownership by adding a TXT record:
```
Type: TXT
Name: @
Value: [Firebase will provide this]
```

### Step 3: Configure DNS
Firebase will show you DNS records to add. Choose one option:

**Option A: A Records (Recommended)**
```
Type: A
Name: @ (or subdomain like "share")
Value: 151.101.1.195
Value: 151.101.65.195
```

**Option B: CNAME Record (for subdomains only)**
```
Type: CNAME
Name: share
Value: rawdogapp-403a2.web.app
```

### Step 4: Add DNS Records at Your Domain Registrar

Go to your domain registrar (Namecheap, GoDaddy, Cloudflare, etc.) and add the records.

**Popular registrars:**
- Namecheap: Dashboard → Domain List → Manage → Advanced DNS
- GoDaddy: My Products → Domains → DNS
- Cloudflare: Websites → Select domain → DNS → Records

### Step 5: Wait for Verification
- DNS propagation: 5 minutes - 48 hours (usually 15 minutes)
- SSL certificate: automatic after DNS verification
- Firebase will email you when ready

### Step 6: Update Your Code

**1. Update DynamicLinksManager.swift:**
```swift
private let universalLinkDomain = "share.beraw.app" // Your custom domain
```

**2. Update RawDogged.entitlements:**
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:share.beraw.app</string>
</array>
```

**3. Rebuild and reinstall app**

## Option 2: Through CLI

### Add domain via CLI:
```bash
cd firebase-hosting
firebase hosting:channel:deploy live --only rawdogapp-403a2
```

### View domains:
```bash
firebase hosting:sites:list
```

## Recommended Domain Structure

**Option A: Subdomain (Recommended)**
```
share.beraw.app → Firebase Hosting (Universal Links)
beraw.app → Your main website
```

**Option B: Main domain**
```
beraw.app → Firebase Hosting (both website and Universal Links)
```

**Option C: Separate domain**
```
link.beraw.com → Firebase Hosting (dedicated for sharing)
```

## DNS Configuration Examples

### Cloudflare (Recommended for speed)
1. Add domain to Cloudflare
2. Change nameservers at registrar
3. Add A records in Cloudflare:
   ```
   Type: A
   Name: share (or @)
   IPv4: 151.101.1.195
   Proxy: ON (orange cloud)
   ```
   ```
   Type: A
   Name: share (or @)
   IPv4: 151.101.65.195
   Proxy: ON (orange cloud)
   ```

### Namecheap
1. Login → Domain List → Manage
2. Advanced DNS → Add New Record
3. Add both A records as shown above

### GoDaddy
1. My Products → Domains → DNS
2. Add Record → A
3. Add both A records

## Verification

### Check DNS propagation:
```bash
dig share.beraw.app
# or
nslookup share.beraw.app
```

### Check if apple-app-site-association works:
```bash
curl https://share.beraw.app/.well-known/apple-app-site-association
```

### Test Universal Link:
```
https://share.beraw.app/challenge/YOUR-UUID
```

## Troubleshooting

### "Domain verification failed"
- Wait longer (up to 48 hours)
- Check DNS records are correct
- Try using A records instead of CNAME

### "SSL certificate pending"
- Automatic after DNS verification
- Can take 15 minutes to 24 hours
- Firebase will send email when ready

### Universal Links not working with custom domain
1. ✅ Check apple-app-site-association is accessible
2. ✅ Updated entitlements with new domain
3. ✅ Rebuilt and reinstalled app
4. ✅ Wait 5-10 minutes for Apple CDN cache

## Cost

✅ **Firebase Hosting**: FREE (up to 10GB/month, 360MB/day)
✅ **SSL Certificate**: FREE (automatic from Firebase)
✅ **Domain**: Depends on registrar ($10-15/year)

## Current Setup

Your current Firebase Hosting URL:
```
https://rawdogapp-403a2.web.app
```

After adding custom domain:
```
https://share.beraw.app (or your domain)
```

Both URLs will work!

## Next Steps

1. **Buy domain** (if you don't have one)
   - Namecheap: ~$10/year
   - Cloudflare Registrar: ~$9/year (at cost)
   - Google Domains: ~$12/year

2. **Add to Firebase Console**
3. **Configure DNS**
4. **Wait for verification**
5. **Update code**
6. **Done!**
