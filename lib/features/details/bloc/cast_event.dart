part of 'cast_bloc.dart';

sealed class CastEvent extends Equatable {
  const CastEvent();

  @override
  List<Object?> get props => [];
}

/// Load the cast of one show (sent when the tab is first built and by Retry).
final class CastFetched extends CastEvent {
  final int showId;

  const CastFetched(this.showId);

  @override
  List<Object?> get props => [showId];
}
