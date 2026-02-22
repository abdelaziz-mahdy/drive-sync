/// Categorizes rclone errors into user-actionable groups.
enum RcloneErrorCategory {
  /// Authentication has expired or is invalid (401, token refresh failure).
  authExpired,

  /// Network is unreachable or timed out.
  networkOffline,

  /// Permission denied on local or remote file system.
  permissionDenied,

  /// Local or remote disk is full.
  diskFull,

  /// Bisync detected file conflicts.
  bisyncConflict,

  /// The configured local or remote path does not exist.
  missingPath,

  /// Rate limited by the remote provider.
  rateLimited,

  /// An unclassified / unknown error.
  unknown,
}

/// Result of classifying an rclone error string.
class ClassifiedError {
  final RcloneErrorCategory category;

  /// Short, user-facing summary of the problem.
  final String userMessage;

  /// Actionable suggestion for resolving the issue.
  final String suggestion;

  /// The original raw error string.
  final String rawError;

  const ClassifiedError({
    required this.category,
    required this.userMessage,
    required this.suggestion,
    required this.rawError,
  });
}

/// Classifies raw rclone error strings into structured [ClassifiedError]s.
///
/// This is a pure function with no side-effects, making it easy to test.
class ErrorClassifier {
  const ErrorClassifier();

  /// Classify [rawError] into a [ClassifiedError].
  ClassifiedError classify(String rawError) {
    final lower = rawError.toLowerCase();

    // --- Auth / token errors ---
    if (_matchesAny(lower, _authPatterns)) {
      return ClassifiedError(
        category: RcloneErrorCategory.authExpired,
        userMessage: 'Authentication has expired or is invalid.',
        suggestion:
            'Re-authorize the remote in rclone. Run "rclone config reconnect <remote>:" in a terminal.',
        rawError: rawError,
      );
    }

    // --- Bisync conflicts (check before generic permission) ---
    if (_matchesAny(lower, _bisyncConflictPatterns)) {
      return ClassifiedError(
        category: RcloneErrorCategory.bisyncConflict,
        userMessage: 'Bisync detected file conflicts that need resolution.',
        suggestion:
            'Review the conflicting files and choose which version to keep. '
            'You may need to run bisync with --resync to force a fresh sync.',
        rawError: rawError,
      );
    }

    // --- Missing path ---
    if (_matchesAny(lower, _missingPathPatterns)) {
      return ClassifiedError(
        category: RcloneErrorCategory.missingPath,
        userMessage: 'The configured local or remote folder does not exist.',
        suggestion:
            'Check that the folder paths in your sync profile are correct '
            'and that the folders have not been moved or deleted.',
        rawError: rawError,
      );
    }

    // --- Disk full ---
    if (_matchesAny(lower, _diskFullPatterns)) {
      return ClassifiedError(
        category: RcloneErrorCategory.diskFull,
        userMessage: 'The disk is full. No more files can be written.',
        suggestion:
            'Free up disk space on the target drive and retry the sync.',
        rawError: rawError,
      );
    }

    // --- Permission denied ---
    if (_matchesAny(lower, _permissionPatterns)) {
      return ClassifiedError(
        category: RcloneErrorCategory.permissionDenied,
        userMessage: 'Permission denied when accessing files.',
        suggestion:
            'Check that DriveSync has the necessary file system permissions. '
            'On macOS, grant Full Disk Access in System Settings > Privacy.',
        rawError: rawError,
      );
    }

    // --- Rate limited ---
    if (_matchesAny(lower, _rateLimitPatterns)) {
      return ClassifiedError(
        category: RcloneErrorCategory.rateLimited,
        userMessage:
            'The cloud provider is rate-limiting requests. Sync slowed down.',
        suggestion:
            'Wait a few minutes and retry. You can also reduce bandwidth in Settings.',
        rawError: rawError,
      );
    }

    // --- Network errors ---
    if (_matchesAny(lower, _networkPatterns)) {
      return ClassifiedError(
        category: RcloneErrorCategory.networkOffline,
        userMessage: 'Network error. Unable to reach the cloud provider.',
        suggestion:
            'Check your internet connection and try again. '
            'If you are behind a firewall or VPN, make sure rclone traffic is allowed.',
        rawError: rawError,
      );
    }

    // --- Fallback ---
    return ClassifiedError(
      category: RcloneErrorCategory.unknown,
      userMessage: 'An unexpected sync error occurred.',
      suggestion:
          'Check the error details below and consult the rclone documentation '
          'if the issue persists.',
      rawError: rawError,
    );
  }

  // ---------------------------------------------------------------------------
  // Pattern lists
  // ---------------------------------------------------------------------------

  static const _authPatterns = [
    'token has been expired',
    'token has been revoked',
    'invalid_grant',
    'authorizationexception',
    '401 unauthorized',
    'oauth2: cannot fetch token',
    'failed to refresh token',
    'insufficient authentication scopes',
    'access denied',
    'invalidauthenticationtoken',
    'unauthenticated',
  ];

  static const _bisyncConflictPatterns = [
    'bisync conflict',
    'bisync critical error',
    'bisync aborted',
    'files changed on both sides',
    'bisync resync required',
    'force resync',
  ];

  static const _missingPathPatterns = [
    'directory not found',
    'no such file or directory',
    'the system cannot find the path',
    'object not found',
    'not found',
    "doesn't exist",
    'failed to list',
    'couldn\'t list files',
  ];

  static const _diskFullPatterns = [
    'no space left on device',
    'disk quota exceeded',
    'not enough space',
    'out of disk space',
    'insufficient storage',
    'the device is full',
    'enospc',
  ];

  static const _permissionPatterns = [
    'permission denied',
    'access is denied',
    '403 forbidden',
    'operation not permitted',
    'read-only file system',
    'eperm',
    'eacces',
  ];

  static const _rateLimitPatterns = [
    'rate limit',
    'too many requests',
    '429',
    'user rate limit exceeded',
    'quota exceeded',
    'rateLimitExceeded',
  ];

  static const _networkPatterns = [
    'connection refused',
    'connection reset',
    'connection timed out',
    'no such host',
    'network is unreachable',
    'dns lookup failed',
    'tls handshake timeout',
    'eof',
    'i/o timeout',
    'context deadline exceeded',
    'dial tcp',
    'broken pipe',
    'connection closed',
  ];

  /// Returns true if [text] contains any of the [patterns].
  bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p));
  }
}
