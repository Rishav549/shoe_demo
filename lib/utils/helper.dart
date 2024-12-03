import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../model/data.dart';
import 'logger.dart';

String formatAdvertisementData(AdvertisementData data) {
  String manufacturerDataStr = 'N/A';
  if (data.manufacturerData.isNotEmpty) {
    try {
      var manufacturerBytes = data.manufacturerData.values.first;
      manufacturerDataStr =
          utf8.decode(manufacturerBytes, allowMalformed: true);
    } catch (e) {
      manufacturerDataStr = 'Invalid UTF-8 data';
    }
  }
  return manufacturerDataStr;
}

ManufacturingData? parseManufacturingData(String rawData) {
  try {
    final parts = rawData.split(',');
    if (parts.length < 5) {
      throw Exception('Invalid data format. Not enough parts.');
    }
    final stepCount = int.parse(parts[1]);
    final lbt = int.parse(parts[2]);
    final lft = int.parse(parts[3]);
    final sos = int.parse(parts[4]);
    final batteryValue = int.parse(parts[5]);
    return ManufacturingData(
      stepCount: stepCount,
      lBT: lbt,
      lFT: lft,
      sos: sos,
      batteryValue: batteryValue,
    );
  } catch (e) {
    CustomLogger.error('Failed to parse manufacturing data: $e');
    return null;
  }
}

int? batteryPercentage(int batteryValue) {
  double percentage = (batteryValue / 4200) * 100;
  return percentage.round();
}
