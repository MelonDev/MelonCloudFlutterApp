part of 'main_cubit.dart';

class MainEventState extends MainTimelineState {
  MainEventState(
      {required int currentPage,
        required Map<dynamic, List<dynamic>> timeline,
        dynamic data,
        int? previousPage,
        int? nextPage})
      : super(
      previousPage: previousPage,
      currentPage: currentPage,
      nextPage: nextPage,
      timeline: timeline,
      data: data);
}

class MainEventLoadingState extends MainState {
  MainEventState? previousState;

  MainEventLoadingState({this.previousState});
}

class MainEventFailureState extends MainState {
  MainEventState? previousState;

  MainEventFailureState({this.previousState});
}
