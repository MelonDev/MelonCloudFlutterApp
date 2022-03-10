part of 'peoples_cubit.dart';

@immutable
abstract class PeoplesBaseState {}

class PeoplesInitialState extends PeoplesBaseState {}

class PeoplesState extends PeoplesBaseState {
  int? previousPage;
  int currentPage;
  int? nextPage;

  List<dynamic> timeline;
  dynamic data;

  PeoplesState(
      {required this.currentPage,
      required this.timeline,
      this.data,
      this.previousPage,
      this.nextPage});
}

class PeoplesLoadingState extends PeoplesBaseState {
  PeoplesState? previousState;

  PeoplesLoadingState({this.previousState});
}

class PeoplesFailureState extends PeoplesBaseState {
  PeoplesState? previousState;

  PeoplesFailureState({this.previousState});
}
