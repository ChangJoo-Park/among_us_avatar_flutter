import 'dart:typed_data';
import 'package:among_us_profile_maker/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'dart:ui' as ui;

class CustomTextEditor extends StatefulWidget {
  @override
  _CustomTextEditorState createState() => _CustomTextEditorState();
}

class _CustomTextEditorState extends State<CustomTextEditor> {
  GlobalKey _globalKey = new GlobalKey();
  final _customTextFormKey = GlobalKey<FormState>();
  String _customText = 'Imposter';
  double _customFontSize = 32;
  Color _customColor = Colors.black;

  @override
  void initState() {
    _customText = 'Imposter';
    _customFontSize = 32;
    _customColor = Colors.black;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).trans('custom_text_title')),
        backgroundColor: Colors.black,
        actions: [
          FlatButton(
            child: Text(Translations.of(context).trans('custom_text_save'), style: TextStyle(color: Colors.white)),
            onPressed: () async {
              RenderRepaintBoundary boundary =
                  _globalKey.currentContext.findRenderObject();
              ui.Image image = await boundary.toImage();
              ByteData byteData =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = byteData.buffer.asUint8List();
              Navigator.of(context).pop(pngBytes);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      width: 250,
                      height: 250,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                _customText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'AmongUs',
                                  fontSize: _customFontSize,
                                  color: _customColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 250,
                    height: 250,
                    foregroundDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _customTextFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: Translations.of(context).trans('custom_text_text'),
                      ),
                      initialValue: _customText,
                      onChanged: (String value) {
                        setState(() {
                          _customText = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text(Translations.of(context).trans('custom_text_size')),
                    Slider(
                      label: _customFontSize.round().toString(),
                      value: _customFontSize,
                      min: 20,
                      max: 44,
                      divisions: 4,
                      onChanged: (double value) {
                        setState(() {
                          _customFontSize = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text(Translations.of(context).trans('custom_text_color')),
                    RaisedButton.icon(
                      icon: Icon(Icons.palette),
                      textColor: Colors.black,
                      label: Text('Change Color'),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: OColorPicker(
                            selectedColor: _customColor,
                            colors: primaryColorsPalette,
                            onColorChange: (color) {
                              setState(() {
                                _customColor = color;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
