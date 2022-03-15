part of 'hashtags_cubit.dart';

@immutable
abstract class HashtagsBaseState {}

class HashtagsInitialState extends HashtagsBaseState {}

class HashtagsState extends HashtagsBaseState {
  int? previousPage;
  int currentPage;
  int? nextPage;
  String hashtagName;

  Map<dynamic, List<dynamic>> timeline;
  dynamic data;

  HashtagsState(
      {this.previousPage,
        required this.currentPage,
        required this.hashtagName,
        this.nextPage,
        required this.timeline,
        this.data});
}

class HashtagsLoadingState extends HashtagsBaseState {
  HashtagsState? previousState;

  HashtagsLoadingState({this.previousState});
}

class HashtagsFailureState extends HashtagsBaseState {
  HashtagsState? previousState;

  HashtagsFailureState({this.previousState});
}
