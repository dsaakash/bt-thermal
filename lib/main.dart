// // Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// // All rights reserved. Use of this source code is governed by a
// // BSD-style license that can be found in the LICENSE file.
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// import 'screens/bluetooth_off_screen.dart';
// import 'screens/scan_screen.dart';
//
// void main() {
//   FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
//   runApp(const FlutterBlueApp());
// }
//
// //
// // This widget shows BluetoothOffScreen or
// // ScanScreen depending on the adapter state
// //
// class FlutterBlueApp extends StatefulWidget {
//   const FlutterBlueApp({Key? key}) : super(key: key);
//
//   @override
//   State<FlutterBlueApp> createState() => _FlutterBlueAppState();
// }
//
// class _FlutterBlueAppState extends State<FlutterBlueApp> {
//   BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
//
//   late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
//       _adapterState = state;
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _adapterStateStateSubscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Widget screen = _adapterState == BluetoothAdapterState.on
//         ? const ScanScreen()
//         : BluetoothOffScreen(adapterState: _adapterState);
//
//     return MaterialApp(
//       color: Colors.lightBlue,
//       home: screen,
//       navigatorObservers: [BluetoothAdapterStateObserver()],
//     );
//   }
// }
//
// //
// // This observer listens for Bluetooth Off and dismisses the DeviceScreen
// //
// class BluetoothAdapterStateObserver extends NavigatorObserver {
//   StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
//
//   @override
//   void didPush(Route route, Route? previousRoute) {
//     super.didPush(route, previousRoute);
//     if (route.settings.name == '/DeviceScreen') {
//       // Start listening to Bluetooth state changes when a new route is pushed
//       _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
//         if (state != BluetoothAdapterState.on) {
//           // Pop the current route if Bluetooth is off
//           navigator?.pop();
//         }
//       });
//     }
//   }
//
//   @override
//   void didPop(Route route, Route? previousRoute) {
//     super.didPop(route, previousRoute);
//     // Cancel the subscription when the route is popped
//     _adapterStateSubscription?.cancel();
//     _adapterStateSubscription = null;
//   }
// }

