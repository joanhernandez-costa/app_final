import 'package:app_final/widgets/CustomTableBuilder.dart';
import 'package:app_final/widgets/CustomTableStyle.dart';
import 'package:flutter/material.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  FavouritesScreenState createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.blue,
        child: Center(
          child: CustomTableBuilder(
            numberOfColumns: 3,
            horizontalSpacing: 10.0,
            verticalSpacing: 10.0,
            cellSize: const Size(100, 100),
            fixedSize: false,
            style: CustomTableStyle(
              backgroundColor: Colors.orange,
              borderRadius: 10,
              padding: const EdgeInsets.all(10),
              border: Border.all(color: Colors.orangeAccent, width: 5),
            ),
            itemCount: 15,
          ),
        ),
      )
    );
  }
}
