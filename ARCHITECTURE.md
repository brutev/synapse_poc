# Loan Origination POC - End-to-End Architecture

## Overview
This is a **Loan Origination System** with a Flutter mobile frontend and FastAPI Python backend. It implements a dynamic form-based application workflow with rule-based evaluation and multi-phase processing.

---

## 🏗️ Architecture Layers

### Frontend (Flutter/Dart) - User Interface & State Management
```
┌─────────────────────────┐
│   Presentation Layer    │
│   (Pages & Widgets)     │
└────────────┬────────────┘
             │
┌─────────────▼────────────┐
│  State Management Layer  │
│   (BLoC/Cubit)          │
└────────────┬────────────┘
             │
┌─────────────▼────────────┐
│    Domain Layer         │
│  (Use Cases & Entities) │
└────────────┬────────────┘
             │
┌─────────────▼────────────┐
│    Data Layer           │
│ (Repositories & Data    │
│  Sources)               │
└────────────┬────────────┘
             │
┌─────────────▼────────────┐
│   Core/Infrastructure   │
│   (API Client, Config)  │
└─────────────────────────┘
```

### Backend (FastAPI/Python) - Business Logic & Database
```
┌──────────────────┐
│  API Routers     │
│  (Orchestration) │
└────────┬─────────┘
         │
┌────────▼──────────┐
│  Services Layer   │
│  (Business Logic) │
└────────┬──────────┘
         │
┌────────▼──────────┐
│ Models & Schemas  │
│  (Data Transfer)  │
└────────┬──────────┘
         │
┌────────▼──────────┐
│ Repositories      │
│ (Database Access) │
└────────┬──────────┘
         │
┌────────▼──────────┐
│ SQLAlchemy ORM    │
│ (PostgreSQL)      │
└───────────────────┘
```

---

## 📱 Frontend Architecture (Flutter)

### 1. **Presentation Layer** (`lib/features/application/presentation/`)
**Purpose**: Renders UI and handles user interactions

**Components**:
- **ApplicationPage**: Main screen showing:
  - "Create Application" button (initial state)
  - Dynamic form sections with fields
  - Action buttons (Submit, Save Draft, Evaluate)
  - Application metadata (ID, Rule Version, Phase)

- **Widgets**:
  - `DynamicSectionWidget`: Renders form sections dynamically
  - `ActionButtonWidget`: Renders action buttons
  - `AppButton`, `AppTextField`, `AppDropdown`: Reusable UI components
  - `LoadingOverlay`: Loading state indicator

### 2. **State Management** (`lib/features/application/presentation/cubit/`)
**Framework**: Flutter BLoC (Cubit)

**ApplicationState**:
```dart
enum ApplicationStatus { initial, loading, success, error }

class ApplicationState {
  final ApplicationStatus status;
  final String? applicationId;
  final String? ruleVersion;
  final EvaluateResponseEntity? evaluate;
  final Map<String, Map<String, dynamic>> draftSectionData;
  final String? errorMessage;
  final String? infoMessage;
}
```

**ApplicationCubit Events** (Methods):
1. `loadApplication()` - Creates new application
2. `refreshEvaluate()` - Re-evaluates form with current data
3. `updateFieldValue()` - Updates form field value
4. `saveDraft()` - Saves form draft
5. `executeAction()` - Executes dynamic action
6. `submit()` - Submits application

### 3. **Domain Layer** (`lib/features/application/domain/`)
**Purpose**: Business logic independent of UI/Framework

**Entities** (Pure Dart objects):
- `ApplicationCreatedEntity`: { applicationId, ruleVersion }
- `FieldEntity`: { fieldId, type, value, mandatory, editable, visible, validation }
- `SectionEntity`: { sectionId, name, fields }
- `EvaluateResponseEntity`: { applicationId, ruleVersion, phase, sections, actions }
- `ActionEntity`: { actionId, name, triggerField, actionData }
- `ActionResponseEntity`: Result of action execution

