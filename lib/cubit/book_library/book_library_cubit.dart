import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meloncloud_flutter_app/environment/app_environment.dart';
import 'package:meloncloud_flutter_app/extensions/http_extension.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'book_library_state.dart';

class BookLibraryCubit extends Cubit<BookLibraryBaseState> {
  BookLibraryCubit() : super(BookLibraryInitialState());

  final String _path = "api/v2/meloncloud-book";
  final String _server = AppEnvironment.server;
  final String _token = AppEnvironment.bookApiKey;

  load({BookLibraryState? previousState,String? command}) async {
    emit(BookLibraryLoadingState(previousState: previousState));
  }

}
