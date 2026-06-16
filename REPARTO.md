# REPARTO DE /lib — WaterLedger (estudio en grupo de 5)

> Documento informativo. No modifica código. Objetivo: que cada persona entienda
> a fondo "su" parte y, entre los 5, puedan reconstruir el flujo completo de la app.

---

## 1. Mapeo general — flujo de punta a punta

```
main.dart
  └─ Firebase.initializeApp() + initializeDateFormatting('es')
  └─ ProviderScope ──> MainApp (ConsumerWidget)
        └─ MaterialApp.router(routerConfig: appRouterProvider)

appRouterProvider (core/config/router/app_router.dart)
  └─ GoRouter
       ├─ refreshListenable: GoRouterRefreshStream(authStateChanges)
       │     → cualquier cambio de sesión Firebase re-evalúa el redirect
       ├─ redirect: usa sessionProvider + route_access.dart
       │     → sin sesión + ruta protegida → /login
       │     → con sesión + ruta de auth (/login,/register) → /home
       │     → con sesión pero rol sin acceso → /home
       └─ initialLocation: /splash

SplashScreen (features/shared) → tras animación → context.go('/login')

sessionProvider (features/auth/presentation/providers/session_provider.dart)
  └─ StreamProvider<UserModel?> ← authRepositoryProvider.authStateChanges
       (FirebaseAuthRepository: Firebase Auth + lee doc /users/{uid} en Firestore)

Login / Register (features/auth)
  → crea/lee documento Firestore "users/{uid}" con role/status/permissions
  → sessionProvider emite UserModel → router redirige a /home

/home → HomeDispatcher (features/dashboards)
  → switch por UserModel.role → dashboard del rol
       retail/company/issuer/auditor/certifier/insurer → dashboards propios
       admin → redirige a /admin-dashboard

/profile → ProfileDispatcher (features/profiles)
  → switch por UserModel.role → screen de perfil del rol

Pipeline de negocio (entidad central: creditRequests/{requestId}):
  Company (credit_issuance) crea/edita/sube docs → submit
    → Admin (admin) aprueba registro B2B previo, asigna auditor
    → Auditor (auditor) revisa, agrega observaciones, conclusión
        → batch: audits.status=submitted + creditRequests.status=certified|rejected
    → Certifier (certifier) certifica solicitudes aprobadas
    → Admin (admin/valuation) valoriza y publica
    → Insurer (insurer) asocia planes de seguro a la solicitud
```

**Colecciones Firestore involucradas:** `users`, `creditRequests`, `audits`,
`registrations/{uid}/...` (docs de onboarding B2B), `creditRequests/{id}/documents/...`.

---

## 2. Tronco común — lo que los 5 deben entender antes de repartirse

Esto es lo transversal: sin esto, cualquier feature "no tiene de dónde colgar".

| Archivo / carpeta | Qué es y por qué es transversal |
|---|---|
| `lib/main.dart` | Bootstrap: inicializa Firebase, intl (es), envuelve la app en `ProviderScope` (Riverpod) y arranca `MaterialApp.router`. Punto de entrada literal de la app. |
| `lib/firebase_options.dart` | Config generada por FlutterFire para conectar con el proyecto Firebase. |
| `lib/core/config/router/app_router.dart` | El **router único** de la app (GoRouter). Define todas las rutas y el `redirect` (guard de auth + rol). Cualquier pantalla nueva pasa por acá. |
| `lib/core/config/router/route_access.dart` | Tablas de "qué rutas son públicas" y "qué rol puede entrar a qué ruta". Se edita junto con el router. |
| `lib/core/config/router/go_router_refresh_stream.dart` | Adapter pequeño: convierte el stream de auth de Firebase en algo que GoRouter pueda escuchar para re-evaluar el redirect en tiempo real. |
| `lib/features/auth/presentation/providers/session_provider.dart` | **El provider más importante de la app**: `sessionProvider` (StreamProvider<UserModel?>) representa "quién está logueado ahora". Lo consume el router, los dispatchers, y casi toda pantalla que necesita saber el rol/usuario actual. |
| `lib/features/shared/domain/entities/user_model.dart` | `UserModel`: la entidad de usuario (uid, email, role, status, permissions, etc.) que viaja por toda la app. |
| `lib/features/shared/domain/enums/*.dart` (`user_role`, `user_status`, `user_type`, `user_permission`) | Los enums que definen roles (company/auditor/certifier/insurer/admin/retail/issuer), estados (pending/active) y permisos. La lógica de acceso de TODA la app gira sobre estos. |
| `lib/features/shared/presentation/screens/splash_screen.dart` | Primera pantalla. Simple, pero es el punto de partida visual. |
| `lib/features/dashboards/presentation/screens/home_dispatcher.dart` | El "switch" que decide qué dashboard mostrar según `UserModel.role`. Es la bisagra entre el tronco (sesión/router) y las features de cada rol. |
| `lib/features/profiles/presentation/screens/profile_dispatcher.dart` | Mismo patrón que `home_dispatcher`, pero para `/profile`. |

