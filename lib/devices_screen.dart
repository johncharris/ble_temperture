import 'package:ble_temperture/device_screen.dart';
import 'package:ble_temperture/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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

      UniversalBle.onQueueUpdate = (queueUpdate, bleDevice) {
        addMessage(bleDevice.toString());
        addMessage(queueUpdate.toString());
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
    var bluetoothPermission = await Permission.bluetooth.request();

    addMessage("Bluetooth Permission: $bluetoothPermission");
    addMessage("Has Permission: $hasPermission");
    if (hasPermission) {
      await UniversalBle.stopScan();
      addMessage("Starting Scan");
      await UniversalBle.startScan();
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
          actions: [IconButton(onPressed: () => startScan(), icon: const Icon(Icons.refresh))],
        ),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    title: Text(device.name ?? device.deviceId),
                    onTap: () async {
                      await UniversalBle.stopScan();
                      if (!context.mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DeviceScreen(device: device)));
                    },
                  );
                }),
          ),
          FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) => Container(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                        color: Colors.white.withAlpha(128),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Version: ${snapshot.data?.version ?? ""}"),
                        )),
                  ))
        ]));
  }
}
