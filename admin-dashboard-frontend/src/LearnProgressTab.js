import React, { useEffect, useState } from 'react';

const API_BASE = 'http://localhost:5000';

function LearnProgressTab({ token }) {
  const [learnProgress, setLearnProgress] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!token) return;
    fetch(`${API_BASE}/users/learn-progress`, {
      headers: { Authorization: `Bearer ${token}` },
    })
      .then(res => res.json())
      .then(data => {
        setLearnProgress(data);
        setLoading(false);
      })
      .catch(err => {
        setError('Failed to fetch learn progress');
        setLoading(false);
      });
  }, [token]);

  if (loading) return <div>Loading learn progress...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="tab-content">
      <h2>Learn Progress (Learning Mode)</h2>
      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Alphabet</th>
              <th>Numbers</th>
              <th>Colours</th>
              <th>Fruits</th>
              <th>Animals</th>
              <th>Verbs</th>
            </tr>
          </thead>
          <tbody>
            {learnProgress.map(user => (
              <tr key={user.userId}>
                <td>{user.displayName || user.userId}</td>
                <td>{user.learnedAlphabetAll ? '✔️' : ''}</td>
                <td>{user.learnedNumbersAll ? '✔️' : ''}</td>
                <td>{user.learnedColoursAll ? '✔️' : ''}</td>
                <td>{user.learnedFruitsAll ? '✔️' : ''}</td>
                <td>{user.learnedAnimalsAll ? '✔️' : ''}</td>
                <td>{user.learnedVerbsAll ? '✔️' : ''}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default LearnProgressTab;
