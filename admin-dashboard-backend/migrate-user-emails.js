// migrate-user-emails.js
// Script to update all users' progress documents with their email addresses

const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'waveact-e419c'
});

const db = admin.firestore();
const auth = admin.auth();

async function migrateUserEmails() {
  try {
    console.log('Starting email migration...');
    
    // Get all users from Firebase Auth
    const listUsersResult = await auth.listUsers(1000);
    const users = listUsersResult.users;
    
    console.log(`Found ${users.length} users in Firebase Auth`);
    
    let updatedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;
    
    for (const user of users) {
      try {
        const progressDoc = await db.collection('progress').doc(user.uid).get();
        
        if (progressDoc.exists) {
          const data = progressDoc.data();
          
          // Check if email is already set
          if (!data.email && user.email) {
            await db.collection('progress').doc(user.uid).update({
              email: user.email
            });
            console.log(`✓ Updated ${user.uid} with email: ${user.email}`);
            updatedCount++;
          } else if (data.email) {
            console.log(`- Skipped ${user.uid} (email already set: ${data.email})`);
            skippedCount++;
          } else {
            console.log(`- Skipped ${user.uid} (no email in Auth)`);
            skippedCount++;
          }
        } else {
          console.log(`- Skipped ${user.uid} (no progress document)`);
          skippedCount++;
        }
      } catch (error) {
        console.error(`✗ Error updating ${user.uid}:`, error.message);
        errorCount++;
      }
    }
    
    console.log('\n=== Migration Complete ===');
    console.log(`Updated: ${updatedCount}`);
    console.log(`Skipped: ${skippedCount}`);
    console.log(`Errors: ${errorCount}`);
    
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrateUserEmails();
