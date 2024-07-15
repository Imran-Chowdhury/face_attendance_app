import 'dart:async';

import 'package:camera/camera.dart';

import 'package:face_attendance_app/features/live_feed/presentation/views/live_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

import '../../../../core/base_state/base_state.dart';
import '../../../../core/base_state/course_state.dart';
import '../../../../core/constants/constants.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../riverpod/course_selection_riverpod.dart';

class CourseDayScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CourseDayScreen> createState() => _CourseDayScreenState();

  CourseDayScreen({
    super.key,
    required this.attendedStudentsMap,
    required this.day,
    required this.courseName,
    required this.isolateInterpreter,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,
  });

  Map<String, List<dynamic>> attendedStudentsMap;
  String day;
  String courseName;

  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;

  // List<String> attendedStudentsList;
}

// 2. extend [ConsumerState]
class _CourseDayScreenState extends ConsumerState<CourseDayScreen> {
  List<dynamic>? attended;
  @override
  void initState() {
    attended = mapToList(widget.attendedStudentsMap, widget.day);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Constants constant = Constants();
    String family = "${widget.courseName}- ${widget.day}";
    final detectController = ref.watch(faceDetectionProvider(family).notifier);
    final recognizeController =
        ref.watch(recognizefaceProvider(family).notifier);

    final recognizeState = ref.watch(recognizefaceProvider(family));
    final detectState = ref.watch(faceDetectionProvider(family));
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool attendedListExecuted = false;

    // String family = "${widget.courseName}- ${widget.day}";
    // final detectController = ref.watch(faceDetectionProvider.notifier);
    // final recognizeState = ref.watch(recognizefaceProvider);
    // final detectState = ref.watch(faceDetectionProvider);

    var attendanceState = ref.watch(attendanceProvider(family));
    AttendanceNotifier attendanceController =
        ref.watch(attendanceProvider(family).notifier);

    // List<dynamic>? attended = mapToList(widget.attendedStudentsMap, widget.day);
    print('the attended list is $attended');

    if (attendanceState is AttendanceSuccessState) {
      attended = attendanceState.data;
    }

    // if (recognizeState is SuccessState && detectState is SuccessState) {
    //   // Execute attendedList only once when both states are SuccessState
    //   if (attendedListExecuted == false) {
    //     Future(() {
    //       String name = recognizeState.name;
    //       attendanceController.attendedList(
    //           name, widget.day, widget.courseName, attended);
    //     });
    //     // Set the flag to true
    //     attendedListExecuted = true;
    //   }
    // } else {
    //   attendedListExecuted =
    //       false; // Reset the flag if states are not both SuccessState
    // }

    // if (recognizeState is SuccessState && detectState is SuccessState) {
    //   Future(() {
    //     String name = recognizeState.name;
    //     attendanceController.attendedList(
    //         name, widget.day, widget.courseName, attended);
    //   });
    // }

    // if (recognizeState is SuccessState && detectState is SuccessState) {
    //   // message = 'Recognized: ${recognizeState.name}';
    //   Future(() {
    //     String name = recognizeState.name;
    //     attendanceController.attendedList(
    //         name, widget.day, widget.courseName, attended);
    //   });
    // } else if (recognizeState is ErrorState && detectState is SuccessState) {
    //   String message = ' ${recognizeState.errorMessage}';
    //   Fluttertoast.showToast(msg: message);
    // } else if (detectState is ErrorState) {
    //   String msg = detectState.errorMessage;
    //   Fluttertoast.showToast(msg: msg);
    //   // 'No face Detected';
    // }

    return Scaffold(
      appBar: AppBar(
        actions: [
          add(context, _formKey, attendanceController, attended, widget.day,
              widget.courseName),
        ],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,

        children: [
          (attendanceState is AttendanceSuccessState)
              ? listOfAttendedStudents(attendanceState.data,
                  attendanceController, attended, widget.day, widget.courseName)
              : listOfAttendedStudents(attended, attendanceController, attended,
                  widget.day, widget.courseName),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  goToLiveFeedScreen(
                      context,
                      detectController,
                      'Total Students',
                      attended,
                      widget.day,
                      family,
                      recognizeController);
                },
                child: const Text('Attend'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listOfAttendedStudents(
    List<dynamic>? attendedList,
    AttendanceNotifier attendanceController,
    List<dynamic>? attended,
    String day,
    String courseName,
  ) {
    return Expanded(
      child: ListView.builder(
        itemCount: attendedList?.length,
        itemBuilder: (context, index) {
          String name = attendedList![index];
          print('The attended students are $attendedList');
          return GestureDetector(
            onLongPress: () {
              showDeleteOption(context, name, attendanceController, attended,
                  day, courseName);
            },
            child: ListTile(
              // title: Text(attendedList![index]),
              title: Text(name),
            ),
          );
        },
      ),
    );
  }

  Future<void> goToLiveFeedScreen(
    context,
    FaceDetectionNotifier detectController,
    fileName,
    List<dynamic>? attended,
    String day,
    String family,
    RecognizeFaceNotifier recognizeController,
  ) async {
    List<CameraDescription> cameras = await availableCameras();

    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => LiveFeedScreen(
          isolateInterpreter: widget.isolateInterpreter,
          // detectionController: detectController,
          faceDetector: widget.faceDetector,
          cameras: cameras,
          interpreter: widget.interpreter,
          studentFile: fileName,
          family: family,
          nameOfScreen: 'Course',
          day: day,
          attended: attended,
          coursename: widget.courseName,
          // livenessInterpreter: livenessInterpreter,
        ),
      ),
    );
  }

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

  Widget add(
      BuildContext context,
      GlobalKey<FormState> formKey,
      AttendanceNotifier attendanceController,
      List<dynamic>? attended,
      String day,
      String courseName) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController nameController = TextEditingController();

            return AlertDialog(
              title: const Text('Add a Student'),
              contentPadding:
                  const EdgeInsets.all(24), // Adjust padding for bigger size
              content: Form(
                key: formKey,
                // mainAxisSize: MainAxisSize.min,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter name of student',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name to add';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Validation passed, proceed with saving

                      // Perform save operation or any other logic here
                      attendanceController.manualAttend(attended,
                          nameController.text.trim(), courseName, day);

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDeleteOption(
      BuildContext context,
      String name,
      AttendanceNotifier attendanceController,
      List<dynamic>? attended,
      String day,
      String courseNam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $name?'),
          content: Text('Are you sure you want to delete $name?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Perform delete operation here
                attendanceController.deleteName(
                    attended, name, widget.courseName, day);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
