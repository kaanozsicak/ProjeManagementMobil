/**
 * Cloud Functions for "Kim Ne Yaptı?" Push Notifications
 *
 * Triggers:
 * - onItemAssigned: Sends push notification when an item is assigned to a user
 */

import {setGlobalOptions} from "firebase-functions/v2";
import {onDocumentUpdated, onDocumentCreated} from
  "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Global options for cost control
setGlobalOptions({maxInstances: 10, region: "us-central1"});

// ============================================
// Helper Functions
// ============================================

/**
 * Get FCM tokens for a user
 */
async function getUserTokens(userId: string): Promise<string[]> {
  const tokensSnapshot = await db
    .collection("users")
    .doc(userId)
    .collection("tokens")
    .get();

  return tokensSnapshot.docs.map((doc) => doc.id);
}

/**
 * Get user display name
 */
async function getUserName(userId: string): Promise<string> {
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return "Bilinmeyen";
  return userDoc.data()?.displayName ?? "Bilinmeyen";
}

/**
 * Get workspace name
 */
async function getWorkspaceName(workspaceId: string): Promise<string> {
  const wsDoc = await db.collection("workspaces").doc(workspaceId).get();
  if (!wsDoc.exists) return "Workspace";
  return wsDoc.data()?.name ?? "Workspace";
}

/**
 * Send push notification to a user
 */
async function sendNotificationToUser(
  userId: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  const tokens = await getUserTokens(userId);

  if (tokens.length === 0) {
    logger.info(`No tokens found for user ${userId}`);
    return;
  }

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title,
      body,
    },
    data,
    android: {
      priority: "high",
      notification: {
        channelId: "task_assignment",
        icon: "ic_notification",
      },
    },
    apns: {
      payload: {
        aps: {
          badge: 1,
          sound: "default",
        },
      },
    },
  };

  try {
    const response = await messaging.sendEachForMulticast(message);
    logger.info(`Sent ${response.successCount}/${tokens.length} notifications to user ${userId}`);

    // Clean up failed tokens
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          logger.warn(`Token failed: ${tokens[idx]}`, resp.error);
        }
      });

      // Delete invalid tokens
      for (const token of failedTokens) {
        await db
          .collection("users")
          .doc(userId)
          .collection("tokens")
          .doc(token)
          .delete();
        logger.info(`Deleted invalid token for user ${userId}`);
      }
    }
  } catch (error) {
    logger.error("Error sending notification:", error);
  }
}

// ============================================
// Firestore Triggers
// ============================================

/**
 * Trigger: When an item is created with an assignee
 */
export const onItemCreated = onDocumentCreated(
  "workspaces/{workspaceId}/items/{itemId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const {workspaceId} = event.params;

    // Check if item has an assignee
    const assigneeId = data.assigneeId;
    if (!assigneeId) return;

    // Don't notify if the creator is the assignee
    const createdBy = data.createdBy;
    if (createdBy === assigneeId) return;

    // Get names for notification
    const [assignerName, workspaceName] = await Promise.all([
      getUserName(createdBy),
      getWorkspaceName(workspaceId),
    ]);

    const itemTitle = data.title ?? "Yeni görev";
    const itemType = data.type ?? "activeTask";
    const typeEmoji = getTypeEmoji(itemType);

    // Send notification
    await sendNotificationToUser(
      assigneeId,
      `${typeEmoji} Sana iş atandı!`,
      `${assignerName} sana "${itemTitle}" atadı`,
      {
        type: "item_assigned",
        workspaceId,
        itemId: event.params.itemId,
        workspaceName,
      }
    );

    logger.info(`Notification sent for new item assignment: ${event.params.itemId}`);
  }
);

/**
 * Trigger: When an item is updated (assignee changed)
 */
export const onItemUpdated = onDocumentUpdated(
  "workspaces/{workspaceId}/items/{itemId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (!beforeData || !afterData) return;

    const {workspaceId, itemId} = event.params;

    // Check if assignee changed
    const oldAssignee = beforeData.assigneeId;
    const newAssignee = afterData.assigneeId;

    // No change or assignee removed
    if (oldAssignee === newAssignee || !newAssignee) return;

    // Get who made the change (from updatedBy or use a default)
    const updatedBy = afterData.updatedBy ?? afterData.createdBy;

    // Don't notify if user assigned to themselves
    if (updatedBy === newAssignee) return;

    // Get names for notification
    const [assignerName, workspaceName] = await Promise.all([
      getUserName(updatedBy),
      getWorkspaceName(workspaceId),
    ]);

    const itemTitle = afterData.title ?? "Görev";
    const itemType = afterData.type ?? "activeTask";
    const typeEmoji = getTypeEmoji(itemType);

    // Send notification to new assignee
    await sendNotificationToUser(
      newAssignee,
      `${typeEmoji} Sana iş atandı!`,
      `${assignerName} sana "${itemTitle}" atadı`,
      {
        type: "item_assigned",
        workspaceId,
        itemId,
        workspaceName,
      }
    );

    logger.info(`Notification sent for item reassignment: ${itemId}`);
  }
);

/**
 * Get emoji for item type
 */
function getTypeEmoji(type: string): string {
  switch (type) {
  case "activeTask":
    return "🎯";
  case "bug":
    return "🐛";
  case "logic":
    return "⚙️";
  case "idea":
    return "💡";
  default:
    return "📋";
  }
}
