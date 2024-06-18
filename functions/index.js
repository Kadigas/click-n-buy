const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendOrderStatusNotification = functions.firestore
    .document("users/{userId}/orders/{orderId}")
    .onUpdate((change, context) => {
      const userId = context.params.userId;
      const newValue = change.after.data();
      const previousValue = change.before.data();

      // Check if statusOrder or statusShipping changed
      if (newValue.statusOrder !== previousValue.statusOrder) {
        const payload = {
          notification: {
            title: "Order Status Updated",
            body: `Your order status: ${newValue.statusOrder}.`,
          },
        };

        return admin.firestore()
            .collection("users")
            .doc(userId)
            .get()
            .then((userDoc) => {
              const token = userDoc.data().fcmToken;
              if (token) {
                return admin.messaging().sendToDevice(token, payload);
              }
              return null;
            });
      }

      return null;
    });

