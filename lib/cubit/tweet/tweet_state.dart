part of 'tweet_cubit.dart';

@immutable
abstract class TweetState {}

class TweetInitialState extends TweetState {}

class LoadingTweetState extends TweetState {
  LoadedTweetState? previousState;

  LoadingTweetState({this.previousState});
}

class TweetFailureState extends TweetState {
  LoadedTweetState? previousState;

  TweetFailureState({this.previousState});
}

class LoadedTweetState extends TweetState {
  dynamic data;

  LoadedTweetState(this.data);
}
