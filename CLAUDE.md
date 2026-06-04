# CLAUDE.md — WaterLedger

## Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore + Storage + Auth)
- **State management:** Riverpod (providers)
- **Router:** GoRouter con rutas protegidas

---

## Convención de Storage (ya acordada, no cambiar)
```
creditRequests/{requestId}/documents/{type}/{filename}   → docs de solicitud
registrations/{uid}/{documentType}/{filename}            → docs de onboarding
audits/{auditId}/reports/{filename}                      → reportes de auditoría
```

## Schema Firestore canónico — creditRequests
```
creditRequests/{requestId}:
  id, companyId, status, creditAmount, createdAt, updatedAt, submittedAt
  project: { name, location, category, description, estimatedInvestment, waterImpact }
  sustainability: { objective, description, benefittedEnvironment }
  roadmap: { phases: [...] }
  documents: [{ type, storageUrl, uploadedAt, isValid }]
  assignedAuditorId?: string
  auditResult?: object
```

## Schema Firestore canónico — audits
```
audits/{requestId}:           ← mismo ID que la creditRequest (1:1)
  requestId, auditorId
  status: 'inProgress' | 'submitted'
  observations: [{ id, text, type, phase?, createdAt }]
  conclusion?: { recommendation: 'approve'|'reject'|'needsMoreInfo', notes, submittedAt }
  createdAt, updatedAt
```
`submitConclusion(approve)` → batch write: audits.status='submitted' + creditRequests.status='certified'
`submitConclusion(reject)`  → batch write: audits.status='submitted' + creditRequests.status='rejected'
`submitConclusion(needsMoreInfo)` → solo actualiza audits, creditRequest se mantiene 'underAudit'

---

## Roles del sistema
| Rol | Acceso |
|-----|--------|
| Empresa (company/issuer) | Crea/edita drafts de solicitudes |
| Auditor | Lee solicitudes asignadas (`underAudit`) |
| Certificadora | Post-auditoría |
| Aseguradora | Carga planes de seguro |
| Admin | Acceso total, aprueba usuarios, asigna auditores |
| Retail investor | Marketplace (futuro) |

> ⚠️ `issuer` está definido en enum pero rutea al dashboard/perfil de `company` (TODO en código)

---

## Estado real del proyecto — Diagnóstico por módulo
> Auditado el 2026-06-03. Priorizar lo que se ve en el código sobre este historial.

### 4.1 Gestión de Usuarios → **PARCIAL**

| Submódulo | Estado | Detalle |
|-----------|--------|---------|
| 4.1.1 Diseño flujo auth | ✅ COMPLETO | Splash, Login, ForgotPassword, Register (selector de tipo) — todos implementados |
| 4.1.2 Registro de usuarios | ✅ COMPLETO | Retail ✅ Company ✅ — Auditor/Certifier/Insurer: UI completa pero **sin upload real a Firebase Storage** (guardan nombre en Firestore pero no suben archivo) |
| 4.1.3 Inicio de sesión | ✅ COMPLETO | Auth con retry (3 intentos, backoff 400ms), mapeo de errores en español, recovery, logout |
| 4.1.4 Roles y permisos | ✅ COMPLETO | Enums, UserModel, route guards con `roleHasAccess()`, HomeDispatcher, ProfileDispatcher |
| 4.1.5 Perfiles de usuario | ⚠️ PARCIAL | Pantallas read-only para todos los roles ✅ — Edición limitada a `displayName`. Datos institucionales (CUIT, representante) no editables |
| 4.1.6 Dashboard inicial | ⚠️ PARCIAL | Admin y Company: datos reales de Firestore. Retail/Auditor/Certifier/Insurer: **skeletons con datos hardcodeados** |

**Riesgos técnicos:**
- File upload ausente en registros B2B: admin aprueba sin ver documentos reales
- Email verification ausente: cuentas operativas con emails no confirmados
- `sessionProvider` **no se refresca** después de `updateProfile()` → usuario ve datos viejos hasta reiniciar la app

**Huecos funcionales:**
- Sin edición de datos institucionales (CUIT, representante, etc.)
- Activity log en dashboards: empty state en todos los roles
- Sin FCM push notifications

---

### 4.2 Solicitudes de Emisión → **COMPLETO**

