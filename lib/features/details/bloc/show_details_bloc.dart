import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../../../data/models/show.dart';
import '../../../data/repositories/show_repository.dart';

part 'show_details_event.dart';
part 'show_details_state.dart';

class ShowDetailsBloc extends Bloc<ShowDetailsEvent, ShowDetailsState> {
  final ShowRepository _repository;

  ShowDetailsBloc(this._repository) : super(const ShowDetailsState()) {
    on<ShowDetailsFetched>(_onFetched);
  }

  Future<void> _onFetched(
      ShowDetailsFetched event, Emitter<ShowDetailsState> emit) async {
    emit(const ShowDetailsState(status: ShowDetailsStatus.loading));
    try {
      final show = await _repository.fetchShowDetails(event.showId);
      emit(ShowDetailsState(status: ShowDetailsStatus.success, show: show));
    } on NotFoundException {
      // The id doesn't exist (any more) on TVMaze.
      emit(const ShowDetailsState(status: ShowDetailsStatus.empty));
    } catch (e) {
      emit(ShowDetailsState(
        status: ShowDetailsStatus.failure,
        errorMessage: friendlyMessage(e),
      ));
    }
  }
}
