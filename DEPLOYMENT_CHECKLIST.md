# Sober Now - Deployment Checklist

## Pre-Deployment Checklist

### 1. Environment Setup
- [ ] Create `.env` file with all required keys
- [ ] Verify Firebase configuration
- [ ] Verify Stripe API keys
- [ ] Test email configuration

### 2. Firebase Configuration
- [ ] Create Firebase project
- [ ] Enable Authentication (Email/Password)
- [ ] Create Firestore database
- [ ] Set up Firestore security rules
- [ ] Create required indexes
- [ ] Configure email templates
- [ ] Set up Cloud Storage (if needed)

### 3. Stripe Configuration
- [ ] Create Stripe account
- [ ] Get API keys (publishable and secret)
- [ ] Create subscription product ($10.99/month)
- [ ] Set up webhook endpoint
- [ ] Test payment flow in test mode
- [ ] Switch to live mode for production

### 4. Code Verification
- [ ] All dependencies installed (`flutter pub get`)
- [ ] No compilation errors
- [ ] Password validation working correctly
- [ ] Username uniqueness check working
- [ ] All screens navigating correctly
- [ ] Firebase operations tested
- [ ] Stripe integration tested

### 5. Testing
- [ ] Sign up flow complete
- [ ] Login with email works
- [ ] Login with username works
- [ ] Password reset works
- [ ] Daily report submission works
- [ ] Badge earning logic works
- [ ] Subscription purchase works
- [ ] Profile updates work
- [ ] Account deletion works
- [ ] App doesn't crash on any screen

## Android Deployment

### 1. App Configuration
Update `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.yourcompany.sobernow"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 2. Generate Signing Key
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 3. Create key.properties
Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-upload-keystore.jks>
```

### 4. Build APK
```bash
flutter build apk --release
```

### 5. Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### 6. Google Play Console
- [ ] Create developer account
- [ ] Create new app
- [ ] Upload app bundle
- [ ] Fill in store listing
- [ ] Add screenshots
- [ ] Set content rating
- [ ] Set pricing (Free)
- [ ] Add privacy policy
- [ ] Submit for review

## iOS Deployment

### 1. App Configuration
Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Sober Now</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.sobernow</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

### 2. Configure Signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Go to Signing & Capabilities
4. Select your team
5. Let Xcode automatically manage signing

### 3. Build Archive
```bash
flutter build ios --release
```

Or in Xcode:
1. Product > Archive
2. Wait for build to complete

### 4. App Store Connect
- [ ] Create App Store Connect account
- [ ] Create new app
- [ ] Upload build via Xcode
- [ ] Fill in app information
- [ ] Add screenshots
- [ ] Set pricing (Free)
- [ ] Add in-app purchases (Premium subscription)
- [ ] Add privacy policy
- [ ] Submit for review

## Post-Deployment

### 1. Monitoring
- [ ] Set up Firebase Analytics
- [ ] Set up Crashlytics
- [ ] Monitor Stripe dashboard
- [ ] Check Cloud Function logs
- [ ] Monitor user feedback

### 2. Marketing Materials
- [ ] Create app icon (1024x1024)
- [ ] Create feature graphics
- [ ] Take screenshots (multiple devices)
- [ ] Write app description
- [ ] Create promotional video (optional)

### 3. Legal Requirements
- [ ] Privacy Policy (required)
- [ ] Terms of Service (required)
- [ ] Cookie Policy (if applicable)
- [ ] GDPR compliance (if EU users)
- [ ] COPPA compliance (if under 13)

### 4. Support Setup
- [ ] Create support email
- [ ] Set up help center/FAQ
- [ ] Create user documentation
- [ ] Set up feedback system

## Version Control

### Git Setup
```bash
# Initialize git repository
git init

# Add remote repository
git remote add origin https://github.com/yourusername/sober-now.git

# Add files
git add .

# Commit
git commit -m "Initial commit"

# Push to remote
git push -u origin main
```

### .gitignore
Ensure the following is in `.gitignore`:
```
# Environment files
.env
.env.local
.env.production

# Key files
android/key.properties
android/*.jks
ios/Runner/GoogleService-Info.plist
android/app/google-services.json

# Build files
build/
.dart_tool/
.packages
.flutter-plugins
.flutter-plugins-dependencies
```

## Maintenance Schedule

### Weekly
- [ ] Check user feedback
- [ ] Monitor crash reports
- [ ] Review analytics
- [ ] Check subscription renewals

### Monthly
- [ ] Update dependencies
- [ ] Review security
- [ ] Backup database
- [ ] Review Cloud Function costs

### Quarterly
- [ ] User survey
- [ ] Feature planning
- [ ] Performance optimization
- [ ] Code review and refactoring

## Emergency Procedures

### Critical Bug
1. Identify the issue
2. Create hotfix branch
3. Fix and test
4. Deploy emergency update
5. Notify users if necessary

### Server Issues
1. Check Firebase status
2. Check Stripe status
3. Review Cloud Function logs
4. Contact support if needed

### Security Breach
1. Immediately revoke compromised keys
2. Force password reset for affected users
3. Notify users
4. Review and patch vulnerability
5. Report to authorities if required

## Success Metrics

### Key Performance Indicators (KPIs)
- [ ] Daily Active Users (DAU)
- [ ] Monthly Active Users (MAU)
- [ ] User retention rate
- [ ] Average session duration
- [ ] Daily report completion rate
- [ ] Subscription conversion rate
- [ ] Churn rate
- [ ] App rating

### Analytics Events to Track
- Sign up completed
- First daily report
- 7-day streak achieved
- 30-day streak achieved
- Subscription purchased
- Subscription cancelled
- Badge earned
- Progress shared

## Resources

### Documentation
- Flutter: https://docs.flutter.dev/
- Firebase: https://firebase.google.com/docs
- Stripe: https://stripe.com/docs

### Support
- Firebase Support: https://firebase.google.com/support
- Stripe Support: https://support.stripe.com/
- Flutter Community: https://flutter.dev/community

### Tools
- Firebase Console: https://console.firebase.google.com/
- Stripe Dashboard: https://dashboard.stripe.com/
- Google Play Console: https://play.google.com/console/
- App Store Connect: https://appstoreconnect.apple.com/
