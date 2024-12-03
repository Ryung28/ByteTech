/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

interface QueryCount {
  data(): {
    count: number;
  };
}

export const updateDailyAnalytics = onSchedule("every 24 hours", async () => {
  const db = admin.firestore();

  try {
    const [usersCount, reportsCount, activeBansCount] = await Promise.all([
      db.collection("users").count().get(),
      db.collection("reports").count().get(),
      db.collection("bans")
        .where("status", "==", "active")
        .where("type", "==", "breeding_season")
        .count()
        .get(),
    ]) as [QueryCount, QueryCount, QueryCount];

    await db.collection("analytics").add({
      date: admin.firestore.Timestamp.now(),
      userCount: usersCount.data().count,
      reportCount: reportsCount.data().count,
      activeBanCount: activeBansCount.data().count,
    });
  } catch (error) {
    console.error("Error updating analytics:", error);
    throw error;
  }
});
