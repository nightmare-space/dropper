import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
// import 'dart:ui'as ui;

class Dropper extends StatefulWidget {
  const Dropper({Key key, this.path}) : super(key: key);
  final String path;

  @override
  _DropperState createState() => _DropperState(path);
}

class _DropperState extends State<Dropper> {
  _DropperState(this.imgPath);
  final String imgPath;
  Color chooseColor = Colors.white;
  final GlobalKey _globalKey = GlobalKey();
  image.Image fullImage;
  int curColor = 0;

  // 将一个Widget转为image.Image对象
  Future<image.Image> _getImageFromWidget() async {
    // _globalKey为需要图像化的widget的key
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    // ui.Image => image.Image
    final dynamic img = await boundary.toImage();
    final ByteData byteData =
        await img.toByteData(format: ImageByteFormat.png) as ByteData;
    final Uint8List pngBytes = byteData.buffer.asUint8List();

    return image.decodeImage(pngBytes);
  }

  Future<void> updateColor() async {
    // image.Image.fromBytes(width, height, bytes)
    // image.
    curColor = fullImage.getPixel(
      (offset.dx).toInt(),
      (offset.dy - 100).toInt(),
    );
    // fullImage.clone();
    // print(curColor);
    chooseColor = Color.fromARGB(
      image.getAlpha(curColor),
      image.getRed(curColor),
      image.getGreen(curColor),
      image.getBlue(curColor),
    );
    // print(chooseColor.value);
    setState(() {});
  }

  Offset offset = const Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    initDropper();
  }

  Future<void> initDropper() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await precacheImage(FileImage(File(imgPath)), context);
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 300));
    fullImage = await _getImageFromWidget();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: RepaintBoundary(
            key: _globalKey,
            child: Stack(
              children: <Widget>[
                RepaintBoundary(
                  child: Align(
                    alignment: Alignment.topCenter,
                    // physics: NeverScrollableScrollPhysics(),
                    child: imgPath.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                            ),
                            child: Image(
                              image: FileImage(File(imgPath)),
                              height: MediaQuery.of(context).size.height - 180,
                              // width: MediaQuery.of(context).size.width*3/4,
                            ),
                          )
                        : Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: InkWell(
                                onTap: () async {},
                                child: const Icon(Icons.image),
                              ),
                            ),
                          ),
                  ),
                  // child: uint8list != null ? Image.memory(uint8list) : SizedBox(),
                ),
                Positioned(
                  top: offset.dy - 100.0,
                  left: offset.dx,
                  child: Center(
                    child: CustomPaint(
                      size: const Size(
                        36,
                        36,
                      ),
                      painter: Logo(color: chooseColor),
                    ),
                  ),
                ),
                if (imgPath.isNotEmpty)
                  GestureDetector(
                    onPanDown: (DragDownDetails details) {
                      if (offset.direction == 0) {
                        offset = details.globalPosition;
                        updateColor();
                        setState(() {});
                      }
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      offset += details.delta;
                      updateColor();
                      setState(() {});
                      // print(details.globalPosition);
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 145,
                    child: Material(
                      elevation: 8.0,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Divider(
                            height: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: chooseColor,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                border: new Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                // boxShadow: <BoxShadow>[
                                //   BoxShadow(
                                //     offset: const Offset(0, 0),
                                //     color: Colors.black.withOpacity(0.6),
                                //     blurRadius: 2.0,
                                //     spreadRadius: 0.0,
                                //   ),
                                // ],
                              ),
                              width: MediaQuery.of(context).size.width - 10,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 36.0,
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'RGB : ${image.getRed(curColor)}|${image.getGreen(curColor)}|${image.getBlue(curColor)}',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 36.0,
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'HEX : 0x${chooseColor.value.toRadixString(16).padLeft(8, '0')} ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Logo extends CustomPainter {
  const Logo({this.color = Colors.black});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paintFore;
    _paintFore = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..isAntiAlias = true;
    final Paint _paintFore1 = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..isAntiAlias = true;
    final Paint _paintFore2 = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..isAntiAlias = true;
    // canvas.drawLine(Offset(0, size.height), Offset(0, 0.0), _paintFore);
    // canvas.drawLine(
    //     Offset(0, size.height), Offset(size.width, size.height), _paintFore);
    // canvas.drawLine(
    //     Offset(size.width, size.height), Offset(size.width, 0), _paintFore);
    // canvas.drawLine(Offset(0, 0), Offset(size.width, 0), _paintFore);
    //正方形
    canvas.drawCircle(const Offset(0, 0), 36.0, _paintFore);

    canvas.drawCircle(const Offset(0, 0), 26.0, _paintFore1);

    canvas.drawCircle(const Offset(0, 0), 2.0, _paintFore2);
    // 圆
    // canvas.drawLine(
    //     Offset(size.width * 0.5 - size.width * 0.75 * tan(pi / 6),
    //         size.height * 0.75),
    //     Offset(size.width / 2, 0),
    //     _paintFore);
    // canvas.drawLine(
    //     Offset(size.width / 2, 0),
    //     Offset(size.width * 0.5 + size.width * 0.75 * tan(pi / 6),
    //         size.height * 0.75),
    //     _paintFore);
    // canvas.drawLine(
    //     Offset(size.width * 0.5 - size.width * 0.75 * tan(pi / 6),
    //         size.height * 0.75),
    //     Offset(size.width * 0.5 + size.width * 0.75 * tan(pi / 6),
    //         size.height * 0.75),
    //     _paintFore);
//三角形
    // canvas.drawLine(
    //     Offset(
    //         size.width * 0.5 -
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75),
    //     Offset(
    //         size.width * 0.5 +
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75),
    //     _paintBackground); //下面那条线
    // canvas.drawLine(
    //     Offset(
    //         size.width * 0.5 -
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6) -
    //             cos(pi / 6) * size.width / 20,
    //         size.height * 0.75 -
    //             size.width / 20 -
    //             cos(pi / 3) * size.width / 20),
    //     Offset(size.width * 0.5 - cos(pi / 6) * size.width / 20,
    //         size.height * 0.1 - cos(pi / 3) * size.width / 20),
    //     _paintBackground); //左上那条线
    // canvas.drawLine(
    //     Offset(
    //       size.width * 0.5 + cos(pi / 6) * size.width / 20,
    //       size.height * 0.1 - cos(pi / 3) * size.width / 20,
    //     ),
    //     Offset(
    //         size.width * 0.5 +
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6) +
    //             cos(pi / 6) * size.width / 20,
    //         size.height * 0.75 -
    //             size.width / 20 -
    //             cos(pi / 3) * size.width / 20),
    //     _paintBackground); //右上那条线

    // canvas.drawLine(
    //     Offset(
    //         size.width * 0.5 -
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75 - size.width / 20),
    //     Offset(size.width * 0.5, size.height * 0.1),
    //     _paintBackground);
    // canvas.drawLine(
    //     Offset(
    //         size.width * 0.5 -
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75 - size.width / 20),
    //     Offset(
    //         size.width * 0.5 +
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75 - size.width / 20),
    //     _paintBackground);
    // canvas.drawLine(
    //     Offset(size.width * 0.5, size.height * 0.1),
    //     Offset(
    //         size.width * 0.5 +
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75 - size.width / 20),
    //     _paintBackground);

