import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/pages/a_pages_index.dart';

class ProfilePicCaptureAndUploadResult {
  final UploadTask? uploadTask;
  final File? imageFile;

  ProfilePicCaptureAndUploadResult({this.uploadTask, this.imageFile});
}
