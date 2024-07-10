abstract class CourseScreenState {
  const CourseScreenState();
}

class CourseScreenInitialState extends CourseScreenState {
  const CourseScreenInitialState();
}

class CourseScreenLoadingState<T> extends CourseScreenState {
  const CourseScreenLoadingState({this.data});

  final T? data;
}

class CourseScreeenSuccessState<T> extends CourseScreenState {
  const CourseScreeenSuccessState({this.data, this.name});

  final T? data;
  final T? name;
}

class CourseScreenErrorState extends CourseScreenState {
  final String errorMessage;

  const CourseScreenErrorState(this.errorMessage);
}
