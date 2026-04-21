const admin = require('firebase-admin');

// Укажи путь к твоему JSON-файлу
const serviceAccount = require('./flutter-storage-project-firebase-adminsdk-fbsvc-b6fb98698c.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

// Вставь сюда UID пользователя, которого проверяешь
const uid = 'Yo8iHKq6jLQYTXxYUXq55Zqavk23';

admin.auth().getUser(uid)
    .then(userRecord => {
        // Посмотрим на весь объект пользователя
        console.log('Данные пользователя:', JSON.stringify(userRecord, null, 2));
        // Посмотрим только на custom claims
        console.log('\nРоль (custom claims):', userRecord.customClaims);
    })
    .catch(error => {
        console.error('Ошибка при получении пользователя:', error);
    });