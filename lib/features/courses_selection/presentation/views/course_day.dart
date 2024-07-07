import 'package:face_attendance_app/core/utils/customButton.dart';
import 'package:face_attendance_app/features/live_feed/presentation/views/live_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base_state/course_state.dart';
import '../riverpod/course_selection_riverpod.dart';

class CourseDayScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CourseDayScreen> createState() => _CourseDayScreenState();
  CourseDayScreen(
      {super.key, required this.attendedStudents, required this.day});
  List<String> attendedStudents;
  String day;
}

// 2. extend [ConsumerState]
class _CourseDayScreenState extends ConsumerState<CourseDayScreen> {
  // @override
  // void initState() {
  //   super.initState();

  // }

  @override
  Widget build(BuildContext context) {
    // 4. use ref.watch() to get the value of the provider
    // final helloWorld = ref.watch(helloWorldProvider);
    var dayState = ref.watch(courseProvider(widget.day));
    CourseNotifier dayController =
        ref.watch(courseProvider(widget.day).notifier);

    List<String>? attended = widget.attendedStudents;

    //  if(CourseState is CourseSuccessState){
    //   attended = CourseState.data;
    // }

    return Scaffold(
      body: Column(
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

          Container(
            color: Colors.red,
            height: 100,
            width: 100,
          ),
        ],
      ),
    );
  }

  // void navigateToLiveFeed(context, widget.attended ) {
  //   Navigator.push(
  //     context,
  //     // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
  //     MaterialPageRoute(
  //       builder: (context) => LiveFeedScreen(),
  //     ),
  //   );
  // }
}
