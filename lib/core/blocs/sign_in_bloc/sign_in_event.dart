import 'package:flutter/material.dart';

abstract class SignInEvent {}

class SignInWithEmailEvent extends SignInEvent {
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  SignInWithEmailEvent({required this.onSuccess, required this.onError});
}

class LogOutEvent extends SignInEvent {
  final VoidCallback onSuccess;

  LogOutEvent({required this.onSuccess});
}