**Use Cases** (Clean Architecture):
- `CreateApplicationUseCase`: Calls repository to create new application
- `EvaluateUseCase`: Evaluates form with rules
- `SaveDraftUseCase`: Saves draft data
- `ActionUseCase`: Executes action
- `SubmitUseCase`: Submits application

**Repositories** (Abstract interfaces):
```dart
abstract class ApplicationRepository {
  Future<Either<Failure, ApplicationCreatedEntity>> createApplication();
  Future<Either<Failure, EvaluateResponseEntity>> evaluate(EvaluateParams params);
  Future<Either<Failure, ActionResponseEntity>> executeAction(ActionParams params);
  Future<Either<Failure, void>> saveDraft(SaveDraftParams params);
  Future<Either<Failure, SubmitResponseEntity>> submit(SubmitParams params);
}
```

### 4. **Data Layer** (`lib/features/application/data/`)
**Purpose**: Data access and transformation

**Remote Data Source**:
- Communicates with FastAPI backend
- Maps responses to models

**Models**:
- `CreateApplicationResponseModel`: { applicationId, ruleVersion }
- `EvaluateResponseModel`: Full form structure + actions
- `ActionResponseModel`: Action result
- etc.

**Repository Implementation**:
- Calls remote data source
- Handles errors and returns Either<Failure, Entity>

### 5. **Core/Infrastructure** (`lib/core/`)
**Purpose**: Shared utilities and configuration

**Components**:
- **ApiClient**: Dio-based HTTP client
- **ApiEndpoints**: API routes
- **AppConfig**: Configuration (baseUrl, constants)
- **ErrorMapper**: Maps exceptions to Failures
- **DI/Injection**: Service locator (GetIt) setup

**API Endpoints**:
```
POST /applications               → Create application
POST /evaluate                   → Evaluate form
POST /action                     → Execute action
POST /save-draft                 → Save draft
POST /submit                     → Submit application
```

---

## 🐍 Backend Architecture (FastAPI/Python)

### 1. **Routers/API Layer** (`src/routers/`)
**Purpose**: HTTP endpoint handlers

**Routers**:
- `applications.py`: Create application
- `evaluate.py`: Evaluate form with rules
- `action.py`: Execute dynamic actions
- `save_draft.py`: Save draft data
- `submit.py`: Submit application

**Flow**:
```
HTTP Request → Router → Service → Repository → Database
     ↓
HTTP Response ← Router ← Service ← Repository ← Database
```

### 2. **Services Layer** (`src/services/`)
**Purpose**: Business logic

**Key Services**:
- **ApplicationService**: 
  - Creates new application
  - Initializes with rule_version="1.0.0" and phase="PRE_SANCTION"

- **EvaluateService**:
  - Validates application exists
  - Validates phase matches
  - Calls RuleService to evaluate rules
  - Returns dynamic form structure based on rules

- **RuleService**:
  - Evaluates business rules
  - Determines visible/editable/mandatory fields
  - Calculates next actions available
  - Returns form sections and actions dynamically

- **SaveDraftService**: Saves section data
- **SubmitService**: Submits application
- **ActionService**: Executes custom actions

### 3. **Models Layer** (`src/models/`)
**Purpose**: SQLAlchemy ORM models (Database schema)

**Models**:
- **Application**: 
  ```python
  - id: UUID (PK)
  - rule_version: str
  - phase: str
  - created_at: datetime
  - section_data: [ApplicationSectionData] (relationship)
  - override: ApplicationOverride (relationship)
  ```

- **ApplicationSectionData**:
  - Stores form field values
  - Links to Application

- **ApplicationOverride**:
  - Stores overrides/approvals

### 4. **Repositories Layer** (`src/repositories/`)
**Purpose**: Database access abstraction

**Repositories**:
- `ApplicationRepository`: CRUD for Application
- `ApplicationSectionDataRepository`: Manage form field data
- `ApplicationOverrideRepository`: Manage overrides

