part of 'tweet_cubit.dart';

@immutable
abstract class TweetBaseState {}

class TweetInitialState extends TweetBaseState {}

class LoadingTweetState extends TweetBaseState {
  TweetState? previousState;

  LoadingTweetState({this.previousState});
}

class TweetFailureState extends TweetBaseState {
  TweetState? previousState;

  TweetFailureState({this.previousState});
}

class TweetState extends TweetBaseState {
  dynamic data;

  TweetState(this.data);
}
