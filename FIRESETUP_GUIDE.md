# Firebase Setup Guide for Email & Username Login

## 🔧 **Firebase Configuration Required**

### 1. **Firebase Console Setup**
Go to your Firebase Console → Project Settings

### 2. **Authentication Setup**
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider ✅
3. Enable **Google** provider ✅
4. Make sure both are **Enabled** and not in test mode

### 3. **Google Sign-In Configuration**
1. In **Authentication** → **Sign-in method** → **Google**
2. Add your app's SHA-1 fingerprint (for Android)
3. Configure OAuth consent screen
4. Add authorized domains for web

### 4. **Firestore Database Setup**
1. Go to **Firestore Database** → **Rules**
2. Update rules to allow authenticated users:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. **Email Configuration (IMPORTANT for Password Reset)**
1. Go to **Authentication** → **Templates** → **Password reset**
2. Customize your email template
3. Go to **Authentication** → **Settings** → **Email templates**
4. Configure **Sender email** and **Reply-to email**

### 6. **Android Configuration for Google Sign-In**
Add your SHA-1 fingerprint to Firebase Console:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 7. **Firebase Initialization**
Ensure your `firebase_options.dart` is properly configured:

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Your Firebase configuration here
    return const FirebaseOptions(
      apiKey: "your-api-key",
      authDomain: "your-project.firebaseapp.com",
      projectId: "your-project-id",
      storageBucket: "your-project.appspot.com",
      messagingSenderId: "your-sender-id",
      appId: "your-app-id",
    );
  }
}
```

## 🐛 **Debugging Steps**

### **For Username Login Issues:**
1. Check console logs for DEBUG messages
2. Verify user data is stored in Firestore
3. Check if username is stored in lowercase
4. Test with exact username (case-sensitive)

### **For Password Reset Email Issues:**
1. Check Firebase Console → Authentication → Users
2. Verify email exists in Firebase Auth
3. Check spam/junk folders
4. Verify email template is configured
5. Check Firebase Console → Usage → Authentication

### **For Google Sign-In Issues:**
1. Verify Google provider is enabled in Firebase Console
2. Check SHA-1 fingerprint is added
3. Verify OAuth consent screen is configured
4. Check internet connection
5. Test with debug build first

## 🔍 **Testing Steps**

### **Test Username Login:**
1. Create a new account with username: "testuser"
2. Try to login with username: "testuser"
3. Check console logs for DEBUG messages
4. Verify Firestore has the user data

### **Test Password Reset:**
1. Enter registered email in forgot password
2. Check console logs for DEBUG messages
3. Check email inbox (including spam)
4. Verify email template is working

### **Test Google Sign-In:**
1. Click Google sign-in button
2. Select Google account
3. Verify successful login
4. Check if user data is stored in Firestore

## 📱 **Common Issues & Solutions**

### **Issue: Username not found**
- **Cause**: User data not stored in Firestore
- **Solution**: Check signup process and Firestore rules

### **Issue: Password reset email not received**
- **Cause**: Email templates not configured
- **Solution**: Configure email templates in Firebase Console

### **Issue: Google Sign-In not working**
- **Cause**: SHA-1 fingerprint missing or OAuth not configured
- **Solution**: Add SHA-1 fingerprint and configure OAuth consent

### **Issue: Firestore permission denied**
- **Cause**: Firestore rules too restrictive
- **Solution**: Update Firestore rules as shown above

## 🚀 **Production Checklist**
- [ ] Email/Password authentication enabled ✅
- [ ] Google authentication enabled ✅
- [ ] Firestore rules configured
- [ ] Email templates customized
- [ ] Sender email configured
- [ ] SHA-1 fingerprint added for Google Sign-In
- [ ] OAuth consent screen configured
- [ ] Test with real email addresses
- [ ] Check spam folder settings
- [ ] Test all sign-in methods
