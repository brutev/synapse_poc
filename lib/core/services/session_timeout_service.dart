import 'dart:async';

class SessionTimeoutService {
  Timer? _timer;

  void start(Duration timeout, void Function() onTimeout) {
    _timer?.cancel();
    _timer = Timer(timeout, onTimeout);
  }

  void cancel() => _timer?.cancel();
}
