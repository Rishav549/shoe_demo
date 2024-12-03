import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shoe_demo/model/data.dart';
import 'package:shoe_demo/utils/helper.dart';
import 'package:shoe_demo/utils/logger.dart';
import 'package:torch_flashlight/torch_flashlight.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StreamController<ManufacturingData> _dataController =
      StreamController<ManufacturingData>();
  final StreamController<ManufacturingData> _dataController1 =
      StreamController<ManufacturingData>();
  final List<ManufacturingData> _dataList = [];
  final List<ManufacturingData> _dataList1 = [];
  List<ManufacturingData> _displayData = [];
  List<ManufacturingData> _displayData1 = [];
  static const int _batchSize = 8;
  int rightBatteryPercentage = 0;
  final FlutterRingtonePlayer ringtonePlayer = FlutterRingtonePlayer();
  int check =0;
  int check1 =0;

  @override
  void initState() {
    super.initState();
    foregroundServices();
    checkBluetoothState();
  }

  void foregroundServices() async{
    ForegroundService().start();
  }
  void checkBluetoothState() async {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        FlutterBluePlus.turnOn();
      } else {
        scanForDevices();
      }
    });
  }

  void scanForDevices() {
    CustomLogger.info("Entered In ScanMode");
    FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (ScanResult r in results) {
          if (r.device.remoteId.toString() == "C1:17:50:F1:C2:19" || r.device.remoteId.toString() == "E0:6B:92:DE:0D:3A") {//
            CustomLogger.info("Device Found");
            final deviceData = {
              'device': r.device,
              'advertisementData': formatAdvertisementData(r.advertisementData),
            };
            if (r.device.remoteId.toString() == "E0:6B:92:DE:0D:3A") {
              final lData = parseManufacturingData(
                  formatAdvertisementData(r.advertisementData))!;
              if (lData.lBT == 1) {
                TorchFlashlight.enableTorchFlashlight();
              } else if (lData.lBT == 0) {
                TorchFlashlight.disableTorchFlashlight();
              }
              _dataController.add((lData));
              CustomLogger.info(lData);
              CustomLogger.debug(deviceData);
              _dataList.add(lData);
            }else if(r.device.remoteId.toString() == "C1:17:50:F1:C2:19"){
              final rData = parseManufacturingData(
                  formatAdvertisementData(r.advertisementData))!;
              if(check != rData.lBT) {
                if (rData.lBT == 1) {
                  setState(() {
                    check = 1;
                  });
                  ringtonePlayer.playNotification();
                } else if (rData.lBT == 0) {
                  setState(() {
                    check = 0;
                  });
                  ringtonePlayer.stop();
                }
              }
              if(check1 != rData.lFT) {
                if (rData.lFT == 1) {
                  setState(() {
                    check1 = 1;
                  });
                  ringtonePlayer.play(
                    fromAsset: "asset/audio/notification-1-269296.mp3"
                  );
                } else if (rData.lFT == 0) {
                  setState(() {
                    check1 = 0;
                  });
                  ringtonePlayer.stop();
                }
              }
              _dataController1.add((rData));
              CustomLogger.info(rData);
              CustomLogger.debug(deviceData);
              _dataList1.add(rData);
              setState(() {
                rightBatteryPercentage = batteryPercentage(rData.batteryValue)!;
              });
            }
            if (_dataList.length <= _batchSize) {
              _displayData = List.from(_dataList);
            } else {
              _displayData = _dataList.sublist(_dataList.length - _batchSize);
            }

            if (_dataList1.length <= _batchSize) {
              _displayData1 = List.from(_dataList1);
            } else {
              _displayData1 = _dataList1.sublist(_dataList1.length - _batchSize);
            }
            setState(() {});
          }
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Center(
              child: Text(
            "Smart Shoe",
            style: TextStyle(color: Colors.white),
          )),
        ),
        body: StreamBuilder<ManufacturingData>(
          stream: _dataController.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              Fluttertoast.showToast(msg: "Turn On the Shoe Device");
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text("${batteryPercentage(data.batteryValue)}%"),
                          const Icon(Icons.battery_6_bar_rounded),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.battery_6_bar_rounded),
                          Text("$rightBatteryPercentage%"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 200),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${data.stepCount}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Table(
                          border: TableBorder.all(color: Colors.black, width: 1),
                          children: [
                            const TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("lLBT",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("lLFT",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            ..._displayData.map((data) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${data.lBT}"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${data.lFT}"),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Table(
                          border: TableBorder.all(color: Colors.black, width: 1),
                          children: [
                            const TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("rLBT",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("rLFT",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            ..._displayData1.map((data) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${data.lBT}"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${data.lFT}"),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ));
  }
}
