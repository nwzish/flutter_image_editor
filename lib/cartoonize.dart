import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Cartoonize{
  Interpreter interpreter;
  InterpreterOptions _interpreterOptions;

  List<int> _inputShape;
  List<int> _outputShape;

  List<int> output_img;

  TensorImage _inputImage;
  TensorBuffer _outputBuffer;

  TfLiteType _outputType = TfLiteType.float16;

  String get modelName => 'whitebox_cartoon_gan_fp16_400.tflite';

  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(-1, 1/127.5);

  var _outputProcessor;



  Cartoonize({int numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }

    loadModel();
    // loadLabels();
  }

  Future<void> loadModel() async {
    try {
      print("Load Model tried");
      interpreter =
      await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      print('Interpreter Created Successfully');

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _outputProcessor =
          TensorProcessorBuilder().add(postProcessNormalizeOp).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
        _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  processOutput(Float32List image) async {

    print(image.length);
    output_img = List<int>.filled(image.length, 0);
    for(var i=0;i<image.length;i++){
      var t =  ((image[i]+1)*127.5).toInt();
      if(t<0) t=0;
      if(t>255) t= 255;
      output_img[i] = t;
    }

    print(image);
    // print(convertedBytes.buffer.asUint8List());
    // var rr = image.buffer.asUint8List();
    // var rr32 = rr.buffer.asInt64List();
    // Image ii = Image.fromBytes(400, 400, rr32);

    print(output_img);
    // return rr;//.buffer.asInt32List();

  }

  cartoonize(Image image)async {

    if (interpreter == null) {
      throw StateError('Cannot run inference, Intrepreter is null');
    }
    final pres = DateTime.now().millisecondsSinceEpoch;
    _inputImage = await TensorImage.fromImage(image);
    _inputImage = await _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;

    print('Time to load image: $pre ms');

    final runs = DateTime.now().millisecondsSinceEpoch;
    await interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;

    print('Time to run inference: $run ms');

    print(_outputBuffer.buffer.asFloat32List());
    // print(_outputProcessor.process(_outputBuffer));
    await processOutput(_outputBuffer.buffer.asFloat32List());
  }

  void close() {
    if (interpreter != null) {
      interpreter.close();
    }
  }
}