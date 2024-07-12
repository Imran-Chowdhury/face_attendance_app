abstract class AttendanceState {
  const AttendanceState();
}

class AttendanceInitialState extends AttendanceState {
  const AttendanceInitialState();
}

class AttendanceLoadingState<T> extends AttendanceState {
  const AttendanceLoadingState({this.data});

  final T? data;
}

class AttendanceSuccessState<T> extends AttendanceState {
  const AttendanceSuccessState({this.data, this.name});

  final T? data;
  final T? name;
}

class AttendanceErrorState extends AttendanceState {
  final String errorMessage;

  const AttendanceErrorState(this.errorMessage);
}
