/// Configuration for map hosting
class MapConfig {
  // Map hosting type - Change this to switch between hosting providers
  static const MapHostingType hostingType = MapHostingType.box;

  // Base URLs for different hosting types
  static const String localServerUrl = 'http://localhost:8000';
  static const String sharePointBaseUrl = 'https://yourcompany.sharepoint.com/sites/YourSite/Shared%20Documents/Building%20Maps';

  // Box Configuration
  // Get the shared link ID from your Box folder's share link
  // Share link looks like: https://app.box.com/s/abc123xyz456
  // Copy everything after /s/ and paste it below
  static const String boxSharedLinkId = 'qcp02picvfjjntune7l8tetbrqie8ee6';

  /// Get the appropriate base URL based on hosting type
  static String getBaseUrl() {
    switch (hostingType) {
      case MapHostingType.local:
        return localServerUrl;
      case MapHostingType.sharePoint:
        return sharePointBaseUrl;
      case MapHostingType.box:
        // Return the base Box shared download URL
        return 'https://app.box.com/shared/static/$boxSharedLinkId';
      case MapHostingType.custom:
        return customBaseUrl;
    }
  }

  /// Custom base URL (for other hosting solutions)
  static const String customBaseUrl = '';
}

enum MapHostingType {
  local,       // Local Python server
  sharePoint,  // Microsoft SharePoint
  box,         // Box.com
  custom,      // Custom URL
}
