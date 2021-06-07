import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_edit/cartoonize.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;


class Utils {
  // static Future loadModel() async{
  //   Tflite.close();
  //   print("Inside loadModel");
  //   try{
  //     String res;
  //     res = await Tflite.loadModel(
  //         model: "assets/whitebox_cartoon_gan_int8.tflite"
  //     );
  //     print(res);
  //   } on Exception {
  //     print('Failed to load model.');
  //   }
  // }

  static Future resizeImage(File cFile)async {
    img.Image im = img.decodeImage(File(cFile.path).readAsBytesSync());
    final rim = await img.copyResize(im,width: 400,height: 400);

    print(rim.height);
    Directory dir = await getTemporaryDirectory();
    // String ts = DateTime.now().millisecondsSinceEpoch;
    String rPath = '${dir.path}/image_resize_${DateTime.now().millisecondsSinceEpoch.toString()}.png';
    File(rPath).writeAsBytesSync(img.encodePng(rim));
    print(rPath);
    return rPath;
  }

  //
  // static Uint8List imageToByteListFloat32(
  //     img.Image image, int inputSize) {
  //   var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  //   var buffer = Float32List.view(convertedBytes.buffer);
  //   int pixelIndex = 0;
  //   for (var i = 0; i < inputSize; i++) {
  //     for (var j = 0; j < inputSize; j++) {
  //       var pixel = image.getPixel(j, i);
  //       // buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
  //       // buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
  //       // buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
  //       buffer[pixelIndex++] = (img.getRed(pixel)/ 127.5)-1;
  //       buffer[pixelIndex++] = (img.getGreen(pixel)/ 127.5)-1;
  //       buffer[pixelIndex++] = (img.getBlue(pixel)/ 127.5)-1;
  //     }
  //   }
  //   return convertedBytes.buffer.asUint8List();
  // }

  static Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    // print(buffer.length);
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    // print(convertedBytes.buffer.asUint8List());
    return convertedBytes.buffer.asUint8List();
  }
  static Uint8List imageToByteListFloat32(
      img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        // buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        // buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getRed(pixel)/1);
        buffer[pixelIndex++] = (img.getGreen(pixel)/1);
        buffer[pixelIndex++] = (img.getBlue(pixel)/1);
      }
    }
    // print(convertedBytes.buffer.asFloat32List());
    return convertedBytes.buffer.asUint8List();
  }

  // static Future cartoonize(String fName) async{
  //
  //   img.Image im = img.decodeImage(File(fName).readAsBytesSync());
  //   print(im.height);
  //   Future res = await loadModel();
  //
  //   print(fName);
  //
  //
  //   // var result = await Tflite.runPix2PixOnImage(
  //   //   path: fName,       // required
  //   //   imageMean: 0.0,       // defaults to 0.0
  //   //   imageStd: 255.0,      // defaults to 255.0
  //   //   asynch: true ,     // defaults to true
  //   //
  //   // );
  //   var result = await Tflite.runPix2PixOnBinary(
  //     binary: imageToByteListUint8(im,400),       // required
  //           // defaults to 0.0
  //           // defaults to 255.0
  //     outputType: 'jpg',
  //     asynch: true ,     // defaults to true
  //
  //   );
  //
  //   Tflite.close();
  //   print(result.length);
  //   return result;//.buffer.asUint64List();
  // }
  static Future<File> pickMedia({
    @required bool isGallery,
    Future<File> Function(File file) cropImage,
    bool toonify,
  }) async {
    final source = isGallery ? ImageSource.gallery : ImageSource.camera;
    final pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile == null) return null;

    if (cropImage == null) {
      return File(pickedFile.path);
    } else {
      final file = File(pickedFile.path);

      if(toonify == false){
        final cFile = await cropImage(file);
        return cFile;
      }
      // print(file.path);
      var nop = Platform.numberOfProcessors;
      if(nop>3){
        nop=2;
      }else{
        nop = 1;
      }
      print('Number of cores');
      print(nop);
      Cartoonize _cartoonize = await new Cartoonize(numThreads: nop);
      final cFile = await cropImage(file);
      
      img.Image im = img.decodeImage(File(cFile.path).readAsBytesSync());
      final ih = im.height;
      final iw = im.width;
      final rim = await img.copyResize(im,width: 400,height:400);
      // img.decodeImage(rim.getBytes());
      // print(rim.height);
      // Directory dir = await getTemporaryDirectory();
      // String ts = DateTime.now().millisecondsSinceEpoch;
      // String rPath = '${dir.path}/image_resize_${DateTime.now().millisecondsSinceEpoch.toString()}.png';
      // File(rPath).writeAsBytesSync(img.encodePng(rim));
      // print(rPath);
      // final rPath = await resizeImage(cFile);

      // final result = await cartoonize(rPath);
      //
      // img.Image ci = img.Image.fromBytes(400, 400,result,channels: img.Channels.rgb);
      // print(ci);
      // Directory dir = await getTemporaryDirectory();
      // // String ts = DateTime.now().millisecondsSinceEpoch;
      // String cPath = '${dir.path}/image_resize_${DateTime.now().millisecondsSinceEpoch.toString()}.png';
      // List<int> ll = img.encodeJpg(ci);
      // // File(cPath).writeAsBytesSync(img.encodeJpg(ci));
      // print(result);
      // print(result.runtimeType);
      //
      // print(result);
      // print(result.runtimeType);
      // // Image im = Image.file(file);
      // print(cFile.path);
      // print("Result printed");
      // return File(cPath);


      // await _cartoonize.cartoonize(img.decodeImage(cFile.readAsBytesSync()));
      await _cartoonize.cartoonize(rim);
      _cartoonize.close();
      var result = _cartoonize.output_img;
      print(result);
      print(result.length);
      print(result.runtimeType);
      print("Break");
      // var result = new List<int>.from(result1);
      img.Image ci = await img.Image.fromBytes(400,400,result,format: img.Format.rgb,channels: img.Channels.rgb);
      final h = ((ih/iw)*512).toInt();
      ci = await img.copyResize(ci,width: 512,height:h);
      print(ci.data.length);
      print(ci.width);
      print(ci.channels);
      print(ci.numberOfChannels);
      print(ci.index(223, 223));
      print(ci.getPixel(500, 110));
      Directory dir = await getTemporaryDirectory();
      // String ts = DateTime.now().millisecondsSinceEpoch;
      String cPath = '${dir.path}/image_resize_${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
      List<int> ll = await img.encodeJpg(ci);
      print(ll.length);
      await File(cPath).writeAsBytesSync(ll);
      print(cPath);
      // return File(cFile.path);
      return File(cPath);



    }
  }


}
