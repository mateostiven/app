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
  bool TaxiSwitch = false;
  int Carro=1;
  Timer Bucle =Timer.periodic(Duration(seconds: 1000000), (Timer t) => null);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), ),
      body: cuerpo(), );
  }

  Widget cuerpo(){

    return Row(
        children:[Column(
          children: [

            Text('Taxi',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 30.0)
              ),

            Row(
              children: [
                Text('Taxi 1'),
                Switch(
                value: TaxiSwitch,
                onChanged: (value) {
                  setState(() {
                    TaxiSwitch = value;
                    if (value) {
                      Carro=2;
                    }
                    else {Carro=1;}
                  });
                },

                activeTrackColor: Colors.redAccent,
                activeColor: Colors.red,
                inactiveTrackColor: Colors.yellowAccent,
                inactiveThumbColor: Colors.yellow,

              ),
                Text('Taxi 2'),
              ],
            ),
            SizedBox(height: 30),
            Text('Activar',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 30.0)
            ),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                  print (value);
                  if (value == true ) {
                    _sendLocation();
                    Bucle.cancel ();
                    Bucle= Timer.periodic(Duration(seconds: 5), (Timer t) => _sendLocation());
                  }
                  else {Bucle.cancel();}

                });
              },

              activeTrackColor: Colors.lightBlueAccent,
              activeColor: Colors.blue,
            ),

          ],
          mainAxisAlignment: MainAxisAlignment.center,

        ),
      ],mainAxisAlignment: MainAxisAlignment.center,
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

    String _Mensaje='${_locationData.time},${_locationData.latitude},${_locationData.longitude},$Carro,';
    print(_Mensaje);

    _UDP(_Mensaje,'taxigps.hopto.org'); //Marcos
    _UDP(_Mensaje,'taxigpsproject.ddnsking.com'); //Mateo
    _UDP(_Mensaje,'taxiservi.sytes.net'); //Mauricio
    _UDP(_Mensaje,'proyectotaxi.sytes.net'); //Camilo
    _UDP(_Mensaje,'taxigpsproject.ddns.net'); //Moises

  }

  _UDP(_Mensaje, IP) async{
    final IP2=await InternetAddress.lookup(IP);
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((RawDatagramSocket udpSocket){
      udpSocket.send(utf8.encode(_Mensaje),IP2.first,8050);
    });
  }

}