import 'package:intl/intl.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Bluetooth demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Bluetooth demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  var addressGroup = [];

  @override
  void initState() {
    super.initState();
   _requestPermissions().then((_) {
      _startScanDevices();
    });
    String address =
        'Jl. Boulevard Raya, RT.11/RW.18, Gedung Menara satu, Kec. Klp. Gading, Kota Jkt Utara, Daerah Khusus Ibukota Jakarta 14240';

    print(122 / 25);
    for (var i = 0; i < address.length / 40; i++) {
      int total = 0;
      total = total + i;
      print(total);
      String tempStr = "";
      if (address.length > 40 * (i + 1)) {
        tempStr = address.substring(40 * i, 40 * (i + 1));
      } else {
        tempStr = address.substring(40 * i, address.length);
      }
      print(tempStr);
      addressGroup.add(tempStr);
      // address = tempStr + "-" + address.substring(26*(i+1), address.length);
      print(address);
    }
    // print(address);
    print(addressGroup);
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();
    // Add more permission requests here if needed
  }

  void _startScanDevices() {
    // Start scanning for devices
    printerManager.startScan(Duration(seconds: 4));
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<List<int>> demoReceipt(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);

    final Generator generator = Generator(paper, profile);

    List<int> bytes = [];

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData), width: 1, height: 1);

    bytes += ticket.text('GROCERYLY',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
        linesAfter: 1);

    bytes += ticket.text('889  Watson Lane',
        styles: const PosStyles(align: PosAlign.center));
    bytes += ticket.text('New Braunfels, TX',
        styles: const PosStyles(align: PosAlign.center));
    bytes += ticket.text('Tel: 830-221-1234',
        styles: const PosStyles(align: PosAlign.center));
    // bytes += ticket.text('Web: www.example.com',
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += ticket.hr();
    bytes += ticket.hr();
    bytes += ticket.hr();
    bytes += ticket.hr();
    bytes += ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += ticket.row([
      PosColumn(text: '2', width: 1),
      PosColumn(text: 'ONION RINGS', width: 7),
      PosColumn(
          text: '0.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '1.98', width: 2, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'PIZZA', width: 7),
      PosColumn(
          text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'SPRING ROLLS', width: 7),
      PosColumn(
          text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '3', width: 1),
      PosColumn(text: 'CRUNCHY STICKS', width: 7),
      PosColumn(
          text: '0.85', width: 2, styles: const PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.55', width: 2, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '\$10.97',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.hr(ch: '=', linesAfter: 1);

    bytes += ticket.row([
      PosColumn(
          text: 'Cash',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$15.00',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Change',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$4.03',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);

    bytes += ticket.feed(2);
    bytes += ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    ticket.feed(2);
    ticket.cut();
    return bytes;
  }

  Future<List<int>> testTicket(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator generator = Generator(paper, profile);
    List<int> bytes = [];
    // bytes += generator.reset();
    // bytes += generator.text('ONDELIVERY',
    //     styles: PosStyles(
    //       align: PosAlign.left,
    //     ));
    final List<String> barData = [
      '{',
      'B',
      'J',
      'K',
    ];

    // bytes += generator.barcode(Barcode.code39(barData),height:100);

    bytes += generator.barcode(Barcode.code128(barData), width: 1, height: 50);
    // bytes += generator.barcode(Barcode.code39(barData),  height:50);
    bytes += generator.row([
      PosColumn(
          text: 'ONDELIVERY',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '23 Oktober 1998 22:53',
          width: 9,
          styles: PosStyles(align: PosAlign.left, bold: true)),
    ]);
    // bytes += generator.barcode(Barcode.code128(barData),height: 1);

    bytes += generator.row([
      PosColumn(
          text: 'Sender',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),

      // PosColumn(
      //     text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Raymond Tumiwa',
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Phone',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '08951273689',
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Receiver',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Abdulah Ahmad',
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Phone',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '08951273689',
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    String? cutAddress;

    // for(var i=0;i<)
    // bytes += generator.text(cutAddress!,
    //     styles: PosStyles(align: PosAlign.right, bold: true));
    //initial
    for (var i = 0; i < addressGroup.length; i++) {
      bytes += generator.text(addressGroup[i],
          styles: PosStyles(align: PosAlign.left, bold: true));
    }


    bytes += generator.row([
      PosColumn(
          text: 'Content Of Package',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),

      // PosColumn(
      //     text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Elektronik',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'QTY (ITEM)',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '1 pcs',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: 'SERVICE',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '9.9999.9999',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Weight',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '1kg',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: 'INSURANCE',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '0',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'VOLUMETRIK',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: 'SURCHARGE',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '0',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([

      PosColumn(
          text: 'P: 0, L: 0, T: 0',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: 'DISCOUNT',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '0',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: '',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '',
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: 'TOTAL',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '0',
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    String add =
        'Notes: PT ADMINISTRASI MEDIKA TELKOM ADMINISTRASI MEDIKA TELKOM ADMINISTRASI MEDIKA TELKOM';
    print(add);
    print(add.length);
    String addCut = add.substring(0, 10);
    bytes += generator.text(add,
        styles: PosStyles(
          align: PosAlign.left,
        ));


    bytes += generator.row([

      PosColumn(
          text: 'JKT-JKT',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'SETIABUDI 17149',
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: 'SAMEDAY SERVICE',
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
          )),

    ]);


    // bytes += generator.cut(mode: PosCutMode.partial);
    bytes += generator.cut();
    //bytes += generator.feed(1);
    // final List<int> barData1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.code128(barData));
    bytes += generator.row([
      PosColumn(
          text: 'ONDELIVERY',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'REGULER SERVICE',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: '2 June 2021 15:45',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Rp 9999.9999',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Sender: RAYMOND TUMIWA',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Phone: 08951273689',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Receiver: Abdullah Ahmad',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Phone: 08951273689',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: '',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Insurance: ',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'No',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);

    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    // TEST PRINT
    final PosPrintResult res = await printerManager.printTicket(
        await testTicket(
          paper,
          profile,
        ),
        queueSleepTimeMs: 100);


    showToast(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),


      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _testPrint(_devices[index]),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address!),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: _startScanDevices,
            );
          }
        },
      ),
    );
  }


}



