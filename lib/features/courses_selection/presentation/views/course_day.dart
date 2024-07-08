import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_attendance_app/core/utils/customButton.dart';
import 'package:face_attendance_app/features/live_feed/presentation/views/live_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/base_state/course_state.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../riverpod/course_selection_riverpod.dart';

class CourseDayScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CourseDayScreen> createState() => _CourseDayScreenState();

  CourseDayScreen(
      {super.key, required this.attendedStudentsMap, required this.day});

  Map<String, List<dynamic>> attendedStudentsMap;
  String day;
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

  @override
  void dispose() {
    // Dispose resources

    faceDetector.close();
    interpreter.close();
    isolateInterpreter.close();
    super.dispose();
  }

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
    // 4. use ref.watch() to get the value of the provider
    // final helloWorld = ref.watch(helloWorldProvider);
    final detectController = ref.watch(faceDetectionProvider.notifier);
    var dayState = ref.watch(courseProvider(widget.day));
    CourseNotifier dayController =
        ref.watch(courseProvider(widget.day).notifier);

    List<dynamic>? attended = mapToList(widget.attendedStudentsMap, widget.day);
    print('the attended list is $attended');

    //  if(CourseState is CourseSuccessState){
    //   attended = CourseState.data;
    // }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Imran'),
          const SizedBox(
            height: 10,
          ),
          const Text('Imran'),
          const SizedBox(
            height: 10,
          ),
          const Text('Imran'),
          const SizedBox(
            height: 10,
          ),

          // CustomButton(
          //   onPressed: () {
          //   navigateToLiveFeed(context, courseName)
          // },
          // buttonName: 'Attend', icon: const  Icon(Icons.people)
          // )

          GestureDetector(
            onTap: () {
              goToLiveFeedScreen(context, detectController, 'All_Students',
                  attended, widget.day);
            },
            child: Container(
              color: Colors.red,
              height: 100,
              width: 100,
              child: const Text('Attend'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> goToLiveFeedScreen(context, detectController, fileName,
      List<dynamic>? attended, String day) async {
    List<CameraDescription> cameras = await availableCameras();

    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => LiveFeedScreen(
          isolateInterpreter: isolateInterpreter,
          detectionController: detectController, faceDetector: faceDetector,
          cameras: cameras, interpreter: interpreter,
          nameOfJsonFile: fileName,
          day: day,
          attended: attended,
          // livenessInterpreter: livenessInterpreter,
        ),
      ),
    );
  }

  List<dynamic>? mapToList(dynamic attendedStudents, String day) {
    if (attendedStudents.keys.contains(day)) {
      return attendedStudents[day];
    }
  }
}
