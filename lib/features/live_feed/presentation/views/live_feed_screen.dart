import 'package:camera/camera.dart';
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

class LiveFeedScreen extends ConsumerStatefulWidget {
  LiveFeedScreen({
    Key? key,
    required this.isolateInterpreter,
    required this.detectionController,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,
    required this.studentFile,
    required this.family,
  }) : super(key: key);

  final FaceDetectionNotifier detectionController;
  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;

  // final tf_lite.Interpreter livenessInterpreter;
  late String studentFile;
  late String family;

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

    await widget.faceDetector.close();
    await widget.isolateInterpreter.close();
    widget.cameras.clear();
    widget.interpreter.close();

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
          // await livenessDetection(faceDetected[0], widget.livenessInterpreter);

          await recognizeController.pickImagesAndRecognize(
              faceDetected[0],
              widget.interpreter,
              widget.isolateInterpreter,
              widget.studentFile);
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

    return Scaffold(
      // appBar: AppBar(
      //   leading: GestureDetector(
      //     onTap: () async {
      //       await disposeController();
      //       Navigator.pop(context);
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
    );
  }
}
































// import 'package:camera/camera.dart';
// import 'package:face_attendance_app/features/courses_selection/presentation/riverpod/course_selection_riverpod.dart';
// // import 'package:face/core/base_state/base_state.dart';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image/image.dart' as img;
// import '../../../../core/base_state/base_state.dart';
// import '../../../../core/utils/convert_camera_image_to_img_image.dart';
// import '../../../../core/utils/convert_camera_image_to_input_image.dart';
// import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
// import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';

// import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

// class LiveFeedScreen extends ConsumerStatefulWidget {
//   LiveFeedScreen({
//     super.key,
//     required this.isolateInterpreter,
//     required this.detectionController,
//     required this.faceDetector,
//     required this.cameras,
//     required this.interpreter,
//     required this.nameOfAllStudentFile,
//     // this.day,
//     // this.attended,
//     // this.courseName,
//     // this.attendedStudentsMap,
//   });

//   final FaceDetectionNotifier detectionController;
//   final FaceDetector faceDetector;
//   late List<CameraDescription> cameras;
//   final tf_lite.Interpreter interpreter;
//   final tf_lite.IsolateInterpreter isolateInterpreter;

//   // final tf_lite.Interpreter livenessInterpreter;
//   late String nameOfAllStudentFile;
//   late String? courseName;
//   late String? day;
//   late List<dynamic>? attended;
//   // Map<String, List<dynamic>> attendedStudentsMap = {};

//   @override
//   ConsumerState<LiveFeedScreen> createState() => _LiveFeedScreenState();
// }

// // 2. extend [ConsumerState]
// class _LiveFeedScreenState extends ConsumerState<LiveFeedScreen> {
//   late CameraController controller;
//   int numberOfFrames = 0;
//   // int frameSkipCount = 15;
//   // int frameSkipCount = 25;
//   int frameSkipCount = 40;
//   List frameList = [];
//   String message = '';

//   @override
//   void initState() {
//     super.initState();
//     initializeCameras();
//     print('Camera initialized');
//   }

//   Future<void> initializeCameras() async {
//     controller = CameraController(
//       widget.cameras[1],
//       // widget.cameras[0],
//       ResolutionPreset.low,
//       // ResolutionPreset.medium,
//       // ResolutionPreset.high,
//       // ResolutionPreset.veryHigh,
//       // ResolutionPreset.max,
//       enableAudio: false,
//     );
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//       startStream(controller);
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//             // Handle access errors here.
//             break;
//           default:
//             // Handle other errors here.
//             break;
//         }
//       }
//     });
//     // await startStream(controller);
//   }

//   @override
//   void dispose() {
//     controller.stopImageStream();
//     controller.dispose();

//     print('disposed');
//     super.dispose();
//   }

//   Future<void> startStream(CameraController controller) async {
//     final detectController = ref.watch(faceDetectionProvider.notifier);
//     // final detectState = ref.watch(faceDetectionProvider);
//     final recognizeController = ref.watch(recognizefaceProvider.notifier);

//     //Image Streaming
//     controller.startImageStream((image) async {
//       // print('The camera image format is ${image.format.group}');

//       numberOfFrames++;
//       if (numberOfFrames % frameSkipCount == 0) {
//         print('the number of frames are $numberOfFrames');

//         // DateTime start = DateTime.now();
//         final stopwatch = Stopwatch()..start();
//         //For detecting faces
//         final InputImage inputImage =
//             convertCameraImageToInputImage(image, controller);

//         //For recognizing faces
//         final img.Image imgImage = convertCameraImageToImgImage(
//             image, controller.description.lensDirection);
//         print(
//             'the width of the image for recognising from live feed ios ${imgImage.width}');
//         print(
//             'the height of the image for recognising from live feed ios ${imgImage.height}');

//         final faceDetected = await detectController
//             .detectFromLiveFeedForRecognition(
//                 [inputImage], [imgImage], widget.faceDetector);

//         if (faceDetected.isNotEmpty) {
//           print('Face Detected');
//           // await livenessDetection(faceDetected[0], widget.livenessInterpreter);

//           await recognizeController.pickImagesAndRecognize(
//               faceDetected[0],
//               widget.interpreter,
//               widget.isolateInterpreter,
//               widget.nameOfAllStudentFile);
//         }

//         stopwatch.stop();
//         final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
//         print(
//             'Detection and Recognition from live feed Execution Time: $elapsedSeconds seconds');
//       }
//     });
//   }

//   Widget build(BuildContext context) {
//     final recognizeState = ref.watch(recognizefaceProvider);
//     final detectState = ref.watch(faceDetectionProvider);
//     // final attendanceController =
//     //     ref.watch(attendanceProvider(widget.day).notifier);

//     if (recognizeState is SuccessState && detectState is SuccessState) {
//       message = 'Recognized: ${recognizeState.name}';
//       // attendanceController.attendedList(recognizeState.name, widget.day!,
//       //     widget.courseName!, widget.attended);
//     } else if (recognizeState is ErrorState && detectState is SuccessState) {
//       message = ' ${recognizeState.errorMessage}';
//     } else if (detectState is ErrorState) {
//       message = detectState.errorMessage;
//       // 'No face Detected';
//     }

    
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // AspectRatio(
//         //    aspectRatio: controller.value.aspectRatio,
//         // child: CameraPreview(controller)),
//         CameraPreview(controller),
//         Positioned(
//           bottom: 16,
//           left: 16,
//           child: Text(
//             message,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
