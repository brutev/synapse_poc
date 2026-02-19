import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature_state.dart';

class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit() : super(const FeatureState());
}
