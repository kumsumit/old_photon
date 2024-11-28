import 'dart:async';
// import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'data_generated.dart' as db;
// import 'dart:isolate';


class FastDB {
  static final FastDB _instance = FastDB._internal();
  factory FastDB() => _instance;
  FastDB._internal();

  static late final db.UserObjectBuilder userBuilder;

  static late File _file;

  static Future<void> init() async {
    
    final directory = await getApplicationSupportDirectory();
    _file = File('${directory.path}/fastDB.bin');
    if (await _file.exists()) {
      await _decryptFile();
    } else {
      await _file.create(recursive: true);
        userBuilder = db.UserObjectBuilder();
    }
  }

 
  static Future<void> _decryptFile() async {
    try {
      final bytes = await _file.readAsBytes();
      if (bytes.isNotEmpty) {
        db.User user = db.User(bytes);
        final List<db.InfoObjectBuilder> sentHistory =  user.sentHistory == null || user.sentHistory!.isEmpty ? []:  [ for (final history in user.sentHistory!) db.InfoObjectBuilder(filePath: history.filePath,date: history.date)]; 
        final List<db.InfoObjectBuilder> fileInfo =  user.fileInfo == null || user.fileInfo!.isEmpty ? []:  [ for (final history in user.fileInfo!) db.InfoObjectBuilder(filePath: history.filePath,date: history.date)];
        userBuilder = db.UserObjectBuilder(username: user.username, avatarPath: user.avatarPath, sentHistory: sentHistory, isIntroRead: user.isIntroRead, fileInfo: fileInfo,
         );
      }else{
     userBuilder = db.UserObjectBuilder();
   }
    } catch (e) {
       userBuilder = db.UserObjectBuilder();
      debugPrint(e.toString());
    }
  }

 static String? getUsername() {
  return userBuilder.username;
 }

  static String? getAvatarPath() {
    return userBuilder.avatarPath;
  }

  static bool? getIsIntroRead() {
    return userBuilder.isIntroRead;
  }

  static bool? getQueryPackages(){
    return userBuilder.queryPackages;
  }
 
  static bool? getIsDarkTheme(){
    return userBuilder.isDarkTheme;
  }

  static String? getDirectoryPath(){
    return userBuilder.directoryPath;
  }
 
 static List<db.Info>? getFileInfo(){
  if(userBuilder.fileInfo == null) return null;
    return  [ for(final info in  userBuilder.fileInfo! ) db.Info(info.toBytes())];
 }
  static List<db.Info>? getSentHistory() {
    if(userBuilder.sentHistory == null) return null;
    return  [ for(final history in  userBuilder.sentHistory! ) db.Info(history.toBytes())];
  }

  static void putUsername(String username) {
    userBuilder.username = username;
  }

  static void putAvatarPath(String avatarPath) {
    userBuilder.avatarPath = avatarPath;
  }

  static void putIsIntroRead(bool isIntroRead) {
    userBuilder.isIntroRead = isIntroRead;
  }

  static void putQueryPackages(bool queryPackages) {
    userBuilder.queryPackages = queryPackages;
  }

  static void putIsDarkTheme(bool isDarkTheme) {
    userBuilder.isDarkTheme = isDarkTheme;
  }

  static void putDirectoryPath(String directoryPath) {
    userBuilder.directoryPath = directoryPath;
  } 

  static void putSentHistory(List<db.InfoObjectBuilder> history) {
    userBuilder.sentHistory = [...userBuilder.sentHistory!, ...history];
  }

  static void putFileInfo(List<db.InfoObjectBuilder> info) {
    userBuilder.fileInfo = [...userBuilder.fileInfo!, ...info];
  }

  static Future<void> flush() async{
      final originalBytes =
          userBuilder.toBytes();
      if (originalBytes.isNotEmpty) {
       await _file.writeAsBytes(originalBytes,flush: true);
      }
  }

  static Future<void> clearAll()async{
      if (await _file.exists()) {
        await _file.delete();
      }
  }
}



// class FileWriter {
//   final String path;
//   final Queue<Function> _writeQueue = Queue<Function>();
//   bool _isWriting = false;

//   FileWriter(this.path);

//   Future<void> write(String content) async {
//     final Completer<void> completer = Completer<void>();

//     _writeQueue.add(() async {
//       final file = File(path);
//       await file.writeAsString(content, mode: FileMode.write);
//       completer.complete();
//     });

//     _processQueue();
//     return completer.future;
//   }

//   Future<String> read() async {
//     final Completer<String> completer = Completer<String>();

//     _writeQueue.add(() async {
//       final file = File(path);
//       final content = await file.readAsString();
//       completer.complete(content);
//     });

//     _processQueue();
//     return completer.future;
//   }

//   void _processQueue() async {
//     if (_isWriting || _writeQueue.isEmpty) return;

//     _isWriting = true;
//     final writeOperation = _writeQueue.removeFirst();
//     await writeOperation();
//     _isWriting = false;

//     _processQueue(); // Check the queue for more operations
//   }
// }


// void main() async {
//   final encryptionReceivePort = ReceivePort();
//   await Isolate.spawn(encryptData, encryptionReceivePort.sendPort);

//   final encryptionSendPort = await encryptionReceivePort.first as SendPort;
//   final encryptionResponsePort = ReceivePort();

//   // Data to encrypt
//   final message = {'data': 'Hello, World!', 'responsePort': encryptionResponsePort.sendPort};
//   encryptionSendPort.send(message);

//   final encryptedData = await encryptionResponsePort.first as String;
//   print('Encrypted Data: $encryptedData');

//   final fileWriter = FileWriter('example_encrypted.txt');
//   await fileWriter.write(encryptedData);

//   print('File write result: File written successfully.');
// }

// void encryptData(SendPort sendPort) {
//   final port = ReceivePort();
//   sendPort.send(port.sendPort);

//   port.listen((message) {
//     final data = message['data'] as String;
//     final responsePort = message['responsePort'] as SendPort;

//     // Encrypt the data (using a simple example here for demonstration)
//     final key = encrypt.Key.fromUtf8('my 32 length key................');
//     final iv = encrypt.IV.fromLength(16);
//     final encrypter = encrypt.Encrypter(encrypt.AES(key));

//     final encrypted = encrypter.encrypt(data, iv: iv);
//     responsePort.send(encrypted.base64);
//   });
// }

// class FileWriter {
//   final String path;
//   final Queue<Function> _writeQueue = Queue<Function>();
//   bool _isWriting = false;

//   FileWriter(this.path);

//   Future<void> write(String content) async {
//     final Completer<void> completer = Completer<void>();

//     _writeQueue.add(() async {
//       final file = File(path);
//       await file.writeAsString(content, mode: FileMode.append);
//       completer.complete();
//     });

//     _processQueue();
//     return completer.future;
//   }

//   void _processQueue() async {
//     if (_isWriting || _writeQueue.isEmpty) return;

//     _isWriting = true;
//     final writeOperation = _writeQueue.removeFirst();
//     await writeOperation();
//     _isWriting = false;

//     _processQueue(); // Check the queue for more operations
//   }
// }
