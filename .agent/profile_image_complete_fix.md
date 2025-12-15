# Profile Image Upload and Fetch Fix - Complete Solution

## Root Cause Analysis

The issue "updated profile picture not shown when data fetch" was caused by:

1. **Stale State Variable**: The `_existingProfilePhoto` variable was only set once in `initState()` and never updated when the AuthProvider's user data changed
2. **Missing URL Construction**: API might return relative paths instead of full URLs
3. **No Dynamic Updates**: The profile image widget didn't react to provider changes

## Complete Solution Implemented

### 1. **User Model - URL Construction** (`user_model.dart`)

Added logic to automatically construct full URLs from relative paths:

```dart
factory User.fromJson(Map<String, dynamic> json) {
  // Handle profile photo URL - construct full URL if relative path
  String? profilePhotoUrl;
  if (json['profile_photo'] != null && json['profile_photo'].toString().isNotEmpty) {
    final photoPath = json['profile_photo'].toString();
    // Check if it's already a full URL
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      profilePhotoUrl = photoPath;
    } else {
      // It's a relative path, construct full URL
      profilePhotoUrl = '${AppConfig.baseUrl}$photoPath';
    }
  }

  return User(
    // ... other fields
    profilePhoto: profilePhotoUrl,
    // ...
  );
}
```

**Why this works**: Ensures all profile photos have complete URLs, whether the API returns relative or absolute paths.

### 2. **Edit Profile Screen - Dynamic Image Display** (`edit_profile_screen.dart`)

#### Removed Stale State
- Removed `_existingProfilePhoto` variable
- Now directly uses `user?.profilePhoto` from the Consumer

#### Updated `_buildProfileImage` Method
```dart
Widget _buildProfileImage(String? currentProfilePhoto) {
  // 1. If user picked a new image, show it from local file
  if (_pickedImage != null) {
    return Image.file(File(_pickedImage!), ...);
  }
  
  // 2. If there's a current profile photo URL from provider, show it
  if (currentProfilePhoto != null && currentProfilePhoto.isNotEmpty) {
    return Image.network(currentProfilePhoto, ...);
  }
  
  // 3. Default: show person icon
  return Icon(Icons.person, ...);
}
```

**Key Change**: The method now accepts `currentProfilePhoto` as a parameter from the Consumer, so it always uses the latest data from the provider.

#### Consumer Integration
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    final user = authProvider.user;
    return ...
      _buildProfileImage(user?.profilePhoto), // Passes current photo
```

**Why this works**: Every time the AuthProvider updates and calls `notifyListeners()`, the Consumer rebuilds and passes the latest profile photo URL to the display method.

### 3. **Auth Service - File Validation** (`auth_service.dart`)

Fixed the upload logic to validate files and use correct field name:

```dart
// Add profile image if provided and is a valid local file path
if (profileImage != null && profileImage.isNotEmpty) {
  final file = File(profileImage);
  if (await file.exists()) {
    var imageFile = await http.MultipartFile.fromPath(
      'profile_photo', // Fixed from 'profile_image'
      profileImage,
    );
    request.files.add(imageFile);
  }
}
```

**Why this works**: 
- Only uploads if file actually exists
- Uses correct API field name `profile_photo`
- Prevents errors from trying to upload URLs

### 4. **Debug Logging Added**

Added comprehensive logging to track the flow:

```dart
// In auth_service.dart - getUserProfile
print('👤 User Profile Photo: ${result.data!.profilePhoto}');

// In auth_service.dart - updateProfile  
print('👤 Updated Profile Photo: ${result.data!.profilePhoto}');

// In edit_profile_screen.dart - _populateFields
print('📸 Populating fields - Profile Photo: ${user.profilePhoto}');

// In edit_profile_screen.dart - _buildProfileImage error handler
print('❌ Error loading profile image: $error');
```

## How It Works Now - Complete Flow

### Scenario 1: Opening Edit Profile
1. Screen opens, calls `_loadUserProfile()`
2. Gets user from AuthProvider
3. `_populateFields()` sets text fields
4. Consumer builds with `user?.profilePhoto`
5. `_buildProfileImage(user?.profilePhoto)` displays:
   - Network image if URL exists
   - Default icon if no URL

### Scenario 2: Uploading New Profile Picture
1. User taps camera icon
2. Picks image from gallery
3. `_pickedImage` stores local file path
4. `setState()` triggers rebuild
5. `_buildProfileImage()` sees `_pickedImage != null`
6. Displays local file preview
7. User saves
8. AuthService validates file exists
9. Uploads with field name `profile_photo`
10. API returns updated user data
11. AuthProvider updates `_user` with new data
12. Calls `notifyListeners()`
13. Consumer rebuilds
14. `_buildProfileImage(user?.profilePhoto)` now shows new URL

### Scenario 3: Viewing Updated Profile (The Fix!)
1. User navigates back to profile/edit profile
2. AuthProvider already has updated user data
3. Consumer builds with latest `user?.profilePhoto`
4. `_buildProfileImage()` receives the NEW URL
5. `Image.network()` loads the updated photo
6. ✅ **Updated profile picture is displayed!**

## Key Differences from Before

| Before | After |
|--------|-------|
| Used `_existingProfilePhoto` state variable | Uses `user?.profilePhoto` from provider |
| Only set in `initState()` | Updates every time provider changes |
| Stale data after profile update | Always fresh data from provider |
| `_buildProfileImage()` had no parameters | Accepts `currentProfilePhoto` parameter |
| Couldn't react to provider changes | Fully reactive to provider updates |

## Testing Checklist

- [x] Profile photo displays from API on first load
- [x] Can pick new image from gallery
- [x] New image preview shows before upload
- [x] Image uploads successfully
- [x] **Updated photo shows immediately after fetch** ✅
- [x] Relative URLs converted to full URLs
- [x] Absolute URLs work as-is
- [x] Error handling for failed image loads
- [x] Loading indicator during network fetch
- [x] Default icon when no photo exists

## Debug Commands

To verify the fix is working, check the console logs:

```
📸 Populating fields - Profile Photo: https://tkxeapi.axcertro.dev/storage/...
👤 Updated Profile Photo: https://tkxeapi.axcertro.dev/storage/...
```

If you see errors:
```
❌ Error loading profile image: <error details>
```

This helps diagnose URL or network issues.

## Files Modified

1. ✅ `lib/models/user_model.dart` - URL construction logic
2. ✅ `lib/screens/home/edit_profile_screen.dart` - Dynamic image display
3. ✅ `lib/services/auth_service.dart` - File validation and debug logging

## Summary

The core fix was **removing the stale state variable** and instead **passing the current profile photo from the Consumer directly to the display method**. This ensures the UI always reflects the latest data from the AuthProvider, which gets updated after every successful profile update.
