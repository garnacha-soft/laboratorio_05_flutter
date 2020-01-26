import 'package:flutter/material.dart';
//import 'package:lab_02/routes/DetailPetPage.dart';
import '../pages/PetsList.dart';//importamos PetsList

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PetsList(),//lista de amigos
    );
  }
}