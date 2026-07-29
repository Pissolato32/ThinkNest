# ThinkNest Documentation Hub

**Version:** 6.1
**Status:** Living documentation
**Audience:** product, design, engineering, security, QA, operations, and AI governance teams
**Last reviewed:** 2026-07-29

ThinkNest is documented as an AI-assisted product-incubation platform. This hub is the canonical entry point for understanding the product vision, architectural constitution, feature behavior, operational expectations, and implementation contracts.

## Documentation quality level: AAA

This documentation set is maintained against the ThinkNest **AAA documentation bar**:

- **Accurate:** every major product claim is anchored to a named specification, ADR, or acceptance criterion.
- **Actionable:** each domain links to the decisions, implementation contracts, testing expectations, and operational safeguards required to build or review the feature.
- **Accessible:** documents use descriptive headings, plain-language summaries, stable relative links, scannable tables, and explicit ownership metadata.

## Start here by role

| Role | Recommended path | Outcome |
| --- | --- | --- |
| Founder / product lead | [Executive Summary](vision/01_Executive_Summary.md) → [Product Roadmap](business/02_Product_Roadmap.md) → [Premium Model](business/01_Premium_Model.md) | Understand strategy, scope, and monetization. |
| Designer | [UX Principles](ux/11_UX_Principles.md) → [Screen Map](ux/16_Screen_Map.md) → [Design System](design/25_Design_System.md) → [Accessibility](design/27_Accessibility.md) | Design consistent, accessible screens and flows. |
| Mobile / frontend engineer | [System Architecture](architecture/01_System_Architecture.md) → [State Machines](architecture/02_State_Machines.md) → [Component Library](design/24_Component_Library.md) → [UX specifications](#ux-specifications) | Implement UI and state behavior safely. |
| Backend engineer | [Backend Architecture](backend/01_Backend_Architecture.md) → [API Guidelines](backend/02_API_Guidelines.md) → [Database Schema](database/02_Database_Schema.md) | Implement services, persistence, and API contracts. |
| AI engineer | [AI Engine](ai/01_AI_Engine.md) → [Provider Abstraction](ai/04_Provider_Abstraction.md) → [AI Specialists](vision/08_AI_Specialists.md) | Build provider-neutral, governed AI capabilities. |
| Security / privacy reviewer | [ADRs](architecture/00_ADRS.md) → [Security](security/02_Security.md) → [Authentication](security/01_Authentication.md) → [Analytics](analytics/01_Analytics.md) | Verify authority boundaries and data-protection controls. |
| QA / release manager | [Test Strategy](testing/01_Test_Strategy.md) → [Acceptance Criteria](testing/02_Acceptance_Criteria.md) → [Deployment](deployment/01_Deployment.md) → [Non-Functional Requirements](deployment/02_Non_Functional_Requirements.md) | Validate readiness for release and operation. |

## Canonical documentation map

### Vision and product constitution

| Document | Purpose |
| --- | --- |
| [ThinkNest](vision/01_Executive_Summary.md) | Executive narrative, goals, and scope. |
| [ThinkNest](vision/02_Product_Philosophy_and_AI_Behavior.md) | Product philosophy and governed AI behavior. |
| [ThinkNest Product Flow](vision/03_Product_Flow.md) | Product Flow. |
| [ThinkNest Information Architecture](vision/04_Information_Architecture.md) | Information Architecture. |
| [ThinkNest User Journey Map](vision/05_User_Journey.md) | User Journey Map. |
| [ThinkNest Project DNA Specification](vision/06_Project_DNA.md) | Project DNA. |
| [ThinkNest Project Maturity Framework](vision/07_Project_Maturity.md) | Project Maturity Framework. |
| [ThinkNest AI Specialists Architecture](vision/08_AI_Specialists.md) | AI Specialists Architecture. |
| [ThinkNest Implementation Pack Specification](vision/09_Implementation_Pack.md) | Implementation Pack. |
| [ThinkNest Product Constitution](vision/10_ThinkNest_Constitution.md) | Product Constitution. |

### Architecture and ADRs

| Document | Purpose |
| --- | --- |
| [ThinkNest Architecture Decision Records (ADRs 0001 - 0028)](architecture/00_ADRS.md) | Architecture Decision Records (ADRs 0001 - 0028). |
| [ThinkNest System Architecture Specification](architecture/01_System_Architecture.md) | System Architecture. |
| [ThinkNest State Machines (ADR-0019 & ADR-0020)](architecture/02_State_Machines.md) | State Machines. |
| [ThinkNest Internal Event System (ADR-0018)](architecture/03_Event_System.md) | Internal Event System (ADR-0018). |

### Product engines

| Document | Purpose |
| --- | --- |
| [ThinkNest Conversation Engine Specification](product/12_Conversation_Engine.md) | Conversation Engine. |
| [ThinkNest Project DNA Engine Specification](product/13_Project_DNA_Engine.md) | Project DNA Engine. |
| [ThinkNest AI Orchestrator Specification](product/14_AI_Orchestrator.md) | AI Orchestrator. |
| [ThinkNest Specialist System Specification](product/15_Specialist_System.md) | Specialist System. |

### AI subsystem

| Document | Purpose |
| --- | --- |
| [ThinkNest AI Engine Core Specification](ai/01_AI_Engine.md) | AI Engine Core. |
| [ThinkNest Grill-me Engine Specification](ai/02_GrillMe_Engine.md) | Grill-me Engine. |
| [ThinkNest Document Generator Specification](ai/03_Document_Generator.md) | Document Generator. |
| [ThinkNest AI Provider Abstraction Layer (ADR-0016 & ADR-0024)](ai/04_Provider_Abstraction.md) | AI Provider Abstraction Layer (ADR-0016 & ADR-0024). |
| [ThinkNest Implementation Ready Engine Specification](ai/05_Implementation_Ready.md) | Implementation Ready Engine. |

### Backend and API

| Document | Purpose |
| --- | --- |
| [ThinkNest Backend Architecture Specification](backend/01_Backend_Architecture.md) | Backend Architecture. |
| [ThinkNest API Guidelines & Supabase Contracts](backend/02_API_Guidelines.md) | API Guidelines & Supabase Contracts. |

### Data model and synchronization

| Document | Purpose |
| --- | --- |
| [ThinkNest Domain-Driven Model Specification (ADR-0017)](database/01_Domain_Model.md) | Domain-Driven Model (ADR-0017). |
| [ThinkNest Database Schema (Local Drift & Supabase PostgreSQL)](database/02_Database_Schema.md) | Database Schema (Local Drift & Supabase PostgreSQL). |
| [ThinkNest Offline Synchronization Specification](database/03_Offline_Synchronization.md) | Offline Synchronization. |

### Security and identity

| Document | Purpose |
| --- | --- |
| [ThinkNest Mobile Authentication Specification](security/01_Authentication.md) | Mobile Authentication. |
| [ThinkNest Security by Design Specification (ADR-0026)](security/02_Security.md) | Security by Design (ADR-0026). |

### Integrations

| Document | Purpose |
| --- | --- |
| [ThinkNest AI Provider & Speech Integrations](integrations/01_AI_Providers.md) | AI Provider & Speech Integrations. |
| [ThinkNest External Tool & Export Integrations](integrations/02_External_Integrations.md) | External Tool & Export Integrations. |

### Plugin platform

| Document | Purpose |
| --- | --- |
| [ThinkNest Extensible Plugin Architecture (ADR-0025)](plugins/01_Plugin_Architecture.md) | Extensible Plugin Architecture (ADR-0025). |
| [ThinkNest Extension SDK Specification](plugins/02_SDK.md) | Extension SDK. |

### Export and handoff

| Document | Purpose |
| --- | --- |
| [ThinkNest Implementation Pack Export Engine (ADR #9)](export/01_Export_Engine.md) | Implementation Pack Export Engine (ADR #9). |
| [ThinkNest Implementation Pack Directory Structure](export/02_Implementation_Pack_Structure.md) | Implementation Pack Directory Structure. |

### Notifications

| Document | Purpose |
| --- | --- |
| [ThinkNest Push & Local Notifications Specification](notifications/01_Notifications.md) | Push & Local Notifications. |

### Analytics and privacy

| Document | Purpose |
| --- | --- |
| [ThinkNest Mobile Analytics & Privacy Specification](analytics/01_Analytics.md) | Mobile Analytics & Privacy. |

### UX specifications

| Document | Purpose |
| --- | --- |
| [ThinkNest UX Design Principles (ADR-0027 & ADR-0028)](ux/11_UX_Principles.md) | UX Design Principles (ADR-0027 & ADR-0028). |
| [ThinkNest Mobile Screen Map](ux/16_Screen_Map.md) | Mobile Screen Map. |
| [ThinkNest Home Screen Specification (`SCR_001_HOME`)](ux/17_Home_Screen.md) | Home Screen (`SCR_001_HOME`). |
| [ThinkNest Project Workspace Screen Specification (`SCR_002_PROJECT_MAIN`)](ux/18_Project_Screen.md) | Project Workspace Screen (`SCR_002_PROJECT_MAIN`). |
| [ThinkNest Conversation Screen Specification (`SCR_003_CONVERSATION`)](ux/19_Conversation_Screen.md) | Conversation Screen (`SCR_003_CONVERSATION`). |
| [ThinkNest Documents Screen Specification (`SCR_004_DOC_VIEWER`)](ux/20_Documents_Screen.md) | Documents Screen (`SCR_004_DOC_VIEWER`). |
| [ThinkNest Search Screen Specification (`SCR_005_SEARCH`)](ux/21_Search_Screen.md) | Search Screen (`SCR_005_SEARCH`). |
| [ThinkNest Settings Screen Specification (`SCR_006_SETTINGS`)](ux/22_Settings_Screen.md) | Settings Screen (`SCR_006_SETTINGS`). |
| [ThinkNest Premium Screen Specification (`SCR_007_PREMIUM`)](ux/23_Premium_Screen.md) | Premium Screen (`SCR_007_PREMIUM`). |

### Wireframes

| Document | Purpose |
| --- | --- |
| [ThinkNest Home Screen Wireframe (`SCR_001_HOME`)](wireframes/01_home.md) | Home Screen Wireframe (`SCR_001_HOME`). |
| [ThinkNest Project Screen Wireframe (`SCR_002_PROJECT_MAIN`)](wireframes/02_project.md) | Project Screen Wireframe (`SCR_002_PROJECT_MAIN`). |
| [ThinkNest Implementation Pack Export Modal Wireframe](wireframes/03_export.md) | Implementation Pack Export Modal Wireframe. |

### Design system

| Document | Purpose |
| --- | --- |
| [ThinkNest Mobile Component Library Specification](design/24_Component_Library.md) | Mobile Component Library. |
| [ThinkNest Design System Tokens](design/25_Design_System.md) | Design System Tokens. |
| [ThinkNest Animation & Micro-Interactions Specification](design/26_Animations.md) | Animation & Micro-Interactions. |
| [ThinkNest Mobile Accessibility (a11y) Guidelines](design/27_Accessibility.md) | Mobile Accessibility (a11y) Guidelines. |

### Testing and acceptance

| Document | Purpose |
| --- | --- |
| [ThinkNest Test Strategy Specification](testing/01_Test_Strategy.md) | Test Strategy. |
| [ThinkNest Feature Acceptance Criteria](testing/02_Acceptance_Criteria.md) | Feature Acceptance Criteria. |

### Deployment and operations

| Document | Purpose |
| --- | --- |
| [ThinkNest Mobile CI/CD & Deployment Pipeline](deployment/01_Deployment.md) | Mobile CI/CD & Deployment Pipeline. |
| [ThinkNest Non-Functional Requirements (NFR)](deployment/02_Non_Functional_Requirements.md) | Non-Functional Requirements (NFR). |

### Business model and roadmap

| Document | Purpose |
| --- | --- |
| [ThinkNest Monetization & Premium Model Specification](business/01_Premium_Model.md) | Monetization & Premium Model. |
| [ThinkNest Product Roadmap (v1.0 -> v2.0)](business/02_Product_Roadmap.md) | Product Roadmap (v1.0 -> v2.0). |

## Operating model

### Source-of-truth hierarchy

1. **Architecture constitution:** ADRs define non-negotiable architectural decisions.
2. **Domain specifications:** product, AI, backend, database, security, and design documents translate ADRs into implementation rules.
3. **Screen and workflow specifications:** UX and wireframe documents define user-facing behavior.
4. **Testing and deployment documents:** acceptance, release, and non-functional requirements define readiness gates.

When two documents appear to conflict, follow the most authoritative document in the hierarchy above and update the lower-level document in the same change.

### Definition of ready for implementation

A feature is ready for implementation only when it has:

- a documented user outcome and owner;
- relevant ADR or explicit architectural rationale;
- state transitions, API contracts, or data model expectations;
- privacy, security, accessibility, and analytics considerations;
- acceptance criteria and release checks.

### Definition of done for documentation changes

Documentation changes are complete when they:

- preserve relative Markdown links;
- add or update glossary terms for project-specific language;
- update acceptance criteria if behavior changes;
- identify migration or compatibility impacts;
- include the review date and status when introducing a new normative document.

## Cross-cutting quality gates

| Gate | Required evidence | Primary docs |
| --- | --- | --- |
| Human authority | AI suggestions remain advisory unless the user confirms the action. | [Product Philosophy and AI Behavior](vision/02_Product_Philosophy_and_AI_Behavior.md), [ADRs](architecture/00_ADRS.md) |
| Offline resilience | User work remains available and synchronizable across connectivity changes. | [Offline Synchronization](database/03_Offline_Synchronization.md), [State Machines](architecture/02_State_Machines.md) |
| Security and privacy | Authentication, storage, analytics, and provider integrations minimize data exposure. | [Security](security/02_Security.md), [Authentication](security/01_Authentication.md), [Analytics](analytics/01_Analytics.md) |
| Accessibility | UI patterns are perceivable, operable, understandable, and robust. | [Accessibility](design/27_Accessibility.md), [Design System](design/25_Design_System.md) |
| Release readiness | Features satisfy acceptance criteria, non-functional targets, and deployment checks. | [Acceptance Criteria](testing/02_Acceptance_Criteria.md), [Non-Functional Requirements](deployment/02_Non_Functional_Requirements.md) |

## Maintainer workflow

1. Start from this hub and locate the authoritative domain document.
2. Check ADR impact before changing architecture, storage, AI authority, security, or synchronization behavior.
3. Update affected downstream docs in the same pull request.
4. Run a Markdown link check or equivalent repository search before review.
5. Use the documentation standard for metadata, tone, link style, and review readiness.

## Companion references

- [Documentation Standard](DOCUMENTATION_STANDARD.md) defines the AAA bar, authoring checklist, and review rubric.
- [Glossary](GLOSSARY.md) provides shared language for product, AI, security, and architecture terms.
