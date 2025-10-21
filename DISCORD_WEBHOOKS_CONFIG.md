# Discord Webhooks Configuration

## Webhook URLs

Your Discord webhooks are configured for the following purposes:

### 1. Bug Reports
**URL:** `https://discord.com/api/webhooks/1429618355840745553/v1NtRD9s_jrxzrC2PL-CY4quSWaFI2wLvyLFTo7cWA5oxhqnnUSCX3fqHIliCdhMGecp`
**Status:** ✅ Already configured in `bug-report.html`
**Purpose:** Receives bug reports submitted through the website

### 2. Game Updates
**URL:** `https://discord.com/api/webhooks/1429274785833160847/XB9VeriDkuyf-5rumyNSf1--JIVLNvOvu0HtQwQLTyk9rOWu9k5XvkGjJ2N-uevvEdcp`
**Status:** ⏳ Needs implementation
**Purpose:** Automatic notifications when game updates are released

### 3. Website Logs
**URL:** `https://discord.com/api/webhooks/1429275472897773742/BI4E8fR6gFf8V3bIT_Zf2sbDC7dyzK5OV80Y3luarf16AMe2HgZbRHPVIprCOS4Vg9o-`
**Status:** ⏳ Needs implementation  
**Purpose:** Log website activity, errors, and important events

## Implementation Plan

### For Game Updates Webhook:
- Add to `admin-secure.html` so you can manually trigger update notifications
- Include in CI/CD pipeline for automatic notifications when deploying

### For Website Logs Webhook:
- Add to `admin-secure.html` for logging admin actions
- Track downloads, page views, errors

## Next Steps

1. Update `admin-secure.html` to include buttons for sending update notifications
2. Add website logging functionality
3. Set up automatic deployment notifications via GitHub Actions or Vercel

## Security Note

⚠️ **Important:** Keep these webhook URLs private! Anyone with these URLs can post to your Discord channels.
