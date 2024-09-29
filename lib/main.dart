import 'dart:io';
import 'dart:convert';
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
      title: 'Dr. Biruwa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dr. Biruwa'),
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
                  'DR BIRUWA is a revolutionary mobile app designed to assist farmers by diagnosing plant diseases in real-time. Using advanced neural networks, DR BIRUWA analyzes plant images and provides instant diagnoses and treatment suggestions. Initially focused on rice and maize, the app will soon expand to cover a wide variety of plant species, offering features such as growth stage prediction and customized crop calendars. With DR BIRUWA, farmers have access to expert-level insights and advisory services 24/7, right in their pockets, empowering them to nurture healthy crops and maximize their yields.',
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
                        Text('From Camera',
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
                        Text('From Gallery',
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
                                    Description(prediction: prediction)));
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

// ignore: must_be_immutable
class Description extends StatelessWidget {
  final String prediction;

  Description({super.key, required this.prediction});

  Map<String, dynamic>? _diseaseData;
  List<dynamic> diseases = [];
  var diseaseInfo;
  String? descrip;
  List<dynamic>? remedies;

  // Load disease data from JSON file
  Future<void> loadDiseaseData() async {
    String jsonString = await rootBundle.loadString('assets/disease_data.json');
    _diseaseData = json.decode(jsonString);
    diseases = _diseaseData?['diseases'];
  }

  Map<String, dynamic>? getDiseaseInfo(String diseaseName) {
    for (var disease in diseases) {
      if (disease['name'] == diseaseName) {
        return disease;
      }
    }
    return null; // Return null if disease is not found
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadDiseaseData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            diseaseInfo = getDiseaseInfo(prediction.trim());
            descrip = diseaseInfo?['description'];
            remedies = diseaseInfo?['remedies'];

            if (diseaseInfo == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Disease Info')),
                body:
                    Center(child: Text('No information found for $prediction')),
              );
            }
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Disease Info for $prediction'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Set app bar color
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title for Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800], // Set title color
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Description Text
                  Text(
                    descrip ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5, // Line height for readability
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify, // Justify the description
                  ),
                  const SizedBox(height: 20),
                  // Title for Remedies
                  Text(
                    'Remedies',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800], // Set title color
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Remedies List
                  remedies != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: remedies!
                              .map((remedy) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ', // Bullet point for each remedy
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Expanded(
                                          child: Text(
                                            remedy,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              height: 1.5,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        )
                      : const Text(
                          'No remedies available',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                ],
              ),
            ),
          );
        });
  }
}
