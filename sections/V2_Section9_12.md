---

# SECTION 9 — Règles de validation (corrigées — 2 couches)

## 9.1 Couche 1 — Validation de schéma (rejet API immédiat)

### Champs required (structure)

| Champ | Règle | Si absent |
|-------|-------|----------|
| `reportDetails` | Objet required | Rejet 400 |
| `reportDetails.reportTypeCode` | integer required | Rejet 400 |
| `reportDetails.submitTypeCode` | integer required | Rejet 400 |
| `reportDetails.reportingEntityNumber` | number required | Rejet 400 |
| `reportDetails.submittingReportingEntityNumber` | number required | Rejet 400 |
| `reportDetails.reportingEntityReportReference` | string required | Rejet 400 |
| `reportDetails.reportingEntityContactId` | number required | Rejet 400 |
| `detailsOfSuspicion` | Objet required | Rejet 400 |
| `detailsOfSuspicion.publicPrivatePartnershipProjectNameCodes` | integer[] required | Rejet 400 |
| `relatedReports` | array required | Rejet 400 |
| `definitions` | array required | Rejet 400 |
| `transactions` | array minItems:1 | Rejet 400 |

### Arrays required (même si vides)

| Array | Parent | Si absent |
|-------|--------|----------|
| `virtualCurrencyTransactionIds` | SA/CA details | Rejet 400 |
| `sendingVirtualCurrencyAddresses` | SA/CA details | Rejet 400 |
| `receivingVirtualCurrencyAddresses` | SA/CA details | Rejet 400 |
| `sourcesOfFundsOrVirtualCurrency` | startingAction | Rejet 400 |
| `conductors` | startingAction | Rejet 400 |
| `onBehalfOfs` | conductor | Rejet 400 |
| `involvements` | completingAction | Rejet 400 |
| `beneficiaries` | completingAction | Rejet 400 |

### Patterns et formats

| Champ | Pattern | Type |
|-------|---------|------|
| `reportingEntityReportReference` | `^[A-Za-z0-9-_]{1,100}$` | string |
| `reportingEntityTransactionReference` | `^[A-Za-z0-9-_]{1,200}$` | string |
| `refId` | `^[A-Za-z0-9-_]{1,50}$` | string |
| `amount`, `exchangeRate`, `valueInCanadianDollars` | `^\d{1,17}(\.\d{2,10})?$` | **string** |
| `dateOfTransaction`, `dateOfBirth`, etc. | `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` | string |
| `timeOfTransaction` | `^[0-9]{2}:[0-9]{2}:[0-9]{2}[\-\+][0-9]{2}:[0-9]{2}$` | string |

### additionalProperties: false

Tout champ non déclaré dans le YAML → rejet 400.

## 9.2 Couche 2 — Validation business (guidance Annex A)

### Champs mandatory (*) selon la guidance

| Champ | Guidance | Impact |
|-------|----------|--------|
| `descriptionOfSuspiciousActivity` | Mandatory | Rejet par business rules |
| `suspicionTypeCode` | Mandatory sauf directive | Rejet par business rules |
| `activitySectorCode` | Mandatory | Rejet par business rules |
| `actionTaken.description` | Mandatory sauf directive | Rejet par business rules |
| `attemptedTransactionIndicator` | Mandatory | ✅ aussi required schéma |

### Cohérence inter-champs

| Règle | Condition |
|-------|-----------|
| Si `attemptedIndicator = true` | `reasonNotCompleted` attendu |
| Si `ministerialDirectiveCode` renseigné | 1 seule txn, pas de suspicion |
| Si `conductorIndicator = true` | `conductors[]` doit avoir ≥ 1 entry |
| Si `onBehalfOfIndicator = true` | `onBehalfOfs[]` doit avoir ≥ 1 entry |
| Si `beneficiaryIndicator = true` | `beneficiaries[]` doit avoir ≥ 1 entry |
| Si `involvementIndicator = true` | `involvements[]` doit avoir ≥ 1 entry |
| Si `sourcesOfFundsOrVirtualCurrencyIndicator = true` | `sourcesOfFundsOrVirtualCurrency[]` ≥ 1 |
| refId dans conductors/beneficiaries/etc. | Doit exister dans `definitions[]` |
| `direction = 1` | fundType limité à [1,2,3,4,5,6,8,9,10,11,12,13,14,16,17] |
| `direction = 2` | fundType limité à [3,7,9,16,17] |

### Doublons

| Contrôle | Portée |
|----------|--------|
| `reportingEntityReportReference` | Unicité **globale** (jamais réutilisé) |
| `refId` dans definitions | Unique dans le rapport |
| `reportingEntityTransactionReference` | Unique dans le rapport |

---

# SECTION 10 — Architecture cible

