# Deploy Backend to Render.com (Free)

## Step 1: Sign Up for Render
1. Go to https://render.com
2. Sign up with your GitHub account

## Step 2: Create New Web Service
1. Click "New +" → "Web Service"
2. Connect your GitHub repository: `hasifnaufall/gmi`
3. Configure the service:
   - **Name**: `waveact-backend`
   - **Root Directory**: `admin-dashboard-backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node index.js`
   - **Plan**: Free

## Step 3: Add Environment Variables
In the Render dashboard, go to "Environment" tab and add:

```
FIREBASE_PROJECT_ID = waveact-e419c
FIREBASE_CLIENT_EMAIL = firebase-adminsdk-fbsvc@waveact-e419c.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY = -----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCfNwZH7tj0vvXS
kXfUOxRIi9Cuv6CXCzmidHs0FGURlxrc1jotDzKVPOtb22ho7N/9CG1Vj7lZGPbH
V+wvZCHZWSNiajE49eQyYj++vSHsKOtUYMPrAsWD92ItcSgdA/RpKZbqjLZ/KCBM
6vDeYkhxNfLGVGNLaypvq5Ntwg0wm16jTncpKLbjT8J0g0iKlYx8oSGCdg/NPXbj
PPr60I+TRbyyTPzO2Xg+n59A0NdL32qn+Yt7QF9iVRsXeAR/R++bT5Aup8aIa7mQ
nEfVA9YMYfo65Pz5XhoidfJm+HU08xjEaqeHscEO59i4tv2hhJdmF5oCJ1+Jmx9F
90780ydxAgMBAAECggEAASfTa66cJcgaruxG49WvMBdByyyy9Gx+RUhXq9OVUXVH
KnjJUxU5KuZzNDXCWYcbf9NjPqlYf5Q2Xjdl/HwE54Y0D+fJIX9eFSXIh5VpT25Z
v84eCk817YJiuxI6ZJE4MX9BJB5wwjLhftXScsAnVvkcun1N4gpvxEy/b3h9Gb5q
ND4qr1PHfMsyiramQE0Z9D+R32gCTBiM/Dvr1hI38QJkTSDHHe9xyA+Z9aIoNYPx
8SaLpslGGttNqT7llffbn2GWPUk2SRK3h4KeJppuZP+NrpAKT/ELl1z+hUGzbZa/
meva7lRVqhSXSf3z8AhZcf1APZZC12AU2TlIC5YcIQKBgQDYfwyXU3op1IFPUR1A
oWUUCZ9qIfeK35th4GWz5vdgyzO0tMHQgIHd0Br7UiSzSdqMTqhTEGmHETpJQu9N
+8XCPZRNrNZJBHJSSF61wnT0qKV9FI6SQHCIyaqdIMRPgzkMKoY6upf71z+JSdXC
JvOouRoETWzKxEUGyr5Redvs0QKBgQC8REFgBCXEYPoeZLF4skkAsaPSxULg4GUD
exWCWbzFyo/XqcH21fmgAzlvwW2WCG9OcbRNIKfFYEVOtLBOqRrcosHBELIAQGHW
1fS7sopAzX/wYDBCPwyeE8xsyUbWbhu12L5TgDDQtN9ubBefEQF+n2BQeu6tRB+L
FK/Oob24oQKBgGBO1GkVB4lIMWX5bYvswCxTw4jRJ2+t3U+DJXsMSgvTGWNP7dA0
+pCUHQykFBN1zTURYKvi5y7gqQ8iKZaFZAnunuSW+JRu1/RmoUs2ABU+WK/1zx6c
b/NJ0w4nH21HsL8Kw7+odifgLzGBmQfPkCEEhuBXGQhym0pUMqnIDd+hAoGACUC9
ic+KX6V4hYfjZRA2IE+awqApUk4VCN/Cxd5NNddnzGyueMg5dZDTANgb37TYa52R
A/1n4X6CyYR96c/L3y4soaWFahe/90QavCLhQqAW+qRvmsHoh9hnQq19ysosmHpn
mEkDnS5WkOHFI289iJCitjHkiyV++2Hv5hLy9SECgYBtwyLMGmfWIDKDgPMJo+6Q
3dwUAye78RxJ6O/O7wpPKgbYDpJjIxYGVvLdYtejnlkfhgGf+IVEwIS67PJ/6ZAO
gY+6Sn8KPXlfOTojWv99Qkmi3CR2TAwTj2tlDF5O2WY6cYVnX0BtdrKSX/kAQk3d
YB2WonNR5eQoCA3ZCVzzyQ==
-----END PRIVATE KEY-----
```

**IMPORTANT**: Copy the entire private key including the BEGIN and END lines as a single value.

## Step 4: Deploy
1. Click "Create Web Service"
2. Wait for deployment to complete (2-3 minutes)
3. Copy your backend URL (e.g., `https://waveact-backend.onrender.com`)

## Step 5: Update Frontend
1. Edit `admin-dashboard-frontend/.env.production`
2. Replace with your Render backend URL:
   ```
   REACT_APP_API_URL=https://waveact-backend.onrender.com
   ```
3. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Update backend URL to Render deployment"
   git push
   ```
4. Vercel will automatically redeploy your frontend

## Done! 🎉
Visit https://waveact.vercel.app and it should work without needing to start the backend locally!

## Important Notes:
- Free Render instances sleep after 15 minutes of inactivity
- First request after sleep takes ~30 seconds to wake up
- For 24/7 uptime, upgrade to paid plan ($7/month)
