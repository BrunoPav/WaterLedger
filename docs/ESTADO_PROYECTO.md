# Estado del Proyecto — WaterLedger

> Documento de referencia detallada para el equipo (onboarding + historial).
> Para la referencia operativa compacta ver [CLAUDE.md](../CLAUDE.md) en la raíz.
> Última actualización: 2026-06-05.

---

## Diagnóstico por módulo

### 4.1 Gestión de Usuarios → **PARCIAL**

| Submódulo | Estado | Detalle |
|-----------|--------|---------|
| 4.1.1 Diseño flujo auth | ✅ COMPLETO | Splash, Login, ForgotPassword, Register (selector de tipo) |
| 4.1.2 Registro de usuarios | ✅ COMPLETO | Retail ✅ Company ✅ Auditor ✅ Certifier ✅ Insurer ✅ — todos los roles suben archivos reales a `registrations/{uid}/{docType}/{filename}` y guardan las URLs en Firestore |
| 4.1.3 Inicio de sesión | ✅ COMPLETO | Auth con retry (3 intentos, backoff 400ms), errores en español, recovery, logout |
| 4.1.4 Roles y permisos | ✅ COMPLETO | Enums, UserModel, route guards con `roleHasAccess()`, HomeDispatcher, ProfileDispatcher |
| 4.1.5 Perfiles de usuario | ⚠️ PARCIAL | Pantallas read-only para todos los roles ✅ — edición limitada a `displayName`. Datos institucionales (CUIT, representante) no editables |
| 4.1.6 Dashboard inicial | ⚠️ PARCIAL | Admin y Company: datos reales. Resto: `ComingSoonBanner` + actividad real, KPIs aún en placeholder |

**Huecos funcionales:**
- Email verification ausente: cuentas operativas con emails no confirmados
- Sin edición de datos institucionales
- Sin FCM push notifications

---

### 4.2 Solicitudes de Emisión → **COMPLETO**

Wizard de 6 pasos con `PageController` (navegación programática):
- 4.2.1 Acceso al módulo · 4.2.2 Confirmación empresa (datos reales de `sessionProvider`)
- 4.2.3 Info proyecto hídrico · 4.2.4 Objetivos · 4.2.5 Roadmap (fases, hitos, validaciones)
- 4.2.6 Carga de documentación (file picker PDF/JPG/PNG, upload a Storage con barra de progreso)
- 4.2.7 Revisión final (`RequestSubmissionValidator` bloqueante + warning no-bloqueante de docs)
- 4.2.8 Envío (`submitRequest` → estado `pending`) · 4.2.9 Seguimiento (`RequestTrackingScreen`, 4 tabs)

Infra: `createDraft(uid)` en paso 0 (ID `REQ_YYYYMMDD_XXXXXX`), auto-save al avanzar,
`_normalize()` convierte Timestamps a DateTime antes de construir entidades.

---

### 4.3 Gestión de Auditoría → **COMPLETO (workflow básico)**

- `AuditorRequestDetailScreen` — iniciar auditoría, agregar/borrar observaciones por tipo,
  enviar conclusión (aprobar/rechazar/más info)
- `AuditEntity` + `AuditObservation` + `AuditConclusion` — modelos de dominio completos
- `FirebaseAuditRepository` — stream en vivo, batch write en `submitConclusion`
- 5 use cases: `GetAudit`, `StartAudit`, `AddObservation`, `DeleteObservation`, `SubmitConclusion`
- `auditStreamProvider` — `StreamProvider.family` con autoDispose

**Deuda:** sin notificación a la empresa al completar; `needsMoreInfo` sin flujo de respuesta.

---

### 4.4 Certificación → **IMPLEMENTADO**

Feature `certifier/` completo: `CertificationEntity`, `CertificationStatus`,
`FirebaseCertificationRepository`, use cases (`GetCertification`, `GetCertifiedRequests`,
`IssueCertificate`, `RejectCertification`), providers y screens (dashboard, lista, detalle).

