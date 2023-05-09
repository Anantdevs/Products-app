import 'dart:async';

import 'package:flutter/widgets.dart';

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() {
    return message;
    // TODO: implement toString
    // return super.toString();
  }
}