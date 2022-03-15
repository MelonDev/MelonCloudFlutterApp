import 'dart:io';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meloncloud_flutter_app/environment/app_environment.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meta/meta.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';

import '../../extensions/http_extension.dart';

part 'main_state.dart';
part 'main_home_state.dart';
part 'main_event_state.dart';
part 'main_hashtag_state.dart';


class MainCubit extends Cubit<MainState> {
  final String _path = "api/v3/twitter";
  final String _server = AppEnvironment.server;
  final String _token = AppEnvironment.token;

  MainCubit() : super(MainInitialState());

  gallery({required BuildContext context,MainHomeState? previousState, String? command}) async {
    emit(MainHomeLoadingState(previousState: previousState));

    Map<String, String> targets = {
      "quality": "ORIG",
      "extra_optional": "PEOPLES",
      "type": "ALL",
      "deleted": "false",
      "me_like": "true",
      "limit": "150"
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
      dynamic peoples = response.data['data']['payload'];
      dynamic fabric = response.data['fabric'];

      dynamic timeline = _mapTimeline(response.data['data']['media'],
          intoTimeline: previousState?.timeline);

      MainHomeState state = MainHomeState(
        peoples: peoples,
        timeline: timeline,
        data: response.data,
        currentPage: fabric['current_page'],
        previousPage: fabric['previous_page'],
        nextPage: fabric['next_page'],
      );
      emit(state);
      MelonRouter.push_async(context: context, path: '/home');
    } else {
      emit(MainHomeFailureState(previousState: previousState));
    }
  }

  event({required BuildContext context, MainEventState? previousState, String? command}) async {
    emit(MainEventLoadingState(previousState: previousState));

    Map<String, String> targets = {
      "quality": "ORIG",
      "type": "ALL",
      "hashtag": "FursuitFriday",
      "limit": "150",
    "me_like": "false",

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

      MainEventState state = MainEventState(
        timeline: timeline,
        data: response.data,
        currentPage: fabric['current_page'],
        previousPage: fabric['previous_page'],
        nextPage: fabric['next_page'],
      );
      emit(state);
      MelonRouter.push_async(context: context, path: '/events');
    } else {
      emit(MainEventFailureState(previousState: previousState));
    }
  }

  hashtag({required BuildContext context, MainHashtagState? previousState, String? query,String? command}) async {
    emit(MainHashtagLoadingState(previousState: previousState));

    query ??= "ALL";

    Map<String, String> targets = {
      "query": query,
      "deleted": "false",
      "limit": "150",
      "me_like": "true",

    };

    if (command != null && previousState != null) {
      if (command == "NEXT" && previousState.nextPage != null) {
        targets['page'] = previousState.nextPage.toString();
      }else if (command == "NEXT" && previousState.nextPage == null){
        targets['page'] = (previousState.currentPage + 1).toString();
      }
    }


    var params = _params(targets: targets);

    Uri uri = Uri.https(_server, '/$_path/hashtags', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      dynamic responseData = response.data['data'];
      List<dynamic> timeline =
      previousState?.timeline != null ? previousState!.timeline : [];

      timeline.addAll(responseData);
      dynamic fabric = response.data['fabric'];

      MainHashtagState state = MainHashtagState(
        timeline: timeline,
        query:query,
        data: response.data,
        currentPage: fabric['current_page'],
        previousPage: fabric['previous_page'],
        nextPage: fabric['next_page'],
        dateStart: fabric['time_range']['start'],
        dateEnd: fabric['time_range']['end'],

      );
      emit(state);


      MelonRouter.push_async(context: context, path: '/tags');


    } else if (response.statusCode == 400){
      if (previousState != null){
        emit(previousState);
      }
    }else {
      emit(MainHashtagFailureState(previousState: previousState));
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