### 4.5 Gestión de Seguros → **IMPLEMENTADO**

Feature `insurer/` completo: `InsurancePlanEntity`, enums de tipo/estado,
`FirebaseInsuranceRepository`, use cases (`CreateInsurancePlan`, `GetInsurancePlan`,
`GetInsuredRequests`, `RejectInsurance`), providers y screens.

---

### 4.6 Gestión del Administrador → **COMPLETO**

| Submódulo | Detalle |
|-----------|---------|
| 4.6.1 Aprobación usuarios | Approve/Reject con audit log, detalle con datos de onboarding |
| 4.6.2 Asignación operativa | `assignAuditor()` + dropdown en detalle + auditor ve sus asignaciones |
| 4.6.3 Supervisión | Stream real, filtros por estado, preview en dashboard |
| 4.6.4 Valorización | `valuations/{requestId}` con batch write → `status = 'valued'` |
| 4.6.5 Publicación | Admin publica desde detalle → `status = 'published'` |

---

## Mapa de dependencias (cadena de valor)
```
4.2 Wizard ✅ → 4.6.2 Asignación ✅ → 4.3 Auditoría ✅ → 4.4 Certificación ✅
  → 4.5 Seguros ✅ → 4.6.4 Valorización ✅ → 4.6.5 Publicación ✅ → Retail marketplace (futuro)
```

---

## Backlog

| # | Estado | Módulo | Descripción |
|---|--------|--------|-------------|
| P0 | ✅ HECHO | 4.2.7 | `RequestSubmissionValidator` conectado |
| P1 | ✅ HECHO | 4.3/4.6.2 | Flujo auditor completo |
| P2 | ✅ HECHO | 4.1.5 | `ref.invalidate(sessionProvider)` tras editar perfil |
| P3 | ✅ HECHO | 4.2.9 | `RequestTrackingScreen` con datos reales |
| P4 | ✅ HECHO | 4.3 | Schema `audits` + workflow básico |
| P5 | ✅ HECHO | infra | Limpieza de rutas QA + mock movido a `test/mocks/` |
| P6 | ⏭️ SKIP | 4.1.2 | File upload institucional (plan base Firebase) |
| P7 | ✅ HECHO | 4.6 | Feature flags / "coming soon" en dashboards |
| P8 | ⏭️ SKIP | firestore | Validar transiciones de estado (rules nunca deployadas) |
| P9 | ✅ HECHO | 4.4 | Certificación |
| P10 | ✅ HECHO | 4.5 | Gestión de seguros |
| P11 | ✅ HECHO | 4.6.4+4.6.5 | Valorización y publicación |
| P12 | 🟢 BAJA | 4.1 | Email verification flow |
| P13 | ✅ HECHO | 4.1.6 | Activity logs reales en dashboards |
| P14 | 🟢 BAJA | 4.1 | FCM push notifications |
| P15 | 🟢 BAJA | 4.1.5 | Perfiles editables completos (CUIT, rep. legal) |

---

## Seguridad & Infraestructura

| Item | Estado |
|------|--------|
| `firestore.rules` / `storage.rules` | ⚠️ Nunca deployadas — proyecto en test mode, archivos son solo documentación |
| `callerData().role == 'Company'` — string literal vs enum | ⚠️ Riesgo de typo |
| Sin paginación en queries Firestore | 🟡 Baja (escala actual) |
| Sin Crashlytics ni Analytics | 🟡 Media |

---

## Historial de implementación

