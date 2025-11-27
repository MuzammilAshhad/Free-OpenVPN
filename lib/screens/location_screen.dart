import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _controller = LocationController();
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Obx(
          () => Scaffold(
            backgroundColor: Pref.isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Pref.isDarkMode ? Colors.black : Colors.white,
          title: Text(
            'Select Server Location',
            style: TextStyle(
                color: Pref.isDarkMode ? Colors.white : Colors.black),
          ),
          leading: IconButton(
            icon: Icon(CupertinoIcons.back, size: 35,color: Pref.isDarkMode ? Colors.white : Colors.black,),
            onPressed: Navigator.of(context).pop,
          ),
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // SEARCH BAR
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: TextField(
            //     decoration: InputDecoration(
            //       hintText: "Search",
            //       filled: true,
            //       fillColor: Colors.grey.shade200,
            //       prefixIcon: Icon(Icons.search, color: Colors.grey),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide.none,
            //       ),
            //     ),
            //   ),
            // ),

            SizedBox(height: 10),

            // FREE SERVERS TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text("FREE ",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text("SERVERS",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),

            SizedBox(height: 10),

            // MAIN LIST
            Expanded(
              child: _controller.isLoading.value
                  ? _loadingWidget()
                  : _controller.vpnList.isEmpty
                  ? _noVPNFound()
                  : _vpnData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vpnData() => ListView.builder(
    itemCount: _controller.vpnList.length,
    physics: BouncingScrollPhysics(),
    padding: EdgeInsets.only(
      bottom: mq.height * .05,
    ),
    itemBuilder: (ctx, i) => VpnCard(vpn: _controller.vpnList[i]),
  );

  Widget _loadingWidget() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieBuilder.asset('assets/lottie/loading.json',
            width: mq.width * .6),
        SizedBox(height: 10),
        Text(
          'Loading VPNs...',
          style: TextStyle(
              fontSize: 17,
              color: Colors.black54,
              fontWeight: FontWeight.bold),
        )
      ],
    ),
  );

  Widget _noVPNFound() => Center(
    child: Text(
      'VPNs Not Found!',
      style: TextStyle(
          fontSize: 17, color: Colors.black54, fontWeight: FontWeight.bold),
    ),
  );
}
