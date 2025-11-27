import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/config.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/watch_ad_dialog.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      backgroundColor: Pref.isDarkMode ? Colors.black : Colors.white,
      //app bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Pref.isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: Pref.isDarkMode ? Colors.white : Colors.black),
        title: Text('Free VPN',style: TextStyle(color: /*Pref.isDarkMode ? Colors.black : */Colors.lightBlueAccent),),
        actions: [
          IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: () => Get.to(() => NetworkTestScreen()),
              icon: Icon(
                CupertinoIcons.settings,
                size: 27,
                // color: Pref.isDarkMode ? Colors.black : Colors.blueAccent,
              )),
        ],
      ),

      drawer: Drawer(
        backgroundColor: Pref.isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            DrawerHeader(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("Free",style: TextStyle(color: Colors.lightBlueAccent,fontSize: 25),),
                        Text('VPN',style: TextStyle(fontSize: 25),),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          //ad dialog
                          if (Config.hideAds) {
                            Get.changeThemeMode(
                                Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                            Pref.isDarkMode = !Pref.isDarkMode;
                            return;
                          }

                          Get.dialog(WatchAdDialog(onComplete: () {
                            //watch ad to gain reward
                            AdHelper.showRewardedAd(onComplete: () {
                              Get.changeThemeMode(
                                  Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                              Pref.isDarkMode = !Pref.isDarkMode;
                            });
                          }));
                        },
                        icon: Icon(
                          Icons.brightness_medium,
                          size: 35,
                        )),
                  ],
                ),
            ),


            //Drawer items
            ListTile(
              leading: Icon(Icons.home,size: 35,color: Colors.lightBlueAccent,),
              title: Text("Home"),
              onTap: Navigator.of(context).pop,
            ),

            ListTile(
              leading: Icon(Icons.info_outline,size: 35,color: Colors.lightBlueAccent,),
              title: Text('About'),
              onTap: (){},
            ),

          ],
        ),

      ),

      //body
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

        // change location
        Obx(()=>_changeLocation(context)),

        //vpn button
        Obx(() => _vpnButton()),


        StreamBuilder<VpnStatus?>(
            initialData: VpnStatus(),
            stream: VpnEngine.vpnStatusSnapshot(),
            builder: (context, snapshot) => Container(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .01,vertical: mq.height * .012),
              margin: EdgeInsets.symmetric(horizontal: mq.width * .04,vertical: mq.height * .04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),bottom: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),left: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),right: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      //Download
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.download,color: Colors.lightGreenAccent,size: 25,),
                            Column(
                              children: [
                                Text('Download'),
                                Text('${snapshot.data?.byteIn ?? '0 kbps'}'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 35,
                        width: 2,
                        child: Container(
                          color: Colors.grey,
                        ),
                      ),


                      //Upload
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.upload,color: Colors.yellow,size: 25,),
                            Column(
                              children: [
                                Text('Upload'),
                                Text('${snapshot.data?.byteIn ?? '0 kbps'}'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 35,
                        width: 2,
                        child: Container(
                          color: Colors.grey,
                        ),
                      ),

                      //Ping
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.equalizer_rounded,color: Colors.greenAccent,size: 30,),
                            Column(
                              children: [
                                Text('Ping'),
                                Text('${snapshot.data?.byteIn ?? '0 kbps'}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ))
      ]),
    );
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: InkWell(
              onTap: () {
                _controller.connectToVpn();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.1)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    width: mq.height * .14,
                    height: mq.height * .14,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        Icon(
                          Icons.power_settings_new,
                          size: 28,
                          color: Colors.white,
                        ),

                        SizedBox(height: 4),

                        //text
                        Text(
                          _controller.getButtonText,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10,),

          //count down timer
          Obx(() => CountDownTimer(
              startTimer:
                  _controller.vpnState.value == VpnEngine.vpnConnected)),
        ],
      );

  //bottom nav to change location
  Widget _changeLocation(BuildContext context) => SafeArea(
          child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
              // color: Colors.transparent/*Theme.of(context).bottomNav*/,
              padding: EdgeInsets.symmetric(horizontal: mq.width * .03),
              margin: EdgeInsets.symmetric(horizontal: mq.width * .04,vertical: mq.height * 0.03),
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),bottom: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),left: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),right: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  )
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //icon
                  CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                        child: _controller.vpn.value.countryLong.isEmpty
                            ? Icon(Icons.vpn_lock_rounded,
                            size: 20, color: Colors.white)
                            : null,
                            backgroundImage: _controller.vpn.value.countryLong.isEmpty
                            ? null
                            : AssetImage(
                            'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
                  ),

                  //for adding some space
                  SizedBox(width: 20),


                  //left side
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300),
                          ),
                          Icon(Icons.location_on_outlined,size: 20,)
                        ],
                      ),
                      Text(_controller.vpn.value.countryLong.isEmpty
                          ? 'Country'
                          : _controller.vpn.value.countryLong,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300
                          )
                      ),
                    ],
                  ),
                  //text

                  //
                  Spacer(),

                  SizedBox(
                    height: 35,
                    width: 3,
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),

                  Spacer(),

                  //right side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _controller.vpnState.value == VpnEngine.vpnDisconnected
                        ? Icons.shield_outlined
                        : Icons.shield_rounded,

                        color: _controller.vpnState.value == VpnEngine.vpnDisconnected
                        ? Pref.isDarkMode ? Colors.white : Colors.black
                        : Colors.green,
                      ),

                      SizedBox(
                        width: 2,
                      ),

                      //connection status label
                      Text(
                        _controller.vpnState.value == VpnEngine.vpnDisconnected
                            ? 'Not Connected'
                            : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),

                  //for covering available spacing
                  Spacer(),


                  //Icon
                  Icon(Icons.keyboard_arrow_right_rounded,size: 40,color: Colors.lightBlueAccent,),
                ],
              )),
        ),
      ));
}
