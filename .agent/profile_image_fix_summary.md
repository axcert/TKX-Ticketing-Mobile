# Profile Image Upload and Display Fix

## Issues Identified

### 1. **Image Display Issue**
- **Problem**: The code was using `Image.file()` for both local file paths and network URLs
- **Location**: `edit_profile_screen.dart` line 152-156
- **Impact**: Profile pictures from the API (network URLs) couldn't be displayed

### 2. **Image Upload Issue**
- **Problem**: When fetching profile data from API, the network URL was stored in `_pickedImage`, causing the app to try uploading the URL string instead of a file
- **Location**: `edit_profile_screen.dart` line 60
- **Impact**: Image upload failed because it tried to send a URL instead of a file

### 3. **File Validation Issue**
- **Problem**: The auth service didn't validate if the profileImage was a valid local file before attempting upload
- **Location**: `auth_service.dart` line 326-332
- **Impact**: Could cause errors when trying to upload non-existent files or URLs

### 4. **API Field Name Mismatch**
- **Problem**: The multipart field name was `profile_image` but should be `profile_photo` to match the API
- **Location**: `auth_service.dart` line 328
- **Impact**: Backend might not receive the image correctly

## Solutions Implemented

### 1. **Separated Image State Variables**
```dart
String? _pickedImage; // Local file path when user picks a new image
String? _existingProfilePhoto; // Network URL from API
```
- Created two separate variables to track:
  - `_pickedImage`: Stores the local file path when user picks a new image
  - `_existingProfilePhoto`: Stores the network URL from the API

### 2. **Updated Field Population Logic**
```dart
void _populateFields(User user) {
  _firstNameController.text = user.firstName;
  _lastNameController.text = user.lastName;
  _phoneNumberController.text = user.phone!;
  _existingProfilePhoto = user.profilePhoto; // Store the network URL
  _pickedImage = null; // Clear any previously picked image
}
```
- Now correctly stores the API profile photo URL in `_existingProfilePhoto`
- Clears `_pickedImage` to ensure we don't send old data

### 3. **Created Smart Image Display Method**
```dart
Widget _buildProfileImage() {
  // If user picked a new image, show it from local file
  if (_pickedImage != null) {
    return Image.file(File(_pickedImage!), fit: BoxFit.cover, ...);
  }
  
  // If there's an existing profile photo URL, show it from network
  if (_existingProfilePhoto != null && _existingProfilePhoto!.isNotEmpty) {
    return Image.network(_existingProfilePhoto!, fit: BoxFit.cover, ...);
  }
  
  // Default: show person icon
  return Icon(Icons.person, size: 60, ...);
}
```
- Handles three cases:
  1. Newly picked local image → uses `Image.file()`
  2. Existing network URL → uses `Image.network()`
  3. No image → shows default icon
- Includes error handling and loading indicators

### 4. **Fixed Image Upload Logic**
```dart
// Add profile image if provided and is a valid local file path
if (profileImage != null && profileImage.isNotEmpty) {
  final file = File(profileImage);
  if (await file.exists()) {
    var imageFile = await http.MultipartFile.fromPath(
      'profile_photo', // Fixed field name
      profileImage,
    );
    request.files.add(imageFile);
  }
}
```
- Validates that the file exists before attempting upload
- Only uploads if `profileImage` is a valid local file path
- Fixed the field name from `profile_image` to `profile_photo`

### 5. **Save Function Already Correct**
```dart
final success = await authProvider.updateProfile(
  firstName: _firstNameController.text.trim(),
  lastName: _lastNameController.text.trim(),
  phoneNumber: _phoneNumberController.text.trim(),
  profileImage: _pickedImage, // Only sends if user picked a new image
);
```
- Only sends `_pickedImage` which is `null` unless user picks a new image
- This prevents sending the network URL back to the server

## How It Works Now

### Scenario 1: User Opens Edit Profile (No New Image)
1. API returns profile data with `profile_photo` URL
2. `_existingProfilePhoto` stores the URL
3. `_pickedImage` is set to `null`
4. Display shows network image using `Image.network()`
5. On save, `profileImage` is `null`, so no image is uploaded

### Scenario 2: User Picks a New Image
1. User taps camera icon and selects image from gallery
2. `_pickedImage` stores the local file path
3. `_existingProfilePhoto` still has the old URL (not used)
4. Display shows new local image using `Image.file()`
5. On save, `profileImage` contains the local path
6. Auth service validates file exists and uploads it

### Scenario 3: User Has No Profile Picture
1. API returns `null` or empty string for `profile_photo`
2. Both `_existingProfilePhoto` and `_pickedImage` are `null`
3. Display shows default person icon
4. User can pick an image which follows Scenario 2

## Files Modified

1. **edit_profile_screen.dart**
   - Added `_existingProfilePhoto` variable
   - Updated `_populateFields()` method
   - Created `_buildProfileImage()` helper method
   - Updated profile image display widget

2. **auth_service.dart**
   - Added file existence validation
   - Fixed field name from `profile_image` to `profile_photo`
   - Added empty string check

## Testing Checklist

- [ ] Open edit profile with existing profile picture (should display network image)
- [ ] Open edit profile without profile picture (should show default icon)
- [ ] Pick a new image from gallery (should display selected image)
- [ ] Save profile without changing image (should not upload image)
- [ ] Save profile with new image (should upload new image)
- [ ] Verify uploaded image appears after refresh
- [ ] Test with slow network (should show loading indicator)
- [ ] Test with invalid image URL (should show default icon)
