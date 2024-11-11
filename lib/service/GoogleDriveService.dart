// lib/services/google_drive_service.dart
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';

import 'package:http/http.dart' as http;

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? _currentUser;
  AuthClient? _authClient;

  // Authenticate and sign in with Google
  Future<void> authenticate() async {
    _currentUser = await _googleSignIn.signIn();
    if (_currentUser != null) {
      final authHeaders = await _currentUser!.authHeaders;
      _authClient = authenticatedClient(http.Client(), AccessCredentials(
        AccessToken(authHeaders['token_type']!, authHeaders['access_token']!, DateTime.now().toUtc()),
        null,
        ['https://www.googleapis.com/auth/drive.file'],
      ));
    }
  }

  // Check if a folder exists by name, or create it if it doesn't exist
  Future<String> _getOrCreateFolderId(String folderName) async {
    final driveApi = drive.DriveApi(_authClient!);

    // Search for the folder by name
    final folderQuery = "mimeType='application/vnd.google-apps.folder' and name='$folderName'";
    final folderList = await driveApi.files.list(q: folderQuery);

    // If folder exists, return its ID
    if (folderList.files != null && folderList.files!.isNotEmpty) {
      return folderList.files!.first.id!;
    }

    // Otherwise, create a new folder
    final newFolder = drive.File();
    newFolder.name = folderName;
    newFolder.mimeType = 'application/vnd.google-apps.folder';

    final createdFolder = await driveApi.files.create(newFolder);
    return createdFolder.id!;
  }

  // Upload file to Google Drive under a specific folder
  Future<void> uploadFileToDrive(File file, String fileName, String folderName) async {
    if (_authClient == null) await authenticate();

    final driveApi = drive.DriveApi(_authClient!);

    // Get or create the folder ID
    final folderId = await _getOrCreateFolderId(folderName);

    // Set up the file with the specified folder ID
    final driveFile = drive.File();
    driveFile.name = fileName;
    driveFile.parents = [folderId]; // Assigns the file to the folder

    final fileStream = file.openRead();
    final media = drive.Media(fileStream, await file.length());

    final uploadedFile = await driveApi.files.create(driveFile, uploadMedia: media);
    print('File uploaded to Google Drive: ${uploadedFile.name} (ID: ${uploadedFile.id})');
  }
}
