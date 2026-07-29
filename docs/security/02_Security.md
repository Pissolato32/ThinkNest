# ThinkNest Security by Design Specification (ADR-0026)

**Version:** 2.0  
**Status:** Approved  
**Normative ADR:** ADR-0026 (Security by Design)

---

## 1. Core Security Foundations

In accordance with **ADR-0026**, security is an integrated architectural principle:

1. **Zero Trust Architecture:** Every module, IPC bridge, and API call validates credentials and permissions explicitly.
2. **Offline Data Encryption:** SQLite local database encrypted at-rest using **SQLCipher (AES-256)**.
3. **Hardware Key Vault:** API keys and encryption master keys stored exclusively in hardware-backed storage (iOS Keychain / Android Keystore).
4. **Key Rotation:** Automated encryption key rotation schedules for offline database and cloud tokens.
5. **Least Privilege Access Control:** Row-Level Security (RLS) policies on Supabase enforce strict user boundary isolation.
6. **Immutable Audit Logging:** Every Project DNA mutation, document deletion, and snapshot creation writes an immutable log entry.
