import 'package:image_picker/image_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';


class SharedIntent {
  static List<XFile>? sharedFiles;
  static Future<List<XFile>?> receiveSharedData() async {
    try {
      // Get the instance of ReceiveSharingIntent
      ReceiveSharingIntent receiveSharingIntent = await ReceiveSharingIntent.instance;

      // Get the initial shared data
      List<SharedMediaFile> receivedFiles = await receiveSharingIntent.getInitialMedia();

      if (receivedFiles.isNotEmpty) {
        // Transform SharedMediaFile to XFile
        sharedFiles = receivedFiles.map((sharedFile) => XFile(sharedFile.path)).toList();
        return sharedFiles;
      } else {
        return null;
      }
    } catch (e) {
      print('Error receiving shared data: $e');
      return null;
    }
  }
  static void cleanupSharedFiles() {
    sharedFiles = null;
  }
}
