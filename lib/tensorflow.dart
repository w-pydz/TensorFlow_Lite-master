import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Tensorflow extends StatefulWidget {
  @override
  _TensorflowState createState() => _TensorflowState();
}

class _TensorflowState extends State<Tensorflow> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_B_rmsProp.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    print("classifyImage running");
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 127.5, //0
        imageStd: 127.5, //255.0
        numResults: 3,
        threshold: 0.1, //0.2
        asynch: true);

    print("output = ");
    print(output);

    if (output.isEmpty) {
      print("in if output = []");
      var tmp = {
        "confidence": 0,
        "index": 100,
        "label": "Can't identify",
      };
      output = [...output, tmp];
      print("output after change in if = ");
      print(output);
    }

    setState(() {
      _loading = false;
      _outputs = output;
    });

    print("_outputs = ");
    print(_outputs);

    print("classifyImage set state complete");
    print(
        "==============================================================================");
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage() async {
    print(
        "==============================================================================");
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print("image is null");
      return null;
    }
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Tensorflow Lite",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _loading
                ? Container(
                    color: Colors.blue,
                    height: 300,
                    width: 300,
                  ) //display while loading
                : Container(
                    color: Colors
                        .red, //include image and result. if image has no bg, red will all around.
                    margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _image == null
                            ? Container(
                                color: Colors.green,
                              )
                            : Image.file(_image),
                        SizedBox(
                          height: 20,
                        ),
                        _image == null
                            ? Container(
                                color: Colors.pink,
                              )
                            : _outputs != null
                                ? Text(
                                    _outputs[0]["label"],
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  )
                                : Container(child: Text("error"))
                      ],
                    ),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            FloatingActionButton(
              tooltip: 'Pick Image',
              onPressed: pickImage,
              child: Icon(
                Icons.add_a_photo,
                size: 20,
                color: Colors.white,
              ),
              backgroundColor: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
