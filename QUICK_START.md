# Sober Now - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Step 1: Install Flutter
If you don't have Flutter installed:
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# Add Flutter to your PATH
flutter doctor
```

### Step 2: Set Up Firebase
1. Go to https://console.firebase.google.com
2. Create a new project called "Sober Now"
3. Add an Android/iOS/Web app
4. Download configuration files:
   - Android: `google-services.json` → Place in `android/app/`
   - iOS: `GoogleService-Info.plist` → Place in `ios/Runner/`

### Step 3: Configure Environment
1. Open the `.env` file in the project root
2. Replace all placeholder values with your actual Firebase and Stripe credentials:
```env
FIREBASE_API_KEY=AIzaSy...
FIREBASE_APP_ID=1:123456789:web:...
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_PROJECT_ID=sober-now-12345
FIREBASE_STORAGE_BUCKET=sober-now-12345.appspot.com

STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

### Step 4: Install Dependencies
```bash
cd sober_now_app
flutter pub get
```

### Step 5: Run the App
```bash
# Connect your device or start an emulator
flutter run
```

## 📱 App Features Overview

### User Flow
1. **Welcome Screen** → User clicks "Start My Journey"
2. **Questionnaire** → 4 questions about drinking history
3. **Sign Up** → Account creation with validation
4. **Login** → Sign in with email/username
5. **Home Screen** → Main dashboard with 5 tabs

### Tabs
- **Home**: Streak counter, statistics, daily report status
- **Daily Report**: Mood, cravings, triggers, notes
- **Badges**: Milestones and achievements
- **Share**: Share progress on social media
- **Settings**: Profile, subscription, account management

## 🔑 Key Features to Test

### Authentication
- ✅ Sign up with unique username
- ✅ Password must have: 1 uppercase, 2 lowercase, 1 special char, 1 number
- ✅ Login with email or username
- ✅ Password reset via email

### Daily Reports
- ✅ Mood rating (1-5 scale)
- ✅ Craving level slider
- ✅ Multiple trigger selection
- ✅ Meeting attendance checkbox
- ✅ Personal notes

### Badges
- ✅ Daily: 1, 7, 14, 21, 30, 60, 90 days
- ✅ Weekly milestones
- ✅ Monthly milestones
- ✅ Yearly milestones

### Subscription
- ✅ Free plan with basic features
- ✅ Premium plan at $10.99/month
- ✅ Auto-renewal every 30 days
- ✅ Email reminder 3 days before renewal
- ✅ Cancel anytime

## 🔧 Configuration Details

### Firebase Collections Required
Create these in Firestore:
- `users` - User profiles
- `daily_reports` - Daily check-ins
- `badges` - Earned achievements
- `subscription_reminders` - Renewal notifications

### Security Rules
Copy the rules from `FIREBASE_SETUP.md` to your Firestore Rules tab.

### Indexes
Create these composite indexes in Firestore:
1. `daily_reports`: userId (Asc) + date (Desc)
2. `badges`: userId (Asc) + type (Asc) + count (Desc)

## 💳 Stripe Setup

### Test Mode
1. Use test API keys from Stripe Dashboard
2. Test card: `4242 4242 4242 4242`
3. Any future expiry date
4. Any CVC

### Live Mode (Production)
1. Complete Stripe account verification
2. Switch to live API keys
3. Set up webhook endpoint for subscription events

## 📊 Testing Checklist

### Must Test Before Launch
- [ ] Sign up with all field validations
- [ ] Login with email
- [ ] Login with username
- [ ] Password reset flow
- [ ] Daily report submission
- [ ] Badge appearance at milestones
- [ ] Subscription purchase (test mode)
- [ ] Profile updates
- [ ] Account deletion

### Test Scenarios
1. **New User**: Complete onboarding → Sign up → Submit first report
2. **Returning User**: Login → Check streak → Submit daily report
3. **Premium User**: Subscribe → Access premium features
4. **Long-term User**: Test 7-day, 30-day badge unlock

## 🐛 Common Issues & Solutions

### Issue: "Firebase not initialized"
**Solution**: Ensure `.env` file has correct Firebase credentials

### Issue: "Username already taken"
**Solution**: This is expected - usernames must be unique

### Issue: "Stripe payment failed"
**Solution**: Check Stripe API keys in `.env` file

### Issue: "App crashes on launch"
**Solution**: Run `flutter clean && flutter pub get`

## 📝 Development Tips

### Hot Reload
```bash
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

### Debug Mode
```bash
flutter run --debug
```

### Release Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### View Logs
```bash
flutter logs
```

## 🎨 Customization

### Change App Colors
Edit `lib/main.dart`:
```dart
primaryColor: const Color(0xFF00897B), // Your color here
```

### Change App Name
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

### Change App Icon
Replace files in:
- `android/app/src/main/res/mipmap-*/`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 📚 Next Steps

1. **Complete Setup**: Fill in all `.env` variables
2. **Test Thoroughly**: Run through all user flows
3. **Deploy to Firebase**: Set up Cloud Functions for reminders
4. **Submit to Stores**: Follow `DEPLOYMENT_CHECKLIST.md`
5. **Monitor**: Set up Analytics and Crashlytics

## 🆘 Support

### Documentation
- 📖 Full README: `README.md`
- 🔥 Firebase Setup: `FIREBASE_SETUP.md`
- 🚀 Deployment Guide: `DEPLOYMENT_CHECKLIST.md`

### Resources
- Flutter Docs: https://docs.flutter.dev/
- Firebase Docs: https://firebase.google.com/docs
- Stripe Docs: https://stripe.com/docs

### Community
- Flutter Discord: https://discord.gg/flutter
- Firebase Slack: https://firebase.google.com/support/slack

---

**Ready to help people on their sobriety journey! 🎉**
