import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../models/band.dart';
import '../services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    //Band(id: '1', name: 'Metalica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 1),
    //Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    // Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];

  @override
  void initState() {
    //´pr que no quiero redibujar nada al inicio
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on("active-bands", _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List)
        //luego usamos el from Map generado de Quytype
        .map((band) => Band.fromMap(band))
        // y necesariamente necesitamos convertirlo a una lista
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off("active-bands");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BandNames",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.blue[300],
                    )
                  : Icon(
                      Icons.offline_bolt,
                      color: Colors.red,
                    ))
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (BuildContext context, int index) =>
                    _bandTile(bands[index])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      //bloquear la direccion hacia un lado
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        print("direcction: $direction");
        print("id: ${band.id}");
        //TODO llamar el borrado en el server
        //delete-band
        //{"id":band.id}
        socketService.emit("delete-band", {"id": band.id});
      },
      //color atras de lo q va elminando a loq  se mueve
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Delete Band",
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit("vote-band", {"id": band.id});
        },
      ),
    );
  }

  addNewBand() {
    // para obtener el texto del textFiled
    final textController = new TextEditingController();

    //para usar en android o ios
    if (Platform.isAndroid) {
      return showDialog(
        context:
            context, //puedo mandar directamente el context por que ya viene en la clase
        builder: (context) {
          return AlertDialog(
            title: Text("New band name: "),
            content: TextField(
              controller: textController,
              autofocus: true,
            ),
            actions: [
              MaterialButton(
                child: Text("Add"),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () {
                  addBandToList(textController.text);
                },
              )
            ],
          );
        },
      );
    }

    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("New band name"),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true, //para presionar enter se dispere
                child: Text("Add"),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("Dismiss"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      //podemos agregar
      //emitir "add-band"
      //{name:name}
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit("add-band", {"name": name});
    }
    Navigator.pop(
        context); //para cerrar el cuadro de dialogo, le saco del context
  }

  //Mostrar grafica

  Widget _showGraph() {
  Map<String, double> dataMap ={};
  bands.forEach((band) {
    dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
  },);
  final List<Color>colorList =[
    Colors.blue,
    Colors.red,
    Colors.black,
    Colors.pink,
    Colors.amber

  ];
    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(  dataMap: dataMap.isEmpty? {'No hay datos':0} : 
      dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      centerText: "Bandas",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 0,
      ),
      // gradientList: ---To add gradient colors---
      // emptyColorGradient: ---Empty Color gradient---
    ) 
      ) ;
  }
}
