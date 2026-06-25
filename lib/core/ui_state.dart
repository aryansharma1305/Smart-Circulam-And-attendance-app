import 'app_error.dart';

/// The status of any screen or controller operation.
enum UiStatus { idle, loading, success, error }

/// Generic UI state wrapper carried by every controller's [StateNotifier].
///
/// Screens watch a [UiState<T>] and render based on [status]:
/// - [UiStatus.idle]    → initial / empty placeholder
/// - [UiStatus.loading] → progress indicator
/// - [UiStatus.success] → display [data]
/// - [UiStatus.error]   → display [error] in a snackbar / banner
///
/// Example usage:
/// ```dart
/// final state = ref.watch(studentDashboardControllerProvider);
/// return UiStateBuilder<DashboardSummary>(
///   state: state,
///   onSuccess: (summary) => DashboardContent(summary: summary),
/// );
/// ```
class UiState<T> {
  const UiState._({
    required this.status,
    this.data,
    this.error,
  });

  final UiStatus status;

  /// Non-null when [status] == [UiStatus.success].
  final T? data;

  /// Non-null when [status] == [UiStatus.error].
  final AppError? error;

  // -- Factories ----------------------------------------------------------

  const UiState.idle() : this._(status: UiStatus.idle);

  const UiState.loading() : this._(status: UiStatus.loading);

  UiState.success(T data) : this._(status: UiStatus.success, data: data);

  const UiState.error(AppError error)
      : this._(status: UiStatus.error, error: error);

  // -- Convenience ----------------------------------------------------------

  bool get isIdle => status == UiStatus.idle;
  bool get isLoading => status == UiStatus.loading;
  bool get isSuccess => status == UiStatus.success;
  bool get isError => status == UiStatus.error;

  /// Transforms the [data] value if present; otherwise returns a new
  /// [UiState] with the same status and error.
  UiState<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      return UiState.success(transform(data as T));
    }
    return UiState._(status: status, error: error);
  }

  @override
  String toString() =>
      'UiState<$T>(status: $status, data: $data, error: $error)';
}
