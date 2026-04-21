const admin = require('firebase-admin');

const serviceAccount = require('./flutter-storage-project-firebase-adminsdk-fbsvc-b6fb98698c.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const uid = 'Yo8iHKq6jLQYTXxYUXq55Zqavk23';

admin.auth().setCustomUserClaims(uid, { role: 'admin' })
    .then(() => {
        admin.firestore().collection('users').doc(uid).set({ role: 'admin' }, { merge: true });
        return console.log(`✅ Пользователю ${uid} успешно назначена роль admin`);
    })
    .then(() => {
        console.log('✅ Документ в Firestore обновлён');
        process.exit(0);
    })
    .catch(error => {
        console.error('❌ Ошибка:', error);
        process.exit(1);
    });