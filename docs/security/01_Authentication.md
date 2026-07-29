# ThinkNest Mobile Authentication Specification

**Version:** 1.1  
**Status:** Approved  
**Module:** Security / Identity Management

---

## 1. Authentication Architecture (Supabase Auth)

- **Guest Local Mode:** Zero login required to capture ideas. Local Drift database created instantly on device.
- **Supabase Auth Integration:** Google Sign-In, Email Magic Link, and Apple Sign-In (mandatory for iOS V2).
- **Biometric App Lock:** Optional local authentication lock utilizing `local_auth` Flutter package (Fingerprint / Face ID API) prior to displaying project content.
