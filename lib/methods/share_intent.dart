import "package:receive_sharing_intent/receive_sharing_intent.dart";

handleSharingIntent() async {
  List<SharedMediaFile> fileList = await ReceiveSharingIntent.instance.getInitialMedia();
  if (fileList.isNotEmpty) {
    return (true, "file");
  }
  return (false, "");
}
