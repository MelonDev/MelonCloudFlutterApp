import 'package:bloc/bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:meloncloud_flutter_app/tools/MelonRouter.dart';
import 'package:meta/meta.dart';
import 'package:routemaster/routemaster.dart';

part 'route_state.dart';

class RouteCubit extends Cubit<RouteState> {
  RouteCubit() : super(RouteInitialState());

  push({required BuildContext context, required String path, Map<String, String>? queryParameters}) async {
    await MelonRouter.push_async(context: context, path: path,queryParameters:queryParameters);
  }

  pop({required BuildContext context}) async {
    await MelonRouter.pop_async(context: context);
  }
}