**Conceptos transversales a entender:**
- **Riverpod**: `Provider`, `StreamProvider`, `StreamProvider.family`, `FutureProvider`, `ConsumerWidget`/`ConsumerStatefulWidget`, `ref.watch` vs `ref.read`.
- **Patrón "dispatcher"**: una pantalla sin UI propia que solo decide (según rol) qué otra pantalla mostrar. Se repite en `/home` y `/profile`.
- **Guard de router reactivo**: cómo un cambio en Firebase Auth dispara `notifyListeners()` → GoRouter re-evalúa `redirect` → navegación automática sin código manual de "ir a tal pantalla".
- **Clean Architecture por feature**: cada feature tiene `domain/` (entities, enums, validators, use_cases, repository interfaces), `data/` (implementación Firebase del repo) y `presentation/` (providers Riverpod, screens, widgets). Este patrón se repite casi idéntico en auditor/certifier/insurer/credit_issuance — entenderlo una vez alcanza para leer todas las features rápido.

---

## 3. Reparto en 5 áreas — tabla resumen

| # | Área | Carpetas principales | Tamaño aprox. (archivos) | Eje conceptual |
|---|------|----------------------|---------------------------|----------------|
| A | Autenticación, Registro e Identidad | `features/auth/**` (+ repaso profundo de `features/shared/**`) | ~13 | Alta (variantes de roles, mixins, Storage) |
| B | Emisión de Solicitudes de Crédito | `features/credit_issuance/**` + `company_dashboard_screen.dart` | ~25 | Alta (dominio rico, wizard, validators) |
| C | Auditoría y Certificación | `features/auditor/**` + `features/certifier/**` | ~29 | Media (mucho volumen pero patrón repetido) |
| D | Administración, Valorización y Seguros | `features/admin/**` + `features/valuation/**` + `features/insurer/**` | ~27 | Media-alta (admin tiene lógica ad-hoc) |
| E | Dashboards, Perfiles y Componentes Compartidos | `features/dashboards/**` (resto) + `features/profiles/**` | ~18 | Baja-media (mucha UI, conexión transversal) |

---

## 4. Ficha por persona

### 🅰️ Persona A — Autenticación, Registro e Identidad de Usuario

**Qué incluye:**
- `lib/features/auth/` completo:
  - `presentation/screens/`: `login_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart`, `corporate_onboarding_screen.dart`, `retail_register_screen.dart`, `auditor_register_screen.dart`, `certifier_register_screen.dart`, `insurance_register_screen.dart`, `register_success_screen.dart`, `company_register_success_screen.dart`, `retail_register_success_screen.dart`
  - `presentation/widgets/`: `register_form.dart`, `b2b_register_upload.dart` (mixins reutilizados por los registros B2B)
  - `presentation/providers/session_provider.dart` (tronco, pero acá se profundiza)
  - `domain/`: `auth_validators.dart`, `auth_exception.dart`, `repositories/auth_repository.dart`
  - `data/repositories/firebase_auth_repository.dart`
- Repaso profundo de `lib/features/shared/domain/` (UserModel + enums) — esta persona es la que mejor debería conocer la forma exacta de un usuario.