| Submódulo | Estado | Detalle |
|-----------|--------|---------|
| 4.2.1 Acceso al módulo | ✅ COMPLETO | Acceso desde dashboard, validación empresa logueada |
| 4.2.2 Confirmación empresa | ✅ COMPLETO | Lee datos reales de `sessionProvider` |
| 4.2.3 Info proyecto hídrico | ✅ COMPLETO | Formulario conectado a `CreditRequestNotifier`, persiste en Firestore |
| 4.2.4 Objetivos del proyecto | ✅ COMPLETO | Goals de sustentabilidad, `updateCreditAmount` |
| 4.2.5 Roadmap | ✅ COMPLETO | `RoadmapEditorStep`: fases, hitos, fechas, validaciones — funcional |
| 4.2.6 Carga de documentación | ✅ COMPLETO | 4 tarjetas opcionales, file picker PDF/JPG/PNG, upload a Storage con barra de progreso |
| 4.2.7 Revisión final | ✅ COMPLETO | Validación bloqueante (proyecto/roadmap/monto) + warning no-bloqueante de documentación con dos acciones |
| 4.2.8 Envío de solicitud | ✅ COMPLETO | `submitRequest` → estado `pending` en Firestore, navega a `/submission-confirmation` |
| 4.2.9 Seguimiento | ✅ COMPLETO | `RequestTrackingScreen` con datos reales — ruta `/request-tracking/:requestId`, 4 tabs (Resumen/Roadmap/Docs/Historial), `DashboardBottomNav` |

**Infraestructura del wizard:**
- 6 pasos con `PageController` (navegación solo programática, sin scroll)
- `createDraft(uid)` en paso 0 → Firestore (ID formato `REQ_YYYYMMDD_XXXXXX`)
- Auto-save al avanzar cada paso
- `_normalize()` en repositorio convierte Timestamps a DateTime antes de construir entidades

**Deuda técnica activa:**
- `test_credit_issuance_repository.dart` vive en `lib/` (no en `test/`). Su `updateProjectInfo()` es un no-op silencioso. Riesgo de conectarlo accidentalmente.
- `RequestSubmissionValidator` declarado pero no llamado desde la UI en paso 7

---

### 4.3 Gestión de Auditoría → **COMPLETO (workflow básico)**

- `AuditorRequestDetailScreen` — workflow interactivo: iniciar auditoría, agregar/borrar observaciones por tipo, enviar conclusión con recomendación (aprobar/rechazar/más info)
- `AuditEntity` + `AuditObservation` + `AuditConclusion` — modelos de dominio completos
- `FirebaseAuditRepository` — stream en vivo, batch write en `submitConclusion`
- 5 use cases: `GetAudit`, `StartAudit`, `AddObservation`, `DeleteObservation`, `SubmitConclusion`
- `auditStreamProvider` — `StreamProvider.family` con autoDispose
- `admin_request_detail_screen.dart` — card de conclusión de auditoría (read-only)
- `firestore.rules` — colección `audits` + auditor asignado puede transicionar `creditRequests`

**Deuda técnica activa:**
- Sin notificación a la empresa cuando la auditoría se completa
- `needsMoreInfo` no tiene flujo de respuesta de la empresa (pendiente P9+)

---

### 4.4 Certificación del Proyecto → **PENDIENTE**

- Solo registro + dashboard skeleton
- Sin modelo de datos más allá del `users` doc
- Collection `certifications` referenciada en KPIs del admin pero vacía/no definida

**Dependencias:** Requiere 4.3 completo

---

### 4.5 Gestión de Seguros → **PENDIENTE**

- Solo registro + dashboard skeleton
- Sin planes de seguro, sin selección, sin asociación a proyectos
- Collection `valuations` referenciada en admin pero vacía

**Dependencias:** Requiere 4.4 completo

---

### 4.6 Gestión del Administrador → **PARCIAL**

| Submódulo | Estado | Detalle |
|-----------|--------|---------|
| 4.6.1 Aprobación usuarios | ✅ COMPLETO | Approve/Reject con audit log, detalle de usuario con datos de onboarding — funcional |
| 4.6.2 Asignación operativa | ✅ COMPLETO | `assignAuditor()` en repo ✅ — dropdown en `admin_request_detail_screen` ✅ — auditor ve sus asignaciones en `AuditorScreen` ✅ |
| 4.6.3 Supervisión de procesos | ✅ COMPLETO | Stream real, filtros por estado (chips), preview últimas 3 solicitudes en dashboard |
| 4.6.4 Valorización | ✅ COMPLETO | Admin crea `valuations/{requestId}` con batch write → `creditRequests.status = 'valued'` |
| 4.6.5 Publicación valorización | ✅ COMPLETO | Admin publica desde detalle → `creditRequests.status = 'published'` |

---

## Seguridad & Infraestructura

