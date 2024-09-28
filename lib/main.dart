import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:pytorch_lite/pytorch_lite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ClassificationModel? _imageModel;
  String? _imagePrediction;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    String pathImageModel = "assets\\torchscript_edgenext_xx_small.pt";
    try {
      _imageModel = await PytorchLite.loadClassificationModel(
          pathImageModel, 224, 224,10,
          labelPath: "assets/labels_classification.txt");
      print('donme');
    } on PlatformException {
      print("only supported for android");
    }
  }

//   Future<Uint8List> preprocess(Uint8List imageBytes) async {
//   // Decode image
//   img.Image? image = img.decodeImage(imageBytes);

//   if (image == null) {
//     throw Exception("Unable to decode image");
//   }

//   // Step 1: Resize the image to (256, 256)
//   img.Image resizedImage = img.copyResize(image, width: 256, height: 256);
  
// print(resizedImage.length);

//   // Step 3: Normalize the image (optional, handled in model)
//   // Normalization with the given mean and std can be handled later in the model

//   // Step 4: Convert back to Uint8List
//   Uint8List processedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage));
  

//   return processedImageBytes;
// }

  Future getClassify() async {
    // Load the image as bytes (example from assets)
    ByteData byteData =
        await rootBundle.load(r'assets\images\narrow_brown (16).jpg');
    Uint8List imageBytes = byteData.buffer.asUint8List();

    // Uint8List preprocessedImage = await preprocess(imageBytes);
    // Assuming _imageModel is your loaded PyTorch model
    String? result;
    try {
      // Call the getImagePrediction method
      result = await _imageModel!.getImagePrediction(
        imageBytes,
      );
      print("Prediction Result: ${imageBytes.length}");
    } catch (e) {
      print("Error during image prediction: $e");
    }

    setState(() {
      _imagePrediction = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Prediction:',
            ),
            Text(
              '$_imagePrediction',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getClassify,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
