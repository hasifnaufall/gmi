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

// Get activities by user
app.get('/activities/user/:userId', async (req, res) => {
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
app.post('/activity', async (req, res) => {
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

app.get('/test-firestore', async (req, res) => {
  try {
    const collections = await db.listCollections();
    res.send({ collections: collections.map(col => col.id) });
  } catch (error) {
    console.error(error);
    res.status(500).send({ error: error.message });
  }
});

app.get('/activities/recent', async (req, res) => {
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



// Listen
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});