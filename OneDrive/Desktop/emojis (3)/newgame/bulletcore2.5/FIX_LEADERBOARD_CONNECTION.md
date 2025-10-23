# 🏆 Fix Leaderboard "Unable to Load" Error

## Problem
Leaderboard shows: "⚠️ Unable to load leaderboard. Please check your connection and try again."

---

## Quick Diagnosis Steps

### Step 1: Check if Supabase Database Has Data

The leaderboard might be empty (no players yet). This is normal if no one has played yet.

**Test by adding a test player:**

1. Go to Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Click "Table Editor" in sidebar
4. Find the `leaderboard` table
5. Click "+ Insert row"
6. Add test data:
   - player_name: "TestPlayer"
   - score: 10000
   - kills: 50
   - wave: 10
7. Click "Save"
8. Refresh your leaderboard page

---

## Common Issues & Solutions

### Issue 1: Table Doesn't Exist

**Solution:** Run the SQL setup

1. Open Supabase Dashboard
2. Click "SQL Editor"
3. Click "New Query"
4. Copy and paste the SQL from `COMPLETE_SUPABASE_DATABASE_SETUP.sql`
5. Click "Run"

---

### Issue 2: API Key is Wrong

**Check your Supabase credentials in `leaderboard.html`:**

Current values in your file:
```javascript
const SUPABASE_URL = 'https://flnbfizlfofqfbrdjttk.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

**Verify these match your Supabase project:**

1. Go to Supabase Dashboard
2. Click "Project Settings" (gear icon)
3. Click "API" in sidebar
4. Compare:
   - URL should match `Project URL`
   - Key should match `anon public` key

If they don't match, update `leaderboard.html` with correct values.

---

### Issue 3: CORS / Network Error

**Check browser console for errors:**

1. Open leaderboard page: https://hideoutads.online/leaderboard.html
2. Press **F12** (Developer Tools)
3. Click "Console" tab
4. Look for red errors

**Common errors:**
- `CORS policy`: Need to add your domain to Supabase allowed origins
- `Network Error`: Check internet connection
- `supabase is not defined`: Supabase library didn't load

---

### Issue 4: Supabase Library Not Loading

The leaderboard dynamically loads Supabase library from CDN. If this fails:

**Solution:** Check if blocked by ad-blocker or firewall

1. Disable ad-blocker temporarily
2. Check browser console for:
   ```
   Failed to load resource: net::ERR_BLOCKED_BY_CLIENT
   ```

---

### Issue 5: RLS (Row Level Security) Blocking Access

**Check RLS policies:**

1. Go to Supabase Dashboard
2. Click "Authentication" → "Policies"
3. Find `leaderboard` table
4. Make sure there's a policy allowing `SELECT` for `anon` role

**Quick fix - Disable RLS temporarily for testing:**

```sql
ALTER TABLE leaderboard DISABLE ROW LEVEL SECURITY;
```

**WARNING:** Only use this for testing. Re-enable with proper policies for production.

---

## Test the Fix

### Option 1: Browser Console Test

1. Open: https://hideoutads.online/leaderboard.html
2. Press **F12**
3. Go to "Console" tab
4. Paste and run:

```javascript
const testConnection = async () => {
    const SUPABASE_URL = 'https://flnbfizlfofqfbrdjttk.supabase.co';
    const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsbmJmaXpsZm9mcWZicmRqdHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk1NTMzNzUsImV4cCI6MjA0NTEyOTM3NX0.kQ9HoYOuVxoQNZAVTy1kpXH3l68kRTBdSbE5_pzI9ik';
    
    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
    
    const { data, error } = await supabase
        .from('leaderboard')
        .select('*')
        .limit(5);
    
    if (error) {
        console.error('❌ Error:', error);
    } else {
        console.log('✅ Success! Data:', data);
    }
};

testConnection();
```

**Expected results:**
- ✅ `Success! Data:` - Connection works, shows data
- ❌ `Error: relation "public.leaderboard" does not exist` - Table not created
- ❌ `Error: Invalid API key` - Wrong credentials

---

### Option 2: Add Test Data Manually

If table exists but is empty:

**Go to Supabase Dashboard → SQL Editor:**

```sql
-- Insert test players
INSERT INTO leaderboard (player_name, score, kills, wave, created_at)
VALUES 
  ('King_davez', 50000, 500, 50, NOW()),
  ('TestPlayer', 30000, 300, 30, NOW()),
  ('TopGun', 25000, 250, 25, NOW()),
  ('AcePlayer', 20000, 200, 20, NOW()),
  ('ProGamer', 15000, 150, 15, NOW());

-- Verify data was inserted
SELECT * FROM leaderboard ORDER BY score DESC LIMIT 10;
```

Then refresh leaderboard page.

---

## Alternative: Check if Problem is Just Empty Database

The leaderboard might actually be working, but shows error because the table is empty and returns null.

**Modify the error handling:**

Instead of showing "Unable to load", show "No players yet" for empty results.

This is already handled in the code:
```javascript
if (!data || data.length === 0) {
    content.innerHTML = '<div class="loading">No players yet. Be the first!</div>';
    return;
}
```

So if you see "Unable to load", it means the Supabase query is actually **failing**, not just returning empty results.

---

## Quick Fix Summary

**Most likely causes (in order):**

1. **Empty database** → Add test data
2. **Table doesn't exist** → Run SQL setup
3. **Wrong API credentials** → Update leaderboard.html
4. **RLS blocking access** → Check/disable RLS policies

**To test:**
1. Open browser console (F12)
2. Look for red errors
3. Run the test connection code above

---

## Need Help?

**If still not working, check:**
1. Browser console errors (F12 → Console)
2. Supabase project status (dashboard)
3. Network tab (F12 → Network) for failed requests

---

*Most common issue: Table is empty, not an actual error. Add test data to verify!*
