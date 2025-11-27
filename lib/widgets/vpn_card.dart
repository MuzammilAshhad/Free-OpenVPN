import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn.dart';
import '../services/vpn_engine.dart';

class VpnCard extends StatelessWidget {
  final Vpn vpn;

  const VpnCard({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
          () => Card(
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: mq.height * .01),
        child: InkWell(
          onTap: () async {
            controller.vpn.value = vpn;               // Update selected VPN
            Pref.vpn = vpn;

            // Show green tick for 1 sec
            await Future.delayed(Duration(milliseconds: 300));

            // Now connect VPN
            if (controller.vpnState.value == VpnEngine.vpnConnected) {
              VpnEngine.stopVpn();
              await Future.delayed(Duration(seconds: 2));
              controller.connectToVpn();
            } else {
              controller.connectToVpn();
            }

            Get.back();  // Close location screen
          },
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),

            // FLAG
            leading: Container(
              padding: EdgeInsets.all(.5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(5)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'assets/flags/${vpn.countryShort.toLowerCase()}.png',
                  height: 40,
                  width: mq.width * .15,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            title: Text(vpn.countryLong),

            subtitle: Row(
              children: [
                Icon(Icons.speed_rounded, color: Colors.blue, size: 20),
                SizedBox(width: 4),
                Text(
                  _formatBytes(vpn.speed, 1),
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),

            // TRAILING RADIO INDICATOR
            trailing: _buildSelector(controller),
          ),
        ),
      ),
    );
  }

  /// Circle Icon Logic (Perfect)
  Widget _buildSelector(HomeController controller) {
    final bool isSelected = controller.vpn.value == vpn;

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
        color: isSelected ? Colors.green : Colors.transparent,
      ),
      child: isSelected
          ? Icon(
        Icons.check,
        size: 16,
        color: Pref.isDarkMode ? Colors.black : Colors.white,
      )
          : Icon(
        Icons.circle,
        size: 20,
        color: Colors.transparent,
      ),
    );
  }

  /// SPEED FORMATTER
  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
