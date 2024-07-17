// import 'dart:async';

import 'package:camera/camera.dart';
import 'package:face_attendance_app/core/constants/constants.dart';
import 'package:face_attendance_app/core/utils/background_widget.dart';
import 'package:face_attendance_app/core/utils/customButton.dart';
// import 'package:face_attendance_app/core/utils/customButton.dart';

import 'package:face_attendance_app/features/live_feed/presentation/views/live_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;

// import '../../../../core/base_state/base_state.dart';
import '../../../../core/base_state/course_state.dart';
// import '../../../../core/constants/constants.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../riverpod/course_selection_riverpod.dart';

// ignore: must_be_immutable
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
    // Constants constant = Constants();
    String family = "${widget.courseName}- ${widget.day}";
    final detectController = ref.watch(faceDetectionProvider(family).notifier);
    final recognizeController =
        ref.watch(recognizefaceProvider(family).notifier);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    var attendanceState = ref.watch(attendanceProvider(family));
    AttendanceNotifier attendanceController =
        ref.watch(attendanceProvider(family).notifier);

    // List<dynamic>? attended = mapToList(widget.attendedStudentsMap, widget.day);
    print('the attended list is $attended');

    if (attendanceState is AttendanceSuccessState) {
      attended = attendanceState.data;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            widget.courseName,
            style: const TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          )),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 20,
          backgroundColor: const Color.fromARGB(255, 101, 123, 120),
          // backgroundColor: ColorConst.backgroundColor,
          actions: [
            add(context, _formKey, attendanceController, attended, widget.day,
                widget.courseName),
          ],
        ),
        body: Stack(
          children: [
            const BackgroudContainer(),
            Column(
              // mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    'Date -${widget.day}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                (attendanceState is AttendanceSuccessState)
                    ? listOfAttendedStudents(
                        attendanceState.data,
                        attendanceController,
                        attended,
                        widget.day,
                        widget.courseName)
                    : listOfAttendedStudents(attended, attendanceController,
                        attended, widget.day, widget.courseName),
                CustomButton(
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
                    buttonName: 'Attend',
                    icon: const Icon(Icons.add_a_photo))
              ],
            ),
          ],
        ),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                padding: const EdgeInsets.only(right: 12.0),
                decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 1.0, color: Colors.white24))),
                child: const Icon(Icons.person_2_outlined, color: Colors.white),
              ),
              title: Text(
                name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Row(
                children: <Widget>[
                  Icon(Icons.linear_scale, color: ColorConst.darkButtonColor),
                  Text(" Present", style: TextStyle(color: Colors.white))
                ],
              ),
              // trailing: const Icon(Icons.keyboard_arrow_right,
              //     color: Colors.white, size: 30.0),
            ),
          );
        },
      ),
    );
  }

  Future<void> goToLiveFeedScreen(
    BuildContext context,
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
      icon: const Icon(
        Icons.person_add,
        color: Colors.white,
      ),
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



//  Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     // child:
//                     // CustomButton(
//                     //   onPressed: () async {
//                     //     await goToLiveFeedScreen(
//                     //         context,
//                     //         detectController,
//                     //         'Total Students',
//                     //         attended,
//                     //         widget.day,
//                     //         family,
//                     //         recognizeController);
//                     //   },
//                     //   buttonName: 'Attend',
//                     //   icon: const Icon(Icons.add_a_photo),
//                     // ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [
//                             // ColorConst.darkButtonColor,
//                             // ColorConst.lightButtonColor
//                             Colors.blue, Colors.purple,
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors
//                               .transparent, // Remove default button background
//                           shadowColor: Colors.transparent, // Remove shadow
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         onPressed: () {
//                           goToLiveFeedScreen(
//                               context,
//                               detectController,
//                               'Total Students',
//                               attended,
//                               widget.day,
//                               family,
//                               recognizeController);
//                         },
//                         child: const Text(
//                           'Attend',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

