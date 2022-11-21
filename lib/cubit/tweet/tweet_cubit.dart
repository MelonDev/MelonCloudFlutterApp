import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meloncloud_flutter_app/environment/app_environment.dart';
import 'package:meloncloud_flutter_app/extensions/http_extension.dart';
import 'package:meta/meta.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';
import 'package:url_launcher/url_launcher.dart';

part 'tweet_state.dart';

class TweetCubit extends Cubit<TweetBaseState> {
  final String _path = "v1/meloncloud/twitter";
  final String _server = AppEnvironment.server;
  final String _token = AppEnvironment.token;

  TweetCubit() : super(TweetInitialState());

  load(String tweetid) async {
    emit(LoadingTweetState());

    var params = _params();
    params.addAll({
      "translate": "true"
    });

    Uri uri = Uri.https(_server, '/$_path/tweets/$tweetid', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      emit(TweetState(response.data['data']));
    } else {
      emit(TweetFailureState());
    }
  }

  openTwitterProfile(String id) async {
    String url = 'https://twitter.com/intent/user?user_id=$id';

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  openSearchTwitterProfile(String id) async {
    String url = 'https://twitter.com/search?q=%40$id&f=live';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  openTweet(String id) async {
    String url = 'https://twitter.com/_MelonDev_/status/$id';
    if (await canLaunch(url)) {
      print("canLaunch");
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  /*
  secretLikeTweet(LoadedTweetDetailState state, String id,
      {Function function}) async {
    emit(LoadingTweetDetailState(previousState: state));
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };

    Uri uri = Uri.https(
        'melondev-cloud.herokuapp.com', '/api/twitter/$id/secret_like');

    dynamic data = await _loadData(uri, headers);

    if (function != null) {
      function.call();
    }

    emit(LoadedTweetDetailState(data));
  }

   */

  like(TweetState state) async {
    emit(LoadingTweetState(previousState:state));

    var params = _params();
    params.addAll({
      "tweetid": "${state.data['id']}",
      "action": "LIKE",
      "translate": "true"
    });

    Uri uri = Uri.https(_server, '/$_path/action');

    HttpResponse response = await http_post_urlencoded(uri,body: params);
    if (response.statusCode == 200 || response.statusCode == 201) {
      emit(TweetState(response.data['data']));
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
