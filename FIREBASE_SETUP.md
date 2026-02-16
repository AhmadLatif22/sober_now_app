# Firebase Setup Guide

## Firestore Database Structure

### Collections

#### 1. users
```javascript
{
  uid: string,
  fullName: string,
  username: string (unique),
  email: string,
  sobrietyStartDate: timestamp,
  dailyAlcoholSpend: number,
  drinkingDuration: number (1-5),
  drinkingAmount: number (1-5),
  medicalAdvice: number (1-5),
  impactLevel: number (1-5),
  createdAt: timestamp,
  isPremium: boolean,
  subscriptionEndDate: timestamp | null
}
```

#### 2. daily_reports
```javascript
{
  id: string,
  userId: string,
  date: timestamp,
  moodRating: number (1-5),
  cravingLevel: number (1-5),
  notes: string,
  triggers: array<string>,
  attended_meeting: boolean,
  createdAt: timestamp
}
```

#### 3. badges
```javascript
{
  id: string,
  userId: string,
  type: string ('BadgeType.daily' | 'BadgeType.weekly' | 'BadgeType.monthly' | 'BadgeType.yearly'),
  count: number,
  earnedAt: timestamp,
  isUnlocked: boolean
}
```

#### 4. subscription_reminders
```javascript
{
  userId: string,
  reminderDate: timestamp,
  subscriptionEndDate: timestamp,
  sent: boolean
}
```

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Users can read and write their own document
      allow read, write: if isOwner(userId);
      
      // Allow reading username for uniqueness check during signup
      allow read: if isSignedIn() && 
        request.query.limit <= 1 &&
        request.query.where.field == 'username';
    }
    
    // Daily reports collection
    match /daily_reports/{reportId} {
      // Users can only access their own reports
      allow read, write: if isSignedIn() && 
        resource.data.userId == request.auth.uid;
      
      // Allow creating new reports
      allow create: if isSignedIn() && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Badges collection
    match /badges/{badgeId} {
      // Users can only access their own badges
      allow read, write: if isSignedIn() && 
        resource.data.userId == request.auth.uid;
      
      // Allow creating new badges
      allow create: if isSignedIn() && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Subscription reminders (admin only for production)
    match /subscription_reminders/{reminderId} {
      allow read, write: if false; // Should be handled by Cloud Functions
      allow create: if isSignedIn();
    }
  }
}
```

## Firestore Indexes

Create these indexes for optimal query performance:

### Index 1: Daily Reports by User and Date
- Collection: `daily_reports`
- Fields:
  - `userId` (Ascending)
  - `date` (Descending)

### Index 2: Badges by User
- Collection: `badges`
- Fields:
  - `userId` (Ascending)
  - `type` (Ascending)
  - `count` (Descending)

### Index 3: Subscription Reminders
- Collection: `subscription_reminders`
- Fields:
  - `reminderDate` (Ascending)
  - `sent` (Ascending)

### Index 4: Username Lookup
- Collection: `users`
- Fields:
  - `username` (Ascending)

## Firebase Authentication Setup

1. Go to Firebase Console > Authentication
2. Enable Email/Password sign-in method
3. Configure email templates:
   - Password reset email
   - Email verification (optional)

### Email Template Customization

#### Password Reset Email
```
Subject: Reset your Sober Now password

Hi %DISPLAY_NAME%,

We received a request to reset your password for your Sober Now account.

Click the link below to reset your password:
%LINK%

If you didn't request this, you can safely ignore this email.

