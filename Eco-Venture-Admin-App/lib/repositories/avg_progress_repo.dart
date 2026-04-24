import 'package:eco_venture_admin_portal/models/avg_progress_model.dart';
import 'package:eco_venture_admin_portal/services/avg_progress_service.dart';

/// Logic: Bridge between the ViewModel and the Aggregation Service.
class ProgressAggregationRepo {
  ProgressAggregationRepo._();
  static final ProgressAggregationRepo instance = ProgressAggregationRepo._();

  /// Logic: Returns the calculated global statistics for the dashboard.
  Future<AvgProgressModel> getGlobalStats() async {
    return await ProgressAggregationService.instance.calculateGlobalStats();
  }
}