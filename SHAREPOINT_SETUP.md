# SharePoint Setup Guide

## Overview
This guide explains how to host building map PDFs on SharePoint for web access.

## Step 1: Upload PDFs to SharePoint

1. Go to your SharePoint site
2. Navigate to Documents (or create a new Document Library)
3. Create a folder structure like:
   ```
   Building Maps/
     Building 200/
       - 200 F-122.pdf
       - 200 F-130.pdf
     Building 203/
       - 203 G118.pdf
     ...
   ```

## Step 2: Configure Sharing Permissions

1. Right-click on the "Building Maps" folder
2. Click **Share** → **People with existing access**
3. Click **⚙️** (Settings) → **Advanced**
4. Set permissions to allow:
   - Anyone in your organization can view
   - OR create a shareable link for wider access

## Step 3: Get the SharePoint Base URL

### Option A: Direct File URL
1. Navigate to your "Building Maps" folder in SharePoint
2. Copy the URL from the browser (it will look like):
   ```
   https://yourcompany.sharepoint.com/sites/YourSite/Shared%20Documents/Building%20Maps
   ```

### Option B: Using Graph API (Advanced)
If you need programmatic access, you can use Microsoft Graph API with authentication.

## Step 4: Update Map Configuration

1. Open `lib/config/map_config.dart`
2. Change the hosting type:
   ```dart
   static const MapHostingType hostingType = MapHostingType.sharePoint;
   ```

3. Update the SharePoint base URL:
   ```dart
   static const String sharePointBaseUrl =
     'https://yourcompany.sharepoint.com/sites/YourSite/Shared%20Documents/Building%20Maps';
   ```

## Step 5: Handle Authentication (If Required)

If your SharePoint requires authentication, you'll need to add authentication headers:

```dart
final response = await http.get(
  Uri.parse(url),
  headers: {
    'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
  },
);
```

### Getting Access Token:
1. Register an app in Azure AD
2. Grant permissions: `Sites.Read.All` or `Files.Read.All`
3. Get access token using MSAL or similar library

## Step 6: CORS Considerations

SharePoint may block CORS requests from web apps. Solutions:

### Solution 1: SharePoint CORS Settings
- Contact your SharePoint admin to enable CORS for your domain

### Solution 2: Proxy Server
- Create a backend proxy that fetches PDFs from SharePoint
- Your Flutter app calls your proxy instead of SharePoint directly

### Solution 3: SharePoint Embedded Links
- Use SharePoint's embed functionality
- Generate embed codes for PDFs

## Alternative: Public CDN

For simpler access without authentication:

1. Export PDFs from SharePoint
2. Host them on a public CDN (Azure Blob Storage, AWS S3, etc.)
3. Update `customBaseUrl` in `map_config.dart`

## Testing

1. Update `map_config.dart` with your settings
2. Run the web app: `flutter run -d chrome`
3. Click "Browse Maps" and try loading a PDF
4. Check browser console for any CORS or authentication errors

## Troubleshooting

### Error: CORS policy blocked
- **Solution**: Enable CORS in SharePoint or use a proxy server

### Error: 401 Unauthorized
- **Solution**: Add authentication headers with valid access token

### Error: 404 Not Found
- **Solution**: Check that the `sharePointBaseUrl` is correct and the folder structure matches

### Error: PDF won't load
- **Solution**: Verify the sharing permissions allow anonymous/authenticated access

## Example Configuration

```dart
// For public SharePoint (no auth required)
static const MapHostingType hostingType = MapHostingType.sharePoint;
static const String sharePointBaseUrl =
  'https://yourcompany.sharepoint.com/:b:/s/BuildingMaps/public';

// For authenticated SharePoint
// You'll need to implement token management
```

## Need Help?

Contact your IT department or SharePoint administrator for:
- Permissions setup
- CORS configuration
- App registration in Azure AD
