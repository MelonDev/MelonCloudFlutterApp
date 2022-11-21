import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meloncloud_flutter_app/environment/app_environment.dart';
import 'package:meloncloud_flutter_app/extensions/http_extension.dart';
import 'package:meta/meta.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileBaseState> {
  final String _path = "v1/meloncloud/twitter";
  final String _server = AppEnvironment.server;
  final String _token = AppEnvironment.token;

  ProfileCubit() : super(ProfileInitialState());

  load(
      {ProfileState? previousState,
      required String account,
      String? command}) async {
    emit(ProfileLoadingState(previousState: previousState));

    Map<String, String>? targets = {
      "quality": "ORIG",
      "me_like": "true",
      "limit": "150",
      "query": "COMBINE",
      "deleted": "false",
      "type": "ALL"
    };


    if (command != null && previousState != null) {
      if (command == "NEXT" && previousState.nextPage != null) {
        targets['page'] = previousState.nextPage.toString();
      }else {
        targets = null;
      }
    } else {
      targets['with_hashtags'] = "true";
    }

    if (targets != null){
      var params = _params(targets: targets);

      Uri uri = Uri.https(_server, '/$_path/media/$account', params);

      HttpResponse response = await http_get(uri);
      if (response.statusCode == 200) {
        dynamic responseData = response.data['data'];

        dynamic profile = responseData['profile'];

        dynamic timestamp = response.data['timestamp'];
        dynamic timeline = _mapTimeline(response.data['data']['media'],
            intoTimeline: previousState?.timeline);

        dynamic fabric = response.data['fabric'];

        ProfileState state = ProfileState(
          profile: profile,
          timeline: timeline,
          data: response.data,
          currentPage: fabric['current_page'],
          previousPage: fabric['previous_page'],
          nextPage: fabric['next_page'],
        );

        if (previousState == null) {
          dynamic responseHashtags = responseData['hashtags'];
          List<dynamic> hashtags = (responseHashtags as List);
          state.hashtags = hashtags;
        } else {
          List<dynamic>? hashtags = previousState.hashtags ?? [];
          state.hashtags = hashtags;
        }
        emit(state);
      } else {
        emit(ProfileFailureState(previousState: previousState));
      }
    }else if(previousState != null) {
      emit(previousState);
    }else {
      emit(ProfileFailureState());
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
