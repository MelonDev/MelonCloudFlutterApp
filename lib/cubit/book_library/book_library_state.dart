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

class BookState extends BookLibraryBaseState {
  List<dynamic> timeline;
  dynamic data;
  String name;
  String? artist;
  String? language;
  String? group;

  BookState(
      {
      required this.name,
      this.artist,
      this.language,
      this.group,
      required this.timeline,
      this.data});
}

class BookLoadingState extends BookLibraryBaseState {
  BookState? previousState;

  BookLoadingState({this.previousState});
}

class BookFailureState extends BookLibraryBaseState {
  BookState? previousState;

  BookFailureState({this.previousState});
}
