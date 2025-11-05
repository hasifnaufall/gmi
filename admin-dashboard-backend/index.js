const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json'); // <--- Download this from Firebase Console
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'waveact-e419c'
});

const db = admin.firestore();

const app = express();
app.use(cors());
app.use(express.json());

// Test route
app.get('/', (req, res) => {
  res.send('Admin Dashboard Backend Running');
});

// ===== AUTH MIDDLEWARE =====
async function verifyAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.substring(7)
      : null;
    if (!token) {
      return res.status(401).send({ error: 'Missing Authorization Bearer token' });
    }
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded; // { uid, email, ... }
    next();
  } catch (err) {
    console.error('Auth verification failed:', err);
    return res.status(401).send({ error: 'Invalid or expired token' });
  }
}

async function requireAdmin(req, res, next) {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).send({ error: 'Unauthenticated' });
    const doc = await db.collection('admins').doc(uid).get();
    const isAdmin = doc.exists && (doc.data().isAdmin === true);
    if (!isAdmin) {
      return res.status(403).send({ error: 'Forbidden: admin access only' });
    }
    next();
  } catch (err) {
    console.error('Admin check failed:', err);
    return res.status(500).send({ error: 'Admin check failed' });
  }
}

// Get activities by user
app.get('/activities/user/:userId', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const snapshot = await db.collection('activities')
      .where('userId', '==', userId)
      .orderBy('timestamp', 'desc')
      .limit(20)
      .get();
    const activities = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    res.send(activities);
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

// Add activity (fixed!)
app.post('/activity', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const { userId, type, details } = req.body;
    if (!userId || !type) {
      return res.status(400).send({ error: 'userId and type are required.' });
    }
    await db.collection('activities').add({
      userId,
      type,
      details: details || "",
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });
    res.status(201).send({ success: true });
  } catch (error) {
      console.error(error); // <--- Add this line
      res.status(500).send({ error: error.message });
    }
});

app.get('/test-firestore', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const collections = await db.listCollections();
    res.send({ collections: collections.map(col => col.id) });
  } catch (error) {
    console.error(error);
    res.status(500).send({ error: error.message });
  }
});

app.get('/activities/recent', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const snapshot = await db.collection('activities')
      .orderBy('timestamp', 'desc')
      .limit(20)
      .get();
    const activities = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    res.send(activities);
  } catch (error) {
    console.error(error);
    res.status(500).send({ error: error.message });
  }
});

// Optional: allow unauthenticated feedback posting from apps using Admin SDK rules.
// If you prefer to restrict to authenticated users only, add verifyAuth here too.
app.post('/feedback', async (req, res) => {
  try {
    const { userId, message } = req.body;
    if (!userId || !message) {
      return res.status(400).send({ error: 'userId and message are required.' });
    }
    await db.collection('feedback').add({
      userId,
      message,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });
    res.status(201).send({ success: true });
  } catch (error) {
    console.error(error);
    res.status(500).send({ error: error.message });
  }
});

// ===== USER PROGRESS ROUTES =====

// Get all users and their progress
app.get('/users/progress', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const snapshot = await db.collection('progress').get();
    const users = snapshot.docs.map(doc => ({
      userId: doc.id,
      ...doc.data(),
      lastStreakUtc: doc.data().lastStreakUtc ? new Date(doc.data().lastStreakUtc).toISOString() : null
    }));
    res.send(users);
  } catch (error) {
    console.error('Error fetching user progress:', error);
    res.status(500).send({ error: error.message });
  }
});

// Get specific user progress
app.get('/users/progress/:userId', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const { userId } = req.params;
    const doc = await db.collection('progress').doc(userId).get();
    if (!doc.exists) {
      return res.status(404).send({ error: 'User progress not found' });
    }
    const data = doc.data();
    res.send({
      userId: doc.id,
      ...data,
      lastStreakUtc: data.lastStreakUtc ? new Date(data.lastStreakUtc).toISOString() : null
    });
  } catch (error) {
    console.error('Error fetching user progress:', error);
    res.status(500).send({ error: error.message });
  }
});

// Get all users from Auth
app.get('/users/auth', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const listUsers = await admin.auth().listUsers(1000);
    const users = listUsers.users.map(user => ({
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      disabled: user.disabled,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      providerData: user.providerData
    }));
    res.send(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).send({ error: error.message });
  }
});

