import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/band.dart';


class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metalica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 1),
    Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BandNames",style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) => _bandTile(bands[index])    
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
        elevation: 1,
      ),
   );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      //bloquear la direccion hacia un lado
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        print("direcction: $direction");
        print("id: ${band.id}");
        //TODO llamar el borrado en el server
      },
      //color atras de lo q va elminando a loq  se mueve
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Delete Band",style: TextStyle(color:Colors.white),)
          ),
      ),
      child: ListTile(
            leading: CircleAvatar(
              child: Text(band.name.substring(0,2)),
              backgroundColor: Colors.blue[100],
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}',style: TextStyle(fontSize: 20),),
            onTap: () {
                print(band.name);
            },
          ),
    );
  }

  addNewBand(){
    // para obtener el texto del textFiled
    final textController = new TextEditingController(); 

    //para usar en android o ios
    if(Platform.isAndroid){
    return  showDialog(
     context: context, //puedo mandar directamente el context por que ya viene en la clase
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
          ) ;
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
      }
    );
  }

  void addBandToList(String name){
    if(name.length >1){
      //podemos agregar
      this.bands.add(new Band(
        id: DateTime.now().toString(),
        name: name,
        votes: 0
      ));
      setState(() {
        
      });
    }
    Navigator.pop(context);//para cerrar el cuadro de dialogo, le saco del context

  }


}