const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Sends a push notification to the partner when a new expense is added.
 * Triggered on Firestore document creation in couples/{coupleId}/expenses/{expenseId}.
 */
exports.onExpenseCreated = functions.firestore
  .document("couples/{coupleId}/expenses/{expenseId}")
  .onCreate(async (snap, context) => {
    const { coupleId } = context.params;
    const expense = snap.data();

    // Don't notify for private expenses
    if (expense.visibility === "private") return null;

    // Get the couple document to find the partner
    const coupleDoc = await db.collection("couples").doc(coupleId).get();
    if (!coupleDoc.exists) return null;

    const couple = coupleDoc.data();
    const partnerId =
      expense.userId === couple.user1Id ? couple.user2Id : couple.user1Id;

    // Get partner's FCM token
    const partnerDoc = await db.collection("users").doc(partnerId).get();
    if (!partnerDoc.exists) return null;

    const partnerToken = partnerDoc.data().fcmToken;
    if (!partnerToken) return null;

    // Send notification
    return messaging.send({
      token: partnerToken,
      notification: {
        title: "New Expense",
        body: `${expense.category}: $${expense.amount.toFixed(2)}`,
      },
      data: {
        coupleId,
        type: "expense_added",
      },
    });
  });

/**
 * Deletes all user data when account deletion is requested.
 * Called from the Flutter app via Cloud Functions callable.
 */
exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be authenticated"
    );
  }

  const userId = context.auth.uid;

  // Get user document
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return { success: true };

  const userData = userDoc.data();
  const { coupleId } = userData;

  // If user is in a couple, remove coupleId from partner
  if (coupleId) {
    const coupleDoc = await db.collection("couples").doc(coupleId).get();
    if (coupleDoc.exists) {
      const couple = coupleDoc.data();
      const partnerId =
        userId === couple.user1Id ? couple.user2Id : couple.user1Id;

      // Remove coupleId from partner
      await db.collection("users").doc(partnerId).update({
        coupleId: admin.firestore.FieldValue.delete(),
      });

      // Delete couple expenses, budgets, privacy settings
      const batch = db.batch();

      const expenses = await db
        .collection("couples")
        .doc(coupleId)
        .collection("expenses")
        .where("userId", "==", userId)
        .get();
      expenses.forEach((doc) => batch.delete(doc.ref));

      const privacy = await db
        .collection("couples")
        .doc(coupleId)
        .collection("privacySettings")
        .doc(userId)
        .get();
      if (privacy.exists) batch.delete(privacy.ref);

      await batch.commit();
    }
  }

  // Delete user document
  await db.collection("users").doc(userId).delete();

  // Delete Firebase Auth account
  await admin.auth().deleteUser(userId);

  return { success: true };
});
