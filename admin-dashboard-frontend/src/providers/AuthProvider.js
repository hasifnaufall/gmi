import React, { createContext, useContext, useEffect, useState } from 'react';
import { auth, onAuthStateChanged, signInWithPopup, provider, signOut } from '../firebase';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [token, setToken] = useState(null);

  useEffect(() => {
    console.log('AuthProvider: Setting up auth listener');
    const unsub = onAuthStateChanged(auth, async (firebaseUser) => {
      console.log('Auth state changed. User:', firebaseUser?.email || 'Not signed in');
      setUser(firebaseUser);
      if (firebaseUser) {
        const t = await firebaseUser.getIdToken();
        setToken(t);
        console.log('Token acquired');
      } else {
        setToken(null);
      }
      setLoading(false);
      console.log('Auth loading complete');
    });
    return () => unsub();
  }, []);

  const loginWithGoogle = async () => {
    try {
      await signInWithPopup(auth, provider);
    } catch (error) {
      // Ignore popup cancelled errors - user intentionally closed the popup
      if (error.code === 'auth/cancelled-popup-request' || error.code === 'auth/popup-closed-by-user') {
        console.log('Login cancelled by user');
        return;
      }
      // Log other errors but don't crash
      console.error('Login error:', error);
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, loginWithGoogle, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