Best regards,
The Sober Now Team
```

## Cloud Functions for Subscription Management

### Function 1: Send Subscription Reminders

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure your email transporter
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.password
  }
});

exports.sendSubscriptionReminders = functions.pubsub
  .schedule('every 24 hours')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const threeDaysFromNow = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000);
    
    const reminders = await admin.firestore()
      .collection('subscription_reminders')
      .where('reminderDate', '<=', admin.firestore.Timestamp.fromDate(threeDaysFromNow))
      .where('sent', '==', false)
      .get();

    const batch = admin.firestore().batch();

    for (const doc of reminders.docs) {
      const data = doc.data();
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(data.userId)
        .get();

      if (userDoc.exists) {
        const user = userDoc.data();
        
        const mailOptions = {
          from: 'noreply@sobernow.app',
          to: user.email,
          subject: 'Your Sober Now subscription is renewing soon',
          html: `
            <h2>Subscription Renewal Reminder</h2>
            <p>Hi ${user.fullName},</p>
            <p>Your Sober Now Premium subscription will automatically renew on 
               ${data.subscriptionEndDate.toDate().toLocaleDateString()}.</p>
            <p>Amount: $10.99</p>
            <p>If you wish to cancel your subscription, you can do so in the app settings.</p>
            <p>Thank you for being a valued member!</p>
            <p>Best regards,<br>The Sober Now Team</p>
          `
        };

        try {
          await transporter.sendMail(mailOptions);
          batch.update(doc.ref, { sent: true });
          console.log(`Reminder sent to ${user.email}`);
        } catch (error) {
          console.error(`Failed to send email to ${user.email}:`, error);
        }
      }
    }

    await batch.commit();
    console.log('Subscription reminders processed');
  });
```

### Function 2: Auto-Renew Subscriptions

```javascript
exports.autoRenewSubscriptions = functions.pubsub
  .schedule('every 24 hours')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const now = new Date();
    
    const expiredSubscriptions = await admin.firestore()
      .collection('users')
      .where('isPremium', '==', true)
      .where('subscriptionEndDate', '<=', admin.firestore.Timestamp.fromDate(now))
      .get();

    const batch = admin.firestore().batch();

    for (const doc of expiredSubscriptions.docs) {
      const newEndDate = new Date(now);
      newEndDate.setDate(newEndDate.getDate() + 30);

      // Here you would integrate with Stripe to charge the customer
      // For now, we'll just extend the subscription
      
      batch.update(doc.ref, {
        subscriptionEndDate: admin.firestore.Timestamp.fromDate(newEndDate)
      });

      // Create new reminder
      const reminderDate = new Date(newEndDate);
      reminderDate.setDate(reminderDate.getDate() - 3);

      const reminderRef = admin.firestore().collection('subscription_reminders').doc();
      batch.set(reminderRef, {
        userId: doc.id,
        reminderDate: admin.firestore.Timestamp.fromDate(reminderDate),
        subscriptionEndDate: admin.firestore.Timestamp.fromDate(newEndDate),
        sent: false
      });
    }

    await batch.commit();
    console.log('Subscriptions renewed');
  });
```

### Function 3: Clean Up Old Data (Optional)

```javascript
exports.cleanUpOldReports = functions.pubsub
  .schedule('every 7 days')
  .onRun(async (context) => {
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

    const oldReports = await admin.firestore()
      .collection('daily_reports')
      .where('date', '<', admin.firestore.Timestamp.fromDate(oneYearAgo))
      .limit(500) // Process in batches
      .get();

    const batch = admin.firestore().batch();

    oldReports.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Deleted ${oldReports.size} old reports`);
  });
```

## Deploy Cloud Functions

```bash
# Initialize Firebase Functions
firebase init functions

# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:sendSubscriptionReminders
```

## Set Function Configuration

```bash
# Set email credentials
firebase functions:config:set email.user="your-email@gmail.com"
firebase functions:config:set email.password="your-app-password"

# Set Stripe keys
firebase functions:config:set stripe.secret_key="sk_test_..."
```

## Monitoring and Logs

### View Function Logs
```bash
firebase functions:log
```

### Monitor in Firebase Console
1. Go to Firebase Console
2. Navigate to Functions
3. View execution logs and metrics

## Backup Strategy

### Automated Backups
Set up automated Firestore backups:

```bash
gcloud firestore export gs://[BUCKET_NAME] \
  --project=[PROJECT_ID] \
  --collection-ids=users,daily_reports,badges
```

### Schedule Regular Backups
Use Cloud Scheduler to run backups weekly.
