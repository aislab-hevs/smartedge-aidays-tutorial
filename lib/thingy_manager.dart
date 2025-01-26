import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:summerschool_tutorial/thingy_device.dart';
import 'package:summerschool_tutorial/thingylib.dart';

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
