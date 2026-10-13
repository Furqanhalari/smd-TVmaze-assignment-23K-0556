part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, empty, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query; // the trimmed query these results belong to
  final List<Show> results;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, query, results, errorMessage];
}
