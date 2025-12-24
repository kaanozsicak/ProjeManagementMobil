/// Firestore collection and document path constants
class FirestorePaths {
  FirestorePaths._();

  // Collections
  static const String users = 'users';
  static const String workspaces = 'workspaces';
  static const String members = 'members';
  static const String invites = 'invites';
  static const String items = 'items';
  static const String presence = 'presence';
  static const String activities = 'activities';

  // Document paths
  static String user(String uid) => '$users/$uid';
  static String workspace(String workspaceId) => '$workspaces/$workspaceId';
  static String workspaceMembers(String workspaceId) =>
      '$workspaces/$workspaceId/$members';
  static String member(String workspaceId, String uid) =>
      '$workspaces/$workspaceId/$members/$uid';
  static String workspaceInvites(String workspaceId) =>
      '$workspaces/$workspaceId/$invites';
  static String invite(String workspaceId, String token) =>
      '$workspaces/$workspaceId/$invites/$token';
  static String workspaceItems(String workspaceId) =>
      '$workspaces/$workspaceId/$items';
  static String item(String workspaceId, String itemId) =>
      '$workspaces/$workspaceId/$items/$itemId';
  static String workspacePresence(String workspaceId) =>
      '$workspaces/$workspaceId/$presence';
  static String userPresence(String workspaceId, String userId) =>
      '$workspaces/$workspaceId/$presence/$userId';
  static String workspaceActivities(String workspaceId) =>
      '$workspaces/$workspaceId/$activities';
  static String activity(String workspaceId, String activityId) =>
      '$workspaces/$workspaceId/$activities/$activityId';
}
