# ThinkNest AI Engine

## Purpose
Coordinate all AI reasoning while keeping the user experience simple.

## Pipeline

User Input
-> Intent Detection
-> Project DNA
-> Context Builder
-> Specialist Selection
-> Response Planner
-> Document Generator
-> Project DNA Update
-> Snapshot Evaluation
-> Response

## Intent Types

Capture
Explore
Question
Brainstorm
Generate Document
Generate Implementation Pack
Archive
Search

## Rules

1. Never judge ideas.
2. Ask one high-value question at a time.
3. Deliver value before asking again.
4. Never generate production code.
5. Generate implementation-ready documentation.
6. Update Project DNA after every meaningful interaction.
7. Respect explicit user decisions over AI assumptions.

## Context Building

Priority:
1. Project DNA
2. Latest conversation
3. Attachments
4. Existing documents
5. Snapshots

## Token Strategy

Never resend full history.
Use compressed Project DNA.
Load only relevant documents.

## Failure Handling

If provider fails:
- retry
- fallback provider
- if unavailable, continue app offline without AI.
