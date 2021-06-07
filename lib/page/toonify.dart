import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as Img;
import 'package:image_edit/utils.dart';
import 'package:image_edit/widget/floating_button.dart';
import 'package:image_edit/widget/image_list_widget.dart';
import 'package:image_edit/widget/staggered_image_list.dart';
import 'package:path_provider/path_provider.dart';

class ToonifyPage extends StatefulWidget {
  final bool isGallery;

  const ToonifyPage({
    Key key,
    @required this.isGallery,
  }) : super(key: key);

  @override
  _ToonifyPageState createState() => _ToonifyPageState();
}

class _ToonifyPageState extends State<ToonifyPage> {
  List<File> imageFiles = [];

  _ToonifyPageState(){
    LoadImages();
  }

  Future LoadImages() async{
    Directory directory = await getExternalStorageDirectory();
    final path = Directory('${directory.path}/image');
    if ((await path.exists())) {
      // print(path.path);
    } else {
      path.create();
      print(path.path);
    }
    await for (var entity in path.list(recursive: true, followLinks: false)) {
      List<String> ftypes = ['jpg','jpeg','png'];
      if(ftypes.contains(entity.path.split('.').last )){
        File img = File(entity.path);
        setState(() => imageFiles.add(img));
      }
      print(entity.path);
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        // body: ImageListWidget(imageFiles: imageFiles),
        body: StaggeredImageList(imageFiles: imageFiles),
        floatingActionButton: FloatingButtonWidget(onClicked: onClickedButton),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );

  Future onClickedButton() async {
    final file = await Utils.pickMedia(
      isGallery: widget.isGallery,
      cropImage: cropPredefinedImage,
      toonify: true
    );

    if (file == null) return;
    Directory directory = await getExternalStorageDirectory();
    // print(directory.path.toString());
    File mfile = await saveImageToDisk(file.path, directory);

    // print(mfile.path);
    setState(() => imageFiles.add(mfile));
  }

  Future<File> saveImageToDisk(String img_path,Directory directory) async{
    try{
      // print(path);
      // print("MImage");
      final path = Directory('${directory.path}/image');
      if ((await path.exists())) {
        // print(path.path);
      } else {
        path.create();
        // print(path.path);
      }
      File tempFile = File(img_path);
      // print(tempFile.path);
      Img.Image image = Img.decodeImage(tempFile.readAsBytesSync());
      // Img.Image mImage = Img.copyResize(image);
      // print("MImage");
      // print(image);

      String imgType = img_path.split('.').last;
      String mPath = '${path.path}/image_${DateTime.now()}.$imgType';
      // String mPath = '/data/user/0/com.nwzish.image_edit/image_${DateTime.now()}.$imgType';
      // print("M_Path");
      // print(mPath);
      File dFile = File(mPath);
      // print(dFile);
      if(imgType=='jpg' || imgType=='jpeg'){
        // tempFile = await tempFile.copy(mPath);
        dFile.writeAsBytesSync(Img.encodeJpg(image));
        // await dFile.writeAsString("Contents written from flutter");
      }else{
        // tempFile = await tempFile.copy(mPath);
        dFile.writeAsBytesSync(Img.encodePng(image));
        // await dFile.writeAsString("Contents written from flutter");
      }
      // print("Image Saved");
      // var directory2 = await Directory(directory.path.toString()).create(recursive: true);
      // print(directory2.path);

      return dFile;
    }catch(e){
      return null;
    }
  }

  Future<File> cropPredefinedImage(File imageFile) async =>
      await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
        ],
        androidUiSettings: androidUiSettingsLocked(),
        iosUiSettings: iosUiSettingsLocked(),
      );

  IOSUiSettings iosUiSettingsLocked() => IOSUiSettings(
        aspectRatioLockEnabled: false,
        resetAspectRatioEnabled: false,
      );

  AndroidUiSettings androidUiSettingsLocked() => AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.red,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      );
}
