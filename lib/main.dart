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
      title: 'Sanjivani',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'संजीवनी'),
      debugShowCheckedModeBanner: false,
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
  List<String> diseases = [
    'Bacterial Leaf Blight',
    'Brown Spot',
    'Healthy',
    'Leaf Blast',
    'Leaf Scald',
    'Narrow Brown Spot',
    'Neck Blast',
    'Rice Hispa',
    'Sheath Blight',
    'Tungro'
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    String pathImageModel = "assets\\torchscript_edgenext_xx_small.pt";
    try {
      _imageModel = await PytorchLite.loadClassificationModel(
          pathImageModel, 224, 224, 10,
          labelPath: "assets/labels_classification.txt");
      print('done');
    } on PlatformException {
      print("only supported for android");
    }
  }

  Future pickerClassify(ImageSource type) async {
    final XFile? image = await _picker.pickImage(source: type);

    var result = await _imageModel!.getImagePrediction(
      await File(image!.path).readAsBytes(),
    );

    var index = diseases.indexOf(result.trim());

    var probability = await _imageModel!.getImagePredictionListProbabilities(
        await File(image.path).readAsBytes());

    var num = probability[index] * 100;

    // ignore: use_build_context_synchronously
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultScreen(
                  prediction: result,
                  probability: num,
                  imageFile: File(image.path),
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green[50], // Light green background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  border: Border.all(
                    color: Colors.green, // Green border
                    width: 3, // Border width
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      offset: Offset(3, 3), // Shadow effect
                    ),
                  ],
                ),
                child: const Text(
                  'SANJIVANI AI एउटा क्रान्तिकारी मोबाइल एप हो, '
                  'जसले किसानहरूलाई वास्तविक समयमा बिरुवाका रोगहरू पत्ता लगाउन मद्दत गर्छ। '
                  'उन्नत न्युरल नेटवर्कहरू प्रयोग गर्दै, SANJIVANI AI बिरुवाको तस्बिर विश्लेषण गर्छ '
                  'र तुरुन्तै रोगको पहिचान र उपचारको सिफारिस दिन्छ। प्रारम्भमा धानमा केन्द्रित यो एप '
                  'चाँडै नै अन्य धेरै बोटबिरुवा प्रजातिहरूमा विस्तार हुनेछ, र यसले बोटबिरुवाको वृद्धिको चरण पहिचान '
                  'र अनुकूलित कृषि कल्याण तालिकाहरू जस्ता सुविधाहरू प्रदान गर्नेछ। SANJIVANI AI संग, किसानहरूले '
                  'विशेषज्ञ स्तरको सल्लाहकार सेवाहरूको पहुँचमा हुन्छन्, जसले उनीहरूलाई स्वस्थ बाली पालन '
                  'गर्न र उत्पादन बढाउन सघाउँछ।',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.green, // Text color
                    fontWeight: FontWeight.bold,
                    height: 1.5, // Line height
                  ),
                  textAlign: TextAlign.justify, // Align text
                ),
              ),
              Container(
                  margin: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width,
                  height: 58.0,
                  child: ElevatedButton(
                    onPressed: () {
                      pickerClassify(ImageSource.camera);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(
                          width: 10,
                        ),
                        Text('क्यामराबाट फोटो लिनुहोस्',
                            style: TextStyle(fontSize: 16.0))
                      ],
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width,
                  height: 58.0,
                  child: ElevatedButton(
                    onPressed: () {
                      pickerClassify(ImageSource.gallery);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_album),
                        SizedBox(
                          width: 10,
                        ),
                        Text('ग्यालरीबाट फोटो लिनुहोस्',
                            style: TextStyle(fontSize: 16.0))
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String prediction;
  final double probability;
  final File imageFile;

  const ResultScreen(
      {super.key,
      required this.prediction,
      required this.probability,
      required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Prediction Result'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).colorScheme.inversePrimary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: Image.file(imageFile)),
                  Text(
                    'Prediction: $prediction',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Probability: ${probability.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const Description()));
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.note),
                          SizedBox(width: 20),
                          Text('Know More', style: TextStyle(fontSize: 20.0))
                        ],
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}

class Description extends StatelessWidget {
  const Description({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
          title: Text('Description'),
      ),
    );
  }
}
