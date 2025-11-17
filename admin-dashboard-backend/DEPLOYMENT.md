# Admin Dashboard Deployment Guide

## Backend Deployment to Vercel

1. **Install Vercel CLI** (if not already installed):
   ```bash
   npm install -g vercel
   ```

2. **Navigate to backend folder**:
   ```bash
   cd admin-dashboard-backend
   ```

3. **Deploy to Vercel**:
   ```bash
   vercel
   ```
   - Follow the prompts
   - Choose "Yes" to set up and deploy
   - Note the deployment URL (e.g., `https://your-backend.vercel.app`)

4. **Set Environment Variables in Vercel**:
   - Go to your Vercel project dashboard
   - Navigate to Settings > Environment Variables
   - Add these variables:
     - `FIREBASE_PROJECT_ID`: `waveact-e419c`
     - `FIREBASE_CLIENT_EMAIL`: (from serviceAccountKey.json)
     - `FIREBASE_PRIVATE_KEY`: (from serviceAccountKey.json - the entire private key including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

5. **Redeploy after setting env variables**:
   ```bash
   vercel --prod
   ```

## Frontend Configuration

1. **Update the production environment file**:
   - Edit `admin-dashboard-frontend/.env.production`
   - Replace `https://your-backend-url.vercel.app` with your actual backend Vercel URL

2. **Redeploy Frontend**:
   - Commit and push changes to GitHub
   - Vercel will automatically redeploy the frontend

## Testing

1. Visit your frontend URL: `https://waveact.vercel.app`
2. The admin dashboard should now work without needing to run the backend locally!

## Local Development

For local development, the backend will still use `serviceAccountKey.json` and the frontend will connect to `http://localhost:5000` (configured in `.env.development`).
