import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final title = 'Flutter BLE Scan Demo';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  var scan_mode = 0;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  void toggleState() {
    setState(() {
      isScanning = !isScanning;
    });

    if (isScanning) {
      startScan();
    } else {
      flutterBlue.stopScan();
    }
  }

  void startScan() {
    try {
      flutterBlue.startScan(scanMode: ScanMode(scan_mode), allowDuplicates: true);
      scan();
    } catch (e) {
      print('Error starting scan: $e');
      setState(() {
        isScanning = false;
      });
    }
  }

  void scan() async {
    if (isScanning) {
      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        setState(() {
          scanResultList = results;
        });
      }).onError((error) {
        print('Error during scan: $error');
        setState(() {
          isScanning = false;
        });
      });
    }
  }

  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }

  Widget deviceName(ScanResult r) {
    String name;
    if (r.device.name.isNotEmpty) {
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      name = r.advertisementData.localName;
    } else {
      name = 'N/A';
    }
    return Text(name);
  }

  Widget leading(ScanResult r) {
    return CircleAvatar(
      backgroundColor: Colors.cyan,
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
    );
  }

  void onTap(ScanResult r) {
    print('${r.device.name}');
  }

  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: scanResultList.length,
          itemBuilder: (context, index) {
            return listItem(scanResultList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleState,
        child: Icon(isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
