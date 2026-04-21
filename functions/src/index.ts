import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from 'firebase-admin';

admin.initializeApp();

export const addAdminRole = onDocumentCreated("admin_requests/{requestId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const uid = snapshot.data().uid;
    if (!uid) return;

    try {
        await admin.auth().setCustomUserClaims(uid, { role: 'admin' });
        await admin.firestore().collection('users').doc(uid).set({ role: 'admin' }, { merge: true });
        console.log(`✅ Админ создан: ${uid}`);
    } catch (error) {
        console.error(`❌ Ошибка: ${error}`);
    }
});