part of 'home_cubit.dart';

@immutable
abstract class HomeBaseState {}

class HomeInitialState extends HomeBaseState {}

class HomeLoadingState extends HomeState {
  HomeLoadingState(HomeChildrenState childrenState) : super(childrenState);
}

class HomeLoadedState extends HomeState {
  bool isRestoreState;

  HomeLoadedState(HomeChildrenState stackState, {this.isRestoreState = false})
      : super(stackState);
}

class HomeFailedState extends HomeLoadedState {
  HomeFailedState({required HomeChildrenState childrenState})
      : super(childrenState);
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
  HomeChildState? galleryChildState;
  HomeChildState? fridayChildState;
  HomeChildState? favoriteChildState;
  HomeChildState? tagChildState;
  HomeChildState? peopleChildState;
}
