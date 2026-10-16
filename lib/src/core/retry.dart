/// Retry policy for transient transport failures.
library;

/// Describes when and how the transport retries failed requests.
///
/// Retries are opt-in: assign [OpenCodeTransport.retry] for a client-wide
/// policy or pass `RequestOptions(retry: ...)` per request. By default only
/// idempotent methods (`GET`, `HEAD`) are retried, so a timed-out
/// `POST /api/session/{id}/prompt` can never be admitted twice; set
/// [retryNonIdempotent] to opt into retrying writes as well.
final class RetryPolicy {
  /// Creates a retry policy.
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 250),
    this.maxDelay = const Duration(seconds: 5),
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.retryNonIdempotent = false,
  });

  /// Total attempts, including the first. Values below 2 disable retrying.
  final int maxAttempts;

  /// Delay before the second attempt; doubles per further attempt.
  final Duration initialDelay;

  /// Upper bound for the computed backoff and for `Retry-After` hints.
  final Duration maxDelay;

  /// Response statuses that are retried.
  final Set<int> retryableStatusCodes;

  /// Whether non-idempotent requests (writes) are retried too.
  ///
  /// Off by default: a request that timed out may already have been applied
  /// server-side, and retrying a `prompt` would admit it twice.
  final bool retryNonIdempotent;

  /// Whether any retry can happen.
  bool get isEnabled => maxAttempts > 1;

  /// Whether a request with [method] may be retried.
  bool retriesMethod(String method) {
    if (!isEnabled) return false;
    if (retryNonIdempotent) return true;
    final upper = method.toUpperCase();
    return upper == 'GET' || upper == 'HEAD';
  }

  /// The delay before the retry that follows failed attempt [attempt]
  /// (1-based), honoring a `Retry-After` header of whole seconds.
  ///
  /// HTTP-date hints are not parsed; those fall back to the computed backoff.
  Duration delayFor(int attempt, {String? retryAfter}) {
    final hinted = _retryAfter(retryAfter);
    if (hinted != null) return hinted;
    final factor = 1 << (attempt - 1).clamp(0, 16);
    final millis = initialDelay.inMilliseconds * factor;
    return Duration(milliseconds: millis.clamp(0, maxDelay.inMilliseconds));
  }

  Duration? _retryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds == null) return null;
    return Duration(seconds: seconds.clamp(0, maxDelay.inSeconds));
  }
}
