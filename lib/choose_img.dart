
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dropper.dart';

class ChooseImg extends StatefulWidget {
  @override
  _ChooseImgState createState() => _ChooseImgState();
}

class _ChooseImgState extends State<ChooseImg> {
  String imgPath;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Theme(
        data: ThemeData(
          // 因为file_manager的icon color用的这个颜色
          accentColor: Colors.teal,
          appBarTheme: AppBarTheme(
            color: Colors.white,
            brightness: Brightness.light,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            textTheme: TextTheme(
              headline6: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        child: Builder(
          builder: (BuildContext builderContext) {
            return Scaffold(
              body: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    onTap: () async {
                      // String userPath;
                      // if (Platform.isLinux) {
                      //   userPath = '/home/' + Platform.environment['USER'];
                      // } else if (Platform.isMacOS) {
                      //   userPath = '/Users/' + Platform.environment['USER'];
                      // } else if (Platform.isWindows) {
                      //   userPath = Platform.environment['USERPROFILE'];
                      // }
                      // print(userPath);
                      // return;

                      FilePickerResult result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        // allowedExtensions: ['jpg', 'pdf', 'doc'],
                      );

                      if (result != null) {
                        PlatformFile file = result.files.first;

                        print(file.name);
                        print(file.bytes);
                        print(file.size);
                        print(file.extension);
                        imgPath = file.path;
                        print(file.path);
                      } else {
                        // User canceled the picker
                      }
                      print('取色器页面返回的文件路径为  $imgPath');
                      if (imgPath != null) {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (BuildContext c) {
                              return Dropper(
                                path: imgPath,
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '点击页面选择你需要取色的图片',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.image),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
