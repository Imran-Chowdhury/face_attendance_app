import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_attendance_app/core/utils/customButton.dart';
import 'package:face_attendance_app/features/live_feed/presentation/views/live_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/base_state/base_state.dart';
import '../../../../core/base_state/course_state.dart';
import '../../../../core/constants/constants.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../riverpod/course_selection_riverpod.dart';

class CourseDayScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CourseDayScreen> createState() => _CourseDayScreenState();

  CourseDayScreen(
      {super.key,
      required this.attendedStudentsMap,
      required this.day,
      required this.courseName});

  Map<String, List<dynamic>> attendedStudentsMap;
  String day;
  String courseName;
  // List<String> attendedStudentsList;
}

// 2. extend [ConsumerState]
class _CourseDayScreenState extends ConsumerState<CourseDayScreen> {
  late FaceDetector faceDetector;
  late tf_lite.Interpreter interpreter;
  late tf_lite.Interpreter livenessInterpreter;
  late tf_lite.IsolateInterpreter isolateInterpreter;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initialize();
    // print('The day is $')
  }

  void initialize() {
    loadModelsAndDetectors();
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

  // @override
  // void dispose() {
  //   // Dispose resources

  //   faceDetector.close();
  //   interpreter.close();
  //   isolateInterpreter.close();
  //   super.dispose();
  // }

  Future<tf_lite.Interpreter> loadModel() async {
    InterpreterOptions interpreterOptions = InterpreterOptions();

    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate(
          options:
              XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
    }

    if (Platform.isIOS) {
      interpreterOptions.addDelegate(GpuDelegate());
    }

    return await tf_lite.Interpreter.fromAsset(
      'assets/facenet_512.tflite',
      options: interpreterOptions..threads = Platform.numberOfProcessors,
    );
  }

  @override
  Widget build(BuildContext context) {
    Constants constant = Constants();
    String family = "${widget.courseName}- ${widget.day}";
    final detectController = ref.watch(faceDetectionProvider(family).notifier);
    final recognizeState = ref.watch(recognizefaceProvider(family));
    final detectState = ref.watch(faceDetectionProvider(family));

    var attendanceState = ref.watch(attendanceProvider(family));
    AttendanceNotifier attendanceController =
        ref.watch(attendanceProvider(family).notifier);

    List<dynamic>? attended = mapToList(widget.attendedStudentsMap, widget.day);
    print('the attended list is $attended');

    if (attendanceState is AttendanceSuccessState) {
      attended = attendanceState.data;
    }

    // if (recognizeState is SuccessState && detectState is SuccessState) {
    //   Future(() {
    //     String name = recognizeState.name;
    //     attendanceController.attendedList(
    //         name, widget.day, widget.courseName, attended);
    //   });
    // }

    if (recognizeState is SuccessState && detectState is SuccessState) {
      // message = 'Recognized: ${recognizeState.name}';
      Future(() {
        String name = recognizeState.name;
        attendanceController.attendedList(
            name, widget.day, widget.courseName, attended);
      });
    } else if (recognizeState is ErrorState && detectState is SuccessState) {
      // message = ' ${recognizeState.errorMessage}';
    } else if (detectState is ErrorState) {
      // message = detectState.errorMessage;
      // 'No face Detected';
    }

    return Scaffold(
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (attendanceState is AttendanceSuccessState)
              ? listOfAttendedStudents(attendanceState.data)
              : listOfAttendedStudents(attended),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  goToLiveFeedScreen(context, detectController,
                      'Total Students', attended, widget.day, family);
                },
                child: const Text('Attend'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> callAttendNotifier(
  //     String name, var attendanceController, List<dynamic>? attended) async {
  //   // String name = recognizeState.name;
  //   await attendanceController.attendedList(
  //       name, widget.day, widget.courseName, attended);
  // }

  Widget listOfAttendedStudents(List<dynamic>? attendedList) {
    return Expanded(
      child: ListView.builder(
        itemCount: attendedList?.length,
        itemBuilder: (context, index) {
          print('The attended students are $attendedList');
          return GestureDetector(
            onTap: () {
              // navigateToDay(context, listOfDays[index], attendanceSheetMap);
            },
            child: ListTile(
              title: Text(attendedList![index]),
            ),
          );
        },
      ),
    );
  }

  Future<void> goToLiveFeedScreen(context, detectController, fileName,
      List<dynamic>? attended, String day, String family) async {
    List<CameraDescription> cameras = await availableCameras();

    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => LiveFeedScreen(
          isolateInterpreter: isolateInterpreter,
          detectionController: detectController,
          faceDetector: faceDetector,
          cameras: cameras,
          interpreter: interpreter,
          studentFile: fileName,
          family: family,
          // day: day,
          // attended: attended,
          // livenessInterpreter: livenessInterpreter,
        ),
      ),
    );
  }

  // List<dynamic>? mapToList(dynamic attendedStudents, String day) {
  //   if (attendedStudents.keys.contains(day)) {
  //     return attendedStudents[day];
  //   }
  // }

  List<dynamic>? mapToList(
      Map<String, List<dynamic>>? attendanceSheetMap, String day) {
    print('babababab');
    List? studentList = [];
    try {
      if (attendanceSheetMap!.isNotEmpty) {
        if (attendanceSheetMap.containsKey(widget.day)) {
          studentList = attendanceSheetMap[widget.day];
        }

        print(studentList);
      } else {
        studentList = [];
      }
    } catch (e) {
      rethrow;
    }
    return studentList;
  }
}
