import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meloncloud_flutter_app/cubit/main/main_cubit.dart';
import 'package:meloncloud_flutter_app/extensions/http_extension.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';

import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meta/meta.dart';

part 'hashtags_state.dart';

class HashtagsCubit extends Cubit<HashtagsBaseState> {
  final String _path = "api/v3/twitter";
  final String _server = dotenv.env['SERVER'] ?? "";
  final String _token = dotenv.env['TWITTER_VIEWER_TOKEN'] ?? "";

  HashtagsCubit() : super(HashtagsInitialState());

  load(
      {required BuildContext context,
      required String hashtagName,
      HashtagsState? previousState,
      String? command}) async {
    emit(HashtagsLoadingState(previousState: previousState));

    Map<String, String> targets = {
      "quality": "ORIG",
      "type": "ALL",
      "hashtag": hashtagName,
      "limit": "150",
      "me_like": "true"
    };

    if (command != null && previousState != null) {
      if (command == "NEXT" && previousState.nextPage != null) {
        targets['page'] = previousState.nextPage.toString();
      }
    }
    var params = _params(targets: targets);

    Uri uri = Uri.https(_server, '/$_path/media', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      dynamic timestamp = response.data['timestamp'];
      dynamic timeline = _mapTimeline(response.data['data'],
          intoTimeline: previousState?.timeline);
      dynamic fabric = response.data['fabric'];

      HashtagsState state = HashtagsState(
        timeline: timeline,
        data: response.data,
        hashtagName: hashtagName,
        currentPage: fabric['current_page'],
        previousPage: fabric['previous_page'],
        nextPage: fabric['next_page'],
      );
      emit(state);
    } else {
      emit(HashtagsFailureState(previousState: previousState));
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

  Map<dynamic, List<dynamic>> _mapTimeline(data,
      {Map<dynamic, List<dynamic>>? intoTimeline}) {
    Map<dynamic, List<dynamic>> map = intoTimeline ?? {};

    for (dynamic i in data) {
      String date = i['timestamp'].substring(0, 10);
      map[date] ??= [];
      map[date]?.add(i);
    }

    return map;
  }
}
