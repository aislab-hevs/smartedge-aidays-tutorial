import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
    }
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
