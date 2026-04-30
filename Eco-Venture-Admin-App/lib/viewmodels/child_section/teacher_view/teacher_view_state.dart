import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherState {
  final bool isLoading;
  final String? errorMessage;

  TeacherState({this.isLoading = false, this.errorMessage});

  TeacherState copyWith({bool? isLoading, String? errorMessage}) {
    return TeacherState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}