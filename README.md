# Sober Now - Sobriety Tracking App

A comprehensive Flutter application to help users track their sobriety journey, maintain daily reports, earn badges, and stay motivated.

## Features

### Authentication
- **Sign Up**: Complete onboarding questionnaire (4 questions) followed by account creation
- **Sign In**: Login with email or username
- **Password Reset**: Recover account via email
- **Secure Password**: Validation with uppercase, lowercase, special character, and number requirements

### Core Features
1. **Home Screen**
    - Sobriety streak counter (days since start date)
    - Money saved calculator
    - Daily report status
    - Statistics overview
    - Motivational quotes

2. **Daily Reports**
    - Mood rating (1-5)
    - Craving level tracking
    - Trigger identification
    - Meeting attendance tracking
    - Personal notes

3. **Badges System**
    - Daily milestones (1, 7, 14, 21, 30, 60, 90 days)
    - Weekly achievements
    - Monthly achievements
    - Yearly achievements

4. **Share Progress**
    - Share sobriety streak
    - Share money saved
    - Invite friends to the app

5. **Settings**
    - Edit profile (name, username, email)
    - Manage subscription
    - Delete account

### Subscription Plans
- **Free Plan**: Basic features
- **Premium Plan**: $10.99/month
    - Unlimited daily reports
    - Advanced analytics
    - Custom goals and reminders
    - Data export
    - Priority support
    - Ad-free experience
    - Premium badges

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Firebase Account
- Stripe Account

### 1. Firebase Setup

1. Create a new Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)

2. Enable the following services:
    - Authentication (Email/Password)
    - Cloud Firestore
    - Cloud Storage

3. Get your Firebase configuration:
    - Go to Project Settings
    - Add a new app (Android/iOS/Web)
    - Copy the configuration values

4. Create Firestore collections:
   ```
   users/
   daily_reports/
   badges/
   subscription_reminders/
   ```

5. Set up Firestore Security Rules:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /daily_reports/{reportId} {
         allow read, write: if request.auth != null && 
           resource.data.userId == request.auth.uid;
       }
       match /badges/{badgeId} {
         allow read, write: if request.auth != null && 
           resource.data.userId == request.auth.uid;
       }
     }
   }
   ```

### 2. Stripe Setup

1. Create a Stripe account at [https://stripe.com](https://stripe.com)

2. Get your API keys:
    - Publishable key
    - Secret key

3. Set up a webhook endpoint for subscription management

### 3. Environment Configuration

1. Create a `.env` file in the root directory (already created, fill in your values):

```env
# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_APP_ID=your_firebase_app_id_here
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
STRIPE_SECRET_KEY=your_stripe_secret_key_here
STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret_here

# Email Configuration (for password reset)
EMAIL_API_KEY=your_email_api_key_here
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
# For development
flutter run

# For production build (Android)
flutter build apk --release

# For production build (iOS)
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── user_model.dart
│   ├── daily_report_model.dart
│   └── badge_model.dart
├── providers/                         # State management
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   └── subscription_provider.dart
├── screens/                           # UI screens
│   ├── onboarding/
│   │   ├── welcome_screen.dart
│   │   └── questionnaire_screen.dart
│   ├── auth/
│   │   ├── signup_screen.dart
│   │   ├── login_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── home_tab.dart
│   │   ├── daily_report_tab.dart
│   │   ├── badges_tab.dart
│   │   ├── share_tab.dart
│   │   ├── settings_tab.dart
│   │   └── edit_profile_screen.dart
│   └── subscription/
│       └── subscription_screen.dart
└── utils/                             # Utilities
    ├── firebase_options.dart
    └── validators.dart
```

## Key Features Implementation

### Password Validation
- Minimum 8 characters
- At least 1 uppercase letter
- At least 2 lowercase letters
- At least 1 special character
- At least 1 number
- No sequential numbers

### Username Validation
- Real-time availability check
- Minimum 3 characters
- Unique across all users

### Subscription Management
- 30-day billing cycle
- Auto-renewal
- Email reminder 3 days before renewal
- Cancel anytime

### Data Privacy
- All user data stored securely in Firebase
- Confidential questionnaire responses
- Account deletion removes all associated data

## Firebase Cloud Functions (Optional)

For subscription reminders, create a Cloud Function:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

exports.sendSubscriptionReminders = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const reminders = await admin.firestore()
      .collection('subscription_reminders')
      .where('reminderDate', '<=', now)
      .where('sent', '==', false)
      .get();

    const transporter = nodemailer.createTransporter({
      // Configure your email service
    });

    for (const doc of reminders.docs) {
      const data = doc.data();
      const user = await admin.firestore()
        .collection('users')
        .doc(data.userId)
        .get();

      if (user.exists) {
        await transporter.sendMail({
          to: user.data().email,
          subject: 'Subscription Renewal Reminder',
          text: 'Your subscription will renew in 3 days.',
        });

        await doc.ref.update({ sent: true });
      }
    }
  });
```

## Testing

### Test Accounts
Create test accounts with different scenarios:
1. Free plan user
2. Premium user
3. User with various sobriety durations

### Test Cases
- [ ] Sign up flow with all validations
- [ ] Login with email and username
- [ ] Password reset
- [ ] Daily report submission
- [ ] Badge earning
- [ ] Subscription purchase
- [ ] Profile updates
- [ ] Account deletion

## Deployment

### Android
1. Update `android/app/build.gradle` with signing config
2. Run `flutter build apk --release`
3. Upload to Google Play Console

### iOS
1. Update `ios/Runner/Info.plist`
2. Configure signing in Xcode
3. Run `flutter build ios --release`
4. Upload to App Store Connect

## Support & Maintenance

### Monitoring
- Set up Firebase Analytics
- Monitor Stripe transactions
- Track subscription renewals

### Updates
- Regular dependency updates
- Security patches
- Feature enhancements

## License

Copyright © 2024 Sober Now. All rights reserved.

## Contact

For support or inquiries, please contact: support@sobernow.app
