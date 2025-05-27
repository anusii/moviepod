/// Create app folder.
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Ashley Tang

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:moviestar/constants/paths.dart';

/// Creates an app folder in POD with initialisation file.
///
/// Returns a [Future<SolidFunctionCallStatus>] indicating the creation result.
/// The [folderName] parameter specifies which folder to create (e.g. 'movies').
/// If [createInitFile] is true, creates an initialisation file in the folder.

Future<SolidFunctionCallStatus> createAppFolder({
  required String folderName,
  required BuildContext context,
  bool createInitFile = true,
  required void Function(bool) onProgressChange,
  required void Function() onSuccess,
}) async {
  try {
    onProgressChange.call(true);

    // Check current resources.

    final dirUrl = await getDirUrl(basePath);
    final resources = await getResourcesInContainer(dirUrl);

    // Check if exists as directory.

    bool existsAsDir = resources.subDirs.contains(folderName);
    if (existsAsDir) {
      debugPrint('App folder $folderName already exists as directory');
      onSuccess.call();
      return SolidFunctionCallStatus.success;
    }

    // Check if exists as file and delete if necessary.

    bool existsAsFile = resources.files.contains(folderName);
    if (existsAsFile) {
      debugPrint(
        'Removing existing file $folderName before creating directory',
      );
      if (!context.mounted) return SolidFunctionCallStatus.fail;

      // Full path for deletion needs to include basePath (e.g. moviestar/data).

      await deleteFile('$basePath/$folderName');
    }

    if (!context.mounted) {
      debugPrint('Widget is no longer mounted, skipping folder creation.');
      return SolidFunctionCallStatus.fail;
    }

    // Create the app folder structure.

    final result = await writePod(
      '$folderName/.init',
      '',
      context,
      const Text('Creating folder'),
      encrypted: false,
    );

    // If folder creation was successful and initialization file is requested.

    if (result == SolidFunctionCallStatus.success && createInitFile) {
      String initContent;

      // Initialisation content for all folders.

      initContent = '''

          {
            "folder": "$folderName",
            "created": "${DateTime.now().toIso8601String()}",
            "version": "1.0"
          }

          ''';

      if (!context.mounted) return result;

      final initResult = await writePod(
        '$folderName/init.json',
        initContent,
        context,
        const Text('Creating initialization file'),
        encrypted: true,
      );

      if (initResult == SolidFunctionCallStatus.success) {
        onSuccess.call();
        return SolidFunctionCallStatus.success;
      }
    }

    return result;
  } catch (e) {
    debugPrint('Error creating app folder: $e');
    return SolidFunctionCallStatus.fail;
  } finally {
    onProgressChange.call(false);
  }
}