**Qué hace en el contexto de la app:**
Es la puerta de entrada. Permite crear cuentas para los 6 roles (retail, company/issuer, auditor, certifier, insurer, admin se crea aparte), capturando datos distintos según el tipo (persona física vs B2B), subiendo documentación institucional a Storage (`registrations/{uid}/{documentType}/{filename}`) y dejando el usuario en estado `pending` hasta aprobación.

**Cómo encaja en el flujo / con qué se conecta:**
- Produce el `UserModel` (tronco) que consumen el router (`route_access.dart`), los dispatchers y todas las demás áreas.
- Los usuarios `pending` creados acá son la cola que revisa **Persona D** (admin → aprobación de registros).
- `session_provider.dart` es compartido con el tronco — esta persona lo explica al resto en detalle.

**Conceptos clave a aprender:**
- Mixins en Dart para reuso (`B2bRegisterUpload`, `RegisterMultiChipSelector`/`toFirestoreMap`).
- Firebase Auth (crear usuario) + Firestore (escribir doc `users/{uid}`) + Storage (subir docs de onboarding).
- Validación de formularios (`auth_validators.dart`) y manejo de excepciones de auth.
- Diferencia entre `UserStatus.pending` y `UserStatus.active` y cómo afecta `canAudit`/`canCertify`/`canInsure` en `UserModel`.

**Por dónde empezar a leer:**
`login_screen.dart` → `register_screen.dart` → `register_form.dart` → uno de los registros B2B (ej. `auditor_register_screen.dart`) + `b2b_register_upload.dart` → `firebase_auth_repository.dart` → `session_provider.dart`.

---

### 🅱️ Persona B — Emisión de Solicitudes de Crédito (Company / Issuer)

**Qué incluye:**
- `lib/features/credit_issuance/` completo:
  - `domain/entities/`: `water_project_entity`, `roadmap_entity`, `project_phase_entity`, `sustainability_goal_entity`, `document_entity`, `credit_request_entity`
  - `domain/enums/`: `document_type`, `milestones`, `project_category`, `request_status`
  - `domain/validators/`: `water_project_validator`, `roadmap_validator`, `phase_validator`, `document_validator`, `request_submission_validator`
  - `domain/use_cases/`: create/submit/update/upload/get/delete (8 use cases)
  - `data/repositories/firebase_credit_issuance_repository.dart`
  - `presentation/providers/`: `credit_request_notifier.dart`, `roadmap_editor_notifier.dart`, `company_requests_provider.dart`, `repository_provider.dart`
  - `presentation/screens/`: `credit_issuance_screen.dart` (wizard de 6 pasos), `submission_confirmation_screen.dart`, `request_tracking_screen.dart`
  - `presentation/widgets/`: `roadmap_editor_step.dart`, `document_upload_step.dart`
  - `presentation/models/roadmap_phase_draft_model.dart`, `presentation/constants/milestone_labels.dart`
- `lib/features/dashboards/presentation/screens/company_dashboard_screen.dart`

**Qué hace en el contexto de la app:**
Es el corazón del negocio: una empresa (`company`/`issuer`) arma una solicitud de crédito hídrico paso a paso (datos del proyecto, objetivos de sostenibilidad, roadmap de fases, documentación), la guarda como draft, la edita y finalmente la envía (`submit`). Después puede hacer seguimiento del estado (`request_tracking_screen`).

**Cómo encaja en el flujo / con qué se conecta:**
- Genera el documento `creditRequests/{requestId}` — la entidad central que **todas** las demás áreas (C y D) leen y modifican.
- Sube documentos a `creditRequests/{requestId}/documents/{type}/{filename}` (convención de Storage del proyecto).
- `company_dashboard_screen` muestra las solicitudes propias de la empresa (usa `company_requests_provider`).
- Conecta con el tronco vía `sessionProvider` (para saber `companyId` = uid del usuario).

