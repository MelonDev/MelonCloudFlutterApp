import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meloncloud_flutter_app/extensions/http_extension.dart';
import 'package:meta/meta.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';

part 'tweet_state.dart';

class TweetCubit extends Cubit<TweetState> {
  final String _path = "api/v3/twitter";
  final String _server = dotenv.env['SERVER'] ?? "";
  final String _token = dotenv.env['TWITTER_VIEWER_TOKEN'] ?? "";

  TweetCubit() : super(TweetInitialState());

  load(String tweetid) async {
    emit(LoadingTweetState());

    var params = _params();

    Uri uri = Uri.https(_server, '/$_path/tweets/$tweetid', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      emit(LoadedTweetState(response.data['data']));
    } else {
      emit(TweetFailureState());
    }
  }

  Map<String, String> _params({Map<String, String>? targets}) {
    Map<String, String> params = {
      'token': _token,
    };

    targets?.let((it) {
      params.addAll(targets);
    });

    return params;
  }
}
