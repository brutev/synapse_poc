import 'dart:ui';

import 'package:flutter/widgets.dart';

class FramePerformanceSample {
  const FramePerformanceSample({
    this.avgBuildMs = 0,
    this.avgRasterMs = 0,
    this.sampleCount = 0,
  });

  final double avgBuildMs;
  final double avgRasterMs;
  final int sampleCount;
}

class FramePerformanceService {
  final ValueNotifier<FramePerformanceSample> notifier =
      ValueNotifier<FramePerformanceSample>(const FramePerformanceSample());

  TimingsCallback? _callback;
  final List<int> _buildTimesMicros = <int>[];
  final List<int> _rasterTimesMicros = <int>[];

  void start() {
    if (_callback != null) {
      return;
    }
    _callback = (List<FrameTiming> timings) {
      for (final FrameTiming timing in timings) {
        _buildTimesMicros.add(timing.buildDuration.inMicroseconds);
        _rasterTimesMicros.add(timing.rasterDuration.inMicroseconds);
      }
      if (_buildTimesMicros.length > 60) {
        _buildTimesMicros.removeRange(0, _buildTimesMicros.length - 60);
        _rasterTimesMicros.removeRange(0, _rasterTimesMicros.length - 60);
      }

      notifier.value = FramePerformanceSample(
        avgBuildMs: _avg(_buildTimesMicros),
        avgRasterMs: _avg(_rasterTimesMicros),
        sampleCount: _buildTimesMicros.length,
      );
    };

    WidgetsBinding.instance.addTimingsCallback(_callback!);
  }

  void stop() {
    if (_callback == null) {
      return;
    }
    WidgetsBinding.instance.removeTimingsCallback(_callback!);
    _callback = null;
  }

  double _avg(List<int> values) {
    if (values.isEmpty) {
      return 0;
    }
    final int sum = values.reduce((int a, int b) => a + b);
    return sum / values.length / 1000;
  }
}
