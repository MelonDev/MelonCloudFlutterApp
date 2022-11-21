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

  final String _path = "v1/meloncloud/bookshelf";
  final String _server = AppEnvironment.server;
  final String _token = AppEnvironment.bookApiKey;

  load({BookLibraryState? previousState, String? command}) async {
    emit(BookLibraryLoadingState(previousState: previousState));
  }

  book({BookState? previousState, required String bookid}) async {
    emit(BookLoadingState(previousState: previousState));


    var params = {'id': bookid};

    Uri uri = Uri.https(_server, '/v1/meloncloud/bookshelf/bypass', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      dynamic responseData = response.data['data'];
      dynamic pages = responseData['pages'];
      dynamic name = responseData['name'];
      dynamic language = responseData['language'];
      dynamic artist = responseData['artist'];
      dynamic group = responseData['group'];

      List<dynamic> timeline =
          previousState?.timeline != null ? previousState!.timeline : [];

      timeline.addAll(pages);
      BookState state = BookState(
        name: name,
        language: language,
        artist:artist,
        group: group,
        timeline: timeline,
        data: response.data,
      );
      emit(state);
    } else if (response.statusCode == 400) {
      if (previousState != null) {
        emit(previousState);
      }
    } else {
      emit(BookFailureState(previousState: previousState));
    }
  }
}
