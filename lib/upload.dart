import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veda_flutter_assgn/utils.dart';

import 'package:http/http.dart' as http;

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  String imgPath;
  double uploadLoadingProgress;

  /// Function for picking image using image_picker library
  void selectImage() {
    ImagePicker().pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        setState(() {
          imgPath = value.path;
        });
      }
    });
  }

  /// Upload image as multipart to given API
  void uploadImg() async {
    if (imgPath == null) {
    } else {
      try {
        final request = MultipartRequest(
          'POST',
          Uri.parse("https://codelime.in/api/remind-app-token"),
          onProgress: (int bytes, int total) {
            final progress = bytes / total;
            setState(() {
              uploadLoadingProgress = progress;
            });
            // print('progress: $progress ($bytes/$total)');
          },
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imgPath,
          ),
        );

        final http.StreamedResponse streamedResponse = await request.send();
        final http.Response res =
            await http.Response.fromStream(streamedResponse);
        print(res.statusCode);
        setState(() {
          uploadLoadingProgress = null;
        });
        log(res.body);

        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text(res.statusCode == 200 ? "Success!" : "Failed"),
                  content: Text(res.statusCode == 200
                      ? "Image uploaded successfully!!"
                      : "Image upload failed. Please try again!!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        selectImage();
                      },
                      child: Text("Pick another image"),
                    ),
                  ],
                ));
      } catch (e) {
        setState(() {
          uploadLoadingProgress = null;
        });
        Fluttertoast.showToast(msg: "Some error took place");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Upload Image",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 35,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Display image for verification only if image is selected
          if (imgPath != null)
            Center(
              child: Container(
                height: size.height / 2,
                width: size.width - 30,
                child: GestureDetector(
                  onTap: selectImage,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white70,
                    size: 70,
                  ),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(
                      File(imgPath),
                    ),
                    colorFilter:
                        ColorFilter.mode(Colors.black26, BlendMode.darken),
                  ),
                ),
              ),
            ),
          // Show the progress indicator if uploading, otherwise show button for picking and uploading image
          uploadLoadingProgress != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: uploadLoadingProgress,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Uploading... " +
                        (uploadLoadingProgress * 100).toStringAsFixed(2) +
                        " %"),
                  ],
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: imgPath == null ? selectImage : uploadImg,
                    child: Text(
                      imgPath == null ? "Pick Image" : "Upload",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