// Combined users (auth + progress)
app.get('/users/combined', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const listUsers = await admin.auth().listUsers(1000);
    const authUsers = listUsers.users.map(user => ({
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      disabled: user.disabled,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime
    }));

    const progressSnapshot = await db.collection('progress').get();
    const progressData = {};
    progressSnapshot.docs.forEach(doc => {
      progressData[doc.id] = doc.data();
    });

    const combinedUsers = authUsers.map(user => ({
      ...user,
      progress: progressData[user.uid] || null
    }));

    // Sort by last sign-in time (most recent first)
    combinedUsers.sort((a, b) => {
      const timeA = a.lastSignInTime ? new Date(a.lastSignInTime).getTime() : 0;
      const timeB = b.lastSignInTime ? new Date(b.lastSignInTime).getTime() : 0;
      return timeB - timeA; // Descending order (most recent first)
    });

    res.send(combinedUsers);
  } catch (error) {
    console.error('Error fetching combined user data:', error);
    res.status(500).send({ error: error.message });
  }
});

// ===== ANALYTICS ROUTES =====

// Get user stats summary
app.get('/analytics/summary', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const authUsers = await admin.auth().listUsers(1000);
    const totalUsers = authUsers.users.length;

    const progressSnapshot = await db.collection('progress').get();
    const progressStats = {
      totalUsersWithProgress: progressSnapshot.size,
      totalLevel: 0,
      totalXP: 0,
      totalChests: 0,
      totalStreaks: 0,
      maxLevel: 0,
      maxXP: 0
    };

    progressSnapshot.docs.forEach(doc => {
      const data = doc.data();
      progressStats.totalLevel += data.level || 0;
      progressStats.totalXP += data.score || 0;
      progressStats.totalChests += data.chestsOpened || 0;
      progressStats.totalStreaks += data.streakDays || 0;
      progressStats.maxLevel = Math.max(progressStats.maxLevel, data.level || 0);
      progressStats.maxXP = Math.max(progressStats.maxXP, data.score || 0);
    });

    res.send({
      totalUsers,
      ...progressStats,
      avgLevel: progressStats.totalUsersWithProgress > 0 ? progressStats.totalLevel / progressStats.totalUsersWithProgress : 0,
      avgXP: progressStats.totalUsersWithProgress > 0 ? progressStats.totalXP / progressStats.totalUsersWithProgress : 0
    });
  } catch (error) {
    console.error('Error fetching analytics:', error);
    res.status(500).send({ error: error.message });
  }
});

// Global leaderboard endpoint
app.get('/leaderboard', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const snapshot = await db.collection('progress')
      .orderBy('level', 'desc')
      .limit(20)
      .get();
    
    // Fetch usernames for each user
    const leaderboard = await Promise.all(snapshot.docs.map(async (doc) => {
      const data = doc.data();
      let displayName = doc.id; // Default to userId
      
      // Priority: changeName > displayName > email (before @)
      if (data.changeName) {
        displayName = data.changeName;
      } else if (data.displayName) {
        displayName = data.displayName;
      } else if (data.email) {
        // Extract part before @ from email
        displayName = data.email.split('@')[0];
      }
      
      return {
        userId: doc.id,
        displayName,
        ...data
      };
    }));
    
    res.send(leaderboard);
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

// Display name change history endpoint
app.get('/display-name-changes', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const snapshot = await db.collection('display_name_changes')
      .orderBy('timestamp', 'desc')
      .limit(50)
      .get();
    const changes = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    res.send(changes);
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

// ===== FEEDBACK ROUTES =====

// Get all feedback
app.get('/feedback', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const snapshot = await db.collection('feedback')
      .orderBy('timestamp', 'desc')
      .limit(100)
      .get();
    const feedback = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    res.send(feedback);
  } catch (error) {
    console.error('Error fetching feedback:', error);
    res.status(500).send({ error: error.message });
  }
});

// Update feedback status
app.put('/feedback/:feedbackId/status', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const { feedbackId } = req.params;
    const { status } = req.body;
    
    if (!['new', 'read', 'resolved'].includes(status)) {
      return res.status(400).send({ error: 'Invalid status. Must be: new, read, or resolved' });
    }

    await db.collection('feedback').doc(feedbackId).update({
      status: status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.send({ success: true, feedbackId, status });
  } catch (error) {
    console.error('Error updating feedback status:', error);
    res.status(500).send({ error: error.message });
  }
});

// Listen
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});