import 'dart:io';

import 'package:file_manager/file_manager.dart';
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
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: InkWell(
              onTap: () async {
                String userPath = '/Users/' + Platform.environment['USER'];
                print(userPath);
                // return;
                imgPath = await FileManager.chooseFile(
                  context: context,
                  pickPath: userPath,
                );
                print('取色器页面返回的文件路径为  $imgPath');
                // imgPath = await showCustomDialog2<String>(
                //   context: context,
                //   isPadding: false,
                //   height: 600,
                //   child: FMPage(
                //     chooseFile: true,
                //     initpath: '${Global.documentsDir}/YanTool',
                //     callback: (String path) {
                //       Navigator.of(context).pop(path);
                //     },
                //   ),
                // );
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
      ),
    );
  }
}
