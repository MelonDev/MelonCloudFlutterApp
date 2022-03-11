part of 'profile_cubit.dart';

@immutable
abstract class ProfileBaseState {}

class ProfileInitialState extends ProfileBaseState {}

class ProfileState extends ProfileBaseState {
  int? previousPage;
  int currentPage;
  int? nextPage;

  dynamic profile;
  Map<dynamic, List<dynamic>> timeline;
  List<dynamic>? hashtags;
  dynamic data;

  ProfileState(
      {required this.currentPage,
      required this.profile,
      required this.timeline,
      this.hashtags,
      this.data,
      this.previousPage,
      this.nextPage});
}

class ProfileLoadingState extends ProfileBaseState {
  ProfileState? previousState;

  ProfileLoadingState({this.previousState});
}

class ProfileFailureState extends ProfileBaseState {
  ProfileState? previousState;

  ProfileFailureState({this.previousState});
}
