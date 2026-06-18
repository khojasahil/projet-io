# Modèle de données cible — STRReport CANAFE (Suspicious Transaction Report)

## Document d'architecture pour la soumission de déclarations d'opérations douteuses via l'API d'ingestion CANAFE

**Version :** 1.0  
**Date :** 2026-06-16  
**Sources analysées :**
- Swagger officiel : `https://www148.fintrac-canafe.canada.ca/swagger`
- YAML externe : `https://www148.fintrac-canafe.canada.ca/reporting-ingest/api-doc-files/swaggerExternal.yaml`
- Guidance STR officielle : `https://fintrac-canafe.canada.ca/guidance-directives/transaction-operation/str-dod/str-dod-eng`
- Annex A — Field instructions to complete a Suspicious Transaction Report

---

# SECTION 1 — Résumé exécutif

## 1.1 Qu'est-ce qu'un STRReport ?

Un **STRReport** (Suspicious Transaction Report / Déclaration d'opérations douteuses — DOD) est un rapport réglementaire qu'une entité déclarante canadienne doit soumettre au Centre d'analyse des opérations et déclarations financières du Canada (**CANAFE / FINTRAC**) lorsqu'elle a des **motifs raisonnables de soupçonner** qu'une transaction financière est liée au blanchiment d'argent, au financement d'activités terroristes, ou à l'évasion de sanctions.

Le code de type de rapport dans l'API est **`reportTypeCode = 102`**.

## 1.2 Pourquoi une banque doit-elle soumettre des STR ?

- **Obligation légale** : Loi sur le recyclage des produits de la criminalité et le financement des activités terroristes (LRPCFAT), article 7
- **Pénalités** : Non-conformité = sanctions administratives ou pénales
- **Aucun seuil monétaire** : Contrairement aux LCTR ($10 000+), un STR peut concerner tout montant
- **Délai** : Dès que praticable après avoir complété les mesures d'évaluation
- Depuis **août 2024**, l'obligation couvre aussi l'évasion de sanctions

## 1.3 Ce que l'API CANAFE attend

L'API d'ingestion CANAFE (`POST /api/v1/reports`) attend un **payload JSON** structuré conforme au schéma **STRReport** exposé dans le Swagger. Ce payload contient :

| Élément | Description |
|---------|-------------|
| `reportDetails` | Métadonnées du rapport (entité déclarante, références, secteur d'activité) |
| `detailsOfSuspicion` | Narratif de suspicion, type de suspicion, indicateurs PEP |
| `relatedReports[]` | Références à des rapports précédemment soumis |
| `actionTaken` | Description des mesures prises |
| `definitions[]` | Catalogue polymorphe des personnes et entités (noms, détails, employeurs, beneficial ownership) |
| `transactions[]` | Transactions suspectes avec startingActions[] et completingActions[] |

## 1.4 Différence entre un dossier AML interne et un STRReport CANAFE

| Aspect | Dossier AML interne (Case) | STRReport CANAFE |
|--------|---------------------------|------------------|
| **Portée** | Tout le cycle d'investigation | Uniquement le payload de déclaration |
| **Contenu** | Notes internes, scores, alertes, workflow | Données structurées + narratif |
| **Format** | Propriétaire (base relationnelle interne) | JSON normé selon schéma OpenAPI CANAFE |
| **Destinataire** | Équipe conformité interne | CANAFE via API ou FWR |
| **Conservation** | Politiques internes | Copie 5 ans minimum (obligation légale) |
| **Confidentialité** | Ne pas révéler au client (tipping off interdit) | Idem |

## 1.5 Périmètre du modèle cible proposé

Ce document couvre **exclusivement** le modèle de données nécessaire pour :
1. **Stocker** les données cibles alimentant le JSON STRReport
2. **Valider** la conformité des données avant soumission
3. **Générer** le payload JSON conforme au schéma CANAFE
4. **Soumettre** via l'API (`POST /api/v1/reports`)
5. **Auditer** les soumissions (journalisation, réponses API, corrections)

> **Hors périmètre** : Modèle source bancaire, case management AML, scoring de risque, workflow d'investigation.

---

# SECTION 2 — Compréhension fonctionnelle du STRReport

## 2.1 General Information / Métadonnées du rapport (`reportDetails`)

**Rôle :** Identifie l'entité déclarante, le type de rapport, le secteur d'activité et les références uniques.

**Pourquoi CANAFE en a besoin :** Permet de router, valider et tracer le rapport. Le `reportingEntityReportReference` est l'identifiant unique du côté de l'entité déclarante.

**Champs clés observés dans le Swagger :**

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `reportTypeCode` | integer | ✅ Oui | Toujours `102` pour STR |
| `submitTypeCode` | integer | ✅ Oui | `1`=Submit, `2`=Update, `5`=Delete |
| `activitySectorCode` | integer | Oui | Secteur : `2`=Banque, `14`=Credit Union, etc. |
| `reportingEntityNumber` | string | ✅ Oui | Numéro CANAFE à 7 chiffres |
| `submittingReportingEntityNumber` | string | ✅ Oui | Si soumis par un tiers |
| `reportingEntityReportReference` | string | ✅ Oui | Référence unique (pattern: `^[A-Za-z0-9-_]{1,100}$`) |
| `reportingEntityContactId` | string | ✅ Oui | Contact pour suivi CANAFE |
| `ministerialDirectiveCode` | string | Non | Ex: `IR2020` |

**Pièges de modélisation :**
- Le `reportingEntityReportReference` doit être **globalement unique** dans votre organisation — jamais réutilisé
- Si `ministerialDirectiveCode` est renseigné, le rapport ne peut contenir qu'**une seule transaction** complétée et les sections `detailsOfSuspicion` et `actionTaken` ne doivent **pas** être remplies
- Le `submitTypeCode` contrôle si c'est une soumission initiale, une correction ou une suppression

## 2.2 Détails de suspicion (`detailsOfSuspicion`)

**Rôle :** Section narrative et structurée décrivant les motifs de suspicion.

**Pourquoi CANAFE en a besoin :** C'est la section la plus critique — elle est partagée avec les forces de l'ordre dans les divulgations CANAFE.

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `descriptionOfSuspiciousActivity` | string | Oui* | Narratif libre décrivant faits, contexte, indicateurs |
| `suspicionTypeCode` | integer | Oui | Enum: `1`-`7` (voir ci-dessous) |
| `publicPrivatePartnershipProjectNameCodes` | integer[] | Non | Codes projet PPP |
| `politicallyExposedPersonIncludedIndicator` | boolean | Non | Le rapport inclut-il un PEP ? |

**Valeurs `suspicionTypeCode` :**

| Code | Signification |
|------|--------------|
| 1 | Blanchiment d'argent |
| 2 | Financement du terrorisme |
| 3 | Blanchiment d'argent ET financement du terrorisme |
| 4 | Évasion de sanctions |
| 5 | Blanchiment d'argent ET évasion de sanctions |
| 6 | Financement du terrorisme ET évasion de sanctions |
| 7 | Blanchiment, financement du terrorisme ET évasion de sanctions |

**Valeurs `publicPrivatePartnershipProjectNameCodes` :**

| Code | Projet |
|------|--------|
| 1 | ANTON |
| 2 | ATHENA |
| 3 | CHAMELEON |
| 5 | GUARDIAN |
| 6 | LEGION |
| 7 | PROTECT |
| 8 | SHADOW |

**Pièges :**
- Le narratif ne doit **pas** contenir d'acronymes internes, de références à des dossiers internes, ni de mise en forme (gras, italique)
- Doit être **cohérent** avec les champs structurés du rapport
- Ne doit **pas** être complété si le rapport est soumis sous directive ministérielle

## 2.3 Rapports liés (`relatedReports[]`)

**Rôle :** Références à des STR précédemment soumis relatifs à la même activité suspecte.

| Champ | Type | Requis |
|-------|------|--------|
| `reportingEntityReportReference` | string | ✅ Oui |
| `reportingEntityTransactionReferences` | string[] | Non |

**Pourquoi :** Permet à CANAFE de lier les analyses et construire des dossiers plus complets.

## 2.4 Mesures prises (`actionTaken`)

**Rôle :** Description des actions entreprises ou prévues suite à la transaction suspecte.

| Champ | Type | Description |
|-------|------|-------------|
| `description` | string | Texte libre (ex: monitoring renforcé, fermeture de compte, signalement aux forces de l'ordre) |

## 2.5 Définitions des parties (`definitions[]`)

**Rôle :** Catalogue centralisé et polymorphe de toutes les personnes et entités référencées dans le rapport.

C'est un **design pattern de référencement** : chaque personne/entité est définie une seule fois dans `definitions[]` avec un `refId` unique, puis référencée par ce `refId` dans les transactions (conductors, beneficiaries, onBehalfOfs, etc.).

**Types polymorphes (via `typeCode`) :**

| typeCode | Type | Description |
|----------|------|-------------|
| 1 | PersonName | Nom d'une personne (surname, givenName, otherInitial) |
| 2 | EntityName | Nom d'une entité |
| 3 | PersonDetails | Détails complets d'une personne (adresse, téléphone, email, DOB, occupation, identifications) |
| 4 | EntityDetails | Détails complets d'une entité (adresse, structure, incorporation, directors, beneficial owners) |
| 5 | PersonAndEmployerDetails | Personne avec info employeur |
| 6 | EntityAndBeneficialOwnershipDetails | Entité avec structure de propriété effective |

**Pièges critiques :**
- Le `refId` doit être unique au sein du rapport
- Une même personne physique avec différents rôles (conducteur + bénéficiaire) peut utiliser le **même refId**
- Les `typeCode` acceptés varient selon le contexte d'utilisation (conductors n'acceptent que 5/6, beneficiaries n'acceptent que 3/4, etc.)

## 2.6 Transactions (`transactions[]`)

**Rôle :** Cœur du rapport — contient les détails de chaque transaction suspecte.

Un STR peut contenir **plusieurs transactions**. Chaque transaction contient :

### 2.6.1 Métadonnées de transaction (`suspiciousTransactionDetails`)

| Champ | Type | Requis |
|-------|------|--------|
| `attemptedTransactionIndicator` | boolean | ✅ Oui |
| `reasonNotCompleted` | string(200) | Si tentée |
| `dateOfTransaction` | date | †Conditionnel |
| `timeOfTransaction` | zonedTime | Non |
| `methodCode` | integer | Oui* |
| `methodOther` | string(200) | Si method=7 |
| `dateOfPosting` | date | Conditionnel |
| `reportingEntityTransactionReference` | string | ‡Processing |
| `purposeOfTransaction` | string | Non |

**Valeurs `methodCode` :**

| Code | Méthode |
|------|---------|
| 1 | En personne |
| 2 | ABM/GAB |
| 3 | Dépôt blindé |
| 4 | Correspondant bancaire |
| 5 | Courrier |
| 6 | Dépôt de nuit |
| 7 | Autre |
| 8 | Quick drop |
| 9 | Téléphone |
| 10 | Télécopieur |
| 11 | GAB monnaie virtuelle |
| 12 | En ligne |

### 2.6.2 Actions de départ (`startingActions[]`)

Chaque transaction a au moins 1 starting action. Contient :

- **`details`** : direction (in/out), type de fonds, montant, devise, comptes, adresses VC
- **`sourcesOfFundsOrVirtualCurrency[]`** : source des fonds (personne/entité)
- **`conductors[]`** : qui effectue la transaction, avec info device, et `onBehalfOfs[]` (tiers mandants)

**Valeurs `fundAssetVirtualCurrencyTypeCode` (direction IN) :**

| Code | Type |
|------|------|
| 1 | Traite bancaire |
| 2 | Espèces |
| 3 | Produit de casino |
| 4 | Chèque |
| 5 | Transfert de fonds domestique |
| 6 | Virement email (EMT) |
| 7 | Transfert de fonds international |
| 8 | Produit d'investissement |
| 9 | Bijoux |
| 10 | Transfert mobile |
| 11 | Mandat |
| 12 | Métaux précieux |
| 13 | Pierres précieuses |
| 14 | Transfert de fonds domestique (entrant) |
| 15 | Transfert de fonds international (entrant) |
| 16 | Monnaie virtuelle |
| 17 | Autre |

### 2.6.3 Actions de complétion (`completingActions[]`)

Décrivent la disposition des fonds. Contiennent :

- **`details`** : dispositionCode, montant, devise, comptes, adresses VC
- **`involvements[]`** : autres personnes/entités impliquées
- **`beneficiaries[]`** : bénéficiaires

**Valeurs `dispositionCode` (sélection) :**

| Code | Disposition |
|------|------------|
| 1 | Dépôt au compte |
| 2 | Échange en monnaie virtuelle |
| 3 | Échange en devise fiduciaire |
| 4 | Transfert international sortant |
| 5 | Transfert domestique sortant |
| 6 | Achat de traite bancaire |
| 7 | Achat de mandat |
| 8 | Achat de bijoux |
| 9 | Achat de métaux précieux |
| 10 | Décaissement (cash out) |
| 11 | Ajout au portefeuille VC |
| 12 | Change de dénomination |
| 13 | Rétention de fonds |
| 14 | Achat d'investissement |
| 15 | Achat d'assurance vie |
| 16 | Émission de chèque |
| 17 | EMT sortant |
| 18 | Transfert mobile sortant |
| 19 | Transfert VC sortant |
| 20 | Paiement au compte |
| 21 | Achat de pierres précieuses |
| 22 | Achat prépayé |
| 23 | Achat immobilier |
| 24 | Achat de biens |
| 25 | Achat de services |
| 26-31 | (Autres dispositions) |
| 32 | Retrait d'espèces (compte) |

## 2.7 Localisation de la transaction

Chaque transaction est liée à un emplacement via `reportingEntityLocationId` — un identifiant de localisation créé lors de l'enrôlement dans CANAFE FWR.

## 2.8 Comptes (`strAccount` dans starting/completing actions)

Les comptes sont intégrés dans les starting et completing actions avec :
- `financialInstitutionNumber`, `branchNumber`, `accountNumber`
- `accountType`, `accountCurrency`, `accountVirtualCurrencyType`
- `dateAccountOpened`, `dateAccountClosed`
- `accountStatusAtTimeOfTransaction`
- Account holders (personne ou entité)

## 2.9 Instruments de monnaie virtuelle

Les transactions impliquant la monnaie virtuelle incluent :
- `virtualCurrencyTransactionIds[]`
- `sendingVirtualCurrencyAddresses[]`
- `receivingVirtualCurrencyAddresses[]`
- `virtualCurrencyTypeCode`

---

# SECTION 3 — Structure logique du payload STRReport

Structure JSON reconstituée fidèlement à partir du schéma Swagger observé :

```
STRReport
├── reportDetails (required)
│   ├── reportTypeCode* (102)
│   ├── submitTypeCode* (1|2|5)
│   ├── activitySectorCode
│   ├── reportingEntityNumber*
│   ├── submittingReportingEntityNumber*
│   ├── reportingEntityReportReference*
│   ├── reportingEntityContactId*
│   └── ministerialDirectiveCode
│
├── detailsOfSuspicion
│   ├── descriptionOfSuspiciousActivity
│   ├── suspicionTypeCode (1-7)
│   ├── publicPrivatePartnershipProjectNameCodes[]
│   └── politicallyExposedPersonIncludedIndicator
│
├── relatedReports[]
│   ├── reportingEntityReportReference*
│   └── reportingEntityTransactionReferences[]
│
├── actionTaken
│   └── description
│
├── definitions[] (polymorphic: OneOf)
│   ├── typeCode* (1=PersonName|2=EntityName|3=PersonDetails|4=EntityDetails|5=PersonAndEmployer|6=EntityAndBO)
│   ├── refId* (unique string)
│   └── details (varies by typeCode)
│       ├── [PersonName]: surname, givenName, otherInitial
│       ├── [EntityName]: entityName
│       ├── [PersonDetails]: name, alias, address, phone, email, DOB,
│       │   countryOfResidence, countryOfCitizenship, occupation,
│       │   employer, identifications[]
│       ├── [EntityDetails]: entityName, address, phone, email, URL,
│       │   entityStructureType, principalBusiness, incorporation[],
│       │   registration[], identifications[], personsAuthorized[]
│       ├── [PersonAndEmployer]: personDetails + employerDetails
│       │   (address, phone)
│       └── [EntityAndBO]: entityDetails + beneficialOwnership
│           (directors[], owners25pct[], trustees[], settlors[],
│            trustBeneficiaries[])
│
└── transactions[] (required, array)
    ├── reportingEntityLocationId* (string30)
    ├── suspiciousTransactionDetails* (required)
    │   ├── attemptedTransactionIndicator* (boolean)
    │   ├── reasonNotCompleted (string200)
    │   ├── dateOfTransaction (date)
    │   ├── timeOfTransaction (zonedTime)
    │   ├── methodCode (enum 1-12)
    │   ├── methodOther (string200)
    │   ├── dateOfPosting (date)
    │   ├── timeOfPosting (zonedTime)
    │   ├── reportingEntityTransactionReference‡
    │   └── purposeOfTransaction
    │
    ├── startingActions[] (required, array)
    │   ├── details* (required)
    │   │   ├── direction (1=In|2=Out)
    │   │   ├── fundAssetVirtualCurrencyTypeCode (enum 1-17)
    │   │   ├── fundAssetVirtualCurrencyTypeOther
    │   │   ├── amount* (number)
    │   │   ├── currencyCode
    │   │   ├── currencyOther
    │   │   ├── virtualCurrencyTypeCode
    │   │   ├── virtualCurrencyTypeOther
    │   │   ├── exchangeRate
    │   │   ├── virtualCurrencyTransactionIds[]
    │   │   ├── sendingVirtualCurrencyAddresses[]
    │   │   ├── receivingVirtualCurrencyAddresses[]
    │   │   ├── referenceNumber
    │   │   ├── otherReferenceNumber
    │   │   ├── account (strAccount)
    │   │   │   ├── financialInstitutionNumber
    │   │   │   ├── branchNumber
    │   │   │   ├── accountNumber
    │   │   │   ├── accountType / accountTypeOther
    │   │   │   ├── accountCurrency / accountCurrencyOther
    │   │   │   ├── accountVirtualCurrencyType / Other
    │   │   │   ├── dateAccountOpened / dateAccountClosed
    │   │   │   └── accountHolders[] (typeCode 1|2, refId)
    │   │   ├── accountStatusAtTimeOfTransaction
    │   │   ├── howFundsOrVirtualCurrencyObtained
    │   │   ├── sourcesOfFundsOrVirtualCurrencyIndicator‡
    │   │   └── conductorIndicator‡
    │   │
    │   ├── sourcesOfFundsOrVirtualCurrency[]
    │   │   ├── typeCode* (1=Person|2=Entity)
    │   │   ├── refId*
    │   │   └── details (accountNumber, policyNumber, identifyingNumber)
    │   │
    │   └── conductors[]
    │       ├── typeCode* (5=PersonAndEmployer|6=EntityAndBO)
    │       ├── refId*
    │       ├── details
    │       │   ├── clientNumber
    │       │   ├── typeOfDeviceCode (1=Computer|2=Mobile|3=Tablet|4=Other)
    │       │   ├── typeOfDeviceOther
    │       │   ├── username
    │       │   ├── deviceIdentifierNumber
    │       │   ├── internetProtocolAddress
    │       │   ├── dateTimeOfOnlineSession
    │       │   └── onBehalfOfIndicator‡
    │       └── onBehalfOfs[]
    │           ├── typeCode* (5|6)
    │           ├── refId*
    │           └── details
    │               ├── clientNumber
    │               ├── relationshipOfConductorCode (enum 1-14)
    │               ├── relationshipOfConductorOther
    │               └── [device info fields]
    │
    └── completingActions[] (required, array)
        ├── details* (required)
        │   ├── dispositionCode (enum 1-32)
        │   ├── dispositionOther
        │   ├── amount
        │   ├── currencyCode / virtualCurrencyTypeCode
        │   ├── exchangeRate
        │   ├── valueInCanadianDollars
        │   ├── virtualCurrencyTransactionIds[]
        │   ├── sendingVirtualCurrencyAddresses[]
        │   ├── receivingVirtualCurrencyAddresses[]
        │   ├── referenceNumber / otherReferenceNumber
        │   ├── account (strAccount)
        │   ├── accountStatusAtTimeOfTransaction
        │   ├── involvementIndicator‡
        │   └── beneficiaryIndicator‡
        │
        ├── involvements[]
        │   ├── typeCode* (1=PersonName|2=EntityName)
        │   ├── refId*
        │   └── details (accountNumber, policyNumber, identifyingNumber)
        │
        └── beneficiaries[]
            ├── typeCode* (3=PersonDetails|4=EntityDetails)
            ├── refId*
            └── details (clientNumber, username, emailAddress)
```

**Légende :**
- `*` = Requis (required dans le schéma OpenAPI)
- `‡` = Mandatory for processing
- `†` = Mandatory if applicable
- Pas de symbole = Reasonable measures / optionnel

