import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:middle_paint/core/services/connectivity_service.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  ConnectivityBloc(this._service) : super(const ConnectivityState()) {
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityChanged>(_onChanged);
  }

  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    final online = await _service.isOnline();
    emit(state.copyWith(isOnline: online));
    _subscription = _service.onConnectivityChanged().listen((online) {
      add(ConnectivityChanged(online));
    });
  }

  void _onChanged(ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    emit(state.copyWith(isOnline: event.isOnline));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
