import 'dart:async';
import 'package:flutter/material.dart'; //Base
import 'package:location/location.dart'; //Locacion
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart'; //cambio de formato

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Envio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'GPS Taxi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  bool isSwitched = false;
  Timer Bucle =Timer.periodic(Duration(seconds: 1000000), (Timer t) => null);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), ),
      body: cuerpo(), );
  }

  Widget cuerpo(){
    return Center(
      child: Switch(
        value: isSwitched,
        onChanged: (value) {
          setState(() {
            isSwitched = value;
            print (value);
            if (value == true ) {
              _sendLocation();
              Bucle.cancel ();
              Bucle= Timer.periodic(Duration(seconds: 10), (Timer t) => _sendLocation());
            }
            else {Bucle.cancel();}

          });
        },

        activeTrackColor: Colors.lightBlueAccent,
        activeColor: Colors.blue,
      ),
    );
  }


  _sendLocation() async{

    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    DateTime now = new DateTime.now();

    String _Mensaje='${_locationData.time},${_locationData.latitude},${_locationData.longitude}';
    //print(_Mensaje);
    _UDP(_Mensaje);

  }

  _UDP(_Mensaje) async{
    final IP=await InternetAddress.lookup('taxigps.hopto.org');
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((RawDatagramSocket udpSocket){
      udpSocket.send(utf8.encode(_Mensaje),(IP.first),8050);});
  }

}