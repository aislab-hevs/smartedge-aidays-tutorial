/* Put this in android/app/main/AndroidManifest.xml
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />

    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />

    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />

    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
*/

library thingylib;

import 'dart:async';
import 'dart:typed_data';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vector_math/vector_math.dart';

var motionServiceId = "ef680400-9b35-4933-9b10-52ffa9740042";
var quaternionCharacteristicId = "ef680404-9b35-4933-9b10-52ffa9740042";
var gravityVectorCharacteristicId = "ef68040a-9b35-4933-9b10-52ffa9740042";
var rawDataCharacteristicId = "ef680406-9b35-4933-9b10-52ffa9740042";
var colorCharacteristicId = "ef680301-9b35-4933-9b10-52ffa9740042";

List<double> parseGravityVector(BluetoothDevice device, List<int> value) {
  Uint8List uint8List = Uint8List.fromList(value);
  ByteData byteData = ByteData.sublistView(uint8List.buffer.asByteData());

  return [
    byteData.getFloat32(0, Endian.little),
    byteData.getFloat32(4, Endian.little),
    byteData.getFloat32(8, Endian.little)
  ];
}

Quaternion parseQuaternions(List<int> value) {
  Uint8List uint8List = Uint8List.fromList(value);
  ByteData byteData = ByteData.sublistView(uint8List.buffer.asByteData());

  if (value.isEmpty) {
    return Quaternion(0, 0, 0, 1);
  }

  return Quaternion(
      byteData.getInt32(0, Endian.little) / (1 << 30), // w
      byteData.getInt32(4, Endian.little) / (1 << 30), // x
      byteData.getInt32(8, Endian.little) / (1 << 30), // y
      byteData.getInt32(12, Endian.little) / (1 << 30)); // z
}

List<List<double>> parseRawData(List<int> value) {
  if (value.isEmpty) {
    return List.empty();
  }

  Uint8List uint8List = Uint8List.fromList(value);
  ByteData byteData = ByteData.view(uint8List.buffer);

  List<double> accelerometerData = [
    byteData.getInt16(0, Endian.little) / (1 << 10),
    byteData.getInt16(2, Endian.little) / (1 << 10),
    byteData.getInt16(4, Endian.little) / (1 << 10),
  ];

  List<double> gyroscopeData = [
    byteData.getInt16(6, Endian.little) / (1 << 5),
    byteData.getInt16(8, Endian.little) / (1 << 5),
    byteData.getInt16(10, Endian.little) / (1 << 5),
  ];

  List<double> compassData = [
    byteData.getInt16(12, Endian.little) / (1 << 4),
    byteData.getInt16(14, Endian.little) / (1 << 4),
    byteData.getInt16(16, Endian.little) / (1 << 4),
  ];

  return [accelerometerData, gyroscopeData, compassData];
}

class ThingyLib {
  static Future<List<BluetoothDevice>> get systemDevices =>
      FlutterBluePlus.systemDevices;
  static Stream<List<ScanResult>> get scanResults =>
      FlutterBluePlus.scanResults;
  static Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  static Stream<List<ScanResult>> get onScanResults =>
      FlutterBluePlus.onScanResults;

  static Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  static Future initiateScan() async {
    try {
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 5),
          continuousUpdates: true,
          androidUsesFineLocation: true,
          withServices: [Guid("ef680100-9b35-4933-9b10-52ffa9740042")]);
    } catch (e) {
      log("ERROR: ${e.toString()}");
    }
  }
}

class ThingyManager {
  Map<String, ThingyDevice> idToDevice = {};
  late List<ScanResult> thingyScanResults = [];
  bool _isScanning = true;

  ThingyManager() {
    ThingyLib.isScanning.listen((state) {
      log("STATE: $state");
      _isScanning = state;
    });

    ThingyLib.onScanResults.listen((results) {
      log("Results: $results");
      thingyScanResults = results;
    });
  }

  bool get isScanning => _isScanning;

  List<ThingyDevice> get connectedDevices => idToDevice.values.toList();

  Future<void> disconnectDevices() async {
    FlutterBluePlus.connectedDevices.forEach((element) async {
      await element.disconnect();
    });
  }

