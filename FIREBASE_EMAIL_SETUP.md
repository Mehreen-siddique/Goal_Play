# Firebase Email Configuration Guide

## ⚠️ IMPORTANT: Enable Email Templates in Firebase Console

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Authentication** → **Templates** tab

### Step 2: Configure Password Reset Email
1. Click on **Password reset** template
2. **Enable the template** (toggle switch must be ON)
3. Customize the email content:
   ```
   Subject: Reset your password for Goal Play App
   
   Body:
   Hello {{email}},
   
   Someone requested a password reset for your Goal Play App account.
   
   Click this link to reset your password:
   {{action_url}}
   
   This link will expire in 24 hours.
   
   If you didn't request this, you can safely ignore this email.
   
   Thanks,
   Goal Play Team
   ```

### Step 3: Verify Email Configuration
1. Go to **Authentication** → **Sign-in method**
2. Ensure **Email/Password** is enabled
3. Click on the gear icon ⚙️ next to Email/Password
4. Verify **Email verification** is enabled
5. Verify **Password reset** is enabled

### Step 4: Test Email Configuration
1. Try the forgot password feature with a real email
2. Check both inbox and spam folder
3. Verify the reset link works

## 🔧 Common Issues & Solutions

### Issue 1: Email Not Received
**Solution**: 
- Check Firebase Console → Authentication → Templates → Password reset is ENABLED
- Verify email address is correct
- Check spam/junk folder
- Ensure Firebase project has email service enabled

### Issue 2: "Too many requests" Error
**Solution**: 
- Wait 10-15 minutes before trying again
- Firebase has rate limiting for password reset emails

### Issue 3: Network Error
**Solution**: 
- Check internet connection
- Ensure Firebase project is properly configured
- Verify Firebase SDK initialization

## 📱 Testing Steps

1. **Open the app**
2. **Go to Login screen**
3. **Click "Forgot Password?"**
4. **Enter a registered email**
5. **Check email inbox**
6. **Click the reset link**
7. **Set new password**
8. **Try logging in with new password**

## 🚀 Production Checklist

- [ ] Password reset template is enabled in Firebase Console
- [ ] Email verification is enabled
- [ ] Custom email template is configured
- [ ] Test with multiple email providers (Gmail, Outlook, etc.)
- [ ] Check spam folder behavior
- [ ] Verify reset link expiration (24 hours)

## 📞 Support

If emails still don't work after following this guide:
1. Check Firebase project billing status
2. Verify domain authentication (if using custom domain)
3. Contact Firebase support for email service issues
