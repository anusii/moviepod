# Scripts Directory

This directory contains utility scripts for the MovieStar project.

## Available Scripts

### convert_imports.dart

**Purpose**: Converts all relative imports in the `lib/` directory to package imports for consistency and better maintainability.

**Usage**:
```bash
dart run scripts/convert_imports.dart
```

**What it does**:
- Finds all `.dart` files in the `lib/` directory recursively
- Converts relative imports (`../path/file.dart`) to package imports (`package:moviestar/path/file.dart`)
- Converts local imports (`file.dart`) to package imports (`package:moviestar/current_dir/file.dart`)
- Preserves external package imports (`package:flutter/material.dart`, `dart:core`, etc.)

**Benefits of package imports**:
- More explicit and clear
- Easier to refactor and move files
- Avoids path resolution issues
- Consistent with Flutter/Dart best practices

**Example conversions**:
- `../models/movie.dart` (from screens/) → `package:moviestar/models/movie.dart`
- `movie_details_screen.dart` (from screens/) → `package:moviestar/screens/movie_details_screen.dart`
- `../utils/network_client.dart` (from services/) → `package:moviestar/utils/network_client.dart`

**Requirements**: Must be run from the project root directory. 