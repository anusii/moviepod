# Phase 1 Implementation: POD Storage Foundation

## Overview
This document describes the implementation of Phase 1: migrating user lists from SharedPreferences to POD storage.

## Files Created/Modified

### New Files
1. **`lib/utils/turtle_serializer.dart`** - Utility for converting Movie objects to/from Turtle (TTL) format
2. **`lib/services/pod_favorites_service.dart`** - POD-based service for managing movie lists

### Modified Files  
1. **`lib/screens/settings_screen.dart`** - Added POD storage toggle in settings

## Key Features Implemented

### 1. TTL Serialization (`turtle_serializer.dart`)
- Converts `List<Movie>` to TTL format with proper schema.org vocabulary
- Converts ratings and comments to TTL format
- Includes JSON backup in TTL comments for easy parsing
- Provides robust parsing from TTL back to Dart objects

### 2. POD Storage Service (`pod_favorites_service.dart`)
- **Core functionality**: Stores movie lists in encrypted TTL files on user's Solid POD
- **File structure**:
  - `lists/to_watch.ttl` - To-watch movies
  - `lists/watched.ttl` - Watched movies  
  - `lists/ratings.ttl` - User ratings
  - `lists/comments.ttl` - User comments
- **Fallback support**: Falls back to SharedPreferences if POD is unavailable
- **Caching**: Caches data locally to avoid frequent POD reads
- **Migration**: Includes `migrateToPod()` method to move existing data

### 3. Settings Integration
- Added "Use Solid POD Storage" toggle in Data Storage section
- Shows user feedback when enabling/disabling POD storage
- Provides foundation for switching between storage modes

## Technical Details

### Data Flow
1. **Initialization**: Service tries to load from POD, falls back to SharedPreferences
2. **Read operations**: Serve from cache first, then POD, then SharedPreferences
3. **Write operations**: Save to POD (encrypted TTL), update cache, fallback to SharedPreferences
4. **Sync**: `syncWithPod()` method refreshes cache from POD

### Error Handling
- Graceful fallback to SharedPreferences if POD operations fail
- Proper logging of errors for debugging
- Non-blocking initialization (app continues to work even if POD fails)

### Security
- All POD files are encrypted using solidpod's encryption system
- Files use ACL (Access Control List) for permission management
- Data is stored in user's private POD space

## File Structure in POD
```
/moviestar/
  ├── lists/
  │   ├── to_watch.ttl (encrypted)
  │   ├── to_watch.ttl.acl
  │   ├── watched.ttl (encrypted)  
  │   ├── watched.ttl.acl
  │   ├── ratings.ttl (encrypted)
  │   ├── ratings.ttl.acl
  │   ├── comments.ttl (encrypted)
  │   └── comments.ttl.acl
```

## Example TTL Output
```turtle
@prefix : <#> .
@prefix movie: <http://schema.org/Movie> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

:toWatchList a :MovieList ;
  :name "To Watch" ;
  :movies (
    :movie12345
    :movie67890
  ) .

:movie12345 a movie:Movie ;
  movie:identifier "12345"^^xsd:integer ;
  movie:name "The Matrix" ;
  movie:description "A computer hacker learns..." ;
  movie:image "https://image.tmdb.org/t/p/w500/poster.jpg" ;
  movie:aggregateRating "8.7"^^xsd:double ;
  movie:datePublished "1999-03-31T00:00:00.000Z"^^xsd:dateTime .

# JSON_DATA: [{"id":12345,"title":"The Matrix",...}]
```

## Status
✅ **Complete**: Basic POD storage functionality  
✅ **Complete**: TTL serialization/deserialization  
✅ **Complete**: Settings UI toggle  
✅ **Complete**: Fallback to SharedPreferences  
✅ **Complete**: Error handling and logging  

## Next Steps (Phase 2)
- Implement actual migration logic in settings  
- Update main app to use PodFavoritesService when POD storage is enabled
- Add sharing functionality using existing solidpod permission functions
- Create sharing UI components

## Testing
```bash
# Check for compilation errors
flutter analyze lib/services/pod_favorites_service.dart lib/utils/turtle_serializer.dart

# Run tests (when created)
flutter test test/pod_favorites_service_test.dart
```

## Dependencies
- `solidpod: ^latest` - For POD operations (readPod, writePod, permissions)
- `rxdart: ^latest` - For reactive streams  
- `shared_preferences: ^latest` - For fallback storage 