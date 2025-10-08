# Bmore Rooted - Netlify Deployment Guide

## Pre-Deployment Checklist

### 1. Domain Purchase
- [ ] Purchase domain: **bmorerooted.com** (recommended registrar: Namecheap, Google Domains, or Cloudflare)
- [ ] Verify domain ownership
- [ ] Access to domain DNS settings

### 2. Netlify Account Setup
- [ ] Create account at [netlify.com](https://netlify.com)
- [ ] Connect GitHub account to Netlify
- [ ] Verify email address

### 3. Required API Keys & Services

#### Google Analytics (Optional but Recommended)
1. Go to [Google Analytics](https://analytics.google.com/)
2. Create a new property for bmorerooted.com
3. Get your Measurement ID (format: G-XXXXXXXXXX)
4. Update `index.html` line 28: Replace `GA_MEASUREMENT_ID` with your actual ID
5. Uncomment the Google Analytics script (lines 27-34)

#### Google Maps API (Optional)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project: "Bmore Rooted"
3. Enable Maps Embed API
4. Create API key
5. Restrict API key to your domain: `bmorerooted.com`
6. Update `index.html` line 375: Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual key

**OR use the simple embed (no API key required):**
- Comment out lines 370-377 in `index.html`
- Uncomment lines 380-389 for basic map embed

### 4. Update Contact Information
Before deployment, update these placeholder values:

**In `index.html`:**
- Line 51: Update phone number `+1-410-555-1234`
- Line 52: Update email `info@bmorerooted.com`
- Line 363: Update phone number display `(410) 555-1234`
- Line 364: Update email display

**In all service pages (`services/*.html`):**
- Update phone numbers in footer
- Update email addresses

**In all blog pages (`blog/*.html`):**
- Update contact information

**In `404.html`:**
- Update contact information

**In Schema.org markup (`index.html` lines 42-121):**
- Line 51: Update telephone
- Line 52: Update email
- Update business hours if different
- Update service area radius if needed

## Deployment Steps

### Step 1: Push to GitHub
All files are already committed. The repository is at:
`https://github.com/BmoreNichol/BmoreRooted`

### Step 2: Connect to Netlify

1. **Login to Netlify**
   - Go to [app.netlify.com](https://app.netlify.com)
   - Click "Add new site" → "Import an existing project"

2. **Connect GitHub Repository**
   - Select "GitHub"
   - Authenticate if needed
   - Choose repository: `BmoreNichol/BmoreRooted`

3. **Configure Build Settings**
   - **Build command:** Leave empty (static site)
   - **Publish directory:** `/` (root directory)
   - Click "Deploy site"

4. **Wait for Deployment**
   - Netlify will assign a random subdomain: `random-name-12345.netlify.app`
   - Wait 1-2 minutes for deployment to complete

### Step 3: Connect Custom Domain

1. **Add Custom Domain**
   - In Netlify dashboard, go to "Domain settings"
   - Click "Add custom domain"
   - Enter: `bmorerooted.com`
   - Netlify will verify ownership

2. **Configure DNS**

   **Option A: Use Netlify DNS (Recommended)**
   - Click "Set up Netlify DNS"
   - Netlify will provide nameservers (e.g., `dns1.p03.nsone.net`)
   - Go to your domain registrar
   - Update nameservers to Netlify's nameservers
   - Wait 24-48 hours for DNS propagation

   **Option B: Use External DNS**
   - In Netlify, note the DNS target (e.g., `apex-loadbalancer.netlify.com`)
   - In your domain registrar:
     - Add A record: `@` → `75.2.60.5`
     - Add CNAME: `www` → `[your-site].netlify.app`
   - Wait 24-48 hours for DNS propagation

3. **Enable HTTPS**
   - Netlify automatically provisions SSL certificate
   - Enable "Force HTTPS" in domain settings
   - Enable "HSTS" for security

### Step 4: Configure Netlify Forms

1. **Verify Form Setup**
   - Forms are already configured in `index.html`
   - Test form submission after deployment
   - Check Netlify dashboard → Forms for submissions

2. **Set Up Form Notifications**
   - In Netlify dashboard → Forms → Form notifications
   - Add email notification to: `info@bmorerooted.com`
   - Configure Slack webhook (optional)

### Step 5: Set Up Redirects & Headers
Files already configured:
- `netlify.toml` - Build settings, headers, redirects
- `_redirects` - URL redirects
- No additional configuration needed

### Step 6: Post-Deployment Configuration

1. **Test Website**
   - [ ] Homepage loads correctly
   - [ ] All 11 service pages accessible
   - [ ] Blog section works
   - [ ] Contact form submits successfully
   - [ ] 404 page displays for invalid URLs
   - [ ] Mobile responsive design works
   - [ ] Google Maps displays (if API key added)

2. **SEO Verification**
   - [ ] Submit sitemap to Google Search Console: `https://bmorerooted.com/sitemap.xml`
   - [ ] Submit sitemap to Bing Webmaster Tools
   - [ ] Verify robots.txt: `https://bmorerooted.com/robots.txt`
   - [ ] Test structured data with [Google Rich Results Test](https://search.google.com/test/rich-results)

3. **Performance Testing**
   - [ ] Run [Google PageSpeed Insights](https://pagespeed.web.dev/)
   - [ ] Test on [GTmetrix](https://gtmetrix.com/)
   - [ ] Check mobile performance

4. **Analytics Verification**
   - [ ] Verify Google Analytics tracking (if configured)
   - [ ] Test event tracking (button clicks, form submissions)
   - [ ] Check Netlify Analytics (optional paid feature)

## Environment Variables (Optional)

If you want to keep API keys secure:

1. In Netlify dashboard → Site settings → Environment variables
2. Add variables:
   - `GOOGLE_ANALYTICS_ID` = Your GA4 Measurement ID
   - `GOOGLE_MAPS_API_KEY` = Your Maps API key

3. Update HTML files to reference these variables (requires build process)

## Continuous Deployment

Every push to the `main` branch on GitHub will automatically trigger a new deployment on Netlify.

**To update the website:**
1. Make changes locally
2. Commit: `git add . && git commit -m "Your message"`
3. Push: `git push origin main`
4. Netlify will auto-deploy in 1-2 minutes

## Troubleshooting

### Form Not Working
- Check Netlify dashboard → Forms
- Verify `data-netlify="true"` attribute exists
- Check for spam filter blocking submissions

### 404 Page Not Showing
- Verify `netlify.toml` exists in root
- Check `404.html` exists
- Redeploy site

### Maps Not Loading
- Verify API key is correct
- Check API key restrictions
- Or use simple embed without API key

### Slow Performance
- Check image optimization
- Verify CSS/JS minification in `netlify.toml`
- Enable Netlify's "Asset Optimization" in dashboard

## Production Checklist

Before going live:
- [ ] Update all placeholder phone numbers
- [ ] Update all placeholder email addresses
- [ ] Add Google Analytics tracking ID
- [ ] Configure Google Maps API (or use simple embed)
- [ ] Test contact form submissions
- [ ] Set up email notifications for form submissions
- [ ] Add real business hours to Schema markup
- [ ] Replace placeholder trust badges with real certifications
- [ ] Add actual testimonials (if different)
- [ ] Update service area cities if needed
- [ ] Test all 11 service pages
- [ ] Test all 3 blog posts
- [ ] Verify 404 page works
- [ ] Test on mobile devices
- [ ] Submit to search engines
- [ ] Set up Google Business Profile
- [ ] Create social media profiles (Facebook, Twitter)

## Maintenance

### Regular Updates
- Update blog monthly with new content
- Add new testimonials as received
- Update service descriptions as needed
- Monitor form submissions and respond promptly
- Check analytics monthly for insights
- Update business hours for holidays

### Performance Monitoring
- Check PageSpeed Insights quarterly
- Monitor Netlify bandwidth usage
- Review form submissions for spam
- Update sitemap when adding new pages

## Support

- **Netlify Support:** [support.netlify.com](https://support.netlify.com)
- **Netlify Docs:** [docs.netlify.com](https://docs.netlify.com)
- **Community Forum:** [answers.netlify.com](https://answers.netlify.com)

## Costs

- **Netlify Hosting:** Free (includes 100GB bandwidth/month)
- **Domain:** ~$10-15/year
- **Google Maps API:** Free (up to $200/month credit)
- **Google Analytics:** Free
- **SSL Certificate:** Free (via Netlify)

**Total estimated annual cost:** $10-15/year

---

**Deployment Date:** TBD
**Last Updated:** 2025-10-08
**Website:** https://bmorerooted.com (pending deployment)
**Repository:** https://github.com/BmoreNichol/BmoreRooted
