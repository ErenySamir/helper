import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService {
  static Future<bool> hasNetworkAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<void> checkConnectivity(BuildContext context, Function(bool) onConnectivityChanged) async {
    await _updateConnectionStatus(context, onConnectivityChanged);
    Connectivity().onConnectivityChanged.listen((result) async {
      await _updateConnectionStatus(context, onConnectivityChanged);
    });
  }

  static Future<void> _updateConnectionStatus(BuildContext context, Function(bool) onConnectivityChanged) async {
    bool isConnected = await hasNetworkAccess();
    onConnectivityChanged(isConnected);

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("لا يوجد اتصال بالإنترنت".tr),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}