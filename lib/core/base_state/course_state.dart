

abstract class CourseState{
  const CourseState();
}

class CourseInitialState extends CourseState{
  const CourseInitialState();
}

class  CourseLoadingState<T> extends CourseState{
  const   CourseLoadingState({this.data});

  final T? data;
}

class  CourseSuccessState<T> extends CourseState {
  const  CourseSuccessState({this.data, this.name});

  final T? data;
  final T? name;
}


class  CourseErrorState extends CourseState {
  final String errorMessage;

  const  CourseErrorState(this.errorMessage);
}