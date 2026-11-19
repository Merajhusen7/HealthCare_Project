# Healthcare ER Diagram - Visual Guide

## Recommended view

Open [ER_DIAGRAM_CORE.mmd](./ER_DIAGRAM_CORE.mmd) in VS Code. Press `Ctrl+Shift+V` to use the Markdown preview if the file is embedded in a Markdown document, or install a Mermaid preview extension.

The core diagram is intentionally smaller than the complete logical model. It shows the entities and relationships that are essential to patient booking and test/checkup requests.

## Viewing in GitHub or VS Code

GitHub and Mermaid-enabled VS Code Markdown preview render Mermaid code fences.

### Mermaid rendering

Copy the contents of `ER_DIAGRAM_CORE.mmd` inside a Mermaid fence:

````markdown
```mermaid
[paste the contents of ER_DIAGRAM_CORE.mmd here]
```
````

## Patient booking flow

```text
PATIENT
   |
   +-- may authenticate through PATIENT_ACCOUNT
   |
   +-- submits SERVICE_REQUEST
   |      |
   |      +-- requests a HEALTH_SERVICE
   |      +-- may be assigned to a DOCTOR
   |      +-- may produce REQUEST_RESULT and RESULT_DOCUMENT
   |
   +-- books APPOINTMENT
          |
          +-- is assigned to a DOCTOR
          +-- takes place at a FACILITY
          +-- contains one or more HEALTH_SERVICE values
          +-- may fulfill a SERVICE_REQUEST
```

## Diagram perspectives

### 1. Patient perspective

Focus on `PATIENT`, `PATIENT_ACCOUNT`, `APPOINTMENT`, `SERVICE_REQUEST`, `HEALTH_SERVICE`, and `REQUEST_RESULT`.

### 2. Doctor and scheduling perspective

Focus on `DOCTOR`, `SPECIALTY`, `DOCTOR_SPECIALTY`, `DOCTOR_SERVICE`, `DOCTOR_AVAILABILITY`, `FACILITY`, and `APPOINTMENT`.

### 3. Test and checkup perspective

Focus on `SERVICE_CATEGORY`, `HEALTH_SERVICE`, `DOCTOR_SERVICE`, `SERVICE_REQUEST`, `REQUEST_RESULT`, and `RESULT_DOCUMENT`.

### 4. Audit perspective

Track changes using `APPOINTMENT_STATUS_HISTORY` and `SERVICE_REQUEST_STATUS_HISTORY`. Do not overwrite the original status.
