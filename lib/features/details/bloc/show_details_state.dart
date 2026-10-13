part of 'show_details_bloc.dart';

enum ShowDetailsStatus { initial, loading, success, empty, failure }

class ShowDetailsState extends Equatable {
  final ShowDetailsStatus status;
  final Show? show; // only set when status is success
  final String? errorMessage;

  const ShowDetailsState({
    this.status = ShowDetailsStatus.initial,
    this.show,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, show, errorMessage];
}
