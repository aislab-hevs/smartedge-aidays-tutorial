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


