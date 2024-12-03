part of 'bluetooth_scan_bloc.dart';

abstract class BluetoothScanState {}

class BluetoothScanInitialState extends BluetoothScanState {}

class BluetoothScanLoadingState extends BluetoothScanState {}

class BluetoothScanLoadedState extends BluetoothScanState {
  final BluetoothDevice device;

  BluetoothScanLoadedState({required this.device});
}

class BluetoothScanErrorState extends BluetoothScanState {
  final ErrorModel error;

  BluetoothScanErrorState({required this.error});
}
