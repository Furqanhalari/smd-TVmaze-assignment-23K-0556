part of 'cast_bloc.dart';

enum CastStatus { initial, loading, success, empty, failure }

class CastState extends Equatable {
  final CastStatus status;
  final List<CastMember> cast;
  final String? errorMessage;

  const CastState({
    this.status = CastStatus.initial,
    this.cast = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, cast, errorMessage];
}
