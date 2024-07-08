import 'dart:convert';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';
import 'package:face_attendance_app/features/courses_selection/presentation/views/course_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/courseButton.dart';

class CourseSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CourseSelectionScreen> createState() =>
      _CourseSelectionScreenState();
}

// 2. extend [ConsumerState]
class _CourseSelectionScreenState extends ConsumerState<CourseSelectionScreen> {
//  late FaceDetector faceDetector;
//   late tf_lite.Interpreter interpreter;
//   late tf_lite.Interpreter livenessInterpreter;
//   late tf_lite.IsolateInterpreter isolateInterpreter;
//   List<CameraDescription> cameras = [];

//   @override
//   void initState() {
//     super.initState();
//     initialize();
//   }

//   void initialize() {
//     loadModelsAndDetectors();
//   }

//   Future<void> loadModelsAndDetectors() async {
//     // Load models and initialize detectors
//     interpreter = await loadModel();
//     isolateInterpreter =
//         await IsolateInterpreter.create(address: interpreter.address);
//     // livenessInterpreter = await loadLivenessModel();
//     cameras = await availableCameras();

//     // Initialize face detector
//     final faceDetectorOptions = FaceDetectorOptions(
//       minFaceSize: 0.2,
//       performanceMode: FaceDetectorMode.accurate, // or .fast
//     );
//     faceDetector = FaceDetector(options: faceDetectorOptions);
//   }

//   @override
//   void dispose() {
//     // Dispose resources

//     faceDetector.close();
//     interpreter.close();
//     isolateInterpreter.close();
//     super.dispose();
//   }

//   Future<tf_lite.Interpreter> loadModel() async {
//     InterpreterOptions interpreterOptions = InterpreterOptions();

//     if (Platform.isAndroid) {
//       interpreterOptions.addDelegate(XNNPackDelegate(
//           options:
//               XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
//     }

//     if (Platform.isIOS) {
//       interpreterOptions.addDelegate(GpuDelegate());
//     }

//     return await tf_lite.Interpreter.fromAsset(
//       'assets/facenet_512.tflite',
//       options: interpreterOptions..threads = Platform.numberOfProcessors,
//     );

//   }

  @override
  Widget build(BuildContext context) {
    // 4. use ref.watch() to get the value of the provider
    // final helloWorld = ref.watch(helloWorldProvider);

    Map<String, List<dynamic>> jsonData = {
      'Day 1': ['Imran', 'Aonmoy', 'Akas', 'Anan'],
    };

    return Scaffold(
      backgroundColor: const Color(0xFF3a3b45),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CourseButton(
              courseName: 'Course 1',
              // listOfStudents: listOfStudents,
              goToCourse: () {
                navigateToCourses(context, 'Course 1');
              },
            ),
          ),
          Center(
            child: CourseButton(
                courseName: 'Course 2',
                // listOfStudents: listOfStudents,
                goToCourse: () {
                  navigateToCourses(context, 'Course 2');
                }),
          ),
          Center(
            child: CourseButton(
                courseName: 'Course 3',
                // listOfStudents: listOfStudents,
                goToCourse: () {
                  navigateToCourses(context, 'Course 3');
                }),
          ),
          Center(
            child: CourseButton(
              courseName: 'Course 4',
              // listOfStudents: listOfStudents,
              goToCourse: () {
                navigateToCourses(context, 'Course 4');
              },
            ),
          ),
          // ElevatedButton(
          //     onPressed: initializeJsonFiles,
          //     child: const Text('Create files')),
          // const SizedBox(
          //   height: 10.0,
          // ),
          // ElevatedButton(onPressed: loadKeys, child: const Text('print files')),
          // const SizedBox(
          //   height: 10.0,
          // ),
          // ElevatedButton(
          //     onPressed: clearAllPrefs, child: const Text('Delete files')),
        ],
      ),
    );
  }

  Future<void> initializeJsonFiles() async {
    List<String> courses = ['Course 1', 'Course 2', 'Course 3', 'Course 4'];
    final prefs = await SharedPreferences.getInstance();

    for (String course in courses) {
      if (prefs.getString(course) == null) {
        prefs.setString(course, json.encode({}));
      }
    }
    for (int i = 0; i < courses.length; i++) {
      getJsonFromPrefs(courses[i]);
    }
  }

  Future<Map<String, dynamic>?> getJsonFromPrefs(String course) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(course);
    if (jsonString != null) {
      Map<String, dynamic> jsonData = json.decode(jsonString);
      print('the map is $jsonData');
      return jsonData;
    }
    return {
      'map': 'working',
    };
  }

  Future<void> saveJsonToPrefs(
      String key, Map<String, dynamic> jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(jsonData);
    prefs.setString(key, jsonString);
  }

  Future<void> deleteAllJsonFiles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> courses = ['Course 1', 'Course 2', 'Course 3', 'Course 4'];

    for (String course in courses) {
      await prefs.remove(course);
    }
  }

  Future<void> loadKeys() async {
    final prefs = await SharedPreferences.getInstance();

    print(prefs.getKeys().toList());
  }

  Future<void> clearAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('All prefs deleted');
    // Refresh the keys list after clearing
    // _loadKeys();
  }

  void navigateToCourses(context, String courseName) {
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => CourseScreen(
          courseName: courseName,
        ),
      ),
    );
  }
}
