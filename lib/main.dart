import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_edit/page/custom_page.dart';
import 'package:image_edit/page/toonify.dart';
import 'package:image_edit/page/square_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Image Edit';

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: ThemeData(
      primaryColor: Colors.black,
      accentColor: Colors.red,
    ),
    home: HomePage(),
  );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;
  bool isGallery = true;
  int index = 1;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(MyApp.title),
      centerTitle: false,
      actions: [
        Row(
          children: [
            Text(
              isGallery ? 'Gallery' : 'Camera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Switch(
              value: isGallery,
              onChanged: (value) => setState(() => isGallery = value),
            ),
          ],
        ),
      ],
    ),
    body: Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: controller,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'Images'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: [
              IndexedStack(
                index: index,
                children: [
                  CustomPage(isGallery: isGallery),
                  ToonifyPage(isGallery: isGallery),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: buildBottomBar(),
  );

  Widget buildBottomBar() {
    final style = TextStyle(color: Theme.of(context).accentColor);

    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: index,
      items: [
        BottomNavigationBarItem(
          icon: Text('Cropper', style: style),
          title: Text('Crop'),
        ),
        BottomNavigationBarItem(
          icon: Text('Filter', style: style),
          title: Text('Toonify'),
        ),
      ],
      onTap: (int index) => setState(() => this.index = index),
    );
  }
}
