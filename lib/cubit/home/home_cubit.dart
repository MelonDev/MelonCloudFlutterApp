import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meloncloud_flutter_app/extensions/http_extension.dart';
import 'package:meta/meta.dart';
import 'package:meloncloud_flutter_app/extensions/kotlin_scope_functions.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeBaseState> {
  HomeCubit() : super(HomeInitialState());

  final String _path = "api/v3/twitter";
  final String _server = dotenv.env['SERVER'] ?? "";
  final String _token = dotenv.env['TWITTER_VIEWER_TOKEN'] ?? "";

  gallery({HomeLoadedState? previousState}) async {
    previousState ??= HomeLoadedState(HomeChildrenState(), -1);

    emit(HomeLoadingState(previousState.childrenState));

    var params = _params(targets: {
      "quality": "ORIG",
      "extra_optional": "PEOPLES",
      "type": "ALL",
      "deleted": "false",
      "me_like":"true"
    });

    Uri uri = Uri.https(_server, '/$_path/media', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      dynamic timestamp = response.data['timestamp'];
      dynamic peoples = response.data['data']['payload'];
      dynamic timeline = _mapTimeline(response.data['data']['media']);
      dynamic fabric = response.data['fabric'];
      previousState.childrenState.galleryChildState = HomeGalleryState(
          peoples: peoples, timeline: timeline, data: response.data);
      emit(HomeLoadedState(previousState.childrenState, fabric['current_page'],
          previous_page: fabric['previous_page'],
          next_page: fabric['next_page']));

    } else {
      emit(HomeFailedState(childrenState: previousState.childrenState));
    }
  }

  event({HomeLoadedState? previousState}) async {
    previousState ??= HomeLoadedState(HomeChildrenState(), -1);

    emit(HomeLoadingState(previousState.childrenState));

    var params = _params(targets: {
      "quality": "ORIG",
      "type": "ALL",
      "hashtag":"FursuitFriday"
    });

    Uri uri = Uri.https(_server, '/$_path/media', params);

    HttpResponse response = await http_get(uri);
    if (response.statusCode == 200) {
      dynamic timestamp = response.data['timestamp'];
      dynamic timeline = _mapTimeline(response.data['data']);
      dynamic fabric = response.data['fabric'];
      previousState.childrenState.galleryChildState = HomeGalleryState(
          peoples: null, timeline: timeline, data: response.data);
      emit(HomeLoadedState(previousState.childrenState, fabric['current_page'],
          previous_page: fabric['previous_page'],
          next_page: fabric['next_page']));

    } else {
      emit(HomeFailedState(childrenState: previousState.childrenState));
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
      {Map<dynamic, List<dynamic>>? intoMap}) {
    Map<dynamic, List<dynamic>> map = intoMap ?? {};

    for (dynamic i in data) {
      String date = i['timestamp'].substring(0, 10);
      map[date] ??= [];
      map[date]?.add(i);
    }

    return map;
  }
}
