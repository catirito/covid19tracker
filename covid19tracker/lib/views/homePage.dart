import 'dart:convert';
import 'dart:io';

import './panels/mostAffectedCountries.dart';
import './panels/worldPanel.dart';
import './panels/chartPanel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_admob/firebase_admob.dart';

import 'countryPage.dart';

const String androidTestDevice = '0ad92dc4cc3d5262'; 

String getAppId() {
  if (Platform.isIOS) {
    return '--';
  } else {
    return '--';
  }

}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return '--';
  } else {
    return '--';
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: <String>[androidTestDevice],
    keywords: <String>['health', 'covid', 'people', 'medic', 'doctor', 'healthy'],
    //contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  Map worldData;
  fetchWorldWideData() async {
    http.Response response = await http.get('https://corona.lmao.ninja/v2/all');
    setState(() {
      if(response.statusCode == 200 ) {
        worldData = json.decode(response.body);
      }
    });
  }

  List<double> historicalData;
  fetchHistoricalData() async {
    http.Response response = await http
        .get('https://corona.lmao.ninja/v2/historical/all?lastdays=all');
    setState(() {
      if(response.statusCode == 200 ) {
        var data = json.decode(response.body);

        var cases = data['cases'].map((a, b) => MapEntry(a, b));
        var deaths = data['deaths'].map((a, b) => MapEntry(a, b));
        var recovered = data['recovered'].map((a, b) => MapEntry(a, b));

        historicalData = [];
        cases.forEach((k, v) => {
              historicalData
                  .add((cases[k] - deaths[k] - recovered[k]).toDouble()),
            });
      }
    });
  }

  List countryData;
  fetchCountryData() async {
    http.Response response =
        await http.get('https://corona.lmao.ninja/v2/countries?sort=active');
    setState(() {
      if(response.statusCode == 200 ) {
        countryData = json.decode(response.body);
        countryData.sort((a, b) => b['active'].compareTo(a['active']));
      }
    });
  }

  BannerAd _bannerAd;
  BannerAd createBannerAd() {
    
    return BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  Future _loadData() async {
    fetchWorldWideData();
    fetchCountryData();
    fetchHistoricalData();
  }

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: getAppId());
    _bannerAd = createBannerAd()..load();

    _loadData();

    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bannerAd..show();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Covid-19 Tracker",
          style: Theme.of(context).textTheme.title,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
              child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'World status',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CountryPage(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).textTheme.body1.color,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Countries',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              worldData == null
                  ? CircularProgressIndicator()
                  : WorldPanel(worldData: worldData),
              historicalData == null
                  ? CircularProgressIndicator()
                  : ChartPanel(historicalData: historicalData),
              Text(
                'Most affected countries',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              countryData == null
                  ? CircularProgressIndicator()
                  : MostAffectedPanel(countryData: countryData),
                  
              // RaisedButton(
              //     child: const Text('SHOW BANNER'),
              //     onPressed: () {
              //       _bannerAd ??= createBannerAd();
              //       _bannerAd
              //         ..load()
              //         ..show();
              //     }),
            ],
          ),
        ),
      ),
    );
  }
}
