import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:ui';

class SkinDiseaseDetector extends StatefulWidget {
  @override
  _SkinDiseaseDetectorState createState() => _SkinDiseaseDetectorState();
}

class _SkinDiseaseDetectorState extends State<SkinDiseaseDetector> {
  Uint8List? _imageBytes;
  String _result = "";
  bool _loading = false;
  XFile? _pickedFile;

  Future pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedFile = picked;
        _imageBytes = bytes;
        _result = "";
      });
    }
  }

  Future predictDisease() async {
    if (_imageBytes == null || _pickedFile == null) return;

    setState(() {
      _loading = true;
      _result = "Predicting...";
    });

    final uri = Uri.parse('http://127.0.0.1:5000/predict');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        _imageBytes!,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = json.decode(respStr);
      setState(() {
        _result =
            "${data['prediction']} (Confidence: ${(data['confidence'] * 100).toStringAsFixed(2)}%)\n\nInfo:\n${data['disease_info']}";
        _loading = false;
      });
    } else {
      try {
        final errorData = json.decode(respStr);
        setState(() {
          _result = "Prediction failed: ${errorData['error']}";
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _result = "Prediction failed: Unexpected error";
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f4ff),
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_2_rounded, color: Colors.white),

            Text(
              'Skin Diseases',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 158, 130, 186),
                Color.fromARGB(255, 188, 87, 201),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Skin Matters",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 117, 68, 165),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "The skin is the body's largest organ and acts as the first line of defense against bacteria, viruses, and pollutants. "
              "Skin diseases can be both painful and emotionally distressing if left untreated. "
              "Taking care of your skin isn't just about appearance — it's about health, hygiene, and well-being.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://cdnl.iconscout.com/lottie/premium/thumb/doctor-explaining-gesture-8936343-7441632.gif',
                  height: 350,
                ),
              ),
            ),
            SizedBox(height: 30),
            if (_imageBytes != null)
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  _imageBytes!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.image, color: Colors.white),
                  label: Text("Pick Image"),
                  onPressed: pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Color.fromARGB(255, 117, 68, 165),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.search, color: Colors.white),
                  label: Text("Predict"),
                  onPressed: predictDisease,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Color.fromARGB(255, 117, 68, 165),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            if (_loading) Center(child: CircularProgressIndicator()),
            if (_result.isNotEmpty && !_loading)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Result:",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _result,
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
