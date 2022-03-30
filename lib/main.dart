import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode/ai_barcode.dart';
import 'package:transmitt_mobile/client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transmitt',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Key idcode = UniqueKey();
  bool selected = false;
  PlatformFile file = PlatformFile(name: "", size: 0);
  ScannerController scannerController = ScannerController(scannerResult:(_)=> _);
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scannerController = ScannerController(scannerResult: (code) {
        send(code);
      });
    });
    super.initState();
  }
  void send(String code) async {
    print(code);
      setState(() {
        selected = false;
      });
      String ip = code.split("@")[0];
      String scode = code.split("@")[1];
      await runUpload(ip, scode, file.bytes!, file.name.replaceAll(".${file.extension!}", ""), file.extension!, idcode.toString()).then((value) => print("end $value"));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CupertinoButton(
              child: Text("YOUR IDCODE: $idcode\nSelect a file to send."),
              onPressed: () async{
               FilePickerResult? result = await FilePicker.platform.pickFiles();

                if(result != null) {
                  file = result.files.first;
                  print(file.name.replaceAll(".${file.extension!}", ""));
                  setState(() {
                    selected = true;
                  });
                } else {
                  // User canceled the picker
                }
                
                
                
             }
            ),
            (selected)?Container(
              color: Colors.black26,
              width: 640,
              height: 480,
              child: PlatformAiBarcodeScannerWidget(
                platformScannerController: scannerController,
              ),
            ):Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'DOWNLOAD A FILE FROM PC',
        child: const Icon(Icons.download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
