# ThinkNest Mobile CI/CD & Deployment Pipeline

**Version:** 1.0  
**Status:** Approved  
**DevOps:** Mobile App Build Pipeline

---

## 1. CI/CD Workflow

- **Build Automation:** Fastlane + GitHub Actions for iOS and Android releases.
- **TestFlight & Google Play Internal Testing:** Automatic deployment on merge to `main`.
- **Code Signing:** Fastlane Match with encrypted Git repository for iOS certificates and provisioning profiles.
- **Over-The-Air (OTA) Updates:** Expo Updates / React Native CodePush for instant bug fixes bypassing App Store review.
