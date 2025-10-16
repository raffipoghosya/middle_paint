part of 'connectivity_bloc.dart';

class ConnectivityState extends Equatable {
  final bool? isOnline; // null until checked

  const ConnectivityState({this.isOnline});

  ConnectivityState copyWith({bool? isOnline}) {
    return ConnectivityState(isOnline: isOnline);
  }

  @override
  List<Object?> get props => [isOnline];
}


