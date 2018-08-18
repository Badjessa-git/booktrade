import 'dart:async';
import 'dart:io';
import 'package:booktrade/models/book.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:validator/validator.dart';
import 'package:path_provider/path_provider.dart';

class FinBook extends StatefulWidget {
  final List<CameraDescription> _cameras;
  final Book curBook;
  final TradeApi _api;

  const FinBook(this._cameras, this.curBook, this._api);

  @override
  _FinBookState createState() => new _FinBookState();
}

class _FinBookState extends State<FinBook> {
  // _FinBookState(String isbn, String author, String title, String edition);

  String _imagePath;
  CameraController _controller;
  Book book;
  @override
  void initState() {
    super.initState();
    if (widget.curBook != null &&
        widget.curBook.picUrl != null &&
        widget.curBook.picUrl.isNotEmpty &&
        isURL(widget.curBook.picUrl)) {
      setState(() {
        _imagePath = widget.curBook.picUrl;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _openDialog(context);
      });
    }
    setUpController();
  }

  void setUpController() {
    _controller =
        new CameraController(widget._cameras[0], ResolutionPreset.medium);
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
        backgroundColor: Colors.black,
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              child: new Container(
                child: new Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                child: new Center(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Divider(
                        indent: MediaQuery.of(context).size.width / 2 - 50.0,
                      ),
                      _captureControlWidget(),
                      _thumbnailWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
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

  Widget _thumbnailWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: _controller == null || _imagePath == null
            ? null
            : new SizedBox(
                width: 64.0,
                height: 64.0,
                child: new Image.file(new File(_imagePath)),
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
    _controller =
        new CameraController(cameraDescription, ResolutionPreset.high);

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
          highlightColor: Colors.redAccent,
          color: Colors.white,
          iconSize: 70.0,
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
        });
      }
      _openDialog(context);
    });
  }

  Future<String> takePicture() async {
    if (!_controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/BookTrade';
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

  void _openDialog(BuildContext context) {
     Navigator.of(context).push<MaterialPageRoute<dynamic>>(new MaterialPageRoute<MaterialPageRoute<dynamic>>(
        builder: (BuildContext context) {
            return new SavePictureDialog(
                _imagePath, widget.curBook, widget._api);
          },
          fullscreenDialog: true,
        ));
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();
}

class SavePictureDialog extends StatelessWidget {
  final String _imagePath;
  final Book curBook;
  final TradeApi _api;

  SavePictureDialog(this._imagePath, this.curBook, this._api);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('Save Image'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () async {
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                duration: const Duration(seconds: 10),
                content: new Row(
                  children: const <Widget>[
                    const CircularProgressIndicator(),
                    const Text('  Submitting Book...')
                  ],
                ),
              ));
              await _submit(context);
            },
            child: new Text('SAVE',
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white)),
          )
        ],
      ),
      body: new Center(
        child: new Container(
          child: new Hero(
            tag: 'Preview',
            child: new Container(
              height: 400.0,
              width: 400.0,
              child: isURL(_imagePath)
                  ? new Image.network(_imagePath)
                  : new Image.file(
                      new File(_imagePath),
                      fit: BoxFit.contain,
                    )
            ),
          ),
        ),
      ),
    );
  }

  dynamic _submit(BuildContext context) async {
    curBook.picUrl = await _api.uploadFile(filePath: _imagePath, isbn: curBook.isbn);
    await _api.uploadBook(curBook).then((dynamic onValue) {
      Navigator.popUntil(context, ModalRoute.withName('Navigation'));
    }).catchError((dynamic error) {
      final dynamic alert = new AlertDialog(
        title: const Text('Error'),
        content: const Text('An error occured while searching for the book\n'
            'Try again or Input values manually'),
        actions: <Widget>[
          new FlatButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
      showDialog<AlertDialog>(context: context, builder: (_) => alert);
      return;
    });
  }
}
