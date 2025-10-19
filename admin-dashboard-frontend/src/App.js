import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('overview');
  const [users, setUsers] = useState([]);
  const [analytics, setAnalytics] = useState({});
  const [activities, setActivities] = useState([]);
  const [leaderboard, setLeaderboard] = useState([]);
  const [displayNameChanges, setDisplayNameChanges] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const API_BASE = 'http://localhost:5000';

  useEffect(() => {
    fetchData();
    fetchLeaderboard();
    fetchDisplayNameChanges();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch all data in parallel
      const [usersRes, analyticsRes, activitiesRes] = await Promise.all([
        fetch(`${API_BASE}/users/combined`),
        fetch(`${API_BASE}/analytics/summary`),
        fetch(`${API_BASE}/activities/recent`)
      ]);

      const usersData = await usersRes.json();
      const analyticsData = await analyticsRes.json();
      const activitiesData = await activitiesRes.json();

      setUsers(usersData);
      setAnalytics(analyticsData);
      setActivities(activitiesData);
      setLoading(false);
    } catch (err) {
      setError('Failed to fetch data');
      setLoading(false);
    }
  };

  const fetchLeaderboard = async () => {
    try {
      const res = await fetch(`${API_BASE}/leaderboard`);
      const data = await res.json();
      setLeaderboard(data);
    } catch (err) {
      setLeaderboard([]);
    }
  };

  const fetchDisplayNameChanges = async () => {
    try {
      const res = await fetch(`${API_BASE}/display-name-changes`);
      const data = await res.json();
      console.log('Fetched display name changes:', data); // Debug log
      setDisplayNameChanges(data);
    } catch (err) {
      setDisplayNameChanges([]);
      console.error('Error fetching display name changes:', err); // Debug log
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
      <h2>📊 Analytics Overview</h2>
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
      <h2>👥 User Management</h2>
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
      <h2>🎮 User Progress Details</h2>
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
      <h2>📋 Recent Activities</h2>
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
      <h2>🏆 Global Leaderboard</h2>
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
                <td>{user.userId}</td>
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
      <h2>📝 Display Name Changes</h2>
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

  if (loading) {
    return (
      <div className="App">
        <div className="loading">Loading admin dashboard...</div>
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
        <div className="tab-nav">
          <button 
            className={activeTab === 'overview' ? 'active' : ''}
            onClick={() => setActiveTab('overview')}
          >
            📊 Overview
          </button>
          <button 
            className={activeTab === 'users' ? 'active' : ''}
            onClick={() => setActiveTab('users')}
          >
            👥 Users
          </button>
          <button 
            className={activeTab === 'progress' ? 'active' : ''}
            onClick={() => setActiveTab('progress')}
          >
            🎮 Progress
          </button>
          <button 
            className={activeTab === 'activities' ? 'active' : ''}
            onClick={() => setActiveTab('activities')}
          >
            📋 Activities
          </button>
          <button 
            className={activeTab === 'leaderboard' ? 'active' : ''}
            onClick={() => setActiveTab('leaderboard')}
          >
            🏆 Leaderboard
          </button>
          <button 
            className={activeTab === 'displayNameChanges' ? 'active' : ''}
            onClick={() => setActiveTab('displayNameChanges')}
          >
            📝 Name Changes
          </button>
        </div>
        <button className="refresh-btn" onClick={() => {fetchData(); fetchLeaderboard(); fetchDisplayNameChanges();}}>
          🔄 Refresh
        </button>
      </header>

      <main className="app-main">
        {activeTab === 'overview' && <OverviewTab />}
        {activeTab === 'users' && <UsersTab />}
        {activeTab === 'progress' && <ProgressTab />}
        {activeTab === 'activities' && <ActivitiesTab />}
        {activeTab === 'leaderboard' && <LeaderboardTab />}
        {activeTab === 'displayNameChanges' && <DisplayNameChangesTab />}
      </main>
    </div>
  );
}

export default App;