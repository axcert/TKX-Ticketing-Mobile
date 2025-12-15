# Side Menu CircleAvatar Fix

## Issue
The app was crashing with `Failed assertion: 'backgroundImage != null || onBackgroundImageError == null': is not true`.
This happens when `backgroundImage` is null (no profile photo) but `onBackgroundImageError` is still provided.

## Fix Implemented
Updated `CircleAvatar` in `side_menu.dart` to conditionally provide `onBackgroundImageError` only when `backgroundImage` is not null.

```dart
CircleAvatar(
  // ...
  backgroundImage: hasPhoto ? NetworkImage(...) : null,
  
  // ✅ Only provide error callback if we are actually trying to load an image
  onBackgroundImageError: hasPhoto 
      ? (exception, stackTrace) { ... } 
      : null,
      
  child: !hasPhoto ? Icon(...) : null,
)
```

## Result
- If user has a photo: `backgroundImage` is set, `onBackgroundImageError` is set. Assertion passes.
- If user has NO photo: `backgroundImage` is null, `onBackgroundImageError` is null. Assertion passes.
- The crash is resolved.
