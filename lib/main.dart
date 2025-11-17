import 'package:flutter/material.dart';
import 'ambil_gambar.dart';
import 'ambil_video.dart';
import 'profil.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Multimedia",
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.queue_music),
                  text: "Ambil Gambar",
                ),
                Tab(
                  icon: Icon(Icons.video_library),
                  text: "Ambil Video",
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: "Profil",
                ),
              ],
              indicatorColor: Colors.amber,
            ),
          ),
          body: Container(
            height: double.infinity,
            width: double.infinity,
            child: TabBarView(
              children: [
                AmbilGambar(),
                AmbilVideo(),
                Profile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
