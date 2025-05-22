/// Save decrypted content.
//
// Time-stamp: <Thursday 2024-12-19 13:33:06 +1100 Graham Williams>
//
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:moviestar/utils/is_text_file.dart';

/// Check if a string looks like base64
bool _isLikelyBase64(String str) {
  // Base64 strings should only contain these characters
  final RegExp base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');

  // Must be at least 4 characters and length must be a multiple of 4
  return str.length >= 4 && str.length % 4 == 0 && base64Pattern.hasMatch(str);
}

/// Check if a string looks like JSON
bool _isLikelyJson(String str) {
  final trimmed = str.trim();
  return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
      (trimmed.startsWith('[') && trimmed.endsWith(']'));
}

/// Saves decrypted content to a file, handling different file formats appropriately.
///
/// Attempts to save as JSON if possible, falls back to binary or text based on file type.

Future<void> saveDecryptedContent(
  String decryptedContent,
  String saveFilePath,
) async {
  final file = File(saveFilePath);

  // Ensure the parent directory exists.
  await file.parent.create(recursive: true);

  try {
    // First, try to detect content type
    if (_isLikelyJson(decryptedContent)) {
      // Try to parse and save as formatted JSON
      try {
        final jsonData = jsonDecode(decryptedContent);
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(jsonData),
        );
        return;
      } catch (jsonError) {
        debugPrint('JSON parsing failed despite looking like JSON: $jsonError');
        // Continue to other options if JSON parsing fails
      }
    }

    // For non-text files, try base64 decoding if it looks like base64
    if (!isTextFile(saveFilePath) && _isLikelyBase64(decryptedContent)) {
      try {
        final bytes = base64Decode(decryptedContent);
        await file.writeAsBytes(bytes);
        return;
      } catch (base64Error) {
        debugPrint(
          'Base64 decode failed despite looking like base64: $base64Error',
        );
        // Continue to text handling if base64 fails
      }
    }

    // Default: treat as plain text
    await file.writeAsString(decryptedContent);
  } catch (e) {
    throw Exception('Failed to save file: ${e.toString()}');
  }
}
