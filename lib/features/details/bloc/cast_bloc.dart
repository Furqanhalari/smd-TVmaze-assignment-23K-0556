import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../../../data/models/cast_member.dart';
import '../../../data/repositories/show_repository.dart';

part 'cast_event.dart';
part 'cast_state.dart';

/// Loads `/shows/:id/cast` the first time the Cast tab is opened.
class CastBloc extends Bloc<CastEvent, CastState> {
  final ShowRepository _repository;

  CastBloc(this._repository) : super(const CastState()) {
    on<CastFetched>(_onFetched);
  }

  Future<void> _onFetched(CastFetched event, Emitter<CastState> emit) async {
    emit(const CastState(status: CastStatus.loading));
    try {
      final cast = await _repository.fetchCast(event.showId);
      emit(CastState(
        status: cast.isEmpty ? CastStatus.empty : CastStatus.success,
        cast: cast,
      ));
    } catch (e) {
      emit(CastState(
        status: CastStatus.failure,
        errorMessage: friendlyMessage(e),
      ));
    }
  }
}
