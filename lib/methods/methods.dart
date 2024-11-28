import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/db/data_generated.dart';
import 'package:photon/db/fastdb.dart';
import '../controllers/controllers.dart';

String formatTime(int seconds) {
  List<String> timeList = Duration(seconds: seconds).toString().split(':');
  String hr = double.parse(timeList[0]).toStringAsFixed(0);
  String min = double.parse(timeList[1]).toStringAsFixed(0);
  String sec = double.parse(timeList[2]).toStringAsFixed(0);
  if (seconds > 3600) {
    return '$hr hr $min mins $sec s';
  }

  if (seconds > 60) {
    return '$min min, $sec s';
  }
  return '$sec seconds';
}

Future<List<String>> getIP() async {
  // todo handle exception when no ip available
  List<NetworkInterface> listOfInterfaces = await NetworkInterface.list();
  List<String> ipList = [];

  for (NetworkInterface netInt in listOfInterfaces) {
    for (InternetAddress internetAddress in netInt.addresses) {
      if (internetAddress.address.toString().startsWith('192.168')) {
        ipList.add(internetAddress.address);
      }
    }
  }
  return ipList;
}

getReceiverIP(ipList) {
  return ipList[0];
}

int getRandomNumber() {
  Random rnd;
  try {
    rnd = Random.secure();
  } catch (_) {
    rnd = Random();
  }
  return rnd.nextInt(1000000) + 1000000;
}

generatePercentageList(len) {
  var getInstance = GetIt.I<PercentageController>();
  getInstance.percentage = RxList.generate(len, (index) {
    return RxDouble(0.0);
  });
  getInstance.isCancelled = RxList.generate(len, (index) {
    return RxBool(false);
  });
  getInstance.isReceived = RxList.generate(len, (index) {
    return RxBool(false);
  });
  getInstance.fileStatus =
      RxList.generate(len, (index) => RxString(Status.waiting.name));
}

Widget getFileIcon(String extn) {
  switch (extn) {
    case 'pdf':
      return SvgPicture.asset(
        'assets/icons/pdffile.svg',
        width: 30,
        height: 30,
      );
    case 'html':
      return const Icon(
        Icons.html,
        color: Colors.red,
        size: 30,
      );
    case 'mp3':
      return const Icon(
        Icons.audio_file,
        color: Colors.deepPurple,
        size: 30,
      );
    case 'jpeg':
      return SvgPicture.asset(
        'assets/icons/jpeg.svg',
        colorFilter: ColorFilter.mode( Colors.cyanAccent, BlendMode.srcIn, ),
        width: 30,
        height: 30,
      );
    case 'png':
      return SvgPicture.asset(
        'assets/icons/png.svg',
        width: 30,
        height: 30,
      );
    case 'exe':
      return SvgPicture.asset(
        'assets/icons/exe.svg',
        colorFilter: ColorFilter.mode( Colors.blueAccent, BlendMode.srcIn, ),
        width: 30,
        height: 30,
      );
    case 'apk':
      return SvgPicture.asset(
        'assets/icons/android.svg',
        colorFilter: ColorFilter.mode( Colors.greenAccent.shade400, BlendMode.srcIn, ),
        width: 30,
        height: 30,
      );
    case 'dart':
      return SvgPicture.asset(
        'assets/icons/dart.svg',
        width: 30,
        height: 30,
      );
    case 'mp4':
      return const Icon(
        Icons.video_collection_rounded,
        size: 30,
        color: Colors.orangeAccent,
      );

    default:
      return SvgPicture.asset(
        'assets/icons/file.svg',
        width: 30,
        height: 30,
      );
  }
}

getStatusWidget(RxString status, idx) {
  switch (status.value) {
    case "waiting":
      return const Text("Waiting");
    case "downloading":
      return Text(
          '${GetIt.I.get<PercentageController>().percentage[idx].value}');
    case "cancelled":
      return const Text("Cancelled");
    case "error":
      return const Text("Error");
    case "downloaded":
      return const Text("Completed");
  }
}

storeHistory(String savePath) async{
  if(FastDB.getFileInfo()== null){FastDB.userBuilder.fileInfo = List.empty();}
 FastDB.putFileInfo([InfoObjectBuilder(filePath: savePath, date: DateTime.now().toString())]);
await FastDB.flush();
}

Future<void> storeSentFileHistory(List<String?> files) async {
    if(FastDB.getSentHistory()== null){FastDB.userBuilder.sentHistory = List.empty();}
 FastDB.putSentHistory([ for(final file in files)  InfoObjectBuilder(filePath: file, date: DateTime.now().toString())]);
 await FastDB.flush();
}

getSentFileHistory(){
  return FastDB.getSentHistory();
}

getHistory(){
  return FastDB.getFileInfo();
}

clearSentHistory()async{
  FastDB.userBuilder.sentHistory = List.empty();
  await FastDB.flush();
}

clearHistory() async {
  FastDB.userBuilder.fileInfo = List.empty();
  await FastDB.flush();
}

String getDateString(DateTime date) {
  String day = "${date.day}".padLeft(2, '0');
  String month = "${date.month}";
  String year = "${date.year}";
  String hour = date.hour > 12 ? "${date.hour - 12}" : "${date.hour}";
  String period = TimeOfDay.fromDateTime(date).period.name;
  String minute = "${date.minute}".padLeft(2, '0');
  String dateString = "$day-$month-$year " "$hour-$minute $period";
  return dateString;
}

processReceiversData(Map<String, dynamic> newReceiverData) {
  var inst = GetIt.I.get<ReceiverDataController>();
  inst.receiverMap.addAll(
    {
      "${newReceiverData["receiverID"]}": {
        "hostName": newReceiverData["hostName"],
        "os": newReceiverData["os"],
        "currentFileName": newReceiverData["currentFileName"],
        "currentFileNumber": newReceiverData["currentFileNumber"],
        "filesCount": newReceiverData['filesCount'],
        "isCompleted": newReceiverData["isCompleted"],
      }
    },
  );
}

getEstimatedTime(receivedBits, totalBits, currentSpeed) {
  ///speed in [mega bits  x * 10^6 bits ]
  double estBits = (totalBits - receivedBits) / 1000000;
  int estTimeInInt = (estBits ~/ currentSpeed);
  int mins = 0;
  int seconds = 0;
  int hours = 0;
  hours = estTimeInInt ~/ 3600;
  mins = (estTimeInInt % 3600) ~/ 60;
  seconds = ((estTimeInInt % 3600) % 60);
  if (hours == 0) {
    if (mins == 0) {
      return 'About $seconds seconds left';
    }
    return 'About $mins m and $seconds s left';
  }
  return 'About $hours h $mins m $seconds s left';
}

getErrorString() {
  final List<String> scanErrorLines = [
    "Lost in the digital wilderness? Ensure your sender and receiver are holding hands through a mobile hotspot or dancing to the same WiFi beat!",
    "Looks like your devices are playing hide and seek. Connect them through a mobile hotspot or let them share the same WiFi network.",
    "Devices feeling lonely? Bridge the gap with a mobile hotspot or let them cozy up in the warmth of the same WiFi network.",
    "No devices in sight? Time to be the matchmaker! Connect them through a mobile hotspot or let them share the sweet harmony of the same WiFi network",
    "Missing connections? Make sure your devices are connected by a mobile hotspot or same WiFi network.",
  ];

  final Random random = Random();
  final int randomIndex = random.nextInt(scanErrorLines.length);

  return scanErrorLines[randomIndex];
}
