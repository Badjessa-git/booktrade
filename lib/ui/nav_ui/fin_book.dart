import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lutexttrade/ui/image_design.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class FinBook extends StatefulWidget {
  var _cameras;
  FinBook(this._cameras);

  // String isbn, author, title, edition;
  // FinBook() 
  // {
  //   // this.isbn = isbn;
  //   // this.author = author;
  //   // this.title = title;
  //   // this.edition = edition;
  // }

  // FinBook();
  
  @override
  _FinBookState createState() => new _FinBookState();
  
    
  }
  
class _FinBookState extends State<FinBook>{

  // _FinBookState(String isbn, String author, String title, String edition);
  
  String _imagePath;
  CameraController _controller;

  @override
  void initState() {
    setUpController();
    super.initState(); 
  }

  void setUpController() {
    _controller = new CameraController(widget._cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
      ),
      backgroundColor: Colors.blue,
       body:new Column(
         children: <Widget>[
           new Divider(
             height: 16.0,
           ),
           new Text(
           "Cover Picture",
           textAlign: TextAlign.start,
              style: new TextStyle(
                fontSize: 30.0,
                color: Colors.white,
              ),
            ),
           new Expanded (
             child: new Container(
               child: new Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: new Center(
                    child: _cameraPreviewWidget(),
                  ),
                ),
              ),
            ),
            _captureControlWidget(),
            new Padding(
              padding: const EdgeInsets.all(1.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _cameraTogglesRowWidget(),
                  _thumbnailWidget(),
                ],
              ),
            )
          ],
        )
      );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _cameraPreviewWidget() {
    if (_controller == null || !_controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return new AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: new CameraPreview(_controller),
      );
    }
  }

  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (widget._cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in widget._cameras) {
        toggles.add(
          new SizedBox(
            width: 90.0,
            child: new RadioListTile<CameraDescription>(
              title:
                  new Icon(getCameraLensIcon(cameraDescription.lensDirection),
                    size: 30.0,
                  ),
              groupValue: _controller?.description,
              value: cameraDescription,
              onChanged: _controller != null && _controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return new Row(children: toggles);
  }

  Widget _thumbnailWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: _controller == null || _imagePath == null
            ? null
            : new SizedBox(
                width: 64.0,
                height: 64.0,
                child: new Image.file(new File(_imagePath)
              ),
        ),
      ),
    );
  }

  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
    }
    throw new ArgumentError('Unknown lens direction');
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = new CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
  //Display the control bar with buttons to take pictures
  Widget _captureControlWidget() {
      return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new IconButton(
          iconSize: 40.0,
          icon: const Icon(Icons.camera_alt),
          onPressed: _controller != null &&
                  _controller.value.isInitialized &&
                  !_controller.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
      ],
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          _imagePath = filePath;
          _controller?.dispose();
          _controller = null;
        });
        var alert = new Dialog();
        Navigator.push(context,
              new HeroDialogRoute(
                builder: (BuildContext context) {
               return new Scaffold(
                appBar: new AppBar(
                  title: Text("Continue?"),
                ),
                body: new Hero(
                  tag: "preview",
                  child: new Image.file(new File(_imagePath)),
                ),
              );
          }));
        }
    });
  }

  Future<String> takePicture() async {
    if (!_controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (_controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await _controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();
  

}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({ this.builder }) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
      opacity: new CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut
      ),
      child: child
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation) {
    return builder(context);
  }

  // TODO: implement barrierLabel
  @override
  String get barrierLabel => null;

}

