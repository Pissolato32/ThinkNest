# ThinkNest Feature Acceptance Criteria

**Version:** 1.0  
**Status:** Approved  
**QA Standards:** User Story Acceptance Criteria

---

## 1. Core Feature Criteria

### Quick Capture (`US_001`)
- **Given** the app is closed, **When** the user opens ThinkNest, **Then** the Quick Capture input is ready for text/voice entry in under 800ms.
- **Given** an input is submitted, **When** the user taps Send, **Then** a new Project Card is rendered in under 100ms and background AI title/category generation begins.

### Test Data Fixtures (JSON)
```json
{
  "project_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "version": 1,
  "last_updated": "2023-10-24T10:00:00Z",
  "identity": {
    "title": "New Idea",
    "one_liner": "A quick thought captured on the go",
    "category": "Uncategorized",
    "maturity": "Raw"
  },
  "core_pillars": {
    "problem_statement": "",
    "target_audience": [],
    "value_proposition": ""
  },
  "technical_constraints": {
    "target_platforms": [],
    "preferred_stack": [],
    "offline_first": false
  },
  "key_decisions": [],
  "open_uncertainties": [],
  "specialist_state": {
    "active_specialist": null,
    "consulted_specialists": []
  }
}
```

### Grill-me Exploration (`US_002`)
- **Given** a user opens a project in `Captured` status, **When** they tap Explore, **Then** the AI asks exactly ONE targeted clarification question.
- **Given** 3 exploration turns are completed, **When** sufficient structure exists, **Then** an action card offering document generation appears automatically.

### Test Data Fixtures (JSON)
```json
{
  "project_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "version": 4,
  "last_updated": "2023-10-24T10:15:00Z",
  "identity": {
    "title": "Automated Plant Watering",
    "one_liner": "Smart IoT system to water indoor plants automatically.",
    "category": "Home Automation",
    "maturity": "Structured"
  },
  "core_pillars": {
    "problem_statement": "People forget to water their indoor plants, leading to dead plants.",
    "target_audience": ["Busy professionals", "Frequent travelers", "Plant enthusiasts"],
    "value_proposition": "Never worry about watering your plants again, even when on vacation."
  },
  "technical_constraints": {
    "target_platforms": ["Android", "iOS"],
    "preferred_stack": ["Flutter", "Arduino", "Firebase"],
    "offline_first": true
  },
  "key_decisions": [
    {
      "id": "dec_001",
      "topic": "Connectivity",
      "decision": "Use Wi-Fi instead of Bluetooth for remote monitoring.",
      "rationale": "Allows users to check plant status while away from home."
    }
  ],
  "open_uncertainties": [
    "Ideal battery life and power source for the moisture sensor."
  ],
  "specialist_state": {
    "active_specialist": "IoT Architect",
    "consulted_specialists": ["Product Manager"]
  }
}
```

### Implementation Pack Export (`US_003`)
- **Given** a project reaches `Implementation Ready`, **When** the user taps Export, **Then** a complete zip archive containing `.cursorrules`, `PROJECT_DNA.json`, and Markdown documents is handed off to the native share sheet.

### Test Data Fixtures (JSON)
```json
{
  "project_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "version": 10,
  "last_updated": "2023-10-24T11:30:00Z",
  "identity": {
    "title": "Automated Plant Watering",
    "one_liner": "Smart IoT system to water indoor plants automatically.",
    "category": "Home Automation",
    "maturity": "Implementation Ready"
  },
  "core_pillars": {
    "problem_statement": "People forget to water their indoor plants, leading to dead plants.",
    "target_audience": ["Busy professionals", "Frequent travelers", "Plant enthusiasts"],
    "value_proposition": "Never worry about watering your plants again, even when on vacation."
  },
  "technical_constraints": {
    "target_platforms": ["Android", "iOS"],
    "preferred_stack": ["Flutter", "Arduino", "Firebase"],
    "offline_first": true
  },
  "key_decisions": [
    {
      "id": "dec_001",
      "topic": "Connectivity",
      "decision": "Use Wi-Fi instead of Bluetooth for remote monitoring.",
      "rationale": "Allows users to check plant status while away from home."
    },
    {
      "id": "dec_002",
      "topic": "Power Source",
      "decision": "Rechargeable Li-ion battery with optional solar panel.",
      "rationale": "Provides flexibility and sustainability."
    }
  ],
  "open_uncertainties": [],
  "specialist_state": {
    "active_specialist": null,
    "consulted_specialists": ["Product Manager", "IoT Architect", "Hardware Engineer", "Software Engineer"]
  }
}
```