### 5. **Schemas Layer** (`src/schemas/`)
**Purpose**: Request/Response validation (Pydantic)

**Schemas**:
- `CreateApplicationResponse`: { applicationId, ruleVersion }
- `EvaluateRequest`: { applicationId, phase, context, sectionData }
- `EvaluateResponse`: { sections, actions, phase, etc. }
- `SubmitRequest/Response`
- `ActionRequest/Response`

### 6. **Database** (`src/core/database.py`)
**Purpose**: PostgreSQL with SQLAlchemy ORM

---

## 🔄 Data Flow: Complete User Journey

### Step 1: Create Application
```
Flutter UI (User clicks "Create Application")
    ↓
ApplicationCubit.loadApplication()
    ↓
CreateApplicationUseCase
    ↓
ApplicationRepository.createApplication()
    ↓
ApplicationRemoteDataSource.createApplication()
    ↓
ApiClient.post("/applications")
    ↓
[FastAPI] applications.py: POST /applications
    ↓
ApplicationService.create_application()
    ↓
Create Application(rule_version="1.0.0", phase="PRE_SANCTION")
    ↓
Save to PostgreSQL
    ↓
Return { applicationId, ruleVersion }
    ↓
Update UI State with applicationId
```

### Step 2: Evaluate (Load Form)
```
ApplicationCubit.refreshEvaluate()
    ↓
EvaluateUseCase with(applicationId, phase, sectionData)
    ↓
ApplicationRemoteDataSource.evaluate()
    ↓
ApiClient.post("/evaluate", data: request)
    ↓
[FastAPI] evaluate.py: POST /evaluate
    ↓
EvaluateService.evaluate()
    ↓
Fetch Application from DB
Validate phase matches
Call RuleService.evaluate()
    ↓
RuleService (Business Rules Engine):
  - Parse rules for current rule_version
  - Apply rules based on sectionData
  - Determine visible/editable/mandatory fields
  - Calculate available actions
  - Return dynamic form structure
    ↓
Return EvaluateResponse with:
  - sections: [{ sectionId, name, fields: [{ fieldId, type, value, editable, ... }] }]
  - actions: [{ actionId, name, triggerField, ... }]
  ↓
UI renders sections and fields dynamically
```

### Step 3: User Fills Form
```
User enters value in field
    ↓
DynamicSectionWidget.onFieldChanged callback
    ↓
ApplicationCubit.updateFieldValue(sectionId, fieldId, value)
    ↓
Update state.draftSectionData (in-memory)
```

### Step 4: Save Draft
```
User taps "Save Draft"
    ↓
ApplicationCubit.saveDraft()
    ↓
SaveDraftUseCase
    ↓
ApplicationRemoteDataSource.saveDraft()
    ↓
ApiClient.post("/save-draft", data: { applicationId, sectionId, fieldData })
    ↓
[FastAPI] save_draft.py: POST /save-draft
    ↓
SaveDraftService.save_draft()
    ↓
Save ApplicationSectionData records to PostgreSQL
    ↓
Return success response
```

### Step 5: Execute Action
```
User taps action button (e.g., "Check Eligibility")
    ↓
ApplicationCubit.executeAction()
    ↓
ActionUseCase with(actionId, payload)
    ↓
ApplicationRemoteDataSource.executeAction()
    ↓
ApiClient.post("/action", data: { applicationId, actionId, payload })
    ↓
[FastAPI] action.py: POST /action
    ↓
ActionService.execute_action()
    ↓
Execute business logic based on actionId
May trigger rule re-evaluation
May update phase
    ↓
Return ActionResponse with new form state
    ↓
Update UI (may trigger auto-refresh)
```

