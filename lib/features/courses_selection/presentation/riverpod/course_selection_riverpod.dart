import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/base_state/course_state.dart';

final courseProvider =
    StateNotifierProvider.family((ref, day) => CourseNotifier());

class CourseNotifier extends StateNotifier<CourseState> {
  CourseNotifier() : super(const CourseInitialState());

  void attendedList(String message, List<dynamic>? attended) {
    state = const CourseLoadingState();
    if (!attended!.contains(message)) {
      attended.add(message);
      //save the person in the main attendance sheet fro the particular day
    }
    state = CourseSuccessState(data: attended);

    print('The state is $state');
  }
}
