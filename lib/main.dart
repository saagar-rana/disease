import 'dart:ffi';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ClassificationModel? _imageModel;
  final ImagePicker _picker = ImagePicker();
  String? _imagePrediction;
  double? _imageNum;
  List<String> diseases= ['bacterial_leaf_blight',
'brown_spot',
'healthy',
'leaf_blast',
'leaf_scald',
'narrow_brown_spot',
'neck_blast',
'rice_hispa',
'sheath_blight',
'tungro'];

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
      print('done');
    } on PlatformException {
      print("only supported for android");
    }
  }

  // Future getClassify() async {
  //   // Load the image as bytes (example from assets)
  //   ByteData byteData =
  //       await rootBundle.load(r'assets\images\narrow_brown (16).jpg');
  //   Uint8List imageBytes = byteData.buffer.asUint8List();

  //   // Uint8List preprocessedImage = await preprocess(imageBytes);
  //   // Assuming _imageModel is your loaded PyTorch model
  //   String? result;
  //   try {
  //     // Call the getImagePrediction method
  //     result = await _imageModel!.getImagePrediction(
  //       imageBytes,
  //     );
  //     print("Prediction Result: ${imageBytes.length}");
  //   } catch (e) {
  //     print("Error during image prediction: $e");
  //   }

  //   setState(() {
  //     _imagePrediction = result;
  //   });
  // }

  Future pickerClassify() async{

    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    var result = await _imageModel!.getImagePrediction(
        await File(image!.path).readAsBytes(),
      );

  
    var index = diseases.indexOf(result.trim());
      

    var probability = await _imageModel!.getImagePredictionListProbabilities( await File(image.path).readAsBytes());

    var num = probability[index]*100;

       
          
    setState(() {
      _imagePrediction = result;
      _imageNum = num;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
  
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Prediction:',
            ),
            Text(
              '$_imagePrediction /n $_imageNum',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickerClassify,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