### Step 6: Submit Application
```
User taps "Submit" button
    ↓
ApplicationCubit.submit()
    ↓
SubmitUseCase
    ↓
ApplicationRemoteDataSource.submit()
    ↓
ApiClient.post("/submit", data: { applicationId, data: {...} })
    ↓
[FastAPI] submit.py: POST /submit
    ↓
SubmitService.submit()
    ↓
Validate all required fields filled
Save final data
Mark application as submitted
    ↓
Return SubmitResponse { success: true, message: "..." }
    ↓
UI shows success message
```

---

## 🎯 Key Design Patterns

### 1. **Clean Architecture**
- Separation of concerns (Presentation, Domain, Data)
- Business logic independent of frameworks
- Easy testing

### 2. **BLoC Pattern** (State Management)
- Cubit simplification of BLoC
- Immutable state
- Single source of truth

### 3. **Repository Pattern**
- Abstract data access
- Easy to mock for testing
- Can switch database/API without UI changes

### 4. **Use Case Pattern**
- Each business action = separate use case
- Follows Single Responsibility Principle
- Parameter objects (Params)

### 5. **Either/Result Pattern** (Functional Programming)
- `Either<Failure, Success>`
- Type-safe error handling
- No exceptions in domain layer

### 6. **Dependency Injection** (Service Locator)
- GetIt for Flutter DI
- FastAPI Depends() for Backend DI
- Loose coupling between layers

### 7. **Dynamic Form Rendering**
- Server returns form structure (sections, fields, rules)
- Client renders dynamically
- No hardcoded forms = flexible

### 8. **Rule Engine Based**
- Business rules stored in RuleService
- Can be updated without code changes
- Support for conditional fields, actions

---

## 📊 Data Model Relationships

```
Application (PK: id)
  ├── ApplicationSectionData (FK: application_id)
  │   └── Field values (fieldId, value)
  └── ApplicationOverride (FK: application_id)
      └── Approval/override records
```

---

## 🔌 Integration Points

### Frontend → Backend
- **Protocol**: HTTP REST (JSON)
- **Base URL**: http://10.0.2.2:8000 (Android emulator)
- **Client**: Dio (async/await)
- **Server**: FastAPI async handler

### Configuration
- **Frontend Config**: `lib/core/config/app_config.dart`
  ```dart
  baseUrl = 'http://10.0.2.2:8000'  // Android emulator
  ```

- **Backend Config**: `src/core/config.py`
  - Database URL
  - Server settings

---

## 🚀 Application Workflow Example

```
1. App starts
   ↓
2. User sees "Create Application" button
   ↓
3. User taps button → ApplicationId created, Phase=PRE_SANCTION
   ↓
4. Form evaluates and renders sections dynamically
   ↓
5. User fills "Loan Amount" field
   ↓
6. Rule engine validates and shows/hides dependent fields
   ↓
7. User taps "Check Eligibility" action
   ↓
8. Server evaluates eligibility, may move to next phase
   ↓
9. New form rendered (may have different fields based on phase)
   ↓
10. User fills remaining fields and taps "Save Draft"
    ↓
11. Data saved to database
    ↓
12. User taps "Submit"
    ↓
13. Final validation
    ↓
14. Application marked as submitted
    ↓
15. Success message shown
```

---

## 🏗️ Tech Stack Summary

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: BLoC/Cubit
- **HTTP Client**: Dio
- **DI Container**: GetIt
- **Error Handling**: Dartz (Either)
- **Validation**: Equatable

### Backend
- **Framework**: FastAPI (Python 3.8+)
- **ORM**: SQLAlchemy
- **Database**: PostgreSQL
- **Validation**: Pydantic
- **Async**: asyncio

---

## 📝 Summary

This is a **rule-based loan origination system** where:
- **Frontend** renders dynamic forms based on server responses
- **Backend** contains business rules and form structure logic
- **Communication** is REST API (JSON)
- **Data** persists in PostgreSQL
- **Architecture** follows Clean Architecture principles for maintainability

The key innovation is **dynamic form rendering** - the form structure is determined server-side based on rules, allowing business logic changes without app updates.
