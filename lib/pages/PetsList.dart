import 'package:flutter/material.dart';//material
import '../models_api/Pet.dart';//clase Pet
import '../routes/DetailPetPage.dart';//clase Detail Pet

import 'dart:convert';//dependencia para json
import 'package:http/http.dart' as http;//http

import '../models_sqlite/Fav.dart';
import '../models_sqlite/FavHelper.dart';

import 'package:toast/toast.dart';

import 'package:temp_05_x/observers.dart';

class PetsList extends StatefulWidget{
  @override
  createState() => PetsListState();
}

class PetsListState extends State<PetsList> implements StateListener{
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =  GlobalKey<RefreshIndicatorState>();

  final dbHelper = FavHelper();
  //creamos una variable para guardar una lista de amigos
  List<Pet> _pets = List<Pet>();

  PetsListState(){
    var stateProvider = new StateProvider();
    stateProvider.subscribe(this);
  }

  @override
  void initState() {
    super.initState();
    getPets();
  }

  // declaramos la funcion de tipo Future Null asincrona
  Future<Null> getPets() async {
    //consumimos el webservice con la librería http y get
    final response = await http.get('http://pets.memoadian.com/api/pets/');

    //si la respuesta es correcta responderá con 200
    if (response.statusCode == 200) {
      final result = json.decode(response.body);//guardamos la respuesta en json
      /* accedemos al array data que es el que nos interesa
       * y lo guardamos en una variable de tipo Iterable
       */
      Iterable list = result['data'];
      setState(() {//seteamos el estado para actualizar los cambios
        //mapeamos la lista en modelos Pet
        print(list.map((model) => Pet.fromJson(model)).toString());
        _pets = list.map((model) => Pet.fromJson(model)).toList();
      });
    } else {
      throw Exception('Fallo al cargar información del servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(//regresamos un Scaffold de contenedor
      body: RefreshIndicator(
        onRefresh: getPets,
        key: _refreshIndicatorKey,
        child: ListView.builder(//creamos un Listview Builder
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: _pets.length,//pasamos la longitud del array list
          itemBuilder: _buildItemsForListView,//llamamos la función que hará la iteración
        ),
      )
    );
  }

  /* 
   * la función _buildItemsForListView recibe 2 parámetros, el contexto
   * y la posición del item a mostrar para mostrar detalles
   * retornamos el Card que construimos en Home Page
  */ 
  Widget _buildItemsForListView(BuildContext context, int index) {
    return Card(//creamos una card
      margin: EdgeInsets.all(10.0),//margen de 10
      child: Column(//creamos una columna para colocar varios hijos
        children: <Widget>[//array
          Container (//contenedor de imagen
            padding: EdgeInsets.all(10.0),//padding
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment(0, 0),
                  child: CircularProgressIndicator()
                ),
                Container(
                  alignment: Alignment.center,
                  child: Image.network(_pets[index].image),
                ),
              ],
            ),//imagen interna
          ),
          Container (//contenedor de texto
            padding: EdgeInsets.all(10.0),//padding
            child: Text(_pets[index].name,//título
              style: TextStyle(fontSize: 18)//estilo del texto
            ),
          ),
          Container(//contenedor de botones
            child: Row(//row para alinear botones en fila
              //esta propiedad permite que los botones se
              //distribuyan equitativamente
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[//usamos un array de botones
                FlatButton.icon(//instancia del icono de navegación
                  icon: Icon(Icons.remove_red_eye,//definimos nombre del icono
                    size: 18.0,//tamaño
                    color: Colors.blue//color
                  ),
                  label: Text('Ver amigo'),//nombre del botón
                  onPressed: () {//evento press
                    Navigator.push(context,//mandamos el navegador
                      MaterialPageRoute(
                        builder: (context) => DetailPetPage(_pets[index].id),//a la página de detalle
                      ),
                    );
                  },
                ),
                FlatButton.icon(//instancia del icono de favoritos
                  icon: Icon(Icons.favorite,//definimos nombre del icono
                    size: 18.0,//tamaño
                    color: Colors.red//color
                  ),
                  label: Text('Me gusta'),//nombre del botón
                  onPressed: () {//evento press
                    _insert(_pets[index].name, _pets[index].age, _pets[index].image);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //insertar nuevo fav
  void _insert(String name, int age, String image) async {
    //llamamos el dbHelper para guardar el registro
    dbHelper.saveFav(new Fav(name, age.toString(), image)).then((_) {
      //cuando se termina lanzamos el toast
      Toast.show(
        'Amigo agregado a favoritos', 
        context,
        duration: Toast.LENGTH_SHORT,
        gravity:  Toast.BOTTOM);
    });
  }

  @override
  void onStateChanged(ObserverState state) {
    if (state == ObserverState.LIST_UPDATED) {
      getPets();
    }
  }
}