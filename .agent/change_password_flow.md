# Change Password Flow Implementation

## Overview
Implemented OTP-based password change flow for authenticated users using existing `forgotPassword` and `verifyOtp` APIs from AuthProvider.

## Implementation Details

### 1. **ChangePasswordScreen** (`lib/screens/home/change_password_screen.dart`)

**Flow:**
1. When screen opens, automatically calls `forgotPassword` API with user's email
2. Displays masked email address (e.g., `i****@gmail.com`)
3. User enters 6-digit OTP code
4. User can resend OTP after 30-second cooldown
5. Calls `verifyOtp` API to validate the code
6. On success, navigates to `SetNewPasswordScreen` with email and OTP

**Key Features:**
- Auto-send OTP on screen initialization
- Email masking for privacy
- 30-second resend timer
- Loading states from AuthProvider
- Error/success handling with toast messages
- Auto-focus navigation between OTP input fields

**API Integration:**
```dart
// Send OTP
await authProvider.forgotPassword(userEmail);

// Verify OTP
await authProvider.verifyOtp(userEmail, otp);
```

### 2. **SetNewPasswordScreen** (`lib/screens/home/set_new_password_screen.dart`)

**Flow:**
1. Receives `email` and `otp` from previous screen
2. User enters new password (minimum 8 characters)
3. User confirms password
4. Calls `resetPassword` API with email, OTP, and new password
5. On success, navigates back to home/login screen

**Key Features:**
- Password validation (minimum 8 characters)
- Password confirmation matching
- Show/hide password toggle
- Loading states during API call
- Error/success handling with toast messages
- Disabled inputs during loading

**API Integration:**
```dart
await authProvider.resetPassword(
  email,
  otp,
  newPassword,
  confirmPassword,
);
```

## API Endpoints Used

All endpoints are already configured in `AppConfig`:

1. **Send OTP**: `POST /auth/gatekeeper/forgot-password`
   - Body: `{ "email": "user@example.com" }`

2. **Verify OTP**: `POST /auth/gatekeeper/verify-otp`
   - Body: `{ "email": "user@example.com", "otp": "123456" }`

3. **Reset Password**: `POST /auth/gatekeeper/reset-password`
   - Body: `{ "email": "user@example.com", "otp": "123456", "password": "newpass", "password_confirmation": "newpass" }`

## User Experience

1. User navigates to "Change Password" from side menu
2. System automatically sends OTP to user's registered email
3. User receives email with 6-digit code
4. User enters code in the app
5. User can resend if code not received (after 30s cooldown)
6. After successful verification, user sets new password
7. Password is updated and user is redirected to home

## Error Handling

- Network errors: "Cannot connect to server. Please check your network connection."
- Invalid OTP: "Invalid verification code"
- Password mismatch: "Passwords do not match"
- Weak password: "Password must be at least 8 characters"
- Missing email: "User email not found. Please login again."

## Security Features

- Email masking in UI
- OTP expiration (handled by backend)
- Password strength validation (minimum 8 characters)
- Password confirmation requirement
- Secure password input (obscured text)
