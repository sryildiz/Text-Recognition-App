import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Recognition',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isImageLoaded = false;
  File pickedImage;
  String readedText = '';
  String dummyText;
  final snackBar = SnackBar(
    content: Text('Text is copied to clipboard!'),
  );

  Future pickImage() async {
    final _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = _imageFile;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizedText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizedText.processImage(ourImage);
    setState(() {
      dummyText = '';
      readedText = '';
    });
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          readedText = readedText + ' ' + word.text;
          // print(word.text);
        }
      }
    }
    dummyText = readedText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Text Recognition App'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // SizedBox(width: 15.0,),
                isImageLoaded
                    ? RaisedButton(
                        color: Colors.blueGrey[600],
                        child: Text(
                          'Pick another image',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: pickImage,
                      )
                    : RaisedButton(
                        color: Colors.blueGrey[600],
                        child: Text(
                          'Pick an image',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: pickImage,
                      ),
                isImageLoaded
                    ? Center(
                        child: Container(
                          margin: EdgeInsets.only(left: 15.0),
                          height: 50.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey),
                              image: DecorationImage(
                                image: FileImage(pickedImage),
                                fit: BoxFit.fill,
                              )),
                        ),
                      )
                    : Container(),
                // SizedBox(width: 15.0,),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              color: Colors.blueGrey[600],
              child: Text(
                'Read the text',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: readText,
            ),
            dummyText == null
                ? Container()
                : GestureDetector(
                    onTap: () {
                      Clipboard.setData(new ClipboardData(text: readedText))
                          .then((_) {
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      });
                    },
                    child: textReadResult(),
                  )
          ],
        ),
      ),
    );
  }

  Widget textReadResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Container(
          child: Text('(Tap on text to copy)'),
          margin: EdgeInsets.only(right: 15.0),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0, left: 18, right: 18.0),
          decoration: BoxDecoration(
              border: Border.all(width: 0.0),
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.blueGrey[500]),
          child: Container(
            margin: EdgeInsets.all(15.0),
            child: Text(
              readedText,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
