

import '../../../models/qr_hunt_model.dart';

class AdminTreasureHuntState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<QrHuntModel> hunts;

  AdminTreasureHuntState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.hunts = const [],
  });

  AdminTreasureHuntState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<QrHuntModel>? hunts,
  }) {
    return AdminTreasureHuntState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      hunts: hunts ?? this.hunts,
    );
  }
}