| Item | Estado | Severidad |
|------|--------|-----------|
| Rutas QA públicas en prod (`/home-temporal`, `/project-info-test`) | ✅ Resuelto | — |
| `test_credit_issuance_repository.dart` en `lib/` (no en `test/`) | ✅ Movido a `test/mocks/` | — |
| `firestore.rules`: sin validación de transiciones de estado | ⚠️ Incompleto | 🟠 Media |
| `firestore.rules`: subcollections de Storage no tienen reglas explícitas | ⚠️ Ausente | 🟠 Media |
| `callerData().role == 'Company'` — string literal, riesgo de typo vs enum | ⚠️ Presente | 🟠 Media |
| Sin paginación en queries Firestore (carga todo en memoria) | ⚠️ Ausente | 🟡 Baja (escala actual) |
| `cloud_functions` en pubspec sin ningún uso en codebase | 🗑️ Dead dep | 🟢 Baja |
| Sin Firebase Crashlytics ni Analytics inicializados | ⚠️ Ausente | 🟡 Media |

---

## Mapa de dependencias (cadena de valor)
```
4.2 Wizard completo ← COMPLETO ✅
  └→ 4.6.2 Asignación auditor ← COMPLETO ✅
      └→ 4.3 Workflow auditoría básico ← COMPLETO ✅
          └→ 4.4 Certificación ← BLOQUEO ACTUAL
              └→ 4.5 Seguros
                  └→ 4.6.4 Valorización
                      └→ 4.6.5 Publicación
                          └→ Retail marketplace
```

---

## Backlog priorizado

| # | Prioridad | Módulo | Descripción | Requiere |
|---|-----------|--------|-------------|----------|
| P0 | ✅ HECHO | 4.2.7 | `RequestSubmissionValidator` conectado — bottom sheet con errores antes de submit | — |
| P1 | ✅ HECHO | 4.3/4.6.2 | `AuditorScreen` + `AuditorRequestDetailScreen` + `auditorAssignmentsProvider` — flujo completo | — |
| P2 | ✅ HECHO | 4.1.5 | `ref.invalidate(sessionProvider)` ya existía en `profile_edit_screen.dart` línea 72 | — |
| P3 | ✅ HECHO | 4.2.9 | `RequestTrackingScreen` con datos reales + `DashboardBottomNav` + ruta parametrizada | — |
| P4 | ✅ HECHO | 4.3 | Schema `audits` + workflow básico (observaciones, conclusión, batch write status) | P1 |
| P5 | ✅ HECHO | infra | Rutas QA eliminadas, `test_credit_issuance_repository` movido a `test/mocks/` | — |
| P6 | ~~🟠 ALTA~~ | 4.1.2 | ~~File upload institucional~~ — **SKIP** (plan base Firebase) | — |
| P7 | ✅ HECHO | 4.6 | Feature flags / "coming soon" en dashboards incompletos (Certifier, Insurer, Retail) | — |
| P8 | ~~🟡 MEDIA~~ | firestore | ~~Validar transiciones de estado~~ — **SKIP** (rules nunca deployadas) | — |
| P9 | ✅ HECHO | 4.4 | Certificación | P4 |
| P10 | ✅ HECHO | 4.5 | Gestión de seguros | P9 |
| P11 | ✅ HECHO | 4.6.4+4.6.5 | Valorización y publicación | P10 |
| P12 | 🟢 BAJA | 4.1 | Email verification flow | — |
| P13 | ✅ HECHO | 4.1.6 | Activity logs reales en dashboards | — |
| P14 | 🟢 BAJA | 4.1 | FCM push notifications | — |
| P15 | 🟢 BAJA | 4.1.5 | Perfiles editables completos (CUIT, rep. legal, etc.) | — |

---

## Historial de implementación completada

### Tarea 1 — Persistencia real (Firestore)
- Entidades con `toMap()` / `fromMap()`: `water_project_entity`, `credit_request_entity`, `document_entity`, `roadmap_entity`, `project_phase_entity`, `sustainability_goal_entity`
- Fix typos: `ubication → location`, `sumary → summary`
- `firebase_credit_issuance_repository.dart` — repositorio real contra Firestore
- `firestore.rules` — colección `creditRequests` con reglas por rol
- `repository_provider.dart` → apunta a `FirebaseCreditIssuanceRepository`

### Tarea 2 — Wizard de Solicitud de Emisión (6 pasos)
- `credit_issuance_screen.dart` — wizard completo con `PageController`
- `roadmap_editor_screen.dart` — refactorizado como wrapper delgado
- `roadmap_editor_step.dart` — widget reutilizable
- `credit_request_notifier.dart` — `updateProjectInfo` + `updateCreditAmount`
- Rutas: `/company-confirmation`, `/project-info`, `/project-objectives`, `/roadmap-editor`, `/documents-upload`, `/request-review`, `/submission-confirmation`

### Tarea 3 — Documentos (Upload real a Storage)
- `document_upload_step.dart` — 4 tarjetas (técnica, ambiental, legal, financiera)
- File picker: PDF, JPG, PNG — `file_picker: ^11.0.2` en pubspec
- Upload con barra de progreso en tiempo real
- `notifier.uploadDocuments(docs)` al avanzar

