# Box.com Setup Guide

## Overview
Host your building map PDFs on Box for easy web access. Box is simpler than SharePoint and provides good performance.

## Step 1: Upload PDFs to Box

1. Log in to [Box.com](https://box.com)
2. Create a folder called "Building Maps" (or any name you prefer)
3. Upload your folder structure:
   ```
   Building Maps/
     Building 200/
       - 200 F-122.pdf
       - 200 F-130.pdf
     Building 203/
       - 203 G118.pdf
     ...
   ```

## Step 2: Get a Shared Link

### Option A: Simple Folder Share (Recommended)
1. Right-click on the "Building Maps" folder
2. Click **Share** → **Create Link**
3. Set link settings:
   - **People with the link** (no sign-in required)
   - **Can view and download**
4. Copy the link - it will look like:
   ```
   https://app.box.com/s/abc123xyz456def789
   ```
5. Extract the ID (everything after `/s/`):
   ```
   abc123xyz456def789
   ```

### Option B: Public Folder (Enterprise accounts)
1. Right-click folder → **More Options** → **Public Link**
2. Enable public sharing
3. Copy the link ID

## Step 3: Update Configuration

1. Open `lib/config/map_config.dart`
2. Change to Box hosting:
   ```dart
   static const MapHostingType hostingType = MapHostingType.box;
   ```

3. Paste your Box shared link ID:
   ```dart
   static const String boxSharedLinkId = 'abc123xyz456def789';
   ```

## Step 4: Test It

1. Run the web app: `flutter run -d chrome`
2. Click "Browse Maps"
3. Select a building and room
4. Click "Load Map"

The app will load the PDF directly from Box!

## How It Works

Box provides several ways to access files:

### Method 1: Box API (Current Implementation)
- Uses Box API with shared link authentication
- Requires the shared link ID in the request header
- Good for authenticated access

### Method 2: Direct Download Link
If Box API doesn't work, try the simpler approach:

In `home_screen.dart`, uncomment this line:
```dart
url = 'https://app.box.com/shared/static/$baseUrl/$encodedPath';
```

And comment out the API approach.

## Troubleshooting

### Error: 404 Not Found
**Problem**: File path doesn't match Box structure

**Solution**:
- Verify folder structure in Box matches your local "Current Maps" folder
- Check that file names are identical (including case)

### Error: 403 Forbidden
**Problem**: Box shared link doesn't allow downloads

**Solution**:
- Go back to Box → Share settings
- Ensure "Can view and download" is selected
- Try "People with the link" instead of "People in your company"

### Error: CORS blocked
**Problem**: Box blocking requests from your domain

**Solution**:
- Box usually allows CORS for shared links
- If blocked, you may need to use Box's embed feature instead

### Files load slowly
**Solution**:
- Box has good CDN, but large PDFs may take time
- Consider compressing your PDFs
- Or use Box's preview API for thumbnails first

## Advanced: Box App Authentication

For better performance and security with enterprise accounts:

1. Create a Box App in [Box Developer Console](https://app.box.com/developers/console)
2. Get an access token
3. Update the code to use OAuth authentication
4. This allows direct API access without shared links

Example:
```dart
headers = {
  'Authorization': 'Bearer YOUR_BOX_ACCESS_TOKEN',
};
```

## Alternative: Box Embed Widget

If direct download doesn't work, use Box's embed feature:

1. Get embed code from Box for each file
2. Create an iframe viewer in Flutter
3. Display PDFs in embedded viewer instead of downloading

## Comparison: Box vs SharePoint vs Local

| Feature | Box | SharePoint | Local Server |
|---------|-----|------------|--------------|
| Setup Difficulty | Easy | Medium | Easiest |
| Auth Required | Optional | Usually | No |
| CORS Issues | Rare | Common | None |
| Speed | Fast (CDN) | Medium | Fastest |
| Cost | Free tier OK | Enterprise | Free |
| Best For | Small teams | Enterprise | Development |

## Need Help?

- Check Box's [File Sharing Guide](https://support.box.com/hc/en-us/articles/360043697094-Sharing-Files-and-Folders)
- Review [Box API Documentation](https://developer.box.com/guides/)
- Contact Box support for enterprise features
