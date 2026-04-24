import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/qr_hunt_model.dart';
import '../../../repositories/admin_treasure_hunt_repository.dart';
import 'admin_treasure_hun_state.dart';


class AdminTreasureHuntViewModel extends StateNotifier<AdminTreasureHuntState> {
  final AdminTreasureHuntRepository _repository;
  StreamSubscription? _streamSub;

  AdminTreasureHuntViewModel(this._repository) : super(AdminTreasureHuntState());

  // --- LOAD ---
  void loadHunts() {
    _streamSub?.cancel();
    state = state.copyWith(isLoading: true);

    _streamSub = _repository.watchHunts().listen(
            (data) {
          state = state.copyWith(isLoading: false, hunts: data);
        },
        onError: (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
        }
    );
  }

  // --- ADD ---
  Future<void> addHunt(QrHuntModel hunt) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.addHunt(hunt);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- UPDATE ---
  Future<void> updateHunt(QrHuntModel hunt) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateHunt(hunt);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- DELETE ---
  Future<void> deleteHunt(String id) async {
    try {
      await _repository.deleteHunt(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}