  /// Scans for Thingy devices, waits for scan to finish,
  /// shows a popup of discovered devices, and returns the selected device.
  Future<ThingyDevice?> scanAndSelectDevice(BuildContext context) async {
    // 1. Initiate scan
    await ThingyLib.initiateScan();

    // 2. Wait for scanning to finish
    if (isScanning) {
      log("Scan in progress...");
      await Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        log("Ongoing scan...$isScanning");
        return isScanning;
      });
    }
    log("Scan over. Found ${thingyScanResults.length} devices.");

    // 3. Show popup to select from discovered devices
    final selectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Thingy Device'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: thingyScanResults.map((result) {
                final device = result.device;
                final name =
                device.name.isNotEmpty ? device.name : 'Unknown Device';
                return ListTile(
                  title: Text(name),
                  subtitle: Text(device.remoteId.toString()),
                  onTap: () {
                    Navigator.of(context).pop(device);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // If user cancelled the dialog, selectedDevice will be null
    if (selectedDevice == null) {
      log("No device selected.");
      return null;
    }

    // 4. Connect to the chosen device
    log("Connecting to ${selectedDevice.name}...");
    try {
      await selectedDevice.connect();
      log("Connected to ${selectedDevice.name}");

      // 5. Create a ThingyDevice wrapper and init
      final thingyDevice = ThingyDevice(selectedDevice);
      await thingyDevice.init();
      await monitorDeviceConnection(selectedDevice);

      // 6. Store in our map
      idToDevice[selectedDevice.remoteId.toString()] = thingyDevice;
      return thingyDevice;
    } catch (e) {
      log("Error connecting to device: $e");
      return null;
    }
  }

  Future<void> monitorDeviceConnection(BluetoothDevice device) async {
    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        log('Device ${device.remoteId} is disconnected');
        idToDevice.remove(device.remoteId.toString());
      }
    });
  }

  Stream<ThingyDevice> connectThingies() async* {
    await ThingyLib.initiateScan();

    if (isScanning) {
      log("Scan in progress...");
      await Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        log("Ongoing scan...$isScanning");
        return isScanning;
      });
    }

    log("Scan over, connecting... $thingyScanResults");

    try {
      await Future.wait(
          thingyScanResults.map((scanResult) => scanResult.device.connect()));
    } catch (e) {
      log("Error connecting to devices.");
      log(e.toString());
    }

    await ThingyLib.systemDevices.then((devices) {
      devices.forEach((e) => idToDevice.putIfAbsent(e.remoteId.toString(), () => ThingyDevice(e)));
    });

    for (var device in idToDevice.values) {
      if (!device.isConnected) {
        idToDevice.remove(device.remoteId.toString());
      }

      if (device.isConnected) {
        await device.init();
        await monitorDeviceConnection(device);
        idToDevice.putIfAbsent(device.remoteId.toString(), () => device);
        yield device;
      }
    }

    log("Connection complete.");
    log(idToDevice.toString());
  }

  Future<void> enableQuaternionService(Function callback) async {
    for (var device in idToDevice.values) {
      if (device.isConnected) {
        await device.enableCharacteristic(
            Guid(quaternionCharacteristicId), parseQuaternions, callback);
      }
    }
    log("Quaternions enabled.");
  }

  Future<void> enableRawDataService(Function callback) async {
    for (var device in idToDevice.values) {
      if (device.isConnected) {
        await device.enableCharacteristic(
            Guid(rawDataCharacteristicId), parseRawData, callback);
      }
    }
    log("Raw Data enabled.");
  }

  Future<void> startCharacteristics(Function callback) async {
    await enableQuaternionService(callback);

    for (var device in idToDevice.values) {
      await device.startCharacteristics();
    }
    log("Characteristics Done.");
  }

  Future<void> stopCharacteristics() async {
    for (var device in idToDevice.values) {
      if (device.isConnected) {
        await device.stopCharacteristics();
      }
    }
    return;
  }
}

class ThingyDevice extends BluetoothDevice {
  Map<Guid, BluetoothService> thingyServices = {};
  Map<Guid, BluetoothCharacteristic> thingyCharacteristics = {};
  List<BluetoothCharacteristic> enabledCharacteristics = [];
  var _notificationSubscription;

  ThingyDevice(BluetoothDevice device) : super(remoteId: device.remoteId);

  Future<void> init() async {
    List<BluetoothService> services = await discoverServices();
    for (var service in services) {
      thingyServices.putIfAbsent(service.uuid, () => service);
      for (var characteristic in service.characteristics)
      {
        thingyCharacteristics.putIfAbsent(
            characteristic.uuid, () => characteristic);
      }
    };
  }

  Future<void> enableCharacteristic(
      Guid characteristicGuid, Function parser, Function callback) async {

    await _notificationSubscription?.cancel();

    _notificationSubscription = thingyCharacteristics[characteristicGuid]!
        .lastValueStream
        .listen((value) {
      callback(parser(value));
    });

    cancelWhenDisconnected(_notificationSubscription);
    enabledCharacteristics.add(thingyCharacteristics[characteristicGuid]!);
  }

  Future<void> startCharacteristics() async {
    for (var characteristic in enabledCharacteristics) {
      await characteristic.setNotifyValue(true);
    }
  }

  Future<void> stopCharacteristics() async {
    for (var characteristic in enabledCharacteristics) {
      await characteristic.setNotifyValue(false);
    }
  }
}
