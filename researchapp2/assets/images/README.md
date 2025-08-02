This folder contains Google logo assets for authentication screens.

To add the Google logo:
1. Download the official Google logo from: https://developers.google.com/identity/branding-guidelines
2. Save as 'google_logo.png' in this folder
3. Add to pubspec.yaml under assets:
   ```yaml
   assets:
     - assets/images/google_logo.png
   ```

For now, the app will use a fallback icon if the logo is not found.
