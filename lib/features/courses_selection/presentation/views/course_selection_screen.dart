import 'dart:convert';
import 'dart:io';

import 'package:face_attendance_app/features/train_face/presentation/views/home_screen.dart';

import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';
import 'package:face_attendance_app/features/courses_selection/presentation/views/course_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/background_widget.dart';
import '../../../../core/utils/courseButton.dart';

class CourseSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CourseSelectionScreen> createState() =>
      _CourseSelectionScreenState();
}

// 2. extend [ConsumerState]
class _CourseSelectionScreenState extends ConsumerState<CourseSelectionScreen> {
  late FaceDetector faceDetector;
  late tf_lite.Interpreter interpreter;
  late tf_lite.IsolateInterpreter isolateInterpreter;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await loadModelsAndDetectors();
  }

  Future<void> loadModelsAndDetectors() async {
    // Load models and initialize detectors
    interpreter = await loadModel();
    isolateInterpreter =
        await IsolateInterpreter.create(address: interpreter.address);
    // livenessInterpreter = await loadLivenessModel();
    cameras = await availableCameras();

    // Initialize face detector
    final faceDetectorOptions = FaceDetectorOptions(
      minFaceSize: 0.2,
      performanceMode: FaceDetectorMode.accurate, // or .fast
    );
    faceDetector = FaceDetector(options: faceDetectorOptions);
  }

  @override
  void dispose() {
    // Dispose resources

    faceDetector.close();
    interpreter.close();
    isolateInterpreter.close();
    super.dispose();
  }

//////////////////////////keep this///////////////

  // Future<tf_lite.Interpreter> loadModel() async {
  //   InterpreterOptions interpreterOptions = InterpreterOptions();
  //   // var interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;

  //   if (Platform.isAndroid) {
  //     interpreterOptions.addDelegate(XNNPackDelegate(
  //         options:
  //             XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
  //   }

  //   if (Platform.isIOS) {
  //     interpreterOptions.addDelegate(GpuDelegate());
  //   }

  //   return await tf_lite.Interpreter.fromAsset(
  //     'assets/facenet_512.tflite',
  //     options: interpreterOptions..threads = Platform.numberOfProcessors,
  //   );
  // }

  Future<tf_lite.Interpreter> loadModel() async {
    // InterpreterOptions interpreterOptions = InterpreterOptions();
    // var interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;// didnt work for me

    // var interpreterOptions = InterpreterOptions()..threads = 2;
    var interpreterOptions = InterpreterOptions()
      ..addDelegate(GpuDelegateV2()); //good

    // if (Platform.isAndroid) {
    //   interpreterOptions.addDelegate(XNNPackDelegate(
    //       options:
    //           XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
    // }

    // if (Platform.isIOS) {
    //   interpreterOptions.addDelegate(GpuDelegate());
    // }

    return await tf_lite.Interpreter.fromAsset('assets/facenet_512.tflite',
        options: interpreterOptions);
  }

  @override
  Widget build(BuildContext context) {
    // 4. use ref.watch() to get the value of the provider
    // final helloWorld = ref.watch(helloWorldProvider);
    // Constants constant = Constants();

    return Scaffold(
      // backgroundColor: Color(0xFF3a3b45),
      body: Stack(children: [
        // Background color with transparency
        const BackgroudContainer(),

        // Main content

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50, bottom: 50),
              child: Text(
                'Courses',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            // const SizedBox(
            //   height: 50,
            // ),
            Center(
              child: Row(
                children: [
                  const SizedBox(
                    width: 25,
                  ),
                  Column(
                    children: [
                      // courseTile('Course 1', 'MAAM'),
                      CourseButton(
                        // courseName: Constants.course_1,
                        courseName: 'Course 1',

                        courseTeacher: 'MAAM',
                        goToCourse: () {
                          navigateToCourses(
                              context,
                              // Constants.course_1,
                              // constant.course_1,
                              'Course 1',
                              isolateInterpreter,
                              faceDetector,
                              cameras,
                              interpreter);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // courseTile('Course 4', 'MSA'),
                      CourseButton(
                        courseName: 'Course 2',

                        // courseName: Constants.course_2,
                        courseTeacher: 'MFK',
                        goToCourse: () {
                          //               (context, String courseName, tf_lite.IsolateInterpreter isolateInterpreter,
                          // FaceDetector faceDetector,List<CameraDescription> cameras, tf_lite.Interpreter interpreter)
                          navigateToCourses(
                              context,
                              // Constants.course_2,
                              // constant.course_1,
                              'Course 2',
                              isolateInterpreter,
                              faceDetector,
                              cameras,
                              interpreter);
                        },
                      ),
                    ],
                  ),
                  // const Padding(padding: EdgeInsets.only(right: 1)),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 70,
                      ),
                      CourseButton(
                          courseName: 'Course 3',
                          // courseName: Constants.course_3,
                          courseTeacher: 'MSA',
                          goToCourse: () {
                            navigateToCourses(
                                context,
                                'Course 3',
                                // Constants.course_3,
                                // constant.course_3,
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          }),
                      // courseTile('Course 3', 'MFK'),
                      const SizedBox(
                        height: 20,
                      ),
                      CourseButton(
                        courseName: 'Course 4',
                        // courseName: Constants.course_4,
                        courseTeacher: 'JUA',
                        goToCourse: () {
                          navigateToCourses(
                              context,
                              // Constants.course_4,
                              // constant.course_4,
                              'Course 4',
                              isolateInterpreter,
                              faceDetector,
                              cameras,
                              interpreter);
                        },
                      ),
                      // courseTile('Course 4', 'JUA'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  const Text(
                    "Didn't register?",
                    style: TextStyle(
                      color: Colors.white38,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              interpreter: interpreter,
                              faceDetector: faceDetector,
                              isolateInterpreter: isolateInterpreter,
                              cameras: cameras,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Register here",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ElevatedButton(
            //     onPressed: initializeJsonFiles,
            //     child: const Text('Create files')),
            // const SizedBox(
            //   height: 10.0,
            // ),
            // ElevatedButton(
            //     onPressed: loadKeys, child: const Text('print files')),
            // const SizedBox(
            //   height: 10.0,
            // ),
            // ElevatedButton(
            //     onPressed: clearAllPrefs, child: const Text('Delete files')),
            // ElevatedButton(
            //     onPressed: deleteAllJsonFiles,
            //     child: const Text('Delete files')),
          ],
        ),
      ]),
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
  // required this.isolateInterpreter,
  // required this.detectionController,
  // required this.faceDetector,
  // required this.cameras,
  // required this.interpreter,

  void navigateToCourses(
      context,
      String courseName,
      tf_lite.IsolateInterpreter isolateInterpreter,
      FaceDetector faceDetector,
      List<CameraDescription> cameras,
      tf_lite.Interpreter interpreter) {
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => CourseScreen(
          interpreter: interpreter,
          isolateInterpreter: isolateInterpreter,
          cameras: cameras,
          faceDetector: faceDetector,
          courseName: courseName,
        ),
      ),
    );
  }
}
