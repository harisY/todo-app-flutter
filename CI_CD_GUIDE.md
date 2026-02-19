# ===========================================
# CI/CD Setup Guide for Todo App
# ===========================================

## 📋 Table of Contents
1. [GitHub Actions CI/CD](#github-actions-cicd)
2. [Setup Instructions](#setup-instructions)
3. [Available Workflows](#available-workflows)
4. [Required Secrets](#required-secrets)

---

## 🚀 GitHub Actions CI/CD

### Files Created:
```
.github/workflows/
├── flutter_ci.yml          # CI: Build & Test on push/PR
├── flutter_release.yml     # CD: Create GitHub Release
└── play_store_deploy.yml   # CD: Deploy to Play Store
```

---

## 📝 Setup Instructions

### 1. **Enable GitHub Actions**
- Go to your GitHub repository
- Click "Actions" tab
- Enable Actions if not already enabled

### 2. **Configure Secrets** (for Play Store deployment)

Navigate to: `Settings > Secrets and variables > Actions`

Add the following secrets:

#### For Google Play Store Deployment:

| Secret Name | Description |
|------------|-------------|
| `KEYSTORE_BASE64` | Base64 encoded keystore file |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias name |
| `KEY_PASSWORD` | Key password |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play Service Account JSON |

### 3. **Get Google Play Service Account**

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to **Setup > API access**
4. Create a new service account
5. Grant permissions (at least: "Production" track access)
6. Download the JSON key file
7. Copy the entire JSON content to `PLAY_STORE_SERVICE_ACCOUNT_JSON` secret

### 4. **Create Keystore for Signing**

```bash
# Generate keystore (run once)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Encode to base64 (for GitHub secret)
# On Linux/Mac:
base64 upload-keystore.jks

# On Windows (PowerShell):
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))
```

Copy the output to `KEYSTORE_BASE64` secret.

---

## ⚙️ Available Workflows

### 1. **Flutter CI** (`flutter_ci.yml`)
**Triggers:** Push to `main`/`develop`, Pull Requests

**Jobs:**
- ✅ Format check
- ✅ Static analysis (`flutter analyze`)
- ✅ Run tests (`flutter test`)
- ✅ Build debug APK
- ✅ Build release APK
- 📦 Upload APKs as artifacts

### 2. **Flutter Release** (`flutter_release.yml`)
**Triggers:** Push tags (e.g., `v1.0.0`)

**Jobs:**
- ✅ Build release APK
- ✅ Build App Bundle (AAB)
- 🚀 Create GitHub Release
- 📎 Upload APK & AAB to release

### 3. **Play Store Deploy** (`play_store_deploy.yml`)
**Triggers:** Push tags (e.g., `v1.0.0`)

**Jobs:**
- ✅ Decode keystore
- ✅ Build signed App Bundle
- 🚀 Deploy to Google Play Internal Testing

---

## 🎯 Usage Examples

### Trigger CI (on every push):
```bash
git add .
git commit -m "feat: add new feature"
git push origin develop
```

### Create Release (manual):
```bash
# Update version in pubspec.yaml
git commit -m "chore: bump version to 1.1.0"
git tag v1.1.0
git push origin v1.1.0
```

### Automated Release with changelog:
```bash
# Use tools like:
# - semantic-release
# - conventional-changelog
# - auto-changelog
```

---

## 🔧 Customization

### Change Flutter Version
Edit workflow files, update:
```yaml
with:
  flutter-version: '3.x'  # Change to specific version
  channel: 'stable'       # or 'beta', 'dev', 'master'
```

### Add More Tests
```yaml
- name: Run integration tests
  working-directory: todo_app
  run: flutter test integration_test
```

### Deploy to Different Tracks
In `play_store_deploy.yml`, change:
```yaml
track: internal      # Options: internal, alpha, beta, production
status: completed    # Options: draft, inProgress, halted, completed
```

---

## 📊 Monitoring Builds

1. Go to **Actions** tab in GitHub
2. Click on workflow run
3. View logs for each job
4. Download artifacts from successful builds

---

## 🔐 Security Best Practices

- ✅ Never commit keystore files
- ✅ Use GitHub Secrets for sensitive data
- ✅ Limit service account permissions
- ✅ Rotate credentials periodically
- ✅ Use environment protection rules for production

---

## 🐛 Troubleshooting

### Build fails with "SDK location not found"
Add `local.properties` to `android/`:
```properties
sdk.dir=/usr/local/Caches/android-sdk
```

### Keystore decoding fails
Ensure base64 string has no line breaks:
```bash
# Remove newlines
echo "BASE64_STRING" | tr -d '\n'
```

### Play Store upload fails
- Check service account has correct permissions
- Verify package name matches
- Ensure AAB is properly signed

---

## 📚 Additional Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter GitHub Actions](https://github.com/marketplace/actions/flutter-action)
- [Google Play Developer API](https://developers.google.com/android-publisher)
- [Fastlane for Flutter](https://docs.fastlane.tools/)

---

**Last Updated:** February 2026
