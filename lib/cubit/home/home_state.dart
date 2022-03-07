part of 'home_cubit.dart';

@immutable
abstract class HomeBaseState {}

class HomeInitialState extends HomeBaseState {}

class HomeLoadingState extends HomeState {
  HomeLoadingState(HomeChildrenState childrenState) : super(childrenState);
}

class HomeLoadedState extends HomeState {
  bool isRestoreState;
  int? previous_page;
  int current_page;
  int? next_page;

  HomeLoadedState(HomeChildrenState childrenState, this.current_page,
      {this.isRestoreState = false, this.previous_page, this.next_page})
      : super(childrenState);
}

class HomeGalleryState extends HomeChildState {
  List<dynamic>? peoples;
  Map<dynamic, List<dynamic>> timeline;

  HomeGalleryState(
      {
      required this.peoples,
      required this.timeline,
      required dynamic data})
      : super(data: data);
}

class HomeFailedState extends HomeLoadedState {
  HomeFailedState({required HomeChildrenState childrenState})
      : super(childrenState, -1);
}

class HomeState extends HomeBaseState {
  HomeChildrenState childrenState;

  HomeState(this.childrenState);
}

class HomeChildState extends HomeBaseState {
  dynamic data;

  HomeChildState({required this.data});
}

class HomeChildrenState {
  HomeGalleryState? galleryChildState;
  HomeChildState? fridayChildState;
  HomeChildState? favoriteChildState;
  HomeChildState? tagChildState;
  HomeChildState? peopleChildState;
}
