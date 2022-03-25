part of 'main_cubit.dart';

class MainMoreState extends MainState {}

class MainMoreFailureState extends MainState {
  MainMoreState? previousState;

  MainMoreFailureState({this.previousState});
}

class MainMoreLoadingState extends MainState {
  MainMoreState? previousState;

  MainMoreLoadingState({this.previousState});
}
