import 'package:flutter/material.dart';

//import socket
import 'package:socket_io_client/socket_io_client.dart' as IO;

//enumeracion para manejar los estados del servidor

enum ServerStatus{
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier{
  
  //la priemra ves por que intento coenctarme
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus =>_serverStatus;
  IO.Socket get socket =>_socket;

  //solo por referencia para una funcion emit
  Function get emit => _socket.emit;

  //Constructor
  SocketService(){
      _initConfig();
  }

  void _initConfig(){
     // Dart client , si no se coencta con localhost utilizar la direccion ip de la maquina
    _socket = IO.io('http://192.168.10.143:3000/',{
      'transports':['websocket'],
      'autoConnect':true
    });
    _socket.onConnect((_) {
      _serverStatus=ServerStatus.Online;
      notifyListeners();
    });
    _socket.onDisconnect((_) {
       _serverStatus=ServerStatus.Offline;
      notifyListeners();
    });

    //recibir o escuchando un mensaje, dejar el payload como dinamico
    /*socket.on('nuevo-mensaje',(payload){
      print('nuevo-mensaje: ');
      print("nombre: "+payload['nombre']);
      print("mensaje: "+payload['mensaje']);
      print(payload.containsKey("mensaje2") ? payload["mensaje2"]:"no hay");
    });*/

    //emitir un mensaje 


    

  }





}