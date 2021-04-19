import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:carby/tflite/recognition.dart';
import 'package:carby/tflite/stats.dart';
import 'package:carby/ui/box_widget.dart';
import 'package:carby/ui/camera_view_singleton.dart';

import 'package:carby/ui/product_detail.dart';
import 'package:carby/ui/product.dart';

import 'package:http/http.dart';
import 'dart:convert';

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'camera_view.dart';

import 'dart:io';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class HomeView extends StatefulWidget {
  final CameraDescription camera;

  const HomeView({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// Results to draw bounding boxes
  List<Recognition> results;

  /// Realtime stats
  Stats stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        floatingActionButton: Container(
          height: 100.0,
          width: 100.0,
          child: FittedBox(
            child: FloatingActionButton(
              child: Icon(Icons.camera_alt, size: 40),
              // Provide an onPressed callback.
              onPressed: () async {
                // Take the Picture in a try / catch block. If anything goes wrong,
                // catch the error.
                try {
                  // Ensure that the camera is initialized.
                  await _initializeControllerFuture;

                  // Attempt to take a picture and get the file `image`
                  // where it was saved.
                  final image = await _controller.takePicture();

                  // If the picture was taken, display it on a new screen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindResultsScreen(
                        // Pass the automatically generated path to
                        // the DisplayPictureScreen widget.
                        imagePath: image?.path,
                      ),
                    ),
                  );
                  upload(File(image?.path), context);
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Stack(children: <Widget>[
          // Camera View
          CameraView(resultsCallback, statsCallback),

          // Bounding boxes
          boundingBoxes(results),

          // Heading
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'Carby Object Detector',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent.withOpacity(0.8),
                ),
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (_, ScrollController scrollController) => Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BORDER_RADIUS_BOTTOM_SHEET),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up,
                            size: 48, color: Colors.orange),
                        (stats != null)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    StatsRow('Inference time:',
                                        '${stats.inferenceTime} ms'),
//                                    StatsRow('Total prediction time:',
//                                        '${stats.totalElapsedTime} ms'),
                                    StatsRow('Pre-processing time:',
                                        '${stats.preProcessingTime} ms'),
                                    StatsRow('Frame',
                                        '${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}'),
                                  ],
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ]));
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition> results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

// A widget that displays the picture taken by the user.
class FindResultsScreen extends StatelessWidget {
  final String imagePath;

  const FindResultsScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Finding product...')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 32.0),
            child: Column(children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Image.file(File(imagePath)))
            ])));
  }
}

// A widget that displays the product found by the server.
class DisplayNotFoundScreen extends StatelessWidget {
  final File imageFile;

  const DisplayNotFoundScreen({Key key, this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Product Not Found')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 32.0),
            child: Column(children: <Widget>[
              Align(
                  alignment: Alignment.topCenter, child: Image.file(imageFile)),
              new Container(
                padding: const EdgeInsets.only(top: 32.0, left: 40.0),
                child: new Row(
                  children: [
                    // First child in the Row for the name and the
                    // Release date information.
                    new Expanded(
                      // Name and Release date are in the same column
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Code to create the view for name.
                          new Container(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: new Text(
                              "Please try again",
                              style: new TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ])));
  }
}

// A widget that displays the product found by the server.
class DisplayResultsScreen extends StatelessWidget {
  final Response response;

  const DisplayResultsScreen({Key key, this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Product product = parseProduct(response.body);
    return Scaffold(
        appBar: AppBar(title: Text('Product Found')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Stack(children: <Widget>[ProductDetail(product)]));
  }
}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left), Text(right)],
      ),
    );
  }
}

void upload(File imageFile, BuildContext context) async {
  if (imageFile == null) return;
  String base64Image = base64Encode(imageFile.readAsBytesSync());
  String fileName = imageFile.path.split("/").last;

  post(
      "http://carbymodelapi-env.eba-zfkqpc4z.us-east-1.elasticbeanstalk.com/predict-product", //      "http://carbyapi-env.eba-wjqkprkx.us-east-1.elasticbeanstalk.com/predict",
      body: {
        "img": base64Image,
        "name": fileName,
      }).then((res) {
    if (res.body.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayNotFoundScreen(
            // Image is passed to the DisplayNotFoundScreen widget.
            imageFile: imageFile,
          ),
        ),
      );
    } else {
      get("http://carbyapi-env.eba-wjqkprkx.us-east-1.elasticbeanstalk.com/metadata/${res.body}")
          .then((res) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayResultsScreen(
              // Pass the response
              // the DisplayPictureScreen widget.
              response: res,
            ),
          ),
        );
      });
    }
  }).catchError((err) {
    print(err);
  });
}
