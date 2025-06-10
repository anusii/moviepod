# POD Storage Integration Guide

## Current Status
✅ **POD Storage Foundation** - Complete  
🔄 **Integration Required** - Manual step needed  

## Why POD Storage Isn't Working Yet

Your observation is correct! The POD storage toggle doesn't save anything to your POD yet because we need to integrate the `FavoritesServiceManager` into the main app.

## Quick Integration Steps

### Option 1: Quick Test (Minimal Changes)

1. **Update `main.dart` to use the service manager:**

```dart
// In main.dart, around line 128, replace:
_favoritesService = FavoritesService(widget.prefs);

// With:
_favoritesServiceManager = FavoritesServiceManager(widget.prefs, context, this);
```

2. **Update all screens to accept the service manager:**

```dart
// In screens like home_screen.dart, to_watch_screen.dart, etc.
// Add optional service manager parameter and use it if available
```

### Option 2: Complete Integration (Recommended)

1. **Update `lib/main.dart`:**

```dart
// Add import
import 'package:moviestar/services/favorites_service_manager.dart';

// Replace FavoritesService with FavoritesServiceManager
class _MainAppState extends State<MainApp> {
  late final FavoritesServiceManager _favoritesServiceManager;

  @override
  void initState() {
    super.initState();
    _favoritesServiceManager = FavoritesServiceManager(widget.prefs, context, this);
  }

  // Update all Navigator.push calls to pass the service manager
  // Instead of: favoritesService: _favoritesService
  // Use: favoritesServiceManager: _favoritesServiceManager
}
```

2. **Update all screen constructors** to accept `FavoritesServiceManager`

3. **Update all screen implementations** to use the manager

## Testing the Integration

### Step 1: Verify Settings Toggle
1. Open Settings → Data Storage
2. Toggle "Use Solid POD Storage" ON
3. **Expected**: You should see a loading spinner, then either:
   - ✅ Success: "POD storage enabled successfully!"
   - ❌ Error: "Failed to enable POD storage" (if not logged into POD)

### Step 2: Test Movie Operations
1. **With POD storage ON**, add a movie to "To Watch"
2. Check your POD file browser for new files in `/moviestar/lists/`
3. Files should appear: `to_watch.ttl`, `watched.ttl`, etc.

### Step 3: Test Data Persistence
1. Close the app completely
2. Reopen the app
3. **Expected**: Movies should load from POD

## Manual Integration for Testing

If you want to test it quickly without changing all files, you can:

### Quick Test in Settings Only

1. **Update `settings_screen.dart` to create its own service manager:**

```dart
class _SettingsScreenState extends State<SettingsScreen> {
  late FavoritesServiceManager _testServiceManager;

  @override
  void initState() {
    super.initState();
    // Create service manager for testing
    _testServiceManager = FavoritesServiceManager(
      widget.prefs, // You'll need to pass SharedPreferences to settings
      context,
      widget,
    );
  }

  // Use _testServiceManager instead of widget.favoritesServiceManager
}
```

2. **Test by adding a movie through this service manager:**

```dart
// In settings screen, add a test button:
ElevatedButton(
  onPressed: () async {
    // Test adding a movie to POD
    final testMovie = Movie(
      id: 999999,
      title: 'POD Test Movie',
      overview: 'Test movie to verify POD storage',
      posterUrl: 'https://example.com/poster.jpg',
      backdropUrl: 'https://example.com/backdrop.jpg',
      voteAverage: 8.0,
      releaseDate: DateTime.now(),
      genreIds: [28], // Action
    );
    
    await _testServiceManager.addToWatch(testMovie);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test movie added to POD!')),
    );
  },
  child: const Text('Test POD Storage'),
),
```

## Expected POD File Structure

When working correctly, you should see these files in your POD:

```
your-pod.provider.com/
├── moviestar/
│   └── lists/
│       ├── to_watch.ttl (encrypted)
│       ├── to_watch.ttl.acl
│       ├── watched.ttl (encrypted)
│       ├── watched.ttl.acl
│       ├── ratings.ttl (encrypted)
│       ├── ratings.ttl.acl
│       ├── comments.ttl (encrypted)
│       └── comments.ttl.acl
```

## Debugging Steps

### 1. Check Flutter Logs
```bash
flutter logs | grep -i "pod\|storage\|moviestar"
```

Look for logs like:
- "POD storage service enabled"
- "Successfully migrated data to POD"
- "Saving to POD: lists/to_watch.ttl"

### 2. Check POD Login Status
Ensure you're logged into your Solid POD. The app needs:
- Valid Solid POD authentication
- Write permissions to your POD
- Network connectivity

### 3. Check for Errors
Common issues:
- "POD is not available" → Check login and network
- "Permission denied" → Check POD authentication
- "Failed to save to POD" → Check POD write permissions

## File to Update for Quick Test

The fastest way to test is to modify one file. Here's a minimal change you can make:

**Update `lib/screens/settings_screen.dart`:**

1. Add SharedPreferences parameter to constructor
2. Create a local service manager in initState
3. Use it for POD operations

This will let you test POD storage without modifying the entire app.

## Complete Integration 

For full integration, you'll need to:

1. Replace `FavoritesService` with `FavoritesServiceManager` in `main.dart`
2. Update all 7 screens to use the service manager
3. Update all constructor calls

This ensures POD storage works throughout the entire app, not just in settings.

Would you like me to help you implement the quick test option first? 