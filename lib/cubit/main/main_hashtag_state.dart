part of 'main_cubit.dart';

class MainHashtagState extends MainState {
  int? previousPage;
  int currentPage;
  int? nextPage;
  String query;

  List<dynamic> timeline;
  dynamic data;
  String? dateStart;
  String? dateEnd;

  MainHashtagState(
      {this.previousPage,
      required this.currentPage,
      required this.query,
      this.nextPage,
      required this.timeline,
      this.data,
      this.dateStart,
      this.dateEnd});
}

class MainHashtagFailureState extends MainState {
  MainHashtagState? previousState;

  MainHashtagFailureState({this.previousState});
}

class MainHashtagLoadingState extends MainState {
  MainHashtagState? previousState;

  MainHashtagLoadingState({this.previousState});
}
