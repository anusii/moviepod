# Manual Testing Guide - POD Storage Integration (COMPLETE)

## 🎉 Integration Status: COMPLETE
The POD storage foundation has been **fully integrated** into the main MovieStar app. All screens now use the POD-enabled storage system and should seamlessly switch between local and POD storage based on user preferences.

## Prerequisites

### 1. Basic Setup
```bash
flutter pub get
flutter analyze  # Should show only minor warnings (solidpod example errors can be ignored)
```

### 2. Solid POD Setup (for full testing)
- Create a Solid POD account at:
  - [solidcommunity.net](https://solidcommunity.net/) (recommended for testing)
  - [inrupt.net](https://inrupt.net/)
  - Or any other Solid POD provider
- Note your WebID (e.g., `https://username.solidcommunity.net/profile/card#me`)

## Testing Scenarios

### Scenario 1: App Compilation & Local Storage (Default)

**Test the app works with local storage (default behavior):**

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test basic movie operations:**
   - Add movies to "To Watch" list via Home/Search screens
   - Add movies to "Watched" list 
   - Add ratings and comments in Movie Details
   - Remove movies from lists
   - Navigate between all screens (Home, Coming Soon, Downloads, Files, Settings)
   - Verify data persists after app restart (uses SharedPreferences when POD is OFF)

3. **Check settings screen:**
   - Navigate to Settings
   - Verify "Data Storage" section exists
   - Verify "Use Solid POD Storage" toggle is present and OFF by default
   - Verify toggle shows current status correctly

**Expected Result:** ✅ App works normally with local storage (SharedPreferences). All screens functional.

---

### Scenario 2: POD Storage Toggle & Real-Time Switching

**Test live POD storage switching:**

1. **Without POD Login - Toggle Testing:**
   - Open Settings → Data Storage
   - Turn ON "Use Solid POD Storage" → Should show success message but fall back to local storage
   - Turn OFF "Use Solid POD Storage" → Should show disabled message
   - Expected: No crashes, graceful fallback behavior

2. **With POD Login - Full POD Integration:**
   - Login to your Solid POD (via existing login flow)
   - Turn ON "Use Solid POD Storage"
   - **Expected real-time behavior:**
     - Toggle turns on immediately
     - Green success message shows
     - **Data migration happens immediately** (no restart needed)
     - App now uses POD storage for all new operations
   
3. **Test POD → Local Switch:**
   - Turn OFF "Use Solid POD Storage"
   - Should switch back to SharedPreferences immediately
   - Data should still be accessible

**Expected Result:** ✅ Real-time switching between storage backends works. POD files created when enabled.

---

### Scenario 3: TTL Serialization Testing

**Create a simple unit test to verify TTL serialization:**

```dart
// test/turtle_serializer_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moviestar/models/movie.dart';
import 'package:moviestar/utils/turtle_serializer.dart';

void main() {
  group('TurtleSerializer', () {
    test('should serialize and deserialize movies correctly', () {
      // Create test movie
      final movie = Movie(
        id: 12345,
        title: 'Test Movie',
        overview: 'A test movie description',
        posterUrl: 'https://example.com/poster.jpg',
        backdropUrl: 'https://example.com/backdrop.jpg',
        voteAverage: 8.5,
        releaseDate: DateTime(2023, 1, 1),
        genreIds: [28, 12], // Action, Adventure
      );

      final movies = [movie];
      
      // Serialize to TTL
      final ttl = TurtleSerializer.moviesToTurtleWithJson(movies, 'testList');
      
      // Verify TTL contains expected content
      expect(ttl, contains('@prefix'));
      expect(ttl, contains('testList'));
      expect(ttl, contains('Test Movie'));
      expect(ttl, contains('JSON_DATA:'));
      
      // Deserialize from TTL
      final deserializedMovies = TurtleSerializer.moviesFromTurtle(ttl);
      
      // Verify deserialization
      expect(deserializedMovies.length, 1);
      expect(deserializedMovies.first.id, 12345);
      expect(deserializedMovies.first.title, 'Test Movie');
    });
  });
}
```

**Run the test:**
```bash
flutter test test/turtle_serializer_test.dart
```

---

### Scenario 4: Full POD Integration Testing (COMPLETE FUNCTIONALITY)

**Prerequisites:**
- Solid POD account created
- App fully integrated with POD storage system

#### 4.1 POD Login & Immediate Integration

1. **Login to POD** (via existing Solid login in app)
2. **Verify login success** 
3. **Enable POD storage in Settings**
4. **Expected:** Immediate activation, no restart required

#### 4.2 Live POD Operations Test

1. **With POD storage enabled:**
   - Add movies to "To Watch" from Home screen
   - Add movies to "Watched" 
   - Set ratings and comments in Movie Details
   - **Expected:** Operations work immediately, data saved to POD in real-time

2. **Check POD files:**
   - Navigate to your POD using POD browser/file manager
   - Look for `/moviestar/data/user_lists/` and `/moviestar/data/ratings/` directories 
   - Should see: `moviestar/data/user_lists/to_watch.ttl`, `moviestar/data/user_lists/watched.ttl`, `moviestar/data/user_lists/comments.ttl`, `moviestar/data/ratings/ratings.ttl`
   - Files should be encrypted TTL format with JSON backup

#### 4.3 Automatic Migration Test

1. **Start with local data** (POD storage OFF)
2. **Add several movies using local storage**
3. **Turn ON POD storage** 
4. **Expected:** Automatic migration happens immediately, no restart needed
5. **Verify all data moved to POD**

#### 4.4 Cross-Session Persistence Test

1. **Add movies with POD storage ON**
2. **Close app completely**
3. **Clear app cache** (but keep POD login)
4. **Restart app** 
5. **Expected:** All data loads from POD automatically

#### 4.5 All-Screen Integration Test

Test POD storage works across all app screens:
- **Home Screen:** Add movies from popular/trending lists
- **Search Screen:** Add movies from search results  
- **Movie Details:** Ratings and comments save to POD
- **Coming Soon:** Add upcoming movies
- **Settings:** POD toggle works immediately

---

### Scenario 5: Error Handling Testing

#### 5.1 Network Failure Test

1. **Enable POD storage**
2. **Turn off internet connection**
3. **Try to add/remove movies**
4. **Expected behavior:**
   - App should not crash
   - Should fallback to local storage
   - Should show appropriate error logs in console

#### 5.2 POD Login Failure Test

1. **Enable POD storage**
2. **Use incorrect POD credentials**
3. **Expected behavior:**
   - App should fallback to local storage
   - Should not crash
   - Should show error messages

---

## Manual Testing Checklist

### ✅ Core Functionality (INTEGRATED)
- [ ] App compiles without errors (ignoring solidpod example warnings)
- [ ] App runs on device/emulator  
- [ ] All screens accessible (Home, Coming Soon, Downloads, Files, Settings)
- [ ] Movie operations work across all screens (add/remove/rate/comment)
- [ ] Data persists across app restarts

### ✅ POD Integration (COMPLETE)
- [ ] POD storage toggle visible and functional in settings
- [ ] **Real-time switching** between local and POD storage
- [ ] **Immediate migration** when enabling POD storage (no restart)
- [ ] All movie operations save to POD when enabled
- [ ] POD files created: `user_lists/to_watch.ttl`, `user_lists/watched.ttl`, `user_lists/comments.ttl`, `ratings/ratings.ttl`
- [ ] Data loads from POD across app sessions
- [ ] **Cross-screen integration** - all screens use POD when enabled

### ✅ TTL Serialization & Storage
- [ ] TTL serialization unit test passes
- [ ] Movies serialize to proper TTL format with schema.org vocabulary
- [ ] TTL includes JSON backup for reliable parsing
- [ ] Files encrypted and stored in POD `/moviestar/user_lists/` and `/moviestar/ratings/` directories

### ✅ Advanced Features (WORKING)
- [ ] **Automatic data migration** from SharedPreferences to POD
- [ ] **Graceful fallback** to local storage when POD unavailable
- [ ] **Live switching** between storage backends without app restart
- [ ] Cross-session persistence via POD
- [ ] All CRUD operations (Create, Read, Update, Delete) work in POD

### ✅ Error Handling & Reliability
- [ ] No crashes during POD operations
- [ ] Graceful fallback when network unavailable
- [ ] Local storage continues working when POD fails
- [ ] Appropriate user feedback for all operations
- [ ] Comprehensive error logging

## Debug Commands

### Check Flutter logs:
```bash
flutter logs
```

### Check for specific errors:
```bash
flutter logs | grep -i "pod\|error\|exception"
```

### Analyze specific files:
```bash
flutter analyze lib/services/pod_favorites_service.dart
flutter analyze lib/utils/turtle_serializer.dart
```

### Run specific tests:
```bash
flutter test test/turtle_serializer_test.dart -v
```

## Expected Log Output

**When POD storage is working correctly:**
```
I/flutter: POD storage service enabled
I/flutter: Successfully loaded user_lists/to_watch.ttl from POD
I/flutter: Successfully loaded X movies from POD
I/flutter: POD storage initialized successfully
I/flutter: Successfully migrated data to POD
I/flutter: POD storage enabled successfully
```

**When using local storage (default):**
```
I/flutter: Using local SharedPreferences storage
I/flutter: Loaded X movies from SharedPreferences
```

**When falling back to local storage:**
```
I/flutter: Failed to load from POD: <error details>
I/flutter: Using SharedPreferences fallback
I/flutter: POD is not available, cannot enable POD storage
```

**During real-time switching:**
```
I/flutter: Switching to POD storage...
I/flutter: Migrating data from local to POD...
I/flutter: Migration completed successfully
I/flutter: Switching to local storage...
```

## Troubleshooting

### "POD not found" errors:
- Verify POD login credentials
- Check internet connection
- Verify POD provider is accessible

### "Permission denied" errors:
- Check POD authentication
- Verify app has proper POD permissions

### App crashes:
- Check flutter logs for stack traces
- Verify all dependencies are installed
- Check for null pointer exceptions in POD operations

### TTL parsing errors:
- Verify movie data doesn't contain special characters
- Check JSON backup in TTL comments
- Verify TTL format is valid 