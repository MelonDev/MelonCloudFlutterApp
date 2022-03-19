import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static String server = dotenv.env['SERVER'] ?? "";
  static String token = dotenv.env['TWITTER_VIEWER_TOKEN'] ?? "";
  static String bookApiKey = dotenv.env['MELONCLOUD_BOOKS_API_KEY'] ?? "";
}