### Tareas 1-9 (2026-06-03/04)
1. **Persistencia real (Firestore)** — entidades con `toMap`/`fromMap`, `FirebaseCreditIssuanceRepository`, fix typos (`ubication→location`, `sumary→summary`)
2. **Wizard de emisión (6 pasos)** — `credit_issuance_screen` con `PageController`, `credit_request_notifier`
3. **Documentos (upload real a Storage)** — 4 tarjetas, file picker, barra de progreso
4. **Fix upload + storage.rules** — validación de `requestId`, manejo de `FirebaseException`
5. **Admin: Supervisión + Asignación** — streams, `assignAuditor`, listado con filtros, detalle con dropdown
6. **Auditoría CTO + cierre P0/P1/P2** — `RequestSubmissionValidator` conectado, módulo auditor completo
7. **Cierre P3 + soft validation docs** — `RequestTrackingScreen` real, bottom sheet de docs faltantes
8. **P4: Workflow de auditoría** — schema `audits`, modelos de dominio, 5 use cases, batch write
9. **P5: Limpieza infraestructura** — rutas QA eliminadas, mock movido a `test/mocks/`

### Auditoría de código + limpieza (2026-06-04)
Revisión completa del código de `main`. Fases A y B aplicadas:

**Fase A — Limpieza segura:**
- Eliminadas entradas `/home-temporal` y `/project-info-test` de `_publicPaths` (`route_access.dart`)
- Borrado `register_credentials_section.dart` (widget muerto, superseded por `StepCredencialesForm`)
- Lints corregidos: `use_build_context_synchronously`, `value→initialValue`, `curly_braces`
- Removidos bloques de código comentado (`main.dart`, `app_router.dart`, `home_dispatcher.dart`, `register_screen.dart`)
- `cloud_functions` eliminado de `pubspec.yaml` (dependencia sin uso)

**Fase B — Código muerto eliminado:**
- Feature `issuer/` borrada (`IssuerCompany`, `IssuerRepository`, `IssuingCompanyScreen` — nunca referenciados)
- Isla de navegación muerta eliminada: `DocumentationScreen` (stub) + `RoadmapEditorScreen` standalone + rutas `/issuing-company`, `/documentation`, `/roadmap-editor`
- `RoadmapEditorStep` (widget del wizard) preservado
- `test/mocks/test_credit_issuance_repository.dart` conservado como base para tests futuros

Resultado: `flutter analyze` → **No issues found**.

### Reorganización core → features (2026-06-05)

Migración de `lib/core` al patrón por-feature en `lib/features` (rama `Arquitectura`,
commit `aa6d624`). 24 archivos movidos con `git mv` (historial preservado), 118 imports
actualizados en 46 archivos.

- **`features/shared/`** (nueva) → kernel de identidad: `user_model` + enums de usuario + `splash_screen`.
- **`features/admin/`** (nueva) → `admin_repository`, `firebase_admin_repository`, `admin_provider`
  y las screens de administración (incluye las 2 de `valuation`).
- **`features/auth/`** → completada con `domain/` + `data/`: `auth_repository`,
  `firebase_auth_repository`, `session_provider`, `auth_exception`, `auth_validators`, success screens.
- Se mantiene en `lib/core/`: routing (`app_router`, `route_access`, `go_router_refresh_stream`),
  `date_picker_field` (sin uso) y `Stitch_Templates/`.

Verificación: `flutter analyze` → **No issues found** (igual que baseline); `dart fix --dry-run` → **Nothing to fix**.
Respaldos: rama `Arquitectura-backup-pre-refactor-2026-06-04` + tag `pre-core-to-features-2026-06-04`.

### Fase C — Pendiente (refactors de duplicación)
- **C1:** extraer helpers de presentación (`_comingSoon` ~11 copias, `_timeAgo` ~7, `_avatarInitial` ~4) a un util/extension compartido
- **C2:** extraer la lógica de upload de los registros B2B (`_uploadFile`/`_mimeType`/`tryUpload`, duplicada en auditor/certifier/insurance) a un servicio compartido
- **C3:** unificar boilerplate de `HomeDispatcher` y `ProfileDispatcher`
- **C4 (opcional):** template común para los dashboards
