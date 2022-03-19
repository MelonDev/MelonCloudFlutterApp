part of 'book_library_cubit.dart';

@immutable
abstract class BookLibraryBaseState {}

class BookLibraryInitialState extends BookLibraryBaseState {}

class BookLibraryState extends BookLibraryBaseState {
  int? previousPage;
  int currentPage;
  int? nextPage;

  List<dynamic> timeline;
  dynamic data;

  BookLibraryState(
      {this.previousPage,
        required this.currentPage,
        this.nextPage,
        required this.timeline,
        this.data});
}
class BookLibraryLoadingState extends BookLibraryBaseState {
  BookLibraryState? previousState;

  BookLibraryLoadingState({this.previousState});
}
class BookLibraryFailureState extends BookLibraryBaseState {
  BookLibraryState? previousState;

  BookLibraryFailureState({this.previousState});
}

