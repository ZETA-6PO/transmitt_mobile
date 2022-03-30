
import 'dart:convert';
import 'dart:typed_data';
import 'package:transmitt_mobile/converter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;



Future<bool?> upload(String ip, String scode, Uint8List filedata, String filename, String ext, String idcode) async {
  //requete task
  print ("x");
  String uuid = Uuid().v4().toString();
  bool termin = false;


  //créer le bundle io
  IO.Socket socket = IO.io('http://$ip:12221');
  //quand connecté on envoie la request sur le channel request pc
  socket.onConnect((_) {
    print('connected');
    print(filename);
    socket.emit('request', [
      {
        "rtype":"upload",
        "scode": scode,
        "uuid": uuid,
        "name": Utf8Encoder().convert(filename),
        "size": filedata.lengthInBytes.toString(),
        "ext": ext,
        "idcode": idcode
      }
    ]);
  });
  //quand disconnect on annule tout le bordel
  socket.onDisconnect((_) {
    socket.destroy();
    termin =true;
    return false;
  });
  //quand receive sur 
  socket.on('response', (data) {
    
    //si c'est accepté;
    if (data["type"] == "accepted") {
      print("d");
      if (data[0]["uuid"] == uuid) { //vérification de l'uuid
        socket.emit('task', JsonEncoder().convert({
          "type": "transfer",
          "uuid": uuid,
          "idcode": idcode,
          "data" : toStr(filedata),
        }).toString());
        print('transfering');
      }
    }
    if (data[0]["type"] == "valided") {
      if (data[0]["uuid"] == uuid) {
        print('transfered & valided');
        socket.emit('request', JsonEncoder().convert({
          "type": "close",
        }).toString());
        socket.destroy();
        termin =true;
        return true;
      }
      
    }else if (data[0]["type"] == "error" && data[0]["uuid"] == uuid){
      socket.destroy();
      termin =true;
      return false;
    }

    
  });
}
Future<bool> runUpload(String ip, String scode, Uint8List filedata, String filename, String ext, String idcode) async {
  bool? request;
  try {
    request = await upload(ip, scode, filedata, filename, ext, idcode)
      .timeout(Duration(seconds: 10), onTimeout: (){
        print('0 timed out');
        return false;
      });
  }catch (e){
    print("Error while uploading $e");
    return false;
  }
 
  if (request == null) {
    print("Error, request null;");
    return false;
  }
  return true;
}