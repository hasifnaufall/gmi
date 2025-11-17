// debug-user.js
const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'waveact-e419c'
});

const db = admin.firestore();

async function debugTopUser() {
  try {
    const snapshot = await db.collection('progress')
      .orderBy('level', 'desc')
      .limit(5)
      .get();
    
    console.log('Top 5 users in database:\n');
    
    snapshot.docs.forEach((doc, idx) => {
      const data = doc.data();
      console.log(`${idx + 1}. UID: ${doc.id}`);
      console.log(`   displayName: "${data.displayName}"`);
      console.log(`   changeName: "${data.changeName}"`);
      console.log(`   email: "${data.email}"`);
      console.log(`   level: ${data.level}`);
      console.log(`   score: ${data.score}`);
      console.log('');
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

debugTopUser();