### Tarea 4 — Fix upload + storage.rules
- `_pickAndUpload`: valida `requestId`, cancela stream con `cancelOnError: true`, captura `FirebaseException` unauthorized
- `storage.rules` desplegadas en Firebase Console (proyecto: `waterledger-e7544`)

### Tarea 5 — Admin: Supervisión (4.6.3) + Asignación (4.6.2)
- `admin_repository.dart` — `creditRequestsStream`, `activeAuditorsStream`, `assignAuditor`
- `firebase_admin_repository.dart` — streams con normalización de Timestamps
- `admin_provider.dart` — `allCreditRequestsProvider`, `activeAuditorsProvider`
- `admin_requests_list_screen.dart` — listado con filtros por estado
- `admin_request_detail_screen.dart` — detalle + asignación de auditor con dropdown
- `admin_dashboard_screen.dart` — preview últimas 3 solicitudes + link "Ver todas"
- Rutas: `/admin-credit-requests`, `/admin-request-detail/:requestId`

### Tarea 7 — Cierre P3 + Soft validation docs (2026-06-03)
- **P3:** `RequestTrackingScreen` reescrita con datos reales de Firestore via `requestTrackingProvider(requestId)`. Ruta cambiada a `/request-tracking/:requestId`. `DashboardBottomNav` + `DashboardNavItem` para consistencia visual. 4 tabs reales: Resumen (status + pipeline derivado), Roadmap (fases + milestones con labels), Documentos (campos correctos), Historial (timestamps reales). `SubmissionConfirmationScreen` actualizada para pasar `request.id`.
- **Validación documentos (soft):** `_handleSubmit` separa errores bloqueantes (proyecto/roadmap/monto) de documentación. Docs faltantes muestran bottom sheet informativo con "Entendido" (vuelve a paso 4) y "Enviar sin documentos" (dispara submit). `_doSubmit` extraído como método compartido.

### Tarea 8 — P4: Workflow básico de auditoría (2026-06-04)
- Schema `audits/{requestId}` definido y documentado
- `AuditEntity`, `AuditObservation`, `AuditConclusion` — modelos de dominio con `toMap`/`fromMap`
- Enums: `AuditStatus`, `ObservationType`, `AuditRecommendation`
- `AuditRepository` abstracto + `FirebaseAuditRepository` — `submitConclusion` con batch write
- 5 use cases siguiendo el patrón de credit_issuance
- `audit_repository_provider.dart` — DI completa + `auditStreamProvider`
- `AuditorRequestDetailScreen` reescrita como `ConsumerStatefulWidget` con workflow completo
- `admin_request_detail_screen.dart` — card de conclusión de auditoría read-only
- `firestore.rules` — colección `audits` + regla para auditor asignado en `creditRequests`

### Tarea 9 — P5: Limpieza infraestructura (2026-06-04)
- Rutas `/home-temporal` y `/project-info-test` eliminadas del router + sus imports y archivos
- `lib/home_temporal.dart` y `lib/core/Stitch_Templates/Steps/step_3_project_info/project_info_step_screen.dart` borrados
- `test_credit_issuance_repository.dart` movido de `lib/` a `test/mocks/` — limpiado de comentarios y no-ops

### Tarea 6 — Auditoría CTO + Cierre P0/P1/P2 (2026-06-03)
- Revisión completa del estado real del código vs. historial documentado
- **P0:** `RequestSubmissionValidator` conectado en `credit_issuance_screen.dart` — bottom sheet con lista de errores antes de `submitRequest()`. Mensajes de error crudos (`Error: $e`) corregidos en steps 0, 2 y 5.
- **P1:** Módulo auditor completo — `AuditorDashboardScreen` movido a `features/auditor/` con datos reales (KPIs, preview 3 asignaciones), `AuditorScreen` (lista completa), `AuditorRequestDetailScreen` (read-only). `getAuditorAssignments()` agregado al repo. `auditor_provider.dart` creado. Rutas `/auditor-request-detail/:requestId` + guards.
- **P2:** `ref.invalidate(sessionProvider)` ya existía en `profile_edit_screen.dart` — falso positivo del audit. Se corrigió el catch genérico que exponía excepción cruda.
- 4.6.2 pasa a COMPLETO. Backlog repriorizado con P0–P15.

---

## Chats activos
- **Refactor:** optimización de componentes y código
- **Exploración:** solo leer y explicar, NO modificar nada
- **Modificaciones grandes:** cambios estructurales — origen de este historial
- **Pulido:** mejoras de calidad, consistencia y UX

---

## Próximo objetivo
**P12–P15:** Mejoras de calidad (email verification, activity logs, FCM, perfiles editables). Todo lo crítico del flujo principal está completo.