**Conceptos clave a aprender:**
- Wizard multi-paso con estado manejado por un `Notifier` de Riverpod (`credit_request_notifier.dart`, `roadmap_editor_notifier.dart`).
- Validators de dominio puros (sin Flutter) que se llaman antes de habilitar "siguiente"/"enviar".
- Modelo de "draft" vs "submitted" (`request_status` enum) y su relación con `creditRequests.status`.
- Subida de archivos a Firebase Storage y su referencia en `documents: [{ type, storageUrl, ... }]`.

**Por dónde empezar a leer:**
`credit_issuance_screen.dart` → `credit_request_notifier.dart` → `roadmap_editor_notifier.dart` + `roadmap_editor_step.dart` → `document_upload_step.dart` → `firebase_credit_issuance_repository.dart` → `request_tracking_screen.dart`.

---

### 🅲️ Persona C — Auditoría y Certificación (pipeline de verificación)

**Qué incluye:**
- `lib/features/auditor/` completo:
  - `domain/entities/`: `audit_entity`, `auditor_entity`
  - `domain/enums/`: `audit_status`, `observation_type`, `audit_recommendation`
  - `domain/use_cases/`: `start_audit`, `add_observation`, `delete_observation`, `get_audit`, `submit_audit_conclusion`
  - `data/repositories/firebase_audit_repository.dart`
  - `presentation/providers/`: `auditor_provider.dart`, `audit_repository_provider.dart`
  - `presentation/screens/`: `auditor_screen.dart`, `auditor_dashboard_screen.dart`, `auditor_request_detail_screen.dart`
- `lib/features/certifier/` completo:
  - `domain/entities/certification_entity.dart`, `domain/enums/certification_status.dart`
  - `domain/use_cases/`: `get_certification`, `get_certified_requests`, `issue_certificate`, `reject_certification`
  - `data/repositories/firebase_certification_repository.dart`
  - `presentation/providers/`: `certifier_provider.dart`, `certification_repository_provider.dart`
  - `presentation/screens/`: `certifier_dashboard_screen.dart`, `certifier_requests_screen.dart`, `certifier_request_detail_screen.dart`

**Qué hace en el contexto de la app:**
Modela las dos etapas de verificación posteriores a la emisión. El **auditor** recibe solicitudes en estado `underAudit` (asignadas por admin), agrega observaciones por fase, y emite una conclusión (`approve`/`reject`/`needsMoreInfo`) que actualiza en batch `audits/{requestId}.status` y `creditRequests.status`. El **certifier** trabaja sobre solicitudes ya auditadas/aprobadas para emitir o rechazar la certificación.

**Cómo encaja en el flujo / con qué se conecta:**
- Consume `creditRequests` generadas en **Área B**, filtradas por `assignedAuditorId` (asignado por **Área D**).
- Escribe en la colección `audits/{requestId}` (mismo ID que la creditRequest, 1:1).
- El resultado (`certified`/`rejected`) es lo que **Área D** usa para habilitar valorización/publicación, y lo que **Área D** (insurer) usa para ofrecer seguros.

**Conceptos clave a aprender:**
- Firestore **batch writes** (cómo `submitConclusion` actualiza dos documentos atómicamente).
- El patrón repetido entity/enum/repository/use_case/provider/screen — aprenderlo a fondo en `auditor` hace que `certifier` se lea en la mitad de tiempo (estructura casi idéntica, sin "observaciones").
- Diferencia entre los 3 estados de conclusión y cómo cada uno afecta (o no) `creditRequests.status`.

**Por dónde empezar a leer:**
`auditor_dashboard_screen.dart` → `auditor_request_detail_screen.dart` → `auditor_provider.dart` → `firebase_audit_repository.dart` (foco en `submitConclusion`) → `submit_audit_conclusion_use_case.dart`. Luego, en paralelo/comparando: `certifier_dashboard_screen.dart` → `firebase_certification_repository.dart`.

---

### 🅳️ Persona D — Administración, Valorización y Seguros

**Qué incluye:**
- `lib/features/admin/` completo:
  - `data/repositories/firebase_admin_repository.dart`, `domain/repositories/admin_repository.dart`
  - `presentation/providers/admin_provider.dart`
  - `presentation/screens/`: `admin_dashboard_screen.dart`, `pending_approvals_list_screen.dart`, `pending_request_detail_screen.dart`, `admin_requests_list_screen.dart`, `admin_request_detail_screen.dart`, `admin_valuations_list_screen.dart`, `admin_valuation_detail_screen.dart`, `notifications_modal.dart`
