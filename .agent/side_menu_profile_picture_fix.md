# Side Menu Profile Picture Fix

## Changes Made

Updated the `SideMenu` widget to display the user's profile picture in the drawer header.

### 1. **Fixed CircleAvatar** (lines 34-43)

```dart
CircleAvatar(
  radius: 30,
  backgroundColor: AppColors.border,
  backgroundImage: _getProfileImage(authProvider.user?.profilePhoto),
  onBackgroundImageError: (exception, stackTrace) {
    print('❌ Error loading profile image in drawer: $exception');
  },
  child: authProvider.user?.profilePhoto == null
      ? const Icon(Icons.person, size: 30, color: Colors.grey)
      : null,
),
```

**Key changes:**
- Uses `_getProfileImage()` helper to get the `ImageProvider`
- Shows default icon only when there's no profile photo
- Added error logging for debugging

### 2. **Added Helper Method** (lines 258-277)

```dart
ImageProvider? _getProfileImage(String? profilePhoto) {
  if (profilePhoto == null || profilePhoto.isEmpty) {
    return null; // Will show the child icon instead
  }

  // Construct full URL if it's a relative path
  String imageUrl = profilePhoto;
  if (!profilePhoto.startsWith('http://') && !profilePhoto.startsWith('https://')) {
    // It's a relative path, construct full URL
    final cleanPath = profilePhoto.startsWith('/') ? profilePhoto : '/$profilePhoto';
    imageUrl = 'https://tkxeapi.axcertro.dev$cleanPath';
    print('🔧 Drawer - Constructed image URL: $imageUrl');
  } else {
    print('✅ Drawer - Using full URL: $imageUrl');
  }

  return NetworkImage(imageUrl);
}
```

**What it does:**
- Returns `null` if no profile photo (shows default icon)
- Constructs full URL from relative paths
- Returns `NetworkImage` provider for `CircleAvatar`

## How It Works

1. **User opens drawer** → `authProvider.user?.profilePhoto` is accessed
2. **`_getProfileImage()` is called** with the profile photo value
3. **If relative path** (e.g., `"profile_photos/image.jpg"`):
   - Adds `/` if needed
   - Prepends base URL: `https://tkxeapi.axcertro.dev/profile_photos/image.jpg`
4. **Returns `NetworkImage`** provider
5. **CircleAvatar displays** the network image
6. **If error or no photo** → Shows default person icon

## Expected Console Output

When drawer opens:
```
🔧 Drawer - Constructed image URL: https://tkxeapi.axcertro.dev/profile_photos/scaled-1000572716-N0ho0.jpg
```

Or if already full URL:
```
✅ Drawer - Using full URL: https://example.com/image.jpg
```

## Result

✅ Profile picture now displays in the side menu drawer
✅ Handles both relative and absolute URLs
✅ Falls back to default icon if no photo
✅ Shows error logs for debugging
✅ Updates automatically when user changes profile picture (via Provider)
