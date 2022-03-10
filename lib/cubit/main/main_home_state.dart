part of 'main_cubit.dart';

class MainHomeState extends MainTimelineState {
  List<dynamic> peoples;

  MainHomeState({required this.peoples,
    required int currentPage,
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

class MainHomeFailureState extends MainState {
  MainHomeState? previousState;

  MainHomeFailureState({this.previousState});
}

class MainHomeLoadingState extends MainState {
  MainHomeState? previousState;

  MainHomeLoadingState({this.previousState});
}