import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:among_us_profile_maker/translations.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class CustomLayerEditor extends StatefulWidget {
  final String title;
  final String type;

  CustomLayerEditor({this.title, this.type});
  @override
  CustomLayerEditorState createState() => CustomLayerEditorState();
}

class CustomLayerEditorState extends State<CustomLayerEditor> {
  GlobalKey _globalKey = GlobalKey();
  Color _customColor = Colors.black;
  Color _backgroundColor = Colors.white;
  int _stroke = 0;
  List<double> _items = <double>[3, 5, 7, 9, 11, 13, 15];
  List<DrawingPoints> points = <DrawingPoints>[];
  bool _showAvatar = true;
  @override
  void initState() {
    if (widget.type != 'BACKGROUND') {
      _backgroundColor = Colors.transparent;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(widget.title ?? 'Custom Layer Editor'),
        actions: [
          IconButton(
            icon: Icon(_showAvatar ? Icons.toggle_on : Icons.toggle_off),
            onPressed: () {
              setState(() => _showAvatar = !_showAvatar);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
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
      body: Stack(children: [
        Column(
          children: [
            SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  if (widget.type != 'BACKGROUND' && _showAvatar)
                    Container(
                      width: 250,
                      height: 250,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.1), BlendMode.dstATop),
                        child: Image.asset('images/PLAYER/BASE.png'),
                      ),
                    ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(DrawingPoints(
                            points:
                                renderBox.globalToLocal(details.localPosition),
                            paint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = _customColor
                              ..strokeWidth = _stroke.toDouble()));
                      });
                    },
                    onPanStart: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(DrawingPoints(
                            points:
                                renderBox.globalToLocal(details.localPosition),
                            paint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = _customColor
                              ..strokeWidth = _stroke.toDouble()));
                      });
                    },
                    onPanEnd: (details) {
                      setState(() => points.add(null));
                    },
                    child: Container(
                      width: 250,
                      height: 250,
                      foregroundDecoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(),
                      ),
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: ClipRRect(
                          child: Container(
                            color: _backgroundColor,
                            child: CustomPaint(
                              key: UniqueKey(),
                              isComplex: true,
                              willChange: true,
                              painter: DrawingPainter(pointsList: points),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                  child: Container(
                child: Column(
                  children: [
                    // 커스텀 컬러
                    Text(Translations.of(context).trans('custom_text_color')),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 40, height: 40, color: _customColor),
                          SizedBox(width: 16),
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
                                    setState(() => _customColor = color);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.type == 'BACKGROUND') Text('배경색'),
                    if (widget.type == 'BACKGROUND')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                foregroundDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(),
                                ),
                                width: 40,
                                height: 40,
                                color: _backgroundColor),
                            SizedBox(width: 16),
                            RaisedButton.icon(
                              icon: Icon(Icons.palette),
                              textColor: Colors.black,
                              label: Text('Change Background Color'),
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: OColorPicker(
                                    selectedColor: _backgroundColor,
                                    colors: primaryColorsPalette,
                                    onColorChange: (color) {
                                      setState(() => _backgroundColor = color);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text('두께'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _items.asMap().entries.map((entry) {
                          return _StrokeButton(
                            key: ValueKey('STROKE_BUTTON_${entry.value}'),
                            stroke: entry.value,
                            color: _customColor,
                            selected: _stroke == entry.key,
                            onTap: () {
                              setState(() => _stroke = entry.key);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ]),
    );
  }
}

class _StrokeButton extends StatelessWidget {
  final double stroke;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _StrokeButton({
    Key key,
    this.stroke,
    this.color,
    this.selected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.only(right: 4),
      foregroundDecoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: selected ? Colors.black87 : Colors.black12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Container(
            width: stroke,
            height: stroke,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}
