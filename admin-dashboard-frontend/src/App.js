// App.js
import React, { useEffect, useState } from 'react';
import './App.css';
import { useAuth } from './providers/AuthProvider';
import { getFirestore, doc, getDoc } from 'firebase/firestore';
import { app } from './firebase';

function App() {
  const { user, token, loading: authLoading, loginWithGoogle, logout } = useAuth();
  const [activeTab, setActiveTab] = useState('overview');
  const [users, setUsers] = useState([]);
  const [analytics, setAnalytics] = useState({});
  const [activities, setActivities] = useState([]);
  const [leaderboard, setLeaderboard] = useState([]);
  const [displayNameChanges, setDisplayNameChanges] = useState([]);
  const [feedback, setFeedback] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [isAdmin, setIsAdmin] = useState(null); // null: unknown, false: not admin, true: admin

  const API_BASE = 'http://localhost:5000';

  useEffect(() => {
    if (!user) return;
    // Check admin status in Firestore
    const checkAdmin = async () => {
      try {
        console.log('Checking admin status for UID:', user.uid);
        const db = getFirestore(app);
        const adminDoc = await getDoc(doc(db, 'admins', user.uid));
        console.log('Admin doc exists:', adminDoc.exists());
        if (adminDoc.exists()) {
          console.log('Admin doc data:', adminDoc.data());
        }
        setIsAdmin(adminDoc.exists() && adminDoc.data().isAdmin === true);
      } catch (err) {
        console.error('Error checking admin status:', err);
        setIsAdmin(false);
      }
    };
    checkAdmin();
  }, [user]);

  useEffect(() => {
    if (!token || !isAdmin) return;
    fetchData();
    fetchLeaderboard();
    fetchDisplayNameChanges();
    fetchFeedback();
  }, [token, isAdmin]);

  const authHeaders = () => ({
    headers: { Authorization: `Bearer ${token}` }
  });

  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch all data in parallel
      const [usersRes, analyticsRes, activitiesRes] = await Promise.all([
        fetch(`${API_BASE}/users/combined`, authHeaders()).catch(e => null),
        fetch(`${API_BASE}/analytics/summary`, authHeaders()).catch(e => null),
        fetch(`${API_BASE}/activities/recent`, authHeaders()).catch(e => null)
      ]);

      const usersData = usersRes ? await usersRes.json().catch(() => []) : [];
      const analyticsData = analyticsRes ? await analyticsRes.json().catch(() => ({})) : {};
      const activitiesData = activitiesRes ? await activitiesRes.json().catch(() => []) : [];

      setUsers(usersData);
      setAnalytics(analyticsData);
      setActivities(activitiesData);
      setError((!usersRes && !analyticsRes && !activitiesRes) ? 'Backend server not running. Please start the backend with the Firebase service account key.' : '');
      setLoading(false);
    } catch (err) {
      setError('Backend server not running. Please start the backend with the Firebase service account key.');
      setLoading(false);
    }
  };

  const fetchLeaderboard = async () => {
    try {
      const res = await fetch(`${API_BASE}/leaderboard`, authHeaders());
      if (!res) {
        setLeaderboard([]);
        return;
      }
      const data = await res.json();
      setLeaderboard(data);
    } catch (err) {
      setLeaderboard([]);
    }
  };

  const fetchDisplayNameChanges = async () => {
    try {
      const res = await fetch(`${API_BASE}/display-name-changes`, authHeaders());
      if (!res) {
        setDisplayNameChanges([]);
        return;
      }
      const data = await res.json();
      console.log('Fetched display name changes:', data); // Debug log
      setDisplayNameChanges(data);
    } catch (err) {
      setDisplayNameChanges([]);
      console.error('Error fetching display name changes:', err); // Debug log
    }
  };

  const fetchFeedback = async () => {
    try {
      const res = await fetch(`${API_BASE}/feedback`, authHeaders());
      if (!res) {
        setFeedback([]);
        return;
      }
      const data = await res.json();
      console.log('Fetched feedback:', data);
      setFeedback(data);
    } catch (err) {
      setFeedback([]);
      console.error('Error fetching feedback:', err);
    }
  };

  const updateFeedbackStatus = async (feedbackId, newStatus) => {
    try {
      await fetch(`${API_BASE}/feedback/${feedbackId}/status`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ status: newStatus })
      });
      fetchFeedback(); // Refresh the list
    } catch (err) {
      console.error('Error updating feedback status:', err);
    }
  };

  // Robust Firestore timestamp parser
  const formatDate = (ts) => {
    if (!ts) return 'Never';
    // Firestore Timestamp object
    if (typeof ts === 'object') {
      if (ts.seconds) {
        return new Date(ts.seconds * 1000).toLocaleString();
      }
      if (ts._seconds) {
        return new Date(ts._seconds * 1000).toLocaleString();
      }
    }
    // ISO string or number
    return new Date(ts).toLocaleString();
  };

  const OverviewTab = () => (
    <div className="tab-content">
      <h2>Analytics Overview</h2>
      <div className="stats-grid">
        <div className="stat-card">
          <h3>{analytics.totalUsers || 0}</h3>
          <p>Total Users</p>
        </div>
        <div className="stat-card">
          <h3>{analytics.totalUsersWithProgress || 0}</h3>
          <p>Active Players</p>
        </div>
        <div className="stat-card">
          <h3>{Math.round(analytics.avgLevel || 0)}</h3>
          <p>Average Level</p>
        </div>
        <div className="stat-card">
          <h3>{Math.round(analytics.avgXP || 0)}</h3>
          <p>Average XP</p>
        </div>
        <div className="stat-card">
          <h3>{analytics.maxLevel || 0}</h3>
          <p>Highest Level</p>
        </div>
        <div className="stat-card">
          <h3>{analytics.totalChests || 0}</h3>
          <p>Total Chests Opened</p>
        </div>
      </div>
    </div>
  );

  const UsersTab = () => (
    <div className="tab-content">
      <h2>User Management</h2>
      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Email</th>
              <th>Level</th>
              <th>XP</th>
              <th>Chests</th>
              <th>Streak</th>
              <th>User Points</th>
              <th>Last Sign In</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {users.map(user => (
              <tr key={user.uid}>
                <td>{user.email}</td>
                <td>{user.progress?.level || 'N/A'}</td>
                <td>{user.progress?.score || 'N/A'}</td>
                <td>{user.progress?.chestsOpened || 'N/A'}</td>
                <td>{user.progress?.streakDays || 'N/A'}</td>
                <td>{user.progress?.userPoints || 'N/A'}</td>
                <td>{formatDate(user.lastSignInTime)}</td>
                <td>
                  <span className={`status ${user.disabled ? 'disabled' : 'active'}`}>
                    {user.disabled ? 'Disabled' : 'Active'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const ProgressTab = () => (
    <div className="tab-content">
      <h2>User Progress Details</h2>
      <div className="progress-grid">
        {users.filter(user => user.progress).map(user => (
          <div key={user.uid} className="progress-card">
            <h3>{user.email}</h3>
            <div className="progress-details">
              <div className="progress-row">
                <span>Level:</span>
                <span>{user.progress.level}</span>
              </div>
              <div className="progress-row">
                <span>XP:</span>
                <span>{user.progress.score}</span>
              </div>
              <div className="progress-row">
                <span>User Points:</span>
                <span>{user.progress.userPoints}</span>
              </div>
              <div className="progress-row">
                <span>Claimed Points:</span>
                <span>{user.progress.claimedPoints}/{user.progress.levelGoalPoints}</span>
              </div>
              <div className="progress-row">
                <span>Chests Opened:</span>
                <span>{user.progress.chestsOpened}</span>
              </div>
              <div className="progress-row">
                <span>Current Streak:</span>
                <span>{user.progress.streakDays} days</span>
              </div>
              <div className="progress-row">
                <span>Longest Streak:</span>
                <span>{user.progress.longestStreak} days</span>
              </div>
              <div className="progress-row">
                <span>Achievements:</span>
                <span>{user.progress.achievements?.length || 0}</span>
              </div>
              <div className="progress-row">
                <span>Unlocked Content:</span>
                <span>{user.progress.unlockedContent?.length || 0}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const ActivitiesTab = () => (
    <div className="tab-content">
      <h2>Recent Activities</h2>
      <div className="activities-list">
        {activities.length > 0 ? (
          activities.map(activity => (
            <div key={activity.id} className="activity-item">
              <div className="activity-type">{activity.type}</div>
              <div className="activity-details">{activity.details}</div>
              <div className="activity-user">User: {activity.userId}</div>
              <div className="activity-time">{formatDate(activity.timestamp?.toDate?.())}</div>
            </div>
          ))
        ) : (
          <p>No activities found</p>
        )}
      </div>
    </div>
  );

  const LeaderboardTab = () => (
    <div className="tab-content">
      <h2>Global Leaderboard</h2>
      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Rank</th>
              <th>User ID</th>
              <th>Level</th>
              <th>XP</th>
            </tr>
          </thead>
          <tbody>
            {leaderboard.map((user, idx) => (
              <tr key={user.userId}>
                <td>{idx + 1}</td>
                <td>{user.displayName || user.userId}</td>
                <td>{user.level}</td>
                <td>{user.score}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const DisplayNameChangesTab = () => (
    <div className="tab-content">
      <h2>Display Name Changes</h2>
      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>User ID</th>
              <th>Old Name</th>
              <th>New Name</th>
            </tr>
          </thead>
          <tbody>
            {displayNameChanges.map(change => (
              <tr key={change.id}>
                <td>{formatDate(change.timestamp)}</td>
                <td>{change.userId}</td>
                <td>{change.oldName}</td>
                <td>{change.newName}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const FeedbackTab = () => (
    <div className="tab-content">
      <h2>User Feedback</h2>
      <div className="feedback-grid">
        {feedback.length > 0 ? (
          feedback.map(item => (
            <div key={item.id} className={`feedback-card ${item.status}`}>
              <div className="feedback-header">
                <div className="feedback-user">
                  <strong>{item.userName}</strong>
                  <span className="feedback-email">{item.userEmail}</span>
                </div>
                <span className={`status-badge ${item.status}`}>
                  {item.status || 'new'}
                </span>
              </div>
              <div className="feedback-message">
                {item.message}
              </div>
              <div className="feedback-footer">
                <span className="feedback-time">{formatDate(item.timestamp)}</span>
                <div className="feedback-actions">
                  {item.status !== 'read' && (
                    <button 
                      className="action-btn read"
                      onClick={() => updateFeedbackStatus(item.id, 'read')}
                    >
                      Mark Read
                    </button>
                  )}
                  {item.status !== 'resolved' && (
                    <button 
                      className="action-btn resolve"
                      onClick={() => updateFeedbackStatus(item.id, 'resolved')}
                    >
                      Resolve
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))
        ) : (
          <p className="no-data">No feedback received yet</p>
        )}
      </div>
    </div>
  );

  if (authLoading) {
    return (
      <div className="App">
        <div className="loading">Checking authentication…</div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="login-screen">
        <div className="login-card">
          <img src="/waveact.png" alt="WaveAct Logo" className="logo-img" />
          <h1>WaveAct Admin</h1>
          <p>Please sign in to continue</p>
          <button className="google-btn" onClick={loginWithGoogle}>Sign in with Google</button>
        </div>
      </div>
    );
  }

  if (isAdmin === null) {
    return (
      <div className="App">
        <div className="loading">Checking admin permissions…</div>
      </div>
    );
  }

  if (!isAdmin) {
    return (
      <div className="App">
        <div className="error">
          <h2>Not authorized</h2>
          <p>Your account does not have admin access.</p>
          <button onClick={logout}>Log out</button>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="App">
        <div className="error">
          <h2>Error: {error}</h2>
          <button onClick={fetchData}>Retry</button>
        </div>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="app-header">
        <div className="header-title-row">
          <img src="/waveact.png" alt="WaveAct Logo" className="logo-img" />
          <h1>WaveAct Admin Dashboard</h1>
        </div>
        <div className="user-chip">
          <span>{user.email}</span>
          <button className="logout-btn" onClick={logout}>Log out</button>
        </div>
        <div className="tab-nav">
          <button 
            className={activeTab === 'overview' ? 'active' : ''}
            onClick={() => setActiveTab('overview')}
          >
            Overview
          </button>
          <button 
            className={activeTab === 'users' ? 'active' : ''}
            onClick={() => setActiveTab('users')}
          >
            Users
          </button>
          <button 
            className={activeTab === 'progress' ? 'active' : ''}
            onClick={() => setActiveTab('progress')}
          >
            Progress
          </button>
          <button 
            className={activeTab === 'activities' ? 'active' : ''}
            onClick={() => setActiveTab('activities')}
          >
            Activities
          </button>
          <button 
            className={activeTab === 'leaderboard' ? 'active' : ''}
            onClick={() => setActiveTab('leaderboard')}
          >
            Leaderboard
          </button>
          <button 
            className={activeTab === 'displayNameChanges' ? 'active' : ''}
            onClick={() => setActiveTab('displayNameChanges')}
          >
            Name Changes
          </button>
          <button 
            className={activeTab === 'feedback' ? 'active' : ''}
            onClick={() => setActiveTab('feedback')}
          >
            Feedback
          </button>
        </div>
        <button className="refresh-btn" onClick={() => {fetchData(); fetchLeaderboard(); fetchDisplayNameChanges(); fetchFeedback();}}>
          Refresh
        </button>
      </header>

      <main className="app-main">
        {activeTab === 'overview' && <OverviewTab />}
        {activeTab === 'users' && <UsersTab />}
        {activeTab === 'progress' && <ProgressTab />}
        {activeTab === 'activities' && <ActivitiesTab />}
        {activeTab === 'leaderboard' && <LeaderboardTab />}
        {activeTab === 'displayNameChanges' && <DisplayNameChangesTab />}
        {activeTab === 'feedback' && <FeedbackTab />}
      </main>
    </div>
  );
}

export default App;