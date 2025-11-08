# Routing App Coverage File for App Store Connect

## File Location
`routing_app_coverage.geojson`

## Countries Covered
- **Lithuania (LT)** - ISO 3166-1 alpha-2: LT
- **United States (US)** - ISO 3166-1 alpha-2: US

## How to Use

### Option 1: Upload via App Store Connect (Recommended)
1. Log in to App Store Connect
2. Go to your app → App Information
3. Scroll to "Routing App Coverage File"
4. Upload the `routing_app_coverage.geojson` file
5. Apple will validate the file and show available countries

### Option 2: Manual Country Selection (Simpler)
Instead of uploading the GeoJSON file, you can:
1. Go to App Store Connect → Your App → Pricing and Availability
2. Select "Specific Countries or Regions"
3. Check boxes for:
   - Lithuania
   - United States
4. Save changes

## Important Notes

⚠️ **The GeoJSON file provided is a simplified version.** For production use, you may want to:
- Use more precise country boundaries from official sources
- Download accurate GeoJSON data from sources like Natural Earth or OpenStreetMap
- Consider using Apple's App Store Connect interface instead (Option 2)

## File Format
The file uses GeoJSON format (RFC 7946) with:
- FeatureCollection type
- Polygon geometries for country boundaries
- ISO country codes in properties

## Validation
Before uploading, validate your GeoJSON at:
- https://geojson.io/
- https://geojsonlint.com/

## Alternative: Use App Store Connect API
If you're managing multiple apps, you can use App Store Connect API to programmatically set country availability.




