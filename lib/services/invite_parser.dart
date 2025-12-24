/// Utility class for parsing invite links/codes
class InviteParser {
  InviteParser._();

  /// Parse invite code or link
  /// Supported formats:
  /// - workspaceId:token (short code)
  /// - kimne://join?workspace=XXX&token=YYY (app link)
  /// - https://app.local/join?workspace=XXX&token=YYY (web link)
  static InviteData? parse(String input) {
    final trimmed = input.trim();

    // Try short code format: workspaceId:token
    if (trimmed.contains(':') && !trimmed.contains('/')) {
      final parts = trimmed.split(':');
      if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return InviteData(
          workspaceId: parts[0],
          token: parts[1],
        );
      }
    }

    // Try URL format
    try {
      final uri = Uri.parse(trimmed);
      final workspaceId = uri.queryParameters['workspace'];
      final token = uri.queryParameters['token'];

      if (workspaceId != null &&
          workspaceId.isNotEmpty &&
          token != null &&
          token.isNotEmpty) {
        return InviteData(
          workspaceId: workspaceId,
          token: token,
        );
      }
    } catch (_) {
      // Not a valid URL
    }

    return null;
  }
}

/// Parsed invite data
class InviteData {
  final String workspaceId;
  final String token;

  const InviteData({
    required this.workspaceId,
    required this.token,
  });

  @override
  String toString() => 'InviteData(workspaceId: $workspaceId, token: $token)';
}
