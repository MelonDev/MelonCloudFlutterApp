part of 'main_cubit.dart';

@immutable
abstract class MainState {}

class MainInitialState extends MainState {}

class MainTimelineState extends MainState {
  int? previousPage;
  int currentPage;
  int? nextPage;

  Map<dynamic, List<dynamic>> timeline;
  dynamic data;

  MainTimelineState(
      {this.previousPage,
      required this.currentPage,
      this.nextPage,
      required this.timeline,
      this.data});
}
