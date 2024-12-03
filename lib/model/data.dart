class ManufacturingData {
  final int stepCount;
  final int lBT;
  final int lFT;
  final int sos;
  final int batteryValue;

  ManufacturingData({
    required this.stepCount,
    required this.lBT,
    required this.lFT,
    required this.sos,
    required this.batteryValue,
  });

  @override
  String toString() {
    return '''
Step Count: $stepCount
LBT: $lBT
LFT: $lFT
SOS: $sos
Battery Value: $batteryValue
''';
  }
}
