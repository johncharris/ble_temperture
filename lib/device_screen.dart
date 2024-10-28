import 'dart:typed_data';

import 'package:ble_temperture/constants.dart';
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({required this.device, super.key});
  final BleDevice device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  double temperature = 0;
  bool useCelcius = true;

  @override
  void initState() {
    readValue();
    super.initState();
  }

  Future readValue() async {
    UniversalBle.onValueChange = (String deviceId, String characteristicId, Uint8List value) {
      if (deviceId == widget.device.deviceId) {
        setState(() {
          temperature = _bytesToFloat(value);
        });
      }
    };

    UniversalBle.setNotifiable(widget.device.deviceId, serviceUUID, characteristicUUID, BleInputProperty.notification);
  }

  @override
  void dispose() {
    UniversalBle.setNotifiable(widget.device.deviceId, serviceUUID, characteristicUUID, BleInputProperty.disabled);

    UniversalBle.disconnect(widget.device.deviceId);
    super.dispose();
  }

  double _bytesToFloat(List<int> bytes) {
    final buffer = Uint8List.fromList(bytes).buffer;
    return ByteData.view(buffer).getFloat32(0, Endian.little);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name ?? widget.device.deviceId),
        actions: [
          IconButton(
              icon: Text(useCelcius ? "°C" : "°F"),
              onPressed: () => setState(() {
                    useCelcius = !useCelcius;
                  }))
        ],
      ),
      body: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            _getTemperature(temperature),
            style: const TextStyle(fontSize: 1000),
          )),
    );
  }

  String _getTemperature(double value) {
    if (useCelcius) {
      return value.toStringAsFixed(2);
    } else {
      return (value * 1.8 + 32).toStringAsFixed(2);
    }
  }
}
