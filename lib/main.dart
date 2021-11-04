import 'dart:async';
import 'package:flutter/material.dart'; //Base
import 'package:location/location.dart'; //Locacion
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart' as hd;
import 'package:bluetooth_obd/bluetooth_obd.dart';
import 'package:flutter/services.dart';


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
  String _obdData="0";
  String obdMesg="";


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          new IconButton(onPressed: _pushBluetooth, icon: const Icon(Icons.list)),
        ],
      ),
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

            Text('$_obdData',style: TextStyle(fontSize:21),),
            Row(
              children: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {Conectar();},
                  child: Text('Conectar OBD2'),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {RPM();},
                  child: Text('Refrescar'),
                ),
              ],
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

    await RPM();

    String _Mensaje='${_locationData.time},${_locationData.latitude},${_locationData.longitude},$Carro,$_obdData,';
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

  void _pushBluetooth(){
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Bluetooth'),
            ),
            body: new Card(
              color: Colors.grey,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('$_obdData',style: TextStyle(fontSize:21),),
              ),
            ),
          );
        },
      ),
    );
  }
  var connection;
  Conectar() async{
    BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
    BluetoothDevice _device;
    List<BluetoothDevice> devices = [];


    if (await hd.Permission.bluetooth.request().isGranted) {
    }

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      return true;
    }

    try {
      print("Try to connected");

      devices = await bluetooth.getBondedDevices();
      print(devices.length);
      print(devices);
      for (int i=0;i<devices.length;i++){
        print(i);
        print(devices[i].name);
        if (devices[i].name=="OBDII"){
          _device=devices[i];
          BluetoothConnection connection = await BluetoothConnection.toAddress(_device.address);
          obdMesg = await BluetoothObd.startOBD;
          obdMesg="Conectado";
          }
        }
      }
    catch (exception) {
      print('Cannot connect, exception occured'+exception.toString());
    }
  }
  RPM() async {
    if(obdMesg=="Conectado"){
      String _obdEngineRpm = '';
      try {_obdEngineRpm = await BluetoothObd.getRPM;
        if(!_obdEngineRpm.contains("Speed")){_obdData = _obdEngineRpm;}
        else{_obdData ="0";}
      } on PlatformException {
      _obdEngineRpm = 'Failed to get Engine Rpm.';
      _obdData= 'Failed to get Engine Rpm.';
      }
      setState(() {});
    }
  }



}