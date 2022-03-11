import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meloncloud_flutter_app/extensions/http_extension.dart';
import 'package:meta/meta.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';

part 'peoples_state.dart';

class PeoplesCubit extends Cubit<PeoplesBaseState> {
  PeoplesCubit() : super(PeoplesInitialState());
  final String _path = "api/v3/twitter";
  final String _server = dotenv.env['SERVER'] ?? "";
  final String _token = dotenv.env['TWITTER_VIEWER_TOKEN'] ?? "";

  load({PeoplesState? previousState, String? command}) async {
    emit(PeoplesLoadingState(previousState: previousState));

    Map<String, String> targets = {"me_like": "true", "limit": "50"};

    if (command != null && previousState != null) {
      if (command == "NEXT" && previousState.nextPage != null) {
        targets['page'] = previousState.nextPage.toString();
      }
    }
    var params = _params(targets: targets);

    Uri uri = Uri.https(_server, '/$_path/peoples', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      dynamic responseData = response.data['data'];
      List<dynamic> data = (responseData as List);

      dynamic timestamp = response.data['timestamp'];
      List<dynamic> timeline =
          previousState?.timeline != null ? previousState!.timeline : [];
      timeline.addAll(data);

      dynamic fabric = response.data['fabric'];

      PeoplesState state = PeoplesState(
        timeline: timeline,
        data: response.data,
        currentPage: fabric['current_page'],
        previousPage: fabric['previous_page'],
        nextPage: fabric['next_page'],
      );
      emit(state);
    } else {
      emit(PeoplesFailureState(previousState: previousState));
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
