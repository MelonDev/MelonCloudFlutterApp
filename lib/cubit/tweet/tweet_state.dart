part of 'tweet_cubit.dart';

@immutable
abstract class TweetState {}

class TweetInitialState extends TweetState {}

class LoadingTweetState extends TweetState {
  LoadedTweetState? previousState;

  LoadingTweetState({this.previousState});
}

class FailedTweetState extends TweetState {
  LoadedTweetState? previousState;

  FailedTweetState({this.previousState});
}

class LoadedTweetState extends TweetState {
  dynamic data;

  LoadedTweetState(this.data);
}
