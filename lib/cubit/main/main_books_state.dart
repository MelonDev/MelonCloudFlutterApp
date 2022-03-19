part of 'main_cubit.dart';

class MainBooksState extends MainState {
  int? previousPage;
  int currentPage;
  int? nextPage;

  List<dynamic> timeline;
  dynamic data;

  MainBooksState(
      {this.previousPage,
      required this.currentPage,
      this.nextPage,
      required this.timeline,
      this.data});
}

class MainBooksLoadingState extends MainState {
  MainBooksState? previousState;

  MainBooksLoadingState({this.previousState});
}

class MainBooksFailureState extends MainState {
  MainBooksState? previousState;

  MainBooksFailureState({this.previousState});
}
