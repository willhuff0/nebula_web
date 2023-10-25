// ignore_for_file: constant_identifier_names

export 'assets.dart';
export 'database.dart';
export 'graphics.dart';

const DEBUG = false;

void nlog(dynamic message) {
  print('System: $message');
}

void nerror(dynamic message) {
  if (DEBUG) {
    throw Exception(message);
  } else {
    print('System Error: $message');
  }
}
