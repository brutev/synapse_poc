import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature_validation_state.dart';

class FeatureValidationCubit extends Cubit<FeatureValidationState> {
  FeatureValidationCubit() : super(const FeatureValidationState());
}
