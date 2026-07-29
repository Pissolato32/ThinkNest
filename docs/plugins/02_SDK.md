# ThinkNest Extension SDK Specification

**Version:** 1.0  
**Status:** Approved  
**Module:** Plugin Subsystem / SDK

---

## 1. SDK Interface Contract

Developers can create extensions using the ThinkNest TypeScript SDK:

```typescript
export interface ThinkNestPlugin {
  id: string;
  name: string;
  version: string;
  registerSpecialists?(): SpecialistDefinition[];
  registerExportTemplates?(): ExportTemplate[];
  onDNAMutated?(projectDna: ProjectDNA): void;
}
```
