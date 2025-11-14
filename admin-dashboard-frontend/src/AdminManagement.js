// AdminManagement.js
import React, { useState, useEffect } from 'react';
import { getFirestore, collection, getDocs, doc, setDoc, deleteDoc } from 'firebase/firestore';
import { app } from './firebase';
import './App.css';

function AdminManagement() {
  const [admins, setAdmins] = useState([]);
  const [newAdminEmail, setNewAdminEmail] = useState('');
  const [newAdminUid, setNewAdminUid] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchAdmins();
  }, []);

  const fetchAdmins = async () => {
    setLoading(true);
    try {
      const db = getFirestore(app);
      const adminsSnapshot = await getDocs(collection(db, 'admins'));
      const adminsList = adminsSnapshot.docs.map(doc => ({
        uid: doc.id,
        ...doc.data()
      }));
      setAdmins(adminsList);
    } catch (error) {
      console.error('Error fetching admins:', error);
      setMessage('Error fetching admins');
    } finally {
      setLoading(false);
    }
  };

  const addAdmin = async (e) => {
    e.preventDefault();
    if (!newAdminUid.trim()) {
      setMessage('Please enter a user UID');
      return;
    }

    setLoading(true);
    setMessage('');
    try {
      const db = getFirestore(app);
      await setDoc(doc(db, 'admins', newAdminUid), {
        isAdmin: true,
        email: newAdminEmail.trim() || null,
        createdAt: new Date().toISOString()
      });
      setMessage('Admin added successfully!');
      setNewAdminEmail('');
      setNewAdminUid('');
      fetchAdmins();
    } catch (error) {
      console.error('Error adding admin:', error);
      setMessage('Error adding admin: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const removeAdmin = async (uid) => {
    if (!window.confirm('Are you sure you want to remove this admin?')) {
      return;
    }

    setLoading(true);
    setMessage('');
    try {
      const db = getFirestore(app);
      await deleteDoc(doc(db, 'admins', uid));
      setMessage('Admin removed successfully!');
      fetchAdmins();
    } catch (error) {
      console.error('Error removing admin:', error);
      setMessage('Error removing admin: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="admin-management">
      <h2 style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '20px' }}>
        Admin Management
      </h2>

      {message && (
        <div style={{
          padding: '12px',
          marginBottom: '20px',
          borderRadius: '8px',
          backgroundColor: message.includes('Error') ? '#fee' : '#efe',
          color: message.includes('Error') ? '#c33' : '#363',
          border: `1px solid ${message.includes('Error') ? '#fcc' : '#cfc'}`
        }}>
          {message}
        </div>
      )}

      {/* Add New Admin Form */}
      <div style={{
        backgroundColor: '#fff',
        padding: '24px',
        borderRadius: '12px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        marginBottom: '30px'
      }}>
        <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '16px' }}>
          Add New Admin
        </h3>
        <form onSubmit={addAdmin}>
          <div style={{ marginBottom: '16px' }}>
            <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>
              User UID (Required) *
            </label>
            <input
              type="text"
              value={newAdminUid}
              onChange={(e) => setNewAdminUid(e.target.value)}
              placeholder="Enter Firebase User UID"
              style={{
                width: '100%',
                padding: '10px',
                border: '1px solid #ddd',
                borderRadius: '6px',
                fontSize: '14px'
              }}
              required
            />
            <small style={{ color: '#666', fontSize: '12px' }}>
              You can find the UID in Firebase Authentication console
            </small>
          </div>
          <div style={{ marginBottom: '16px' }}>
            <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500' }}>
              Email (Optional)
            </label>
            <input
              type="email"
              value={newAdminEmail}
              onChange={(e) => setNewAdminEmail(e.target.value)}
              placeholder="Enter admin email (optional)"
              style={{
                width: '100%',
                padding: '10px',
                border: '1px solid #ddd',
                borderRadius: '6px',
                fontSize: '14px'
              }}
            />
          </div>
          <button
            type="submit"
            disabled={loading}
            style={{
              backgroundColor: '#4CAF50',
              color: 'white',
              padding: '10px 24px',
              border: 'none',
              borderRadius: '6px',
              fontSize: '14px',
              fontWeight: '600',
              cursor: loading ? 'not-allowed' : 'pointer',
              opacity: loading ? 0.6 : 1
            }}
          >
            {loading ? 'Adding...' : 'Add Admin'}
          </button>
        </form>
      </div>

      {/* Current Admins List */}
      <div style={{
        backgroundColor: '#fff',
        padding: '24px',
        borderRadius: '12px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
      }}>
        <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '16px' }}>
          Current Admins ({admins.length})
        </h3>
        {loading && admins.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '20px', color: '#666' }}>
            Loading admins...
          </div>
        ) : admins.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '20px', color: '#666' }}>
            No admins found
          </div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{
              width: '100%',
              borderCollapse: 'collapse',
              fontSize: '14px'
            }}>
              <thead>
                <tr style={{ backgroundColor: '#f5f5f5', borderBottom: '2px solid #ddd' }}>
                  <th style={{ padding: '12px', textAlign: 'left', fontWeight: '600' }}>UID</th>
                  <th style={{ padding: '12px', textAlign: 'left', fontWeight: '600' }}>Email</th>
                  <th style={{ padding: '12px', textAlign: 'left', fontWeight: '600' }}>Added On</th>
                  <th style={{ padding: '12px', textAlign: 'center', fontWeight: '600' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {admins.map((admin) => (
                  <tr key={admin.uid} style={{ borderBottom: '1px solid #eee' }}>
                    <td style={{ padding: '12px', fontFamily: 'monospace', fontSize: '12px' }}>
                      {admin.uid}
                    </td>
                    <td style={{ padding: '12px' }}>
                      {admin.email || 'N/A'}
                    </td>
                    <td style={{ padding: '12px' }}>
                      {admin.createdAt ? new Date(admin.createdAt).toLocaleDateString() : 'N/A'}
                    </td>
                    <td style={{ padding: '12px', textAlign: 'center' }}>
                      <button
                        onClick={() => removeAdmin(admin.uid)}
                        disabled={loading}
                        style={{
                          backgroundColor: '#f44336',
                          color: 'white',
                          padding: '6px 16px',
                          border: 'none',
                          borderRadius: '4px',
                          fontSize: '12px',
                          fontWeight: '600',
                          cursor: loading ? 'not-allowed' : 'pointer',
                          opacity: loading ? 0.6 : 1
                        }}
                      >
                        Remove
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Instructions */}
      <div style={{
        marginTop: '30px',
        padding: '16px',
        backgroundColor: '#f9f9f9',
        borderRadius: '8px',
        border: '1px solid #e0e0e0'
      }}>
        <h4 style={{ fontSize: '14px', fontWeight: '600', marginBottom: '8px' }}>
          📝 Instructions:
        </h4>
        <ul style={{ fontSize: '13px', color: '#666', lineHeight: '1.6', paddingLeft: '20px' }}>
          <li>To add a new admin, you need the user's Firebase UID from the Authentication console</li>
          <li>The email field is optional but recommended for reference</li>
          <li>Only users in this list can access the admin dashboard</li>
          <li>Be careful when removing admins - this action cannot be undone</li>
        </ul>
      </div>
    </div>
  );
}

export default AdminManagement;
