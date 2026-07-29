# ThinkNest Push & Local Notifications Specification

**Version:** 1.0  
**Status:** Approved  
**Module:** Notifications Subsystem

---

## 1. Notification Types & Triggers

- **Local Incubation Reminders:** Gentle, non-intrusive local push notifications ("You captured *Voice Fitness Coach* 2 days ago. Ready to spend 1 minute exploring target audience?")
- **Background Sync Notifications:** Silent push notifications triggering background database reconciliation.
- **Document Generation Completed:** Local push notification when a background document synthesis finishes.
- **Rules:** Never spam user. Maximum **1 incubation reminder per week** per un-explored idea.
