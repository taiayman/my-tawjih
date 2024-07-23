import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseService().storage;

  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('File uploaded successfully. Download URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Error uploading file: ${e.code} - ${e.message}');
      if (e.code == 'unauthorized') {
        throw Exception('User is not authorized to upload files. Please check your permissions.');
      } else {
        throw Exception('Failed to upload file: ${e.message}');
      }
      } catch (e) {
      print('Unexpected error uploading file: $e');
      throw Exception('An unexpected error occurred while uploading the file.');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      print('File deleted successfully: $path');
    } on FirebaseException catch (e) {
      print('Error deleting file: ${e.code} - ${e.message}');
      throw Exception('Failed to delete file: ${e.message}');
    } catch (e) {
      print('Unexpected error deleting file: $e');
      throw Exception('An unexpected error occurred while deleting the file.');
    }
  }

  Future<String> getDownloadURL(String path) async {
    try {
      final downloadUrl = await _storage.ref().child(path).getDownloadURL();
      print('Download URL retrieved: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Error getting download URL: ${e.code} - ${e.message}');
      throw Exception('Failed to get download URL: ${e.message}');
    } catch (e) {
      print('Unexpected error getting download URL: $e');
      throw Exception('An unexpected error occurred while getting the download URL.');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());