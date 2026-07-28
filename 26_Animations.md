# Domain Model

User
 ├─ Projects
 │   ├─ Conversation
 │   ├─ Attachments
 │   ├─ Documents
 │   ├─ Snapshots
 │   ├─ Exports
 │   └─ ProjectDNA

Relationships

One User -> Many Projects
One Project -> One DNA
One Project -> Many Documents
One Project -> Many Snapshots
