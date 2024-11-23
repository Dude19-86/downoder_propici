import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FileDownloader(),
    );
  }
}

class FileDownloader extends StatefulWidget {
  const FileDownloader({super.key});

  @override
  _FileDownloaderState createState() => _FileDownloaderState();
}

class _FileDownloaderState extends State<FileDownloader> {
  int start = 1;
  int end = 10;
  String? folderPath;
  bool isLoading = false;

  Future<void> selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    setState(() {
      folderPath = selectedDirectory;
    });
  }

  Future<void> downloadFiles() async {
    if (folderPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a folder first")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    for (int i = start; i <= end; i++) {
      final url = 'https://www.aversev.by/media/qr/propisi_s_animatsiey_1/$i.mp4';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File('$folderPath/$i.mp4');
        await file.writeAsBytes(response.bodyBytes);
        print('File $i downloaded');
      } else {
        print('Failed to download file $i');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Start'),
                    onChanged: (value) {
                      setState(() {
                        start = int.parse(value);
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'End'),
                    onChanged: (value) {
                      setState(() {
                        end = int.parse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectFolder,
              child: Text('Select Folder'),
            ),
            if (folderPath != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Selected folder: $folderPath'),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : downloadFiles,
              child: Text(isLoading ? 'Downloading...' : 'Download Files'),
            ),
          ],
        ),
      ),
    );
  }
}
