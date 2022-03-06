import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeBaseState> {
  HomeCubit() : super(HomeInitialState());

  String server = "meloncloud.herokuapp.com";

  gallery({HomeLoadedState? previousLoadedState}) async {

  }

  event({HomeLoadedState? previousLoadedState}) async {

  }



}