- `lib/features/valuation/` completo (`valuation_entity`, `valuation_status`, `valuation_repository`, `firebase_valuation_repository`, `valuation_repository_provider`)
- `lib/features/insurer/` completo:
  - `domain/entities/insurance_plan_entity.dart`, `domain/enums/`: `insurance_plan_status`, `insurance_plan_type`
  - `domain/use_cases/`: `create_insurance_plan`, `get_insurance_plan`, `get_insured_requests`, `reject_insurance`
  - `data/repositories/firebase_insurance_repository.dart`
  - `presentation/providers/`: `insurer_provider.dart`, `insurance_repository_provider.dart`
  - `presentation/screens/`: `insurer_dashboard_screen.dart`, `insurer_requests_screen.dart`, `insurer_request_detail_screen.dart`

**Qué hace en el contexto de la app:**
Es el rol "dios" de la app: aprueba registros B2B pendientes (cambia `UserStatus.pending → active`), asigna auditores a solicitudes, supervisa el estado global del pipeline (`admin_requests_list_screen`), y en la etapa final valoriza y publica solicitudes certificadas (`admin_valuations_*`). El insurer, en paralelo, asocia planes de seguro a solicitudes (probablemente certificadas/valorizadas).

**Cómo encaja en el flujo / con qué se conecta:**
- Lee la cola de usuarios `pending` creada en **Área A** (`pendingUsersProvider`, `pending_approvals_list_screen`).
- Asigna `assignedAuditorId` sobre `creditRequests` de **Área B**, lo que habilita el trabajo de **Área C**.
- La valorización/publicación cierra el ciclo iniciado en B y verificado en C.
- El insurer trabaja sobre las mismas `creditRequests` ya certificadas (Área C).

**Conceptos clave a aprender:**
- `StreamProvider.family` para contadores genéricos de colecciones (`collectionCountProvider`) — patrón reusable.
- Flujo de aprobación de usuarios (pending → active) y su efecto sobre `UserModel.canAudit/canCertify/canInsure`.
- Workflow de valorización/publicación (último estado de `creditRequests`).
- Tipos y estados de planes de seguro (`insurance_plan_type`/`insurance_plan_status`).

**Por dónde empezar a leer:**
`admin_dashboard_screen.dart` → `admin_provider.dart` → `pending_approvals_list_screen.dart` → `pending_request_detail_screen.dart` (aprobación) → `admin_requests_list_screen.dart` → `admin_request_detail_screen.dart` (asignación de auditor) → `admin_valuations_list_screen.dart` (valorización). Luego `insurer_dashboard_screen.dart` → `firebase_insurance_repository.dart`.

---

### 🅴️ Persona E — Dashboards, Perfiles y Componentes Compartidos de Presentación

**Qué incluye:**
- `lib/features/dashboards/` (excepto `company_dashboard_screen.dart`, que va con Área B):
  - `presentation/screens/`: `retail_dashboard_screen.dart` (`home_dispatcher.dart` es tronco, pero se repasa acá su conexión con esta área)
  - `presentation/providers/activity_providers.dart`
  - `presentation/widgets/`: `activity_tile.dart`, `coming_soon_banner.dart`, `dashboard_bottom_nav.dart`, `dashboard_tokens.dart`, `dashboard_top_bar.dart`, `pending_approval_banner.dart`, `section_header.dart`, `stat_card.dart`
- `lib/features/profiles/` completo:
  - `presentation/screens/`: `admin_profile_screen.dart`, `auditor_profile_screen.dart`, `certifier_profile_screen.dart`, `company_profile_screen.dart`, `insurer_profile_screen.dart`, `retail_profile_screen.dart`, `profile_edit_screen.dart` (`profile_dispatcher.dart` es tronco)
  - `presentation/widgets/`: `profile_header.dart`, `profile_info_card.dart`

