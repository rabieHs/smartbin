import 'package:flutter/material.dart';
import 'package:smart_bin/views/bins.dart';
import 'package:smart_bin/views/favourites.dart';
import 'package:smart_bin/views/map.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> screens = [Maps(), Trashes(), Favourites()];
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: "Trashes"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favourites"),
        ],
        currentIndex: index,
        onTap: (int i) {
          setState(() {
            index = i;
          });
        },
      ),
    );
  }
}
