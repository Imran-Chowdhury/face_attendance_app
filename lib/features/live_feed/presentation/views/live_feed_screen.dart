import 'package:camera/camera.dart';
import 'package:face_attendance_app/features/courses_selection/presentation/riverpod/course_selection_riverpod.dart';
import 'package:face_attendance_app/features/courses_selection/presentation/views/course_day.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import '../../../../core/base_state/base_state.dart';
import '../../../../core/utils/convert_camera_image_to_img_image.dart';
import '../../../../core/utils/convert_camera_image_to_input_image.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';

import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

// ignore: must_be_immutable
class LiveFeedScreen extends ConsumerStatefulWidget {
  LiveFeedScreen({
    super.key,
    required this.isolateInterpreter,
    // required this.detectionController,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,
    required this.studentFile,
    required this.family,
    required this.nameOfScreen,
    required this.day,
    required this.attended,
    required this.coursename,
  });

  // final FaceDetectionNotifier detectionController;
  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;

  // final tf_lite.Interpreter livenessInterpreter;
  late String studentFile;
  late String family;
  late String nameOfScreen;
  late String day;
  late List<dynamic>? attended;
  late String coursename;

  @override
  ConsumerState<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

// 2. extend [ConsumerState]
class _LiveFeedScreenState extends ConsumerState<LiveFeedScreen> {
  late CameraController controller;
  int numberOfFrames = 0;
  // int frameSkipCount = 15;
  // int frameSkipCount = 25;
  // int frameSkipCount = 40;
  int frameSkipCount = 50;

  List frameList = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    initializeCameras();
    print('Camera initialized');
  }

  Future<void> initializeCameras() async {
    controller = CameraController(
      widget.cameras[1],
      // widget.cameras[0],
      ResolutionPreset.low,
      // ResolutionPreset.medium,
      // ResolutionPreset.high,
      // ResolutionPreset.veryHigh,
      // ResolutionPreset.max,
      enableAudio: false,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      startStream(controller);
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
    // await startStream(controller);
  }

  @override
  void dispose() {
    disposeController();
    // controller.stopImageStream();
    // controller.dispose();

    // print('disposed');
    super.dispose();
  }

  Future<void> disposeController() async {
    await controller.stopImageStream();
    await controller.dispose();

    // await widget.faceDetector.close();
    // await widget.isolateInterpreter.close();
    // widget.cameras.clear();
    // widget.interpreter.close();

    print('disposed');
  }

  Future<void> startStream(CameraController controller) async {
    ///////////////Changes are made////////////////////////////////////////////////////////
    // final detectController = ref.watch(faceDetectionProvider.notifier);
    // final recognizeController = ref.watch(recognizefaceProvider.notifier);

    final detectController =
        ref.watch(faceDetectionProvider(widget.family).notifier);
    final recognizeController =
        ref.watch(recognizefaceProvider(widget.family).notifier);

    final AttendanceNotifier attendancController =
        ref.watch(attendanceProvider(widget.family).notifier);

    //Image Streaming
    controller.startImageStream((image) async {
      // print('The camera image format is ${image.format.group}');

      numberOfFrames++;
      if (numberOfFrames % frameSkipCount == 0) {
        print('the number of frames are $numberOfFrames');

        // DateTime start = DateTime.now();
        final stopwatch = Stopwatch()..start();
        //For detecting faces
        final InputImage inputImage =
            convertCameraImageToInputImage(image, controller);

        //For recognizing faces
        final img.Image imgImage = convertCameraImageToImgImage(
            image, controller.description.lensDirection);
        print(
            'the width of the image for recognising from live feed ios ${imgImage.width}');
        print(
            'the height of the image for recognising from live feed ios ${imgImage.height}');

        final faceDetected = await detectController
            .detectFromLiveFeedForRecognition(
                [inputImage], [imgImage], widget.faceDetector);

        if (faceDetected.isNotEmpty) {
          print('Face Detected');
          final name = await recognizeController.pickImagesAndRecognize(
              faceDetected[0],
              widget.interpreter,
              widget.isolateInterpreter,
              widget.studentFile);

          if (name.isNotEmpty) {
            attendancController.attendedList(
                name, widget.day, widget.coursename, widget.attended);
          }

          // if (widget.nameOfScreen == 'Home') {
          //   await recognizeController.pickImagesAndRecognize(
          //       faceDetected[0],
          //       widget.interpreter,
          //       widget.isolateInterpreter,
          //       widget.studentFile);
          // } else {
          //   final name = await recognizeController.liveFeedRecognize(
          //       faceDetected[0],
          //       widget.interpreter,
          //       widget.isolateInterpreter,
          //       widget.studentFile);

          //   if (name.isNotEmpty) {
          //     attendancController.attendedList(
          //         name, widget.day, widget.coursename, widget.attended);
          //   }
          // }
        }

        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print(
            'Detection and Recognition from live feed Execution Time: $elapsedSeconds seconds');
      }
    });
  }

  Widget build(BuildContext context) {
    //////////////////////////////////changes///////////////////////////////////////////////////////////////
    // final recognizeState = ref.watch(recognizefaceProvider);
    // final detectState = ref.watch(faceDetectionProvider);

    final recognizeState = ref.watch(recognizefaceProvider(widget.family));
    final detectState = ref.watch(faceDetectionProvider(widget.family));

    if (recognizeState is SuccessState && detectState is SuccessState) {
      message = 'Recognized: ${recognizeState.name}';
    } else if (recognizeState is ErrorState && detectState is SuccessState) {
      message = ' ${recognizeState.errorMessage}';
    } else if (detectState is ErrorState) {
      message = detectState.errorMessage;
      // 'No face Detected';
    }

    // }else if(detectState is ErrorState){
    //
    //   message = detectState.errorMessage;
    //   // 'No face Detected';
    // }
    // else{
    //   message = 'No face detected';
    // }

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   leading: GestureDetector(
        //     onTap: () async {
        //       await disposeController();
        //       Navigator.pop(context,);
        //     },
        //     child: const Icon(Icons.arrow_back),
        //   ),
        // ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // AspectRatio(
            //    aspectRatio: controller.value.aspectRatio,
            // child: CameraPreview(controller)),
            //  Positioned(
            //   top: 16,
            //   left: 16,
            //   child: GestureDetector(
            //     child: ,
            //   ),

            // ),

            CameraPreview(controller),
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
