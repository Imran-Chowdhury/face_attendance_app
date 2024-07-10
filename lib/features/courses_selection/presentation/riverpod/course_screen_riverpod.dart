import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/base_state/course_screen_state.dart';

final courseScreenProvider =
    StateNotifierProvider.family((ref, courseName) => CourseScreenNotifier());

class CourseScreenNotifier extends StateNotifier<CourseScreenState> {
  CourseScreenNotifier() : super(const CourseScreenInitialState());

  void dayList(String courseName, String date, List<dynamic>? listOfDates,
      Map<String, List<dynamic>>? attendanceMap) {
    state = const CourseScreenLoadingState();

    try {
      if (!listOfDates!.contains(date)) {
        listOfDates.add(date);
        state = CourseScreeenSuccessState(data: listOfDates);
        Fluttertoast.showToast(msg: 'New date added');

        saveOrUpdateJsonInSharedPreferences(date, courseName);
      } else {
        state = CourseScreeenSuccessState(data: listOfDates);
        Fluttertoast.showToast(msg: 'This date already exists');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveOrUpdateJsonInSharedPreferences(
      String key, String courseName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? existingJsonString = prefs.getString(courseName); //Course 1

    // for(int i  = 0; i<listOfOutputs.length; i++){
    //   print('The $i st list of $key is ${listOfOutputs[i]} ');
    // }

    if (existingJsonString == null) {
      // If the JSON file doesn't exist, create a new one with the provided key and value
      Map<String, dynamic> newJsonData = {key: []};
      // Map<String, List<List<double>>> newJsonData = {key: listOfOutputs};
      await prefs.setString(courseName, jsonEncode(newJsonData));
    } else {
      // If the JSON file exists, update it
      Map<String, dynamic> existingJson =
          json.decode(existingJsonString) as Map<String, dynamic>;

      existingJson[key] = [];

      // Check if the key already exists in the JSON
      // if (existingJson.containsKey(key)) {
      //   // If the key exists, update its value
      //   // existingJson[key] = listOfOutputs;
      // } else {
      //   // If the key doesn't exist, add a new key-value pair
      //   existingJson[key] = listOfOutputs;
      // }

      await prefs.setString(courseName, jsonEncode(existingJson));
      // dynamic printMap = await readMapFromSharedPreferencesFromTrainDataSource(nameOfJsonFile);
      // print('The name of the file is $nameOfJsonFile');
      // print(printMap);
    }
  }
}