**Qué hace en el contexto de la app:**
Es la "capa de cierre": las pantallas de aterrizaje (`/home`, `/profile`) que ve cada rol al loguearse, con sus tarjetas de actividad, KPIs, banners de "próximamente" (módulos sin implementar aún) y la edición básica de perfil (`displayName`).

**Cómo encaja en el flujo / con qué se conecta:**
- `home_dispatcher.dart`/`profile_dispatcher.dart` (tronco) son literalmente el punto de entrada a esta área — esta persona debe entenderlos bien aunque viva en el tronco.
- `activity_providers.dart` agrega datos de **varias** colecciones (creditRequests, audits, etc.) — esta persona necesita una vista panorámica liviana de qué datos expone cada feature (B, C, D) sin entrar en su lógica de negocio.
- Los widgets de `dashboards/presentation/widgets/` (tokens de diseño, tarjetas, nav bar) son reusados por **todas** las dashboards de las otras áreas — son la "librería visual compartida".
- Los perfiles leen `UserModel` (tronco) y permiten editar vía `auth` (Área A, `firebase_auth_repository` para actualizar `displayName`).

**Conceptos clave a aprender:**
- Patrón "dispatcher por rol" (ya visto en tronco), aplicado dos veces (`/home`, `/profile`).
- `StreamProvider` que combina/agrega datos de múltiples colecciones para armar un feed de actividad.
- Sistema de design tokens (`dashboard_tokens.dart`) y cómo se reusan widgets entre features (evita duplicar estilos).
- `ComingSoonBanner`: cómo la app marca módulos no implementados (ej. marketplace retail) sin romper la navegación.

**Por dónde empezar a leer:**
`home_dispatcher.dart` (tronco) → `retail_dashboard_screen.dart` → `activity_providers.dart` → `dashboard_tokens.dart` + un par de widgets (`stat_card.dart`, `activity_tile.dart`) → `profile_dispatcher.dart` (tronco) → `company_profile_screen.dart` → `profile_edit_screen.dart`.

---

## 5. Síntesis: orden de estudio y teach-back

### Orden lógico sugerido

1. **Tronco común (individual, ~30–45 min cada uno):** `main.dart` → `app_router.dart` + `route_access.dart` → `session_provider.dart` → `shared/` (UserModel + enums) → `home_dispatcher.dart` / `profile_dispatcher.dart`. Todos deben poder explicar: "¿qué pasa desde que abro la app hasta que veo mi dashboard?"
2. **Persona A (Auth)** — primero en el grupo: define el `UserModel` y el ciclo de vida de un usuario (pending → active).
3. **Persona B (Credit Issuance)** — segundo: define la entidad central `creditRequest` que todo lo demás consume.
4. **Persona C (Auditoría/Certificación)** — tercero: siguiente etapa del pipeline sobre `creditRequest`.
5. **Persona D (Admin/Valuation/Insurer)** — cuarto: orquesta (asigna, aprueba) y cierra el ciclo (valoriza, asegura).
6. **Persona E (Dashboards/Perfiles)** — quinto: capa de presentación que amarra visualmente todo lo anterior.

### Esquema de teach-back (sesión grupal)

- **Ronda 1 — Presentación individual (10–15 min c/u):** cada persona muestra el "happy path" de su área con un ejemplo concreto (ej. "así se ve un `creditRequest` recién creado y así queda después de mi paso").
- **Ronda 2 — Reconstrucción del flujo end-to-end:** entre los 5, narran en orden un caso completo:
  *registro B2B de una empresa (A) → aprobación admin (D) → creación y envío de solicitud (B) → asignación de auditor (D) → auditoría y conclusión (C) → certificación (C) → valorización y publicación (D) → seguro asociado (D) → la empresa ve el estado actualizado en su dashboard (E)*.
- **Ronda 3 — Pizarra del schema Firestore:** entre todos arman en una pizarra/doc compartido el esquema completo de `users`, `creditRequests`, `audits` y subcolecciones de Storage, marcando quién lee y quién escribe cada campo. Esto valida que no quedaron huecos de comprensión entre áreas.
