# Profile Photo URL Construction Fix

## Issue Found

The error message revealed the problem:
```
📸 Populating fields - Profile Photo: https://tkxeapi.axcertro.devprofile_photos/scaled-1000572716-N0ho0.jpg
❌ Error loading profile image: SocketException: Failed host lookup: 'tkxeapi.axcertro.devprofile_photos'
```

**Problem**: Missing `/` between base URL and photo path!
- Expected: `https://tkxeapi.axcertro.dev/profile_photos/...`
- Got: `https://tkxeapi.axcertro.devprofile_photos/...`

## Root Cause

The API returns the photo path as `profile_photos/...` (without leading `/`).

When we concatenated:
```dart
profilePhotoUrl = '${AppConfig.baseUrl}$photoPath';
// https://tkxeapi.axcertro.dev + profile_photos/... 
// = https://tkxeapi.axcertro.devprofile_photos/... ❌
```

## Solution

Updated `user_model.dart` to ensure exactly one `/` between base URL and path:

```dart
factory User.fromJson(Map<String, dynamic> json) {
  String? profilePhotoUrl;
  if (json['profile_photo'] != null && json['profile_photo'].toString().isNotEmpty) {
    final photoPath = json['profile_photo'].toString();
    
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      // Already a full URL
      profilePhotoUrl = photoPath;
    } else {
      // Relative path - ensure it starts with /
      final baseUrl = AppConfig.baseUrl;
      final cleanPath = photoPath.startsWith('/') ? photoPath : '/$photoPath';
      profilePhotoUrl = '$baseUrl$cleanPath';
      // Now: https://tkxeapi.axcertro.dev + /profile_photos/... ✅
    }
  }
  return User(..., profilePhoto: profilePhotoUrl, ...);
}
```

## Debug Logging Added

Now you'll see:
```
🔍 Original photo path from API: "profile_photos/scaled-1000572716-N0ho0.jpg"
🔧 Constructed URL: https://tkxeapi.axcertro.dev/profile_photos/scaled-1000572716-N0ho0.jpg
```

Or if API returns full URL:
```
🔍 Original photo path from API: "https://tkxeapi.axcertro.dev/profile_photos/..."
✅ Already full URL: https://tkxeapi.axcertro.dev/profile_photos/...
```

## Test Cases Covered

| API Returns | Our Code Produces |
|-------------|-------------------|
| `profile_photos/image.jpg` | `https://tkxeapi.axcertro.dev/profile_photos/image.jpg` ✅ |
| `/profile_photos/image.jpg` | `https://tkxeapi.axcertro.dev/profile_photos/image.jpg` ✅ |
| `https://example.com/image.jpg` | `https://example.com/image.jpg` ✅ |
| `http://example.com/image.jpg` | `http://example.com/image.jpg` ✅ |

## Expected Result

After this fix, you should see:
```
🔍 Original photo path from API: "profile_photos/scaled-1000572716-N0ho0.jpg"
🔧 Constructed URL: https://tkxeapi.axcertro.dev/profile_photos/scaled-1000572716-N0ho0.jpg
📸 Populating fields - Profile Photo: https://tkxeapi.axcertro.dev/profile_photos/scaled-1000572716-N0ho0.jpg
```

And the image should load successfully! 🎉
