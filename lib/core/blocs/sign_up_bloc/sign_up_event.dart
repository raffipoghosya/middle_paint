import 'package:flutter/material.dart';

class SignUpEvent {}

class SignUpWithEmailEvent extends SignUpEvent {
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  SignUpWithEmailEvent({required this.onSuccess, required this.onError});
}
