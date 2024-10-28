import 'package:ble_temperture/device_screen.dart';
import 'package:ble_temperture/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<BleDevice> devices = [];

  String message = "";

  @override
  void initState() {
    try {
      UniversalBle.onScanResult = (bleDevice) {
        addMessage(bleDevice.toString());
        setState(() {
          var index = devices.indexWhere((element) => element.deviceId == bleDevice.deviceId);
          if (index != -1) {
            devices[index] = bleDevice;
          } else {
            devices.add(bleDevice);
          }
        });
      };

      // UniversalBle.startScan();
      startScan();
    } catch (e) {
      setState(() => message += "\n$e");
    }
    super.initState();
  }

  startScan() async {
    bool hasPermission = await PermissionHandler.arePermissionsGranted();

    setState(() {
      message += "\n$hasPermission";
    });
    if (hasPermission) {
      addMessage("Starting Scan");
      UniversalBle.startScan();
    }
  }

  addMessage(String message) {
    setState(() {
      this.message += "\n$message";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select Device"),
        ),
        body: Column(children: [
          SizedBox(
            height: 300,
            child: Text(message),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    title: Text(device.name ?? device.deviceId),
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DeviceScreen(device: device))),
                  );
                }),
          )
        ]));
  }
}