//三角形
    // canvas.drawLine(
    //     Offset(
    //         size.width * 0.5 -
    //             (size.width * 0.5 - size.width * 3 / 20) * cos(pi / 6),
    //         size.height * 0.5 +
    //             (size.width * 0.5 - size.width * 3 / 20) * cos(pi / 3)),
    //     Offset(size.width / 2, size.height / 2),
    //     _paintFore);
    // canvas.drawLine(
    //     Offset(
    //         size.width * 0.5 +
    //             (size.width * 0.5 - size.width * 3 / 20) * cos(pi / 6),
    //         size.height * 0.5 +
    //             (size.width * 0.5 - size.width * 3 / 20) * cos(pi / 3)),
    //     Offset(size.width / 2, size.height / 2),
    //     _paintFore);
    // canvas.drawLine(Offset(size.width * 0.5, size.width * 3 / 20),
    //     Offset(size.width / 2, size.height / 2), _paintFore);
    // //三条虚线
    // canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.1),
    //     size.width / 20, _paintBackground); //上面那个小圆
    // canvas.drawCircle(
    //     Offset(
    //         size.width * 0.5 -
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75 - size.width / 20),
    //     size.width / 20,
    //     _paintBackground); //左下角那个圆
    // canvas.drawCircle(
    //     Offset(
    //         size.width * 0.5 +
    //             (size.height * 0.75 - size.height * 3 / 20) * tan(pi / 6),
    //         size.height * 0.75 - size.width / 20),
    //     size.width / 20,
    //     _paintBackground); //右下角那个圆
    canvas.drawPoints(
        PointMode.points,
        <Offset>[
          const Offset(
            0,
            0,
          ),
        ],
        Paint()
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