```
┌─────────────────────────────────────────────────────────┐
│              SYSTÈME AML / CASE MANAGEMENT              │
└──────────────────────┬──────────────────────────────────┘
                       │ Décision: soumettre STR
                       ▼
┌─────────────────────────────────────────────────────────┐
│            COUCHE EXTRACTION / MAPPING                  │
│  - Extract des données du case AML                      │
│  - Mapping vers modèle cible STR (34 tables)            │
│  - Enrichissement KYC, comptes, identifications         │
│  - Rédaction narratif                                    │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│               BASE DE DONNÉES CIBLE STR                 │
│  34 tables normalisées (Section 4)                      │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│   MOTEUR DE VALIDATION (2 couches — Section 9)          │
│  1. Schéma: required, patterns, types, additionalProp   │
│  2. Business: mandatory, cohérence, refId lookup         │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│               GÉNÉRATEUR JSON                           │
│  - Assemblage bottom-up (Section 6)                     │
│  - Arrays vides required: toujours émis []              │
│  - amount/exchangeRate en STRING                        │
│  - reportingEntityNumber en NUMBER                      │
│  - additionalProperties: false respecté                 │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│              CLIENT API CANAFE                          │
│  - OAuth2 Bearer token                                  │
│  - POST /api/v1/reports                                 │
│  - TLS, timeout, retry backoff                          │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│            JOURNALISATION & AUDIT                       │
│  - STR_API_SUBMISSION (statut, HTTP code, réponse)      │
│  - STR_SUBMITTED_PAYLOAD (JSON + SHA-256)               │
│  - STR_VALIDATION_ERROR (instancePath, message)         │
│  - STR_AUDIT_EVENT (trace chaque action)                │
└─────────────────────────────────────────────────────────┘
```

---

# SECTION 11 — Recommandations d'implémentation

## 11.1 Types de données critiques

| Aspect | Recommandation |
|--------|---------------|
| `amount`, `exchangeRate`, `valueInCanadianDollars` | **Stocker en VARCHAR(28)** — le YAML les définit comme strings avec regex. Utiliser DECIMAL en interne pour les calculs mais sérialiser en string pour le JSON |
| `reportingEntityNumber`, `reportingEntityContactId` | **Stocker en NUMERIC** — le YAML les définit comme `type: number` |
| Dates | **VARCHAR(10)** pour fidélité au format `YYYY-MM-DD` |
| Times | **VARCHAR(25)** pour le format avec timezone |

## 11.2 Gestion de `additionalProperties: false`

- Le générateur JSON ne doit **jamais** émettre de champs non déclarés
- Tester avec un validateur JSON Schema avant soumission
- Tout champ interne (status, created_at, etc.) est **exclu** du JSON

## 11.3 Pattern required arrays vides

Le générateur doit implémenter une règle : si un array required n'a pas de données, émettre `[]`. Ne jamais omettre le champ.

## 11.4 Conservation et audit

- **5 ans minimum** après soumission
- Copie immuable du JSON soumis (STR_SUBMITTED_PAYLOAD)
- Hash SHA-256 pour non-répudiation
- Ne jamais supprimer physiquement — utiliser `status = ARCHIVED`

## 11.5 Gestion des corrections

- `submitTypeCode = 2` (Update) : renvoyer le rapport **complet**
- Délai : **20 jours** après notification d'erreur
- Journaliser la raison de correction dans STR_AUDIT_EVENT

## 11.6 Environnement de test

- CANAFE fournit un **Report Ingest Test API**
- Contact technique : `tech@fintrac-canafe.gc.ca`
- Accès portail API : `F2R@fintrac-canafe.gc.ca`
- Téléphone : 1-866-346-8722

---

# SECTION 12 — Zones à confirmer avec CANAFE

| # | Élément | Question |
|---|---------|----------|
| 1 | `activitySectorCode` | Pas dans required du schéma — confirmé obligatoire par business rules ? |
| 2 | `descriptionOfSuspiciousActivity` | Idem — max length ? (pas de maxLength dans le YAML) |
| 3 | `actionTaken.description` | Max length ? |
| 4 | `completingActions` minimum | Required vide OK même pour transaction non-tentée ? |
| 5 | Rate limiting API | Combien de soumissions par minute ? |
| 6 | Taille max payload | Limite en Ko/Mo ? |
| 7 | `submitTypeCode = 2` | Rapport complet ou delta ? |
| 8 | `submitTypeCode = 5` | Conditions de suppression ? |
| 9 | Mutual TLS | Requis ou simple HTTPS ? |
| 10 | Idempotence | Même `reportingEntityReportReference` soumis 2x → erreur ou écrasement ? |
| 11 | `reportingEntityContactId` | Comment obtenir cet ID numérique ? |
| 12 | PersonDetails (tc3) `nameOfEmployer` | Champ plat dans tc3 vs objet imbriqué dans tc5 — confirmé ? |
| 13 | `virtualCurrencyTypeCode` | Enum complet non visible publiquement — à obtenir dans le portail |
| 14 | `CurrencyCode` | ISO 4217 complet ou sous-ensemble CANAFE ? |
| 15 | `ProvinceStateCode` | Liste exacte des codes provinciaux acceptés ? |

---

**FIN DU DOCUMENT V2**

*34 tables • 12 sections • Corrigé selon swaggerExternal.yaml officiel (6 883 lignes)*
