part of 'main_cubit.dart';

class MainMoreState extends MainState {
  dynamic summary;
  Map<String, dynamic>? portfolios;
  Map<String, dynamic>? coins;

  MainMoreState({this.summary, this.portfolios, this.coins});
}

class MainMoreFailureState extends MainState {
  MainMoreState? previousState;

  MainMoreFailureState({this.previousState});
}

class MainMoreLoadingState extends MainState {
  MainMoreState? previousState;

  MainMoreLoadingState({this.previousState});
}
