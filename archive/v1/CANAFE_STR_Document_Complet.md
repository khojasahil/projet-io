# ModÃ¨le de donnÃ©es cible â€” STRReport CANAFE (Suspicious Transaction Report)

## Document d'architecture pour la soumission de dÃ©clarations d'opÃ©rations douteuses via l'API d'ingestion CANAFE

**Version :** 1.0  
**Date :** 2026-06-16  
**Sources analysÃ©es :**
- Swagger officiel : `https://www148.fintrac-canafe.canada.ca/swagger`
- YAML externe : `https://www148.fintrac-canafe.canada.ca/reporting-ingest/api-doc-files/swaggerExternal.yaml`
- Guidance STR officielle : `https://fintrac-canafe.canada.ca/guidance-directives/transaction-operation/str-dod/str-dod-eng`
- Annex A â€” Field instructions to complete a Suspicious Transaction Report

---

# SECTION 1 â€” RÃ©sumÃ© exÃ©cutif

## 1.1 Qu'est-ce qu'un STRReport ?

Un **STRReport** (Suspicious Transaction Report / DÃ©claration d'opÃ©rations douteuses â€” DOD) est un rapport rÃ©glementaire qu'une entitÃ© dÃ©clarante canadienne doit soumettre au Centre d'analyse des opÃ©rations et dÃ©clarations financiÃ¨res du Canada (**CANAFE / FINTRAC**) lorsqu'elle a des **motifs raisonnables de soupÃ§onner** qu'une transaction financiÃ¨re est liÃ©e au blanchiment d'argent, au financement d'activitÃ©s terroristes, ou Ã  l'Ã©vasion de sanctions.

Le code de type de rapport dans l'API est **`reportTypeCode = 102`**.

## 1.2 Pourquoi une banque doit-elle soumettre des STR ?

- **Obligation lÃ©gale** : Loi sur le recyclage des produits de la criminalitÃ© et le financement des activitÃ©s terroristes (LRPCFAT), article 7
- **PÃ©nalitÃ©s** : Non-conformitÃ© = sanctions administratives ou pÃ©nales
- **Aucun seuil monÃ©taire** : Contrairement aux LCTR ($10 000+), un STR peut concerner tout montant
- **DÃ©lai** : DÃ¨s que praticable aprÃ¨s avoir complÃ©tÃ© les mesures d'Ã©valuation
- Depuis **aoÃ»t 2024**, l'obligation couvre aussi l'Ã©vasion de sanctions

## 1.3 Ce que l'API CANAFE attend

L'API d'ingestion CANAFE (`POST /api/v1/reports`) attend un **payload JSON** structurÃ© conforme au schÃ©ma **STRReport** exposÃ© dans le Swagger. Ce payload contient :

| Ã‰lÃ©ment | Description |
|---------|-------------|
| `reportDetails` | MÃ©tadonnÃ©es du rapport (entitÃ© dÃ©clarante, rÃ©fÃ©rences, secteur d'activitÃ©) |
| `detailsOfSuspicion` | Narratif de suspicion, type de suspicion, indicateurs PEP |
| `relatedReports[]` | RÃ©fÃ©rences Ã  des rapports prÃ©cÃ©demment soumis |
| `actionTaken` | Description des mesures prises |
| `definitions[]` | Catalogue polymorphe des personnes et entitÃ©s (noms, dÃ©tails, employeurs, beneficial ownership) |
| `transactions[]` | Transactions suspectes avec startingActions[] et completingActions[] |

## 1.4 DiffÃ©rence entre un dossier AML interne et un STRReport CANAFE

| Aspect | Dossier AML interne (Case) | STRReport CANAFE |
|--------|---------------------------|------------------|
| **PortÃ©e** | Tout le cycle d'investigation | Uniquement le payload de dÃ©claration |
| **Contenu** | Notes internes, scores, alertes, workflow | DonnÃ©es structurÃ©es + narratif |
| **Format** | PropriÃ©taire (base relationnelle interne) | JSON normÃ© selon schÃ©ma OpenAPI CANAFE |
| **Destinataire** | Ã‰quipe conformitÃ© interne | CANAFE via API ou FWR |
| **Conservation** | Politiques internes | Copie 5 ans minimum (obligation lÃ©gale) |
| **ConfidentialitÃ©** | Ne pas rÃ©vÃ©ler au client (tipping off interdit) | Idem |

## 1.5 PÃ©rimÃ¨tre du modÃ¨le cible proposÃ©

Ce document couvre **exclusivement** le modÃ¨le de donnÃ©es nÃ©cessaire pour :
1. **Stocker** les donnÃ©es cibles alimentant le JSON STRReport
2. **Valider** la conformitÃ© des donnÃ©es avant soumission
3. **GÃ©nÃ©rer** le payload JSON conforme au schÃ©ma CANAFE
4. **Soumettre** via l'API (`POST /api/v1/reports`)
5. **Auditer** les soumissions (journalisation, rÃ©ponses API, corrections)

> **Hors pÃ©rimÃ¨tre** : ModÃ¨le source bancaire, case management AML, scoring de risque, workflow d'investigation.

---

# SECTION 2 â€” ComprÃ©hension fonctionnelle du STRReport

## 2.1 General Information / MÃ©tadonnÃ©es du rapport (`reportDetails`)

**RÃ´le :** Identifie l'entitÃ© dÃ©clarante, le type de rapport, le secteur d'activitÃ© et les rÃ©fÃ©rences uniques.

**Pourquoi CANAFE en a besoin :** Permet de router, valider et tracer le rapport. Le `reportingEntityReportReference` est l'identifiant unique du cÃ´tÃ© de l'entitÃ© dÃ©clarante.

**Champs clÃ©s observÃ©s dans le Swagger :**

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `reportTypeCode` | integer | âœ… Oui | Toujours `102` pour STR |
| `submitTypeCode` | integer | âœ… Oui | `1`=Submit, `2`=Update, `5`=Delete |
| `activitySectorCode` | integer | Oui | Secteur : `2`=Banque, `14`=Credit Union, etc. |
| `reportingEntityNumber` | string | âœ… Oui | NumÃ©ro CANAFE Ã  7 chiffres |
| `submittingReportingEntityNumber` | string | âœ… Oui | Si soumis par un tiers |
| `reportingEntityReportReference` | string | âœ… Oui | RÃ©fÃ©rence unique (pattern: `^[A-Za-z0-9-_]{1,100}$`) |
| `reportingEntityContactId` | string | âœ… Oui | Contact pour suivi CANAFE |
| `ministerialDirectiveCode` | string | Non | Ex: `IR2020` |

**PiÃ¨ges de modÃ©lisation :**
- Le `reportingEntityReportReference` doit Ãªtre **globalement unique** dans votre organisation â€” jamais rÃ©utilisÃ©
- Si `ministerialDirectiveCode` est renseignÃ©, le rapport ne peut contenir qu'**une seule transaction** complÃ©tÃ©e et les sections `detailsOfSuspicion` et `actionTaken` ne doivent **pas** Ãªtre remplies
- Le `submitTypeCode` contrÃ´le si c'est une soumission initiale, une correction ou une suppression

## 2.2 DÃ©tails de suspicion (`detailsOfSuspicion`)

**RÃ´le :** Section narrative et structurÃ©e dÃ©crivant les motifs de suspicion.

**Pourquoi CANAFE en a besoin :** C'est la section la plus critique â€” elle est partagÃ©e avec les forces de l'ordre dans les divulgations CANAFE.

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `descriptionOfSuspiciousActivity` | string | Oui* | Narratif libre dÃ©crivant faits, contexte, indicateurs |
| `suspicionTypeCode` | integer | Oui | Enum: `1`-`7` (voir ci-dessous) |
| `publicPrivatePartnershipProjectNameCodes` | integer[] | Non | Codes projet PPP |
| `politicallyExposedPersonIncludedIndicator` | boolean | Non | Le rapport inclut-il un PEP ? |

**Valeurs `suspicionTypeCode` :**

| Code | Signification |
|------|--------------|
| 1 | Blanchiment d'argent |
| 2 | Financement du terrorisme |
| 3 | Blanchiment d'argent ET financement du terrorisme |
| 4 | Ã‰vasion de sanctions |
| 5 | Blanchiment d'argent ET Ã©vasion de sanctions |
| 6 | Financement du terrorisme ET Ã©vasion de sanctions |
| 7 | Blanchiment, financement du terrorisme ET Ã©vasion de sanctions |

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

**PiÃ¨ges :**
- Le narratif ne doit **pas** contenir d'acronymes internes, de rÃ©fÃ©rences Ã  des dossiers internes, ni de mise en forme (gras, italique)
- Doit Ãªtre **cohÃ©rent** avec les champs structurÃ©s du rapport
- Ne doit **pas** Ãªtre complÃ©tÃ© si le rapport est soumis sous directive ministÃ©rielle

## 2.3 Rapports liÃ©s (`relatedReports[]`)

**RÃ´le :** RÃ©fÃ©rences Ã  des STR prÃ©cÃ©demment soumis relatifs Ã  la mÃªme activitÃ© suspecte.

| Champ | Type | Requis |
|-------|------|--------|
| `reportingEntityReportReference` | string | âœ… Oui |
| `reportingEntityTransactionReferences` | string[] | Non |

**Pourquoi :** Permet Ã  CANAFE de lier les analyses et construire des dossiers plus complets.

## 2.4 Mesures prises (`actionTaken`)

**RÃ´le :** Description des actions entreprises ou prÃ©vues suite Ã  la transaction suspecte.

| Champ | Type | Description |
|-------|------|-------------|
| `description` | string | Texte libre (ex: monitoring renforcÃ©, fermeture de compte, signalement aux forces de l'ordre) |

## 2.5 DÃ©finitions des parties (`definitions[]`)

**RÃ´le :** Catalogue centralisÃ© et polymorphe de toutes les personnes et entitÃ©s rÃ©fÃ©rencÃ©es dans le rapport.

C'est un **design pattern de rÃ©fÃ©rencement** : chaque personne/entitÃ© est dÃ©finie une seule fois dans `definitions[]` avec un `refId` unique, puis rÃ©fÃ©rencÃ©e par ce `refId` dans les transactions (conductors, beneficiaries, onBehalfOfs, etc.).

**Types polymorphes (via `typeCode`) :**

| typeCode | Type | Description |
|----------|------|-------------|
| 1 | PersonName | Nom d'une personne (surname, givenName, otherInitial) |
| 2 | EntityName | Nom d'une entitÃ© |
| 3 | PersonDetails | DÃ©tails complets d'une personne (adresse, tÃ©lÃ©phone, email, DOB, occupation, identifications) |
| 4 | EntityDetails | DÃ©tails complets d'une entitÃ© (adresse, structure, incorporation, directors, beneficial owners) |
| 5 | PersonAndEmployerDetails | Personne avec info employeur |
| 6 | EntityAndBeneficialOwnershipDetails | EntitÃ© avec structure de propriÃ©tÃ© effective |

**PiÃ¨ges critiques :**
- Le `refId` doit Ãªtre unique au sein du rapport
- Une mÃªme personne physique avec diffÃ©rents rÃ´les (conducteur + bÃ©nÃ©ficiaire) peut utiliser le **mÃªme refId**
- Les `typeCode` acceptÃ©s varient selon le contexte d'utilisation (conductors n'acceptent que 5/6, beneficiaries n'acceptent que 3/4, etc.)

## 2.6 Transactions (`transactions[]`)

**RÃ´le :** CÅ“ur du rapport â€” contient les dÃ©tails de chaque transaction suspecte.

Un STR peut contenir **plusieurs transactions**. Chaque transaction contient :

### 2.6.1 MÃ©tadonnÃ©es de transaction (`suspiciousTransactionDetails`)

| Champ | Type | Requis |
|-------|------|--------|
| `attemptedTransactionIndicator` | boolean | âœ… Oui |
| `reasonNotCompleted` | string(200) | Si tentÃ©e |
| `dateOfTransaction` | date | â€ Conditionnel |
| `timeOfTransaction` | zonedTime | Non |
| `methodCode` | integer | Oui* |
| `methodOther` | string(200) | Si method=7 |
| `dateOfPosting` | date | Conditionnel |
| `reportingEntityTransactionReference` | string | â€¡Processing |
| `purposeOfTransaction` | string | Non |

**Valeurs `methodCode` :**

| Code | MÃ©thode |
|------|---------|
| 1 | En personne |
| 2 | ABM/GAB |
| 3 | DÃ©pÃ´t blindÃ© |
| 4 | Correspondant bancaire |
| 5 | Courrier |
| 6 | DÃ©pÃ´t de nuit |
| 7 | Autre |
| 8 | Quick drop |
| 9 | TÃ©lÃ©phone |
| 10 | TÃ©lÃ©copieur |
| 11 | GAB monnaie virtuelle |
| 12 | En ligne |

### 2.6.2 Actions de dÃ©part (`startingActions[]`)

Chaque transaction a au moins 1 starting action. Contient :

- **`details`** : direction (in/out), type de fonds, montant, devise, comptes, adresses VC
- **`sourcesOfFundsOrVirtualCurrency[]`** : source des fonds (personne/entitÃ©)
- **`conductors[]`** : qui effectue la transaction, avec info device, et `onBehalfOfs[]` (tiers mandants)

**Valeurs `fundAssetVirtualCurrencyTypeCode` (direction IN) :**

| Code | Type |
|------|------|
| 1 | Traite bancaire |
| 2 | EspÃ¨ces |
| 3 | Produit de casino |
| 4 | ChÃ¨que |
| 5 | Transfert de fonds domestique |
| 6 | Virement email (EMT) |
| 7 | Transfert de fonds international |
| 8 | Produit d'investissement |
| 9 | Bijoux |
| 10 | Transfert mobile |
| 11 | Mandat |
| 12 | MÃ©taux prÃ©cieux |
| 13 | Pierres prÃ©cieuses |
| 14 | Transfert de fonds domestique (entrant) |
| 15 | Transfert de fonds international (entrant) |
| 16 | Monnaie virtuelle |
| 17 | Autre |

### 2.6.3 Actions de complÃ©tion (`completingActions[]`)

DÃ©crivent la disposition des fonds. Contiennent :

- **`details`** : dispositionCode, montant, devise, comptes, adresses VC
- **`involvements[]`** : autres personnes/entitÃ©s impliquÃ©es
- **`beneficiaries[]`** : bÃ©nÃ©ficiaires

**Valeurs `dispositionCode` (sÃ©lection) :**

| Code | Disposition |
|------|------------|
| 1 | DÃ©pÃ´t au compte |
| 2 | Ã‰change en monnaie virtuelle |
| 3 | Ã‰change en devise fiduciaire |
| 4 | Transfert international sortant |
| 5 | Transfert domestique sortant |
| 6 | Achat de traite bancaire |
| 7 | Achat de mandat |
| 8 | Achat de bijoux |
| 9 | Achat de mÃ©taux prÃ©cieux |
| 10 | DÃ©caissement (cash out) |
| 11 | Ajout au portefeuille VC |
| 12 | Change de dÃ©nomination |
| 13 | RÃ©tention de fonds |
| 14 | Achat d'investissement |
| 15 | Achat d'assurance vie |
| 16 | Ã‰mission de chÃ¨que |
| 17 | EMT sortant |
| 18 | Transfert mobile sortant |
| 19 | Transfert VC sortant |
| 20 | Paiement au compte |
| 21 | Achat de pierres prÃ©cieuses |
| 22 | Achat prÃ©payÃ© |
| 23 | Achat immobilier |
| 24 | Achat de biens |
| 25 | Achat de services |
| 26-31 | (Autres dispositions) |
| 32 | Retrait d'espÃ¨ces (compte) |

## 2.7 Localisation de la transaction

Chaque transaction est liÃ©e Ã  un emplacement via `reportingEntityLocationId` â€” un identifiant de localisation crÃ©Ã© lors de l'enrÃ´lement dans CANAFE FWR.

## 2.8 Comptes (`strAccount` dans starting/completing actions)

Les comptes sont intÃ©grÃ©s dans les starting et completing actions avec :
- `financialInstitutionNumber`, `branchNumber`, `accountNumber`
- `accountType`, `accountCurrency`, `accountVirtualCurrencyType`
- `dateAccountOpened`, `dateAccountClosed`
- `accountStatusAtTimeOfTransaction`
- Account holders (personne ou entitÃ©)

## 2.9 Instruments de monnaie virtuelle

Les transactions impliquant la monnaie virtuelle incluent :
- `virtualCurrencyTransactionIds[]`
- `sendingVirtualCurrencyAddresses[]`
- `receivingVirtualCurrencyAddresses[]`
- `virtualCurrencyTypeCode`

---

# SECTION 3 â€” Structure logique du payload STRReport

Structure JSON reconstituÃ©e fidÃ¨lement Ã  partir du schÃ©ma Swagger observÃ© :

```
STRReport
â”œâ”€â”€ reportDetails (required)
â”‚   â”œâ”€â”€ reportTypeCode* (102)
â”‚   â”œâ”€â”€ submitTypeCode* (1|2|5)
â”‚   â”œâ”€â”€ activitySectorCode
â”‚   â”œâ”€â”€ reportingEntityNumber*
â”‚   â”œâ”€â”€ submittingReportingEntityNumber*
â”‚   â”œâ”€â”€ reportingEntityReportReference*
â”‚   â”œâ”€â”€ reportingEntityContactId*
â”‚   â””â”€â”€ ministerialDirectiveCode
â”‚
â”œâ”€â”€ detailsOfSuspicion
â”‚   â”œâ”€â”€ descriptionOfSuspiciousActivity
â”‚   â”œâ”€â”€ suspicionTypeCode (1-7)
â”‚   â”œâ”€â”€ publicPrivatePartnershipProjectNameCodes[]
â”‚   â””â”€â”€ politicallyExposedPersonIncludedIndicator
â”‚
â”œâ”€â”€ relatedReports[]
â”‚   â”œâ”€â”€ reportingEntityReportReference*
â”‚   â””â”€â”€ reportingEntityTransactionReferences[]
â”‚
â”œâ”€â”€ actionTaken
â”‚   â””â”€â”€ description
â”‚
â”œâ”€â”€ definitions[] (polymorphic: OneOf)
â”‚   â”œâ”€â”€ typeCode* (1=PersonName|2=EntityName|3=PersonDetails|4=EntityDetails|5=PersonAndEmployer|6=EntityAndBO)
â”‚   â”œâ”€â”€ refId* (unique string)
â”‚   â””â”€â”€ details (varies by typeCode)
â”‚       â”œâ”€â”€ [PersonName]: surname, givenName, otherInitial
â”‚       â”œâ”€â”€ [EntityName]: entityName
â”‚       â”œâ”€â”€ [PersonDetails]: name, alias, address, phone, email, DOB,
â”‚       â”‚   countryOfResidence, countryOfCitizenship, occupation,
â”‚       â”‚   employer, identifications[]
â”‚       â”œâ”€â”€ [EntityDetails]: entityName, address, phone, email, URL,
â”‚       â”‚   entityStructureType, principalBusiness, incorporation[],
â”‚       â”‚   registration[], identifications[], personsAuthorized[]
â”‚       â”œâ”€â”€ [PersonAndEmployer]: personDetails + employerDetails
â”‚       â”‚   (address, phone)
â”‚       â””â”€â”€ [EntityAndBO]: entityDetails + beneficialOwnership
â”‚           (directors[], owners25pct[], trustees[], settlors[],
â”‚            trustBeneficiaries[])
â”‚
â””â”€â”€ transactions[] (required, array)
    â”œâ”€â”€ reportingEntityLocationId* (string30)
    â”œâ”€â”€ suspiciousTransactionDetails* (required)
    â”‚   â”œâ”€â”€ attemptedTransactionIndicator* (boolean)
    â”‚   â”œâ”€â”€ reasonNotCompleted (string200)
    â”‚   â”œâ”€â”€ dateOfTransaction (date)
    â”‚   â”œâ”€â”€ timeOfTransaction (zonedTime)
    â”‚   â”œâ”€â”€ methodCode (enum 1-12)
    â”‚   â”œâ”€â”€ methodOther (string200)
    â”‚   â”œâ”€â”€ dateOfPosting (date)
    â”‚   â”œâ”€â”€ timeOfPosting (zonedTime)
    â”‚   â”œâ”€â”€ reportingEntityTransactionReferenceâ€¡
    â”‚   â””â”€â”€ purposeOfTransaction
    â”‚
    â”œâ”€â”€ startingActions[] (required, array)
    â”‚   â”œâ”€â”€ details* (required)
    â”‚   â”‚   â”œâ”€â”€ direction (1=In|2=Out)
    â”‚   â”‚   â”œâ”€â”€ fundAssetVirtualCurrencyTypeCode (enum 1-17)
    â”‚   â”‚   â”œâ”€â”€ fundAssetVirtualCurrencyTypeOther
    â”‚   â”‚   â”œâ”€â”€ amount* (number)
    â”‚   â”‚   â”œâ”€â”€ currencyCode
    â”‚   â”‚   â”œâ”€â”€ currencyOther
    â”‚   â”‚   â”œâ”€â”€ virtualCurrencyTypeCode
    â”‚   â”‚   â”œâ”€â”€ virtualCurrencyTypeOther
    â”‚   â”‚   â”œâ”€â”€ exchangeRate
    â”‚   â”‚   â”œâ”€â”€ virtualCurrencyTransactionIds[]
    â”‚   â”‚   â”œâ”€â”€ sendingVirtualCurrencyAddresses[]
    â”‚   â”‚   â”œâ”€â”€ receivingVirtualCurrencyAddresses[]
    â”‚   â”‚   â”œâ”€â”€ referenceNumber
    â”‚   â”‚   â”œâ”€â”€ otherReferenceNumber
    â”‚   â”‚   â”œâ”€â”€ account (strAccount)
    â”‚   â”‚   â”‚   â”œâ”€â”€ financialInstitutionNumber
    â”‚   â”‚   â”‚   â”œâ”€â”€ branchNumber
    â”‚   â”‚   â”‚   â”œâ”€â”€ accountNumber
    â”‚   â”‚   â”‚   â”œâ”€â”€ accountType / accountTypeOther
    â”‚   â”‚   â”‚   â”œâ”€â”€ accountCurrency / accountCurrencyOther
    â”‚   â”‚   â”‚   â”œâ”€â”€ accountVirtualCurrencyType / Other
    â”‚   â”‚   â”‚   â”œâ”€â”€ dateAccountOpened / dateAccountClosed
    â”‚   â”‚   â”‚   â””â”€â”€ accountHolders[] (typeCode 1|2, refId)
    â”‚   â”‚   â”œâ”€â”€ accountStatusAtTimeOfTransaction
    â”‚   â”‚   â”œâ”€â”€ howFundsOrVirtualCurrencyObtained
    â”‚   â”‚   â”œâ”€â”€ sourcesOfFundsOrVirtualCurrencyIndicatorâ€¡
    â”‚   â”‚   â””â”€â”€ conductorIndicatorâ€¡
    â”‚   â”‚
    â”‚   â”œâ”€â”€ sourcesOfFundsOrVirtualCurrency[]
    â”‚   â”‚   â”œâ”€â”€ typeCode* (1=Person|2=Entity)
    â”‚   â”‚   â”œâ”€â”€ refId*
    â”‚   â”‚   â””â”€â”€ details (accountNumber, policyNumber, identifyingNumber)
    â”‚   â”‚
    â”‚   â””â”€â”€ conductors[]
    â”‚       â”œâ”€â”€ typeCode* (5=PersonAndEmployer|6=EntityAndBO)
    â”‚       â”œâ”€â”€ refId*
    â”‚       â”œâ”€â”€ details
    â”‚       â”‚   â”œâ”€â”€ clientNumber
    â”‚       â”‚   â”œâ”€â”€ typeOfDeviceCode (1=Computer|2=Mobile|3=Tablet|4=Other)
    â”‚       â”‚   â”œâ”€â”€ typeOfDeviceOther
    â”‚       â”‚   â”œâ”€â”€ username
    â”‚       â”‚   â”œâ”€â”€ deviceIdentifierNumber
    â”‚       â”‚   â”œâ”€â”€ internetProtocolAddress
    â”‚       â”‚   â”œâ”€â”€ dateTimeOfOnlineSession
    â”‚       â”‚   â””â”€â”€ onBehalfOfIndicatorâ€¡
    â”‚       â””â”€â”€ onBehalfOfs[]
    â”‚           â”œâ”€â”€ typeCode* (5|6)
    â”‚           â”œâ”€â”€ refId*
    â”‚           â””â”€â”€ details
    â”‚               â”œâ”€â”€ clientNumber
    â”‚               â”œâ”€â”€ relationshipOfConductorCode (enum 1-14)
    â”‚               â”œâ”€â”€ relationshipOfConductorOther
    â”‚               â””â”€â”€ [device info fields]
    â”‚
    â””â”€â”€ completingActions[] (required, array)
        â”œâ”€â”€ details* (required)
        â”‚   â”œâ”€â”€ dispositionCode (enum 1-32)
        â”‚   â”œâ”€â”€ dispositionOther
        â”‚   â”œâ”€â”€ amount
        â”‚   â”œâ”€â”€ currencyCode / virtualCurrencyTypeCode
        â”‚   â”œâ”€â”€ exchangeRate
        â”‚   â”œâ”€â”€ valueInCanadianDollars
        â”‚   â”œâ”€â”€ virtualCurrencyTransactionIds[]
        â”‚   â”œâ”€â”€ sendingVirtualCurrencyAddresses[]
        â”‚   â”œâ”€â”€ receivingVirtualCurrencyAddresses[]
        â”‚   â”œâ”€â”€ referenceNumber / otherReferenceNumber
        â”‚   â”œâ”€â”€ account (strAccount)
        â”‚   â”œâ”€â”€ accountStatusAtTimeOfTransaction
        â”‚   â”œâ”€â”€ involvementIndicatorâ€¡
        â”‚   â””â”€â”€ beneficiaryIndicatorâ€¡
        â”‚
        â”œâ”€â”€ involvements[]
        â”‚   â”œâ”€â”€ typeCode* (1=PersonName|2=EntityName)
        â”‚   â”œâ”€â”€ refId*
        â”‚   â””â”€â”€ details (accountNumber, policyNumber, identifyingNumber)
        â”‚
        â””â”€â”€ beneficiaries[]
            â”œâ”€â”€ typeCode* (3=PersonDetails|4=EntityDetails)
            â”œâ”€â”€ refId*
            â””â”€â”€ details (clientNumber, username, emailAddress)
```

**LÃ©gende :**
- `*` = Requis (required dans le schÃ©ma OpenAPI)
- `â€¡` = Mandatory for processing
- `â€ ` = Mandatory if applicable
- Pas de symbole = Reasonable measures / optionnel

# SECTION 4 â€” ModÃ¨le de donnÃ©es cible recommandÃ©

> **Source :** SchÃ©ma STRReport du Swagger CANAFE + Guidance officielle Annex A

## 4.1 Table `STR_REPORT`

**Objectif :** Enregistrement principal d'un STRReport. Un enregistrement = un rapport soumis ou Ã  soumettre.

| Colonne | Type SQL | Nullable | Validation | JSON CANAFE |
|---------|----------|----------|------------|-------------|
| `str_report_id` (PK) | BIGINT AUTO | Non | â€” | â€” (interne) |
| `report_type_code` | SMALLINT | Non | Toujours 102 | `reportDetails.reportTypeCode` |
| `submit_type_code` | SMALLINT | Non | 1,2,5 | `reportDetails.submitTypeCode` |
| `activity_sector_code` | SMALLINT | Non | Enum (2,3,6,10,14,16,19,20...) | `reportDetails.activitySectorCode` |
| `reporting_entity_number` | VARCHAR(7) | Non | 7 chiffres | `reportDetails.reportingEntityNumber` |
| `submitting_re_number` | VARCHAR(7) | Non | 7 chiffres | `reportDetails.submittingReportingEntityNumber` |
| `re_report_reference` | VARCHAR(100) | Non | Unique, `^[A-Za-z0-9-_]{1,100}$` | `reportDetails.reportingEntityReportReference` |
| `re_contact_id` | VARCHAR(100) | Non | â€” | `reportDetails.reportingEntityContactId` |
| `ministerial_directive_code` | VARCHAR(10) | Oui | Ex: IR2020 | `reportDetails.ministerialDirectiveCode` |
| `suspicion_type_code` | SMALLINT | Oui | 1-7 | `detailsOfSuspicion.suspicionTypeCode` |
| `suspicious_activity_desc` | TEXT | Oui | â€” | `detailsOfSuspicion.descriptionOfSuspiciousActivity` |
| `pep_included_indicator` | BOOLEAN | Oui | â€” | `detailsOfSuspicion.politicallyExposedPersonIncludedIndicator` |
| `action_taken_desc` | TEXT | Oui | â€” | `actionTaken.description` |
| `status` | VARCHAR(20) | Non | DRAFT/VALIDATED/SUBMITTED/ACCEPTED/REJECTED | â€” (interne) |
| `created_at` | TIMESTAMP | Non | â€” | â€” (interne) |
| `updated_at` | TIMESTAMP | Non | â€” | â€” (interne) |
| `submitted_at` | TIMESTAMP | Oui | â€” | â€” (interne) |

**CardinalitÃ© :** 1 STR_REPORT â†’ N STR_TRANSACTION, N STR_DEFINITION, N STR_RELATED_REPORT

---

## 4.2 Table `STR_PPP_PROJECT`

**Objectif :** Codes de projet partenariat public-privÃ© associÃ©s au rapport.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `ppp_id` (PK) | BIGINT AUTO | Non | â€” |
| `str_report_id` (FK) | BIGINT | Non | â€” |
| `project_name_code` | SMALLINT | Non | `detailsOfSuspicion.publicPrivatePartnershipProjectNameCodes[]` |

**CardinalitÃ© :** STR_REPORT 1â†’N STR_PPP_PROJECT

---

## 4.3 Table `STR_RELATED_REPORT`

**Objectif :** RÃ©fÃ©rences aux rapports prÃ©cÃ©demment soumis liÃ©s Ã  l'activitÃ© suspecte.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `related_report_id` (PK) | BIGINT AUTO | Non | â€” |
| `str_report_id` (FK) | BIGINT | Non | â€” |
| `re_report_reference` | VARCHAR(100) | Non | `relatedReports[].reportingEntityReportReference` |

**CardinalitÃ© :** STR_REPORT 1â†’N STR_RELATED_REPORT

---

## 4.4 Table `STR_RELATED_REPORT_TXN_REF`

**Objectif :** RÃ©fÃ©rences de transaction des rapports liÃ©s.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `id` (PK) | BIGINT AUTO | Non | â€” |
| `related_report_id` (FK) | BIGINT | Non | â€” |
| `txn_reference` | VARCHAR(100) | Non | `relatedReports[].reportingEntityTransactionReferences[]` |

---

## 4.5 Table `STR_DEFINITION`

**Objectif :** Catalogue polymorphe des personnes et entitÃ©s. Un `refId` unique par dÃ©finition dans le rapport.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `definition_id` (PK) | BIGINT AUTO | Non | â€” |
| `str_report_id` (FK) | BIGINT | Non | â€” |
| `ref_id` | VARCHAR(50) | Non | `definitions[].refId` |
| `type_code` | SMALLINT | Non | `definitions[].typeCode` (1-6) |

**CardinalitÃ© :** STR_REPORT 1â†’N STR_DEFINITION. Le `ref_id` est unique au sein d'un rapport.

---

## 4.6 Table `STR_PERSON`

**Objectif :** DÃ©tails d'une personne (typeCode 1, 3 ou 5). LiÃ©e Ã  STR_DEFINITION.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `person_id` (PK) | BIGINT AUTO | Non | â€” |
| `definition_id` (FK) | BIGINT | Non | â€” |
| `surname` | VARCHAR(100) | Oui | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_initial` | VARCHAR(100) | Oui | `otherInitial` |
| `alias` | VARCHAR(100) | Oui | `alias` |
| `client_number` | VARCHAR(50) | Oui | `clientNumber` |
| `date_of_birth` | DATE | Oui | `dateOfBirth` |
| `country_of_residence` | VARCHAR(3) | Oui | `countryOfResidence` |
| `country_of_citizenship` | VARCHAR(3) | Oui | `countryOfCitizenship` |
| `occupation` | VARCHAR(200) | Oui | `occupation` |
| `employer_name` | VARCHAR(200) | Oui | `nameOfEmployer` |
| `email_address` | VARCHAR(200) | Oui | `emailAddress` |
| `url` | VARCHAR(500) | Oui | `url` |
| `username` | VARCHAR(200) | Oui | `username` |

---

## 4.7 Table `STR_ENTITY`

**Objectif :** DÃ©tails d'une entitÃ© (typeCode 2, 4 ou 6).

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `entity_id` (PK) | BIGINT AUTO | Non | â€” |
| `definition_id` (FK) | BIGINT | Non | â€” |
| `entity_name` | VARCHAR(200) | Non | `entityName` |
| `client_number` | VARCHAR(50) | Oui | `clientNumber` |
| `entity_structure_type` | VARCHAR(50) | Oui | `entityStructureType` (Corporation/Trust/...) |
| `principal_business` | VARCHAR(200) | Oui | `natureOfEntityPrincipalBusiness` |
| `is_incorporated_registered` | VARCHAR(30) | Oui | `incorporatedOrRegistered` |
| `email_address` | VARCHAR(200) | Oui | `emailAddress` |
| `url` | VARCHAR(500) | Oui | `url` |

---

## 4.8 Table `STR_ADDRESS`

**Objectif :** Adresses structurÃ©es ou non structurÃ©es pour personnes, entitÃ©s, employeurs.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `address_id` (PK) | BIGINT AUTO | Non | â€” |
| `owner_type` | VARCHAR(20) | Non | 'PERSON','ENTITY','EMPLOYER','DIRECTOR','TRUSTEE','SETTLOR','BO_OWNER' |
| `owner_id` | BIGINT | Non | FK polymorphe vers person/entity/etc. |
| `unit_number` | VARCHAR(50) | Oui | `unitNumber` |
| `building_number` | VARCHAR(50) | Oui | `buildingNumber` |
| `street_address` | VARCHAR(200) | Oui | `streetAddress` |
| `city` | VARCHAR(100) | Oui | `city` |
| `district` | VARCHAR(100) | Oui | `district` |
| `country_code` | VARCHAR(3) | Oui | `country` |
| `province_state_code` | VARCHAR(10) | Oui | `provinceStateCode` |
| `province_state_name` | VARCHAR(100) | Oui | `provinceStateName` |
| `sub_province_locality` | VARCHAR(100) | Oui | `subProvinceLocality` |
| `postal_zip_code` | VARCHAR(20) | Oui | `postalZipCode` |
| `unstructured_address` | VARCHAR(500) | Oui | `unstructuredAddressDetails` |

---

## 4.9 Table `STR_PHONE`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `phone_id` (PK) | BIGINT AUTO | Non | â€” |
| `owner_type` | VARCHAR(20) | Non | â€” |
| `owner_id` | BIGINT | Non | â€” |
| `phone_number` | VARCHAR(30) | Non | `telephoneNumber` |
| `extension` | VARCHAR(10) | Oui | `extension` |

---

## 4.10 Table `STR_IDENTIFICATION`

**Objectif :** PiÃ¨ces d'identitÃ© pour personnes ou entitÃ©s.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `identification_id` (PK) | BIGINT AUTO | Non | â€” |
| `owner_type` | VARCHAR(20) | Non | 'PERSON' ou 'ENTITY' |
| `owner_id` | BIGINT | Non | â€” |
| `identifier_type` | VARCHAR(50) | Non | `identifierType` |
| `identifier_type_other` | VARCHAR(200) | Oui | si "Other" |
| `identifier_number` | VARCHAR(100) | Non | `numberAssociatedWithIdentifierType` |
| `jurisdiction_country` | VARCHAR(3) | Oui | `jurisdictionOfIssueCountry` |
| `jurisdiction_province` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceState` |

---

## 4.11 Table `STR_INCORPORATION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `incorporation_id` (PK) | BIGINT AUTO | Non | â€” |
| `entity_id` (FK) | BIGINT | Non | â€” |
| `incorporation_number` | VARCHAR(100) | Non | `incorporationNumber` |
| `country` | VARCHAR(3) | Oui | `jurisdictionOfIssueCountry` |
| `province_state` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceState` |

---

## 4.12 Table `STR_REGISTRATION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `registration_id` (PK) | BIGINT AUTO | Non | â€” |
| `entity_id` (FK) | BIGINT | Non | â€” |
| `registration_number` | VARCHAR(100) | Non | `registrationNumber` |
| `country` | VARCHAR(3) | Oui | `jurisdictionOfIssueCountry` |
| `province_state` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceState` |

---

## 4.13 Table `STR_BENEFICIAL_OWNER`

**Objectif :** PropriÃ©taire effectif, directeur, fiduciaire, constituant d'entitÃ© (typeCode 6).

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `bo_id` (PK) | BIGINT AUTO | Non | â€” |
| `entity_id` (FK) | BIGINT | Non | â€” |
| `role_type` | VARCHAR(30) | Non | 'DIRECTOR','OWNER_25PCT','TRUSTEE','SETTLOR','TRUST_BENEFICIARY' |
| `surname` | VARCHAR(100) | Oui | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_initial` | VARCHAR(100) | Oui | `otherInitial` |

**Note :** Chaque BO peut avoir des adresses et tÃ©lÃ©phones (via STR_ADDRESS, STR_PHONE avec owner_type appropriÃ©).

---

## 4.14 Table `STR_PERSON_AUTHORIZED`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `auth_id` (PK) | BIGINT AUTO | Non | â€” |
| `entity_id` (FK) | BIGINT | Non | â€” |
| `surname` | VARCHAR(100) | Non | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_initial` | VARCHAR(100) | Oui | `otherInitial` |

---

## 4.15 Table `STR_TRANSACTION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `transaction_id` (PK) | BIGINT AUTO | Non | â€” |
| `str_report_id` (FK) | BIGINT | Non | â€” |
| `re_location_id` | VARCHAR(30) | Non | `reportingEntityLocationId` |
| `attempted_indicator` | BOOLEAN | Non | `attemptedTransactionIndicator` |
| `reason_not_completed` | VARCHAR(200) | Oui | `reasonNotCompleted` |
| `date_of_transaction` | DATE | Oui | `dateOfTransaction` |
| `time_of_transaction` | VARCHAR(25) | Oui | `timeOfTransaction` (HH:MM:SSÂ±ZZ:ZZ) |
| `method_code` | SMALLINT | Oui | `methodCode` (1-12) |
| `method_other` | VARCHAR(200) | Oui | `methodOther` |
| `date_of_posting` | DATE | Oui | `dateOfPosting` |
| `time_of_posting` | VARCHAR(25) | Oui | `timeOfPosting` |
| `re_txn_reference` | VARCHAR(100) | Oui | `reportingEntityTransactionReference` |
| `purpose_of_transaction` | VARCHAR(500) | Oui | `purposeOfTransaction` |

---

## 4.16 Table `STR_STARTING_ACTION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `starting_action_id` (PK) | BIGINT AUTO | Non | â€” |
| `transaction_id` (FK) | BIGINT | Non | â€” |
| `direction_code` | SMALLINT | Non | `direction` (1=In, 2=Out) |
| `fund_type_code` | SMALLINT | Oui | `fundAssetVirtualCurrencyTypeCode` |
| `fund_type_other` | VARCHAR(200) | Oui | â€” |
| `amount` | DECIMAL(18,2) | Non | `amount` |
| `currency_code` | VARCHAR(3) | Oui | `currencyCode` |
| `currency_other` | VARCHAR(50) | Oui | â€” |
| `vc_type_code` | VARCHAR(10) | Oui | `virtualCurrencyTypeCode` |
| `vc_type_other` | VARCHAR(50) | Oui | â€” |
| `exchange_rate` | DECIMAL(18,8) | Oui | `exchangeRate` |
| `reference_number` | VARCHAR(100) | Oui | `referenceNumber` |
| `other_reference_number` | VARCHAR(100) | Oui | `otherReferenceNumber` |
| `how_funds_obtained` | VARCHAR(500) | Oui | `howFundsOrVirtualCurrencyObtained` |
| `source_funds_indicator` | BOOLEAN | Oui | `sourcesOfFundsOrVirtualCurrencyIndicator` |
| `conductor_indicator` | BOOLEAN | Oui | `conductorIndicator` |

---

## 4.17 Table `STR_COMPLETING_ACTION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `completing_action_id` (PK) | BIGINT AUTO | Non | â€” |
| `transaction_id` (FK) | BIGINT | Non | â€” |
| `disposition_code` | SMALLINT | Non | `dispositionCode` (1-32) |
| `disposition_other` | VARCHAR(200) | Oui | â€” |
| `amount` | DECIMAL(18,2) | Oui | `amount` |
| `currency_code` | VARCHAR(3) | Oui | `currencyCode` |
| `currency_other` | VARCHAR(50) | Oui | â€” |
| `vc_type_code` | VARCHAR(10) | Oui | `virtualCurrencyTypeCode` |
| `exchange_rate` | DECIMAL(18,8) | Oui | `exchangeRate` |
| `value_in_cad` | DECIMAL(18,2) | Oui | `valueInCanadianDollars` |
| `reference_number` | VARCHAR(100) | Oui | `referenceNumber` |
| `other_reference_number` | VARCHAR(100) | Oui | â€” |
| `involvement_indicator` | BOOLEAN | Oui | `involvementIndicator` |
| `beneficiary_indicator` | BOOLEAN | Oui | `beneficiaryIndicator` |

---

## 4.18 Table `STR_ACCOUNT`

**Objectif :** Comptes liÃ©s aux starting/completing actions.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `account_id` (PK) | BIGINT AUTO | Non | â€” |
| `action_type` | VARCHAR(10) | Non | 'STARTING' ou 'COMPLETING' |
| `action_id` | BIGINT | Non | FK vers starting/completing action |
| `fi_number` | VARCHAR(10) | Oui | `financialInstitutionNumber` |
| `branch_number` | VARCHAR(10) | Oui | `branchNumber` |
| `account_number` | VARCHAR(50) | Oui | `accountNumber` |
| `account_type` | VARCHAR(50) | Oui | `accountType` |
| `account_type_other` | VARCHAR(100) | Oui | â€” |
| `account_currency` | VARCHAR(3) | Oui | `accountCurrency` |
| `account_currency_other` | VARCHAR(50) | Oui | â€” |
| `account_vc_type` | VARCHAR(20) | Oui | `accountVirtualCurrencyType` |
| `date_opened` | DATE | Oui | `dateAccountOpened` |
| `date_closed` | DATE | Oui | `dateAccountClosed` |
| `status_at_txn` | VARCHAR(50) | Oui | `accountStatusAtTimeOfTransaction` |

---

## 4.19 Table `STR_ACCOUNT_HOLDER`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `holder_id` (PK) | BIGINT AUTO | Non | â€” |
| `account_id` (FK) | BIGINT | Non | â€” |
| `type_code` | SMALLINT | Non | 1=Person, 2=Entity |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` â†’ rÃ©fÃ©rence Ã  STR_DEFINITION |

---

## 4.20 Table `STR_VC_ADDRESS`

**Objectif :** Adresses de monnaie virtuelle (sending/receiving) et transaction IDs.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `vc_address_id` (PK) | BIGINT AUTO | Non | â€” |
| `action_type` | VARCHAR(10) | Non | 'STARTING' ou 'COMPLETING' |
| `action_id` | BIGINT | Non | â€” |
| `address_type` | VARCHAR(10) | Non | 'SENDING','RECEIVING','TXN_ID' |
| `address_value` | VARCHAR(200) | Non | Adresse VC ou hash de transaction |

---

## 4.21 Table `STR_CONDUCTOR`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `conductor_id` (PK) | BIGINT AUTO | Non | â€” |
| `starting_action_id` (FK) | BIGINT | Non | â€” |
| `type_code` | SMALLINT | Non | 5 ou 6 |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(50) | Oui | `clientNumber` |
| `device_type_code` | SMALLINT | Oui | `typeOfDeviceCode` |
| `device_type_other` | VARCHAR(100) | Oui | â€” |
| `username` | VARCHAR(200) | Oui | `username` |
| `device_id_number` | VARCHAR(100) | Oui | `deviceIdentifierNumber` |
| `ip_address` | VARCHAR(50) | Oui | `internetProtocolAddress` |
| `online_session_datetime` | TIMESTAMP | Oui | `dateTimeOfOnlineSession` |
| `on_behalf_of_indicator` | BOOLEAN | Oui | `onBehalfOfIndicator` |

---

## 4.22 Table `STR_ON_BEHALF_OF`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `obo_id` (PK) | BIGINT AUTO | Non | â€” |
| `conductor_id` (FK) | BIGINT | Non | â€” |
| `type_code` | SMALLINT | Non | 5 ou 6 |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(50) | Oui | â€” |
| `relationship_code` | SMALLINT | Oui | `relationshipOfConductorCode` (1-14) |
| `relationship_other` | VARCHAR(200) | Oui | â€” |
| `device_type_code` | SMALLINT | Oui | â€” |
| `username` | VARCHAR(200) | Oui | â€” |
| `ip_address` | VARCHAR(50) | Oui | â€” |

---

## 4.23 Table `STR_SOURCE_OF_FUNDS`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `source_id` (PK) | BIGINT AUTO | Non | â€” |
| `starting_action_id` (FK) | BIGINT | Non | â€” |
| `type_code` | SMALLINT | Non | 1=Person, 2=Entity |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `account_number` | VARCHAR(50) | Oui | `accountNumber` |
| `policy_number` | VARCHAR(50) | Oui | `policyNumber` |
| `identifying_number` | VARCHAR(50) | Oui | `identifyingNumber` |

---

## 4.24 Table `STR_INVOLVEMENT`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `involvement_id` (PK) | BIGINT AUTO | Non | â€” |
| `completing_action_id` (FK) | BIGINT | Non | â€” |
| `type_code` | SMALLINT | Non | 1=PersonName, 2=EntityName |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `account_number` | VARCHAR(50) | Oui | `accountNumber` |
| `policy_number` | VARCHAR(50) | Oui | `policyNumber` |
| `identifying_number` | VARCHAR(50) | Oui | `identifyingNumber` |

---

## 4.25 Table `STR_BENEFICIARY`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `beneficiary_id` (PK) | BIGINT AUTO | Non | â€” |
| `completing_action_id` (FK) | BIGINT | Non | â€” |
| `type_code` | SMALLINT | Non | 3=PersonDetails, 4=EntityDetails |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(50) | Oui | `clientNumber` |
| `username` | VARCHAR(200) | Oui | `username` |
| `email_address` | VARCHAR(200) | Oui | `emailAddress` |

---

## 4.26 Tables d'audit et traÃ§abilitÃ© (recommandation architecturale)

> âš ï¸ Ces tables ne sont **pas** exigÃ©es par le schÃ©ma CANAFE mais sont des **recommandations d'architecture** essentielles.

### `STR_API_SUBMISSION`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `submission_id` (PK) | BIGINT AUTO | â€” |
| `str_report_id` (FK) | BIGINT | â€” |
| `submitted_at` | TIMESTAMP | Date/heure de soumission |
| `http_status_code` | SMALLINT | 200, 400, 401, 500... |
| `api_response_body` | TEXT | RÃ©ponse JSON complÃ¨te |
| `canafe_acknowledgement_id` | VARCHAR(100) | ID de confirmation CANAFE |
| `success_indicator` | BOOLEAN | SuccÃ¨s ou Ã©chec |

### `STR_VALIDATION_ERROR`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `error_id` (PK) | BIGINT AUTO | â€” |
| `str_report_id` (FK) | BIGINT | â€” |
| `error_code` | VARCHAR(20) | Code erreur CANAFE (ex: 300, 324) |
| `field_path` | VARCHAR(200) | Chemin JSON du champ en erreur |
| `error_message` | TEXT | Message descriptif |
| `detected_at` | TIMESTAMP | â€” |

### `STR_AUDIT_EVENT`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `event_id` (PK) | BIGINT AUTO | â€” |
| `str_report_id` (FK) | BIGINT | â€” |
| `event_type` | VARCHAR(30) | CREATED/EDITED/VALIDATED/SUBMITTED/CORRECTED |
| `event_user` | VARCHAR(100) | Utilisateur |
| `event_timestamp` | TIMESTAMP | â€” |
| `event_details` | TEXT | DÃ©tails/diff |

### `STR_SUBMITTED_PAYLOAD`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `payload_id` (PK) | BIGINT AUTO | â€” |
| `str_report_id` (FK) | BIGINT | â€” |
| `submission_id` (FK) | BIGINT | â€” |
| `payload_json` | TEXT | Copie intÃ©grale du JSON soumis |
| `payload_hash` | VARCHAR(64) | SHA-256 du payload (intÃ©gritÃ©) |
| `created_at` | TIMESTAMP | â€” |

# SECTION 5 â€” Diagramme relationnel

```mermaid
erDiagram
    STR_REPORT ||--o{ STR_PPP_PROJECT : "1â†’N"
    STR_REPORT ||--o{ STR_RELATED_REPORT : "1â†’N"
    STR_REPORT ||--o{ STR_DEFINITION : "1â†’N"
    STR_REPORT ||--|{ STR_TRANSACTION : "1â†’N (min 1)"
    STR_REPORT ||--o{ STR_API_SUBMISSION : "1â†’N"
    STR_REPORT ||--o{ STR_VALIDATION_ERROR : "1â†’N"
    STR_REPORT ||--o{ STR_AUDIT_EVENT : "1â†’N"

    STR_RELATED_REPORT ||--o{ STR_RELATED_REPORT_TXN_REF : "1â†’N"

    STR_DEFINITION ||--o| STR_PERSON : "1â†’0..1"
    STR_DEFINITION ||--o| STR_ENTITY : "1â†’0..1"

    STR_PERSON ||--o{ STR_ADDRESS : "1â†’N"
    STR_PERSON ||--o{ STR_PHONE : "1â†’N"
    STR_PERSON ||--o{ STR_IDENTIFICATION : "1â†’N"

    STR_ENTITY ||--o{ STR_ADDRESS : "1â†’N"
    STR_ENTITY ||--o{ STR_PHONE : "1â†’N"
    STR_ENTITY ||--o{ STR_IDENTIFICATION : "1â†’N"
    STR_ENTITY ||--o{ STR_INCORPORATION : "1â†’N"
    STR_ENTITY ||--o{ STR_REGISTRATION : "1â†’N"
    STR_ENTITY ||--o{ STR_BENEFICIAL_OWNER : "1â†’N"
    STR_ENTITY ||--o{ STR_PERSON_AUTHORIZED : "1â†’N (max 3)"

    STR_BENEFICIAL_OWNER ||--o{ STR_ADDRESS : "1â†’N"
    STR_BENEFICIAL_OWNER ||--o{ STR_PHONE : "1â†’N"

    STR_TRANSACTION ||--|{ STR_STARTING_ACTION : "1â†’N (min 1)"
    STR_TRANSACTION ||--o{ STR_COMPLETING_ACTION : "1â†’N"

    STR_STARTING_ACTION ||--o| STR_ACCOUNT : "1â†’0..1"
    STR_STARTING_ACTION ||--o{ STR_VC_ADDRESS : "1â†’N"
    STR_STARTING_ACTION ||--o{ STR_CONDUCTOR : "1â†’N"
    STR_STARTING_ACTION ||--o{ STR_SOURCE_OF_FUNDS : "1â†’N"

    STR_CONDUCTOR ||--o{ STR_ON_BEHALF_OF : "1â†’N"

    STR_COMPLETING_ACTION ||--o| STR_ACCOUNT : "1â†’0..1"
    STR_COMPLETING_ACTION ||--o{ STR_VC_ADDRESS : "1â†’N"
    STR_COMPLETING_ACTION ||--o{ STR_INVOLVEMENT : "1â†’N"
    STR_COMPLETING_ACTION ||--o{ STR_BENEFICIARY : "1â†’N"

    STR_ACCOUNT ||--o{ STR_ACCOUNT_HOLDER : "1â†’N"

    STR_API_SUBMISSION ||--o| STR_SUBMITTED_PAYLOAD : "1â†’1"
```

### RÃ©sumÃ© des cardinalitÃ©s

| Relation | CardinalitÃ© | Source |
|----------|------------|--------|
| STR_REPORT â†’ STR_TRANSACTION | 1â†’N (min 1) | Swagger: `transactions` required array |
| STR_REPORT â†’ STR_DEFINITION | 1â†’N | Swagger: `definitions` array |
| STR_REPORT â†’ STR_RELATED_REPORT | 1â†’0..N | Swagger: `relatedReports` optional array |
| STR_TRANSACTION â†’ STR_STARTING_ACTION | 1â†’N (min 1) | Swagger: `startingActions` required |
| STR_TRANSACTION â†’ STR_COMPLETING_ACTION | 1â†’0..N | Guidance: required si complÃ©tÃ©e |
| STR_STARTING_ACTION â†’ STR_CONDUCTOR | 1â†’0..N | Swagger: `conductors` array |
| STR_STARTING_ACTION â†’ STR_SOURCE_OF_FUNDS | 1â†’0..N | Swagger: array |
| STR_CONDUCTOR â†’ STR_ON_BEHALF_OF | 1â†’0..N | Swagger: `onBehalfOfs` array |
| STR_COMPLETING_ACTION â†’ STR_BENEFICIARY | 1â†’0..N | Swagger: `beneficiaries` array |
| STR_COMPLETING_ACTION â†’ STR_INVOLVEMENT | 1â†’0..N | Swagger: `involvements` array |
| STR_DEFINITION â†’ STR_PERSON | 1â†’0..1 | Si typeCode 1,3,5 |
| STR_DEFINITION â†’ STR_ENTITY | 1â†’0..1 | Si typeCode 2,4,6 |
| STR_ENTITY â†’ STR_BENEFICIAL_OWNER | 1â†’0..N | Si typeCode 6 |
| STR_ENTITY â†’ STR_PERSON_AUTHORIZED | 1â†’0..3 | Max 3 par le Swagger |

---

# SECTION 6 â€” Dictionnaire de donnÃ©es dÃ©taillÃ© (extrait principal)

> Le dictionnaire complet couvre toutes les tables de la Section 4. Ci-dessous les tables principales.

## 6.1 STR_REPORT

| Colonne | Description mÃ©tier | Type SQL | Nullable | Valeur permise / enum | RÃ¨gle de validation | JSON CANAFE | Exemple |
|---------|-------------------|----------|----------|----------------------|---------------------|-------------|---------|
| `str_report_id` | ClÃ© primaire interne | BIGINT | Non | Auto-incrÃ©mentÃ© | PK | â€” | 10001 |
| `report_type_code` | Type de rapport CANAFE | SMALLINT | Non | 102 | Toujours 102 pour STR | `reportDetails.reportTypeCode` | 102 |
| `submit_type_code` | Type de soumission | SMALLINT | Non | 1=Submit, 2=Update, 5=Delete | Enum fermÃ© | `reportDetails.submitTypeCode` | 1 |
| `activity_sector_code` | Secteur d'activitÃ© | SMALLINT | Non | 2=Banque, 3=Caisse populaire, 6=Co-op credit, 10=Assurance vie, 14=Credit union, 16=Trust/Loan, 19=CU central, 20=Financial services coop | Enum CANAFE | `reportDetails.activitySectorCode` | 2 |
| `reporting_entity_number` | # CANAFE 7 chiffres | VARCHAR(7) | Non | `^\d{7}$` | Exactement 7 chiffres | `reportDetails.reportingEntityNumber` | 1234567 |
| `re_report_reference` | RÃ©fÃ©rence unique du rapport | VARCHAR(100) | Non | `^[A-Za-z0-9_-]{1,100}$` | UnicitÃ© globale | `reportDetails.reportingEntityReportReference` | STR-2026-00142 |
| `suspicion_type_code` | Type de suspicion | SMALLINT | Oui | 1-7 | Requis si pas directive ministÃ©rielle | `detailsOfSuspicion.suspicionTypeCode` | 1 |
| `suspicious_activity_desc` | Narratif de suspicion | TEXT | Oui | Texte libre max ~20000 car. | Pas d'acronymes internes, pas de formatting | `detailsOfSuspicion.descriptionOfSuspiciousActivity` | "Le client a effectuÃ©..." |
| `action_taken_desc` | Actions prises | TEXT | Oui | Texte libre | Requis si pas directive | `actionTaken.description` | "Monitoring renforcÃ©..." |
| `ministerial_directive_code` | Directive ministÃ©rielle | VARCHAR(10) | Oui | IR2020 | Si renseignÃ©: 1 seule txn, pas de suspicion | `reportDetails.ministerialDirectiveCode` | null |

## 6.2 STR_TRANSACTION

| Colonne | Description mÃ©tier | Type SQL | Nullable | RÃ¨gle de validation | JSON CANAFE | Exemple |
|---------|-------------------|----------|----------|---------------------|-------------|---------|
| `re_location_id` | # localisation CANAFE | VARCHAR(30) | Non | AssignÃ© par CANAFE Ã  l'enrÃ´lement | `reportingEntityLocationId` | LOC001 |
| `attempted_indicator` | Transaction tentÃ©e? | BOOLEAN | Non | true/false | `attemptedTransactionIndicator` | false |
| `reason_not_completed` | Raison non complÃ©tÃ©e | VARCHAR(200) | Oui | Requis si attempted=true | `reasonNotCompleted` | null |
| `date_of_transaction` | Date de transaction | DATE | Oui | Pas dans le futur, â‰  date posting | `dateOfTransaction` | 2026-06-15 |
| `time_of_transaction` | Heure avec fuseau | VARCHAR(25) | Oui | Format HH:MM:SSÂ±ZZ:ZZ | `timeOfTransaction` | 13:25:06-05:00 |
| `method_code` | MÃ©thode de transaction | SMALLINT | Oui | 1-12 | `methodCode` | 1 |
| `re_txn_reference` | RÃ©fÃ©rence unique txn | VARCHAR(100) | Oui | Unique dans le rapport | `reportingEntityTransactionReference` | TXN-2026-A1 |

## 6.3 STR_STARTING_ACTION

| Colonne | Description mÃ©tier | Type SQL | Nullable | RÃ¨gle | JSON CANAFE | Exemple |
|---------|-------------------|----------|----------|-------|-------------|---------|
| `direction_code` | Direction des fonds | SMALLINT | Non | 1=In, 2=Out | `direction` | 1 |
| `fund_type_code` | Type de fonds/actif/VC | SMALLINT | Oui | 1-17 (selon direction) | `fundAssetVirtualCurrencyTypeCode` | 2 |
| `amount` | Montant | DECIMAL(18,2) | Non | >0 | `amount` | 9900.00 |
| `currency_code` | Code devise ISO 4217 | VARCHAR(3) | Oui | CAD, USD, EUR... | `currencyCode` | CAD |

## 6.4 STR_PERSON

| Colonne | Description mÃ©tier | Type SQL | Nullable | RÃ¨gle | JSON CANAFE | Exemple |
|---------|-------------------|----------|----------|-------|-------------|---------|
| `surname` | Nom de famille | VARCHAR(100) | Oui | Si nom unique: givenName=XXX | `surname` | Green |
| `given_name` | PrÃ©nom | VARCHAR(100) | Oui | â€” | `givenName` | Jennifer |
| `alias` | Alias/surnom | VARCHAR(100) | Oui | â€” | `alias` | Jenny |
| `date_of_birth` | Date de naissance | DATE | Oui | Pas dans le futur | `dateOfBirth` | 1985-03-15 |
| `occupation` | Profession dÃ©taillÃ©e | VARCHAR(200) | Oui | Descriptif, pas juste un code | `occupation` | Hotel reservations manager |
| `employer_name` | Nom de l'employeur | VARCHAR(200) | Oui | Nom d'entreprise, pas superviseur | `nameOfEmployer` | Blue Moon Hotel Inc. |

---

# SECTION 7 â€” Mapping relationnel vers JSON CANAFE

## 7.1 StratÃ©gie de mapping

Le mapping des tables relationnelles vers le JSON STRReport suit une approche **bottom-up avec assemblage par Ã©tapes** :

```
1. Assembler les STR_DEFINITION â†’ definitions[]
2. Assembler chaque STR_STARTING_ACTION avec ses conductors, sources, accounts â†’ startingActions[]
3. Assembler chaque STR_COMPLETING_ACTION avec ses beneficiaries, involvements â†’ completingActions[]
4. Assembler chaque STR_TRANSACTION avec ses starting/completing actions â†’ transactions[]
5. Assembler le rapport racine avec reportDetails, detailsOfSuspicion, relatedReports, actionTaken, definitions[], transactions[]
```

## 7.2 Gestion des definitions[] (pattern de rÃ©fÃ©rencement)

Le pattern `definitions[]` est le concept clÃ© du schÃ©ma CANAFE. Chaque personne/entitÃ© est dÃ©finie **une seule fois** avec un `refId` unique, puis rÃ©fÃ©rencÃ©e partout par ce `refId`.

**RÃ¨gle d'assemblage :**
```sql
-- Pour chaque STR_DEFINITION liÃ©e au rapport:
SELECT d.ref_id, d.type_code,
       p.surname, p.given_name, ...  -- si personne
       e.entity_name, ...            -- si entitÃ©
       addr.*, phone.*, id.*         -- dÃ©tails associÃ©s
FROM STR_DEFINITION d
LEFT JOIN STR_PERSON p ON p.definition_id = d.definition_id
LEFT JOIN STR_ENTITY e ON e.definition_id = d.definition_id
...
WHERE d.str_report_id = ?
```

**JSON rÃ©sultant :**
```json
{
  "definitions": [
    {
      "typeCode": 5,
      "refId": "person-green-01",
      "details": {
        "personDetails": { "surname": "Green", "givenName": "Jennifer", ... },
        "employerDetails": { "nameOfEmployer": "...", ... }
      }
    }
  ]
}
```

## 7.3 Gestion des arrays

| Array JSON | Table source | Jointure |
|------------|-------------|----------|
| `transactions[]` | STR_TRANSACTION | `WHERE str_report_id = ?` |
| `startingActions[]` | STR_STARTING_ACTION | `WHERE transaction_id = ?` |
| `completingActions[]` | STR_COMPLETING_ACTION | `WHERE transaction_id = ?` |
| `conductors[]` | STR_CONDUCTOR | `WHERE starting_action_id = ?` |
| `onBehalfOfs[]` | STR_ON_BEHALF_OF | `WHERE conductor_id = ?` |
| `beneficiaries[]` | STR_BENEFICIARY | `WHERE completing_action_id = ?` |
| `involvements[]` | STR_INVOLVEMENT | `WHERE completing_action_id = ?` |
| `sourcesOfFundsOrVirtualCurrency[]` | STR_SOURCE_OF_FUNDS | `WHERE starting_action_id = ?` |
| `relatedReports[]` | STR_RELATED_REPORT | `WHERE str_report_id = ?` |
| `definitions[]` | STR_DEFINITION + enfants | `WHERE str_report_id = ?` |

## 7.4 Gestion des rÃ´les multiples d'une mÃªme personne

Une mÃªme personne physique peut Ãªtre conducteur d'une transaction et bÃ©nÃ©ficiaire d'une autre (ex: Mme Green dÃ©pose de l'argent dans son propre compte).

**StratÃ©gie :** Utiliser le **mÃªme `refId`** dans `definitions[]` et le rÃ©fÃ©rencer dans les deux rÃ´les.

```json
{
  "definitions": [
    { "typeCode": 5, "refId": "green-01", "details": { ... } }
  ],
  "transactions": [{
    "startingActions": [{
      "conductors": [{ "typeCode": 5, "refId": "green-01", ... }]
    }],
    "completingActions": [{
      "beneficiaries": [{ "typeCode": 3, "refId": "green-01", ... }]
    }]
  }]
}
```

> **Attention :** Le `typeCode` dans le rÃ´le peut diffÃ©rer du `typeCode` dans la dÃ©finition. Le `refId` reste le lien.

## 7.5 Gestion de plusieurs transactions dans un mÃªme STR

Chaque transaction est un objet distinct dans l'array `transactions[]`. Chaque transaction a ses propres starting/completing actions, mais peut rÃ©fÃ©rencer les mÃªmes personnes via `refId`.

## 7.6 Gestion des rapports liÃ©s

Assembler `relatedReports[]` Ã  partir de `STR_RELATED_REPORT` et `STR_RELATED_REPORT_TXN_REF` :

```json
{
  "relatedReports": [
    {
      "reportingEntityReportReference": "STR-2026-00100",
      "reportingEntityTransactionReferences": ["TXN-A1", "TXN-A2"]
    }
  ]
}
```

## 7.7 CohÃ©rence champs structurÃ©s / narration

**RÃ¨gle critique :** Toute information mentionnÃ©e dans le narratif (`descriptionOfSuspiciousActivity`) doit aussi Ãªtre renseignÃ©e dans les champs structurÃ©s correspondants. CANAFE considÃ¨re comme un dÃ©faut de conformitÃ© le fait de rÃ©sumer les transactions uniquement dans le narratif sans les dÃ©clarer dans les champs structurÃ©s.

**ContrÃ´le recommandÃ© :**
- VÃ©rifier que chaque personne mentionnÃ©e dans le narratif a un `refId` dans `definitions[]`
- VÃ©rifier que chaque transaction mentionnÃ©e dans le narratif est dans `transactions[]`
- VÃ©rifier que les montants du narratif concordent avec les champs `amount`

---

# SECTION 8 â€” Exemple de pseudo-payload JSON

> âš ï¸ DonnÃ©es entiÃ¨rement fictives. Certains noms de champs sont basÃ©s sur l'analyse du Swagger; le nom exact doit Ãªtre confirmÃ© dans la documentation technique CANAFE.

```json
{
  "reportDetails": {
    "reportTypeCode": 102,
    "submitTypeCode": 1,
    "activitySectorCode": 2,
    "reportingEntityNumber": "1234567",
    "submittingReportingEntityNumber": "1234567",
    "reportingEntityReportReference": "STR-2026-00142",
    "reportingEntityContactId": "CONTACT-001"
  },
  "detailsOfSuspicion": {
    "descriptionOfSuspiciousActivity": "Le 15 juin 2026, Mme Jennifer Green a deposÃ© 9 900 dollars canadiens en espÃ¨ces dans son compte d'epargne Ã  la succursale 1 de la Banque Exemple. Le depot est juste sous le seuil de 10 000 dollars. Mme Green a change plusieurs fois son explication pour le depot. Son historique de revenus n'est pas coherent avec les montants deposes. Ces elements constituent des motifs raisonnables de soupconner que la transaction est liee au blanchiment d'argent.",
    "suspicionTypeCode": 1,
    "politicallyExposedPersonIncludedIndicator": false
  },
  "relatedReports": [],
  "actionTaken": {
    "description": "Monitoring transactionnel renforce sur le compte de Mme Green. Les activites seront revues dans les 30 prochains jours."
  },
  "definitions": [
    {
      "typeCode": 5,
      "refId": "person-green-01",
      "details": {
        "personDetails": {
          "surname": "Green",
          "givenName": "Jennifer",
          "dateOfBirth": "1985-03-15",
          "countryOfResidence": "CA",
          "countryOfCitizenship": "CA",
          "occupation": "Restaurant server",
          "address": {
            "buildingNumber": "456",
            "streetAddress": "Rue Principale",
            "city": "Montreal",
            "provinceStateCode": "QC",
            "country": "CA",
            "postalZipCode": "H2X 1Y4"
          },
          "telephoneNumber": "1-514-555-1234",
          "emailAddress": "j.green@example.ca",
          "identifications": [
            {
              "identifierType": "DriversLicense",
              "numberAssociatedWithIdentifierType": "G1234-567890-12",
              "jurisdictionOfIssueCountry": "CA",
              "jurisdictionOfIssueProvinceState": "QC"
            }
          ]
        },
        "employerDetails": {
          "nameOfEmployer": "Restaurant Le Bon Gout Inc."
        }
      }
    }
  ],
  "transactions": [
    {
      "reportingEntityLocationId": "LOC-BRANCH-001",
      "suspiciousTransactionDetails": {
        "attemptedTransactionIndicator": false,
        "dateOfTransaction": "2026-06-15",
        "timeOfTransaction": "14:30:00-04:00",
        "methodCode": 1,
        "reportingEntityTransactionReference": "TXN-2026-A1",
        "purposeOfTransaction": "Cash deposit into savings account"
      },
      "startingActions": [
        {
          "details": {
            "direction": 1,
            "fundAssetVirtualCurrencyTypeCode": 2,
            "amount": 9900.00,
            "currencyCode": "CAD",
            "sourcesOfFundsOrVirtualCurrencyIndicator": false,
            "conductorIndicator": true,
            "howFundsOrVirtualCurrencyObtained": "Employment tips"
          },
          "conductors": [
            {
              "typeCode": 5,
              "refId": "person-green-01",
              "details": {
                "onBehalfOfIndicator": false
              }
            }
          ]
        }
      ],
      "completingActions": [
        {
          "details": {
            "dispositionCode": 1,
            "amount": 9900.00,
            "currencyCode": "CAD",
            "account": {
              "financialInstitutionNumber": "001",
              "branchNumber": "12345",
              "accountNumber": "9876543-21",
              "accountType": "Savings",
              "accountCurrency": "CAD",
              "dateAccountOpened": "2020-01-15",
              "accountHolders": [
                { "typeCode": 1, "refId": "person-green-01" }
              ]
            },
            "beneficiaryIndicator": true
          },
          "beneficiaries": [
            {
              "typeCode": 3,
              "refId": "person-green-01",
              "details": {}
            }
          ]
        }
      ]
    }
  ]
}
```

> **Note importante :** Les noms exacts des propriÃ©tÃ©s JSON (camelCase, nesting exact) doivent Ãªtre validÃ©s contre le schÃ©ma OpenAPI officiel accessible via le portail API CANAFE aprÃ¨s enrÃ´lement. L'exemple ci-dessus est basÃ© sur l'analyse du Swagger public et de la guidance officielle.

# SECTION 9 â€” RÃ¨gles de validation et contrÃ´les qualitÃ©

## 9.1 ContrÃ´les obligatoires avant soumission

### PrÃ©sence des champs obligatoires

| ContrÃ´le | RÃ¨gle | PrioritÃ© |
|----------|-------|----------|
| `reportDetails.reportTypeCode` | Doit Ãªtre 102 | BLOQUANT |
| `reportDetails.submitTypeCode` | Doit Ãªtre 1, 2 ou 5 | BLOQUANT |
| `reportDetails.reportingEntityNumber` | Exactement 7 chiffres | BLOQUANT |
| `reportDetails.reportingEntityReportReference` | Non vide, unique, pattern `^[A-Za-z0-9_-]{1,100}$` | BLOQUANT |
| `transactions[]` | Au moins 1 transaction | BLOQUANT |
| `transactions[].startingActions[]` | Au moins 1 par transaction | BLOQUANT |
| `transactions[].suspiciousTransactionDetails.attemptedTransactionIndicator` | Requis | BLOQUANT |
| `detailsOfSuspicion.descriptionOfSuspiciousActivity` | Requis sauf directive ministÃ©rielle | BLOQUANT |
| `detailsOfSuspicion.suspicionTypeCode` | Requis sauf directive ministÃ©rielle | BLOQUANT |
| `actionTaken.description` | Requis sauf directive ministÃ©rielle | BLOQUANT |

### Format des dates

| ContrÃ´le | RÃ¨gle |
|----------|-------|
| `dateOfTransaction` | Format ISO 8601 (YYYY-MM-DD), pas dans le futur |
| `timeOfTransaction` | Format HH:MM:SSÂ±ZZ:ZZ |
| `dateOfPosting` | â‰  `dateOfTransaction`, pas dans le futur |
| `dateOfBirth` | Pas dans le futur |
| `dateAccountOpened` | Avant `dateAccountClosed` si les deux prÃ©sents |

### Montants et devises

| ContrÃ´le | RÃ¨gle |
|----------|-------|
| `amount` (starting/completing) | > 0, DECIMAL(18,2) |
| `currencyCode` | Code ISO 4217 valide ou "Other" + spÃ©cification |
| `exchangeRate` | > 0 si prÃ©sent |
| `valueInCanadianDollars` | Requis si disposition non monÃ©taire (bijoux, mÃ©taux) |
| CohÃ©rence montant starting vs completing | Ã€ vÃ©rifier si une seule SA/CA |

### CohÃ©rence des rÃ´les et parties

| ContrÃ´le | RÃ¨gle |
|----------|-------|
| Chaque `refId` dans conductors/beneficiaries/etc. | Doit exister dans `definitions[]` |
| `typeCode` du rÃ´le vs `typeCode` de la dÃ©finition | CohÃ©rence (conducteur = 5 ou 6, bÃ©nÃ©ficiaire = 3 ou 4) |
| `conductorIndicator` = true | Au moins 1 conductor dans `conductors[]` |
| `onBehalfOfIndicator` = true | Au moins 1 entry dans `onBehalfOfs[]` |
| `beneficiaryIndicator` = true | Au moins 1 entry dans `beneficiaries[]` |
| `involvementIndicator` = true | Au moins 1 entry dans `involvements[]` |
| `sourcesOfFundsOrVirtualCurrencyIndicator` = true | Au moins 1 entry dans `sourcesOfFundsOrVirtualCurrency[]` |

### CohÃ©rence personnes / entitÃ©s

| ContrÃ´le | RÃ¨gle |
|----------|-------|
| Personne avec nom unique | `givenName` = "XXX", `surname` = nom rÃ©el |
| Occupation | Descriptive (pas juste un code NOC) |
| Champs non applicables | Laisser vide â€” ne pas mettre "N/A", "x", "-", "unknown" |
| Adresse | StructurÃ©e OU non structurÃ©e, pas les deux |
| TÃ©lÃ©phone | Format: CC-CCC-CCCC-CCCC |

### PrÃ©sence des narratifs

| ContrÃ´le | RÃ¨gle |
|----------|-------|
| `descriptionOfSuspiciousActivity` | Non vide (sauf directive ministÃ©rielle) |
| Pas d'acronymes internes | VÃ©rification textuelle |
| Pas de rÃ©fÃ©rences internes | Pas de # de dossier interne |
| Pas de formatting | Pas de HTML/markdown/bold/italic |

### Directive ministÃ©rielle

| ContrÃ´le | RÃ¨gle |
|----------|-------|
| Si `ministerialDirectiveCode` renseignÃ© | Exactement 1 transaction, pas de suspicion, pas d'action |
| Transaction sous directive | Doit Ãªtre complÃ©tÃ©e (pas attempted), avec SA et CA |

### Domaines de valeurs (enums)

| Champ | Valeurs permises |
|-------|-----------------|
| `suspicionTypeCode` | 1, 2, 3, 4, 5, 6, 7 |
| `methodCode` | 1-12 |
| `direction` | 1 (In), 2 (Out) |
| `fundAssetVirtualCurrencyTypeCode` | 1-17 |
| `dispositionCode` | 1-32 |
| `typeOfDeviceCode` | 1-4 |
| `relationshipOfConductorCode` | 1-14 |
| `activitySectorCode` | 2, 3, 6, 10, 14, 16, 19, 20 (+ autres Ã  confirmer) |

### Doublons

| ContrÃ´le | RÃ¨gle |
|----------|-------|
| `reportingEntityReportReference` | UnicitÃ© globale â€” jamais rÃ©utilisÃ© |
| `refId` dans definitions | Unique dans le rapport |
| `reportingEntityTransactionReference` | Unique dans le rapport |

### Gestion des erreurs API

| Code HTTP | Action |
|-----------|--------|
| 200 | SuccÃ¨s â€” stocker l'acknowledgement |
| 400 | Erreur de validation â€” parser les erreurs, corriger, resoumettre |
| 401/403 | Erreur d'authentification â€” vÃ©rifier les clÃ©s API |
| 500 | Erreur serveur â€” retry avec backoff exponentiel |

---

# SECTION 10 â€” Architecture cible minimale

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    SYSTÃˆME AML / CASE MANAGEMENT            â”‚
â”‚  (Investigation, scoring, alertes, workflow interne)        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â”‚ DÃ©cision: soumettre STR
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              COUCHE D'EXTRACTION / MAPPING                  â”‚
â”‚  - Extract des donnÃ©es du case AML                          â”‚
â”‚  - Mapping vers le modÃ¨le cible STR                         â”‚
â”‚  - Enrichissement (KYC, comptes, identifications)           â”‚
â”‚  - RÃ©daction du narratif (assistance ou manuel)             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   BASE DE DONNÃ‰ES CIBLE STR                 â”‚
â”‚  Tables: STR_REPORT, STR_TRANSACTION, STR_DEFINITION,       â”‚
â”‚  STR_PERSON, STR_ENTITY, STR_STARTING_ACTION, etc.          â”‚
â”‚  (ModÃ¨le Section 4)                                         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                  MOTEUR DE VALIDATION                       â”‚
â”‚  - Champs obligatoires                                      â”‚
â”‚  - Formats (dates, montants, tÃ©lÃ©phones)                    â”‚
â”‚  - Enums / domaines de valeurs                              â”‚
â”‚  - CohÃ©rence inter-champs                                   â”‚
â”‚  - CohÃ©rence refId definitions â†” rÃ´les                     â”‚
â”‚  - RÃ©sultat: PASS / FAIL + dÃ©tails erreurs                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   GÃ‰NÃ‰RATEUR JSON                           â”‚
â”‚  - Assemblage bottom-up (Section 7)                         â”‚
â”‚  - SÃ©rialisation JSON conforme au schÃ©ma CANAFE             â”‚
â”‚  - Validation contre le schÃ©ma OpenAPI (optionnel)          â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   CLIENT API CANAFE                         â”‚
â”‚  - Authentification (clÃ©s secrÃ¨tes via portail API)         â”‚
â”‚  - POST /api/v1/reports                                     â”‚
â”‚  - Gestion TLS, timeout, retry                              â”‚
â”‚  - Parsing de la rÃ©ponse                                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              JOURNALISATION & STOCKAGE                      â”‚
â”‚  - STR_API_SUBMISSION: statut, code HTTP, rÃ©ponse           â”‚
â”‚  - STR_SUBMITTED_PAYLOAD: copie JSON + hash SHA-256         â”‚
â”‚  - STR_VALIDATION_ERROR: erreurs CANAFE parsÃ©es             â”‚
â”‚  - STR_AUDIT_EVENT: trace de chaque action                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚               MÃ‰CANISME DE CORRECTION                       â”‚
â”‚  - Charger le rapport existant                              â”‚
â”‚  - Modifier les donnÃ©es                                     â”‚
â”‚  - submitTypeCode = 2 (Update)                              â”‚
â”‚  - Resoumettre dans les 20 jours                            â”‚
â”‚  - Journaliser la correction et sa raison                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Composants et responsabilitÃ©s

| Composant | ResponsabilitÃ© | Technologie recommandÃ©e |
|-----------|---------------|------------------------|
| Base cible STR | Stockage normalisÃ© | PostgreSQL / Oracle |
| Moteur de validation | RÃ¨gles mÃ©tier prÃ©-soumission | Java/Python + bibliothÃ¨que de rÃ¨gles |
| GÃ©nÃ©rateur JSON | Assemblage du payload | Service dÃ©diÃ© avec mapping ORM |
| Client API | Communication HTTPS avec CANAFE | Client HTTP avec auth OAuth2/API Key |
| Journalisation | Audit trail complet | Tables dÃ©diÃ©es + logs applicatifs |
| Conservation | Copie 5 ans minimum | Archivage du JSON soumis avec hash |

---

# SECTION 11 â€” Recommandations d'implÃ©mentation

## 11.1 ModÃ©lisation relationnelle vs JSON natif

**Recommandation : ModÃ¨le relationnel normalisÃ©** (tel que proposÃ© en Section 4).

| Approche | Avantages | InconvÃ©nients |
|----------|-----------|---------------|
| Relationnel normalisÃ© | RequÃªtable, indexable, auditable, validable par contraintes SQL | Plus de tables, mapping JSON nÃ©cessaire |
| JSON natif (JSONB) | FidÃ©litÃ© directe au schÃ©ma CANAFE, moins de mapping | Difficile Ã  requÃªter, valider, auditer |
| **Hybride (recommandÃ©)** | Tables relationnelles + colonne JSONB pour payload soumis | Meilleur des deux mondes |

## 11.2 Historisation

- Chaque modification d'un STR_REPORT doit crÃ©er un Ã©vÃ©nement dans `STR_AUDIT_EVENT`
- Conserver le payload JSON de chaque soumission dans `STR_SUBMITTED_PAYLOAD`
- Ne jamais supprimer physiquement un rapport â€” utiliser un statut `DELETED` ou `ARCHIVED`
- Conservation minimum : **5 ans** aprÃ¨s soumission (obligation lÃ©gale)

## 11.3 Gestion des versions du schÃ©ma CANAFE

- Stocker la version du schÃ©ma utilisÃ©e dans chaque rapport
- Maintenir un mÃ©canisme de migration si CANAFE modifie le schÃ©ma
- Surveiller les mises Ã  jour du Swagger et les bulletins techniques CANAFE
- Tester dans l'**environnement de test CANAFE** avant toute mise en production

## 11.4 SÃ©paration donnÃ©es structurÃ©es / narratifs

- Les narratifs (`descriptionOfSuspiciousActivity`, `actionTaken.description`) sont des champs TEXT libres
- Les stocker sÃ©parÃ©ment permet une rÃ©daction indÃ©pendante du remplissage structurÃ©
- ImplÃ©menter un contrÃ´le de cohÃ©rence narratif â†” donnÃ©es structurÃ©es

## 11.5 Gestion des erreurs de validation

- **PrÃ©-soumission** : Moteur de validation interne (Section 9)
- **Post-soumission** : Parser la rÃ©ponse API CANAFE et stocker dans `STR_VALIDATION_ERROR`
- ImplÃ©menter un workflow de correction avec notification
- Le rapport corrigÃ© doit Ãªtre soumis dans les **20 jours**

## 11.6 Gouvernance des enums

- CrÃ©er des **tables de rÃ©fÃ©rence** pour chaque enum CANAFE (`REF_SUSPICION_TYPE`, `REF_METHOD_CODE`, `REF_DISPOSITION_CODE`, etc.)
- Mettre Ã  jour ces tables lorsque CANAFE publie de nouvelles valeurs
- Utiliser des contraintes FK pour empÃªcher les valeurs invalides

## 11.7 Tests unitaires de gÃ©nÃ©ration JSON

- Test unitaire pour chaque type de dÃ©finition (PersonName, EntityDetails, etc.)
- Test d'intÃ©gration pour un rapport complet avec multiple transactions
- Validation du JSON gÃ©nÃ©rÃ© contre le schÃ©ma OpenAPI
- Tests de rÃ©gression lors des mises Ã  jour du schÃ©ma
- Utiliser les scÃ©narios de l'Annex B de la guidance CANAFE comme cas de test

## 11.8 Environnement de test CANAFE

- CANAFE fournit un **Report Ingest Test API** pour valider les soumissions
- Utiliser cet environnement pour chaque release
- Tester les cas limites : transactions tentÃ©es, directive ministÃ©rielle, monnaie virtuelle
- Contacter `tech@fintrac-canafe.gc.ca` pour support technique

## 11.9 StratÃ©gie de preuve / audit

- **Non-rÃ©pudiation** : Hash SHA-256 du payload soumis
- **TraÃ§abilitÃ©** : Chaque action (crÃ©ation, Ã©dition, validation, soumission) est journalisÃ©e avec utilisateur et timestamp
- **IntÃ©gritÃ©** : La copie du JSON soumis est immuable
- **Preuve de soumission** : Stocker la rÃ©ponse API CANAFE (acknowledgement ID, timestamp)
- **Preuve de conservation** : MÃ©canisme d'archivage avec rÃ©tention 5 ans

---

# SECTION 12 â€” Liste des zones Ã  confirmer

> Les Ã©lÃ©ments suivants nÃ©cessitent une validation auprÃ¨s de CANAFE, dans le Swagger authentifiÃ© (portail API), ou dans la documentation technique officielle.

## 12.1 Champs ambigus

| Ã‰lÃ©ment | AmbiguÃ¯tÃ© | Source |
|---------|-----------|--------|
| `definitions[].typeCode` | La correspondance exacte typeCode â†” structure JSON imbriquÃ©e doit Ãªtre validÃ©e dans le schÃ©ma OpenAPI authentifiÃ© | Swagger public limitÃ© |
| `accountType` enum values | La liste complÃ¨te des types de comptes n'est pas visible dans le Swagger public | Ã€ confirmer dans le portail API |
| `accountStatusAtTimeOfTransaction` | Format libre ou enum ? (active, inactive, dormant, closed mentionnÃ©s dans la guidance mais pas comme enum formel) | Guidance vs Swagger |
| `virtualCurrencyTypeCode` | Liste complÃ¨te des codes VC non exposÃ©e publiquement | Portail API |

## 12.2 RÃ¨gles conditionnelles non explicites

| RÃ¨gle | Question |
|-------|----------|
| Night deposit / Quick drop | Exemption du conductor â€” le champ `conductorIndicator` doit-il Ãªtre `false` automatiquement ? |
| Transaction tentÃ©e | Les champs mandatory (*) deviennent-ils tous "reasonable measures" ? Comment le schÃ©ma JSON gÃ¨re-t-il ce changement de cardinalitÃ© ? |
| Directive ministÃ©rielle | La validation API rejette-t-elle si `detailsOfSuspicion` est renseignÃ© avec une directive ? |

## 12.3 CardinalitÃ©s non Ã©videntes

| Ã‰lÃ©ment | Question |
|---------|----------|
| `transactions[]` maximum | Y a-t-il une limite au nombre de transactions par rapport ? (guidance mentionne des limites de soumission) |
| `definitions[]` maximum | Limite au nombre de dÃ©finitions ? |
| `personsAuthorized[]` | Maximum 3 confirmÃ© par guidance, mais validÃ© par le schÃ©ma ? |
| `completingActions[]` minimum | Requis pour transaction complÃ©tÃ©e, optionnel pour tentÃ©e ? |

## 12.4 Valeurs permises non exposÃ©es

| Enum | Statut |
|------|--------|
| `activitySectorCode` | Liste partielle connue (2,3,6,10,14,16,19,20) â€” liste complÃ¨te Ã  confirmer |
| `currencyCode` | ISO 4217 supposÃ© â€” confirmÃ© ? Ou sous-ensemble CANAFE ? |
| `identifierType` | Liste fermÃ©e ou ouverte avec "Other" ? |
| `accountType` | Liste fermÃ©e ou ouverte avec "Other" ? |
| `relationshipOfConductorCode` | 1-14 visible, signification exacte de chaque code Ã  confirmer |
| `publicPrivatePartnershipProjectNameCodes` | Liste de 8 codes visible â€” peut Ã©voluer |

## 12.5 Contraintes API non visibles

| Ã‰lÃ©ment | Question |
|---------|----------|
| Rate limiting | Combien de rapports par minute/heure ? |
| Taille maximale du payload | Limite en Ko/Mo du JSON ? |
| Authentification | OAuth2, API Key, ou autre mÃ©canisme ? |
| Idempotence | Que se passe-t-il si le mÃªme `reportingEntityReportReference` est soumis deux fois ? |
| RÃ©ponse API | Structure exacte de la rÃ©ponse (acknowledgement ID, erreurs) ? |
| Certificats TLS | Mutual TLS requis ? |

## 12.6 Exigences de correction / modification

| Ã‰lÃ©ment | Question |
|---------|----------|
| `submitTypeCode = 2` (Update) | Faut-il renvoyer le rapport complet ou seulement les champs modifiÃ©s ? |
| `submitTypeCode = 5` (Delete) | Quelles conditions permettent la suppression ? |
| DÃ©lai de correction | 20 jours confirmÃ© dans la guidance â€” validÃ© dans l'API ? |
| Raison de modification | OÃ¹/comment fournir la raison du changement dans le JSON ? |
| Versioning | CANAFE conserve-t-il l'historique des versions ? |

## 12.7 Ã‰lÃ©ments du schÃ©ma non confirmÃ©s publiquement

| Ã‰lÃ©ment | Statut |
|---------|--------|
| Structure exacte de `details` dans `definitions[]` selon `typeCode` | SchÃ©ma polymorphe (oneOf) Ã  valider dans le Swagger authentifiÃ© |
| `strAccount` â€” structure exacte des champs imbriquÃ©s | Ã€ confirmer |
| Noms exacts des propriÃ©tÃ©s JSON (camelCase) | BasÃ©s sur l'analyse du Swagger public â€” Ã  valider |
| Champs `required` dans les sous-objets | La profondeur des validations requises n'est pas entiÃ¨rement visible publiquement |

---

## Contacts CANAFE pour validation

| Besoin | Contact |
|--------|---------|
| Questions techniques API | tech@fintrac-canafe.gc.ca |
| AccÃ¨s au portail API | F2R@fintrac-canafe.gc.ca |
| Questions rÃ©glementaires | guidelines-lignesdirectrices@fintrac-canafe.gc.ca |
| TÃ©lÃ©phone | 1-866-346-8722 |

