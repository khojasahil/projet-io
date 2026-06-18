# Modèle de données cible — STRReport CANAFE
## Document d'architecture V2 — Corrigé selon le swaggerExternal.yaml officiel

**Version :** 2.0  
**Date :** 2026-06-17  
**Sources analysées :**
- Swagger officiel : `https://www148.fintrac-canafe.canada.ca/swagger`
- YAML officiel téléchargé : `swaggerExternal.yaml` (261 794 octets, 6 883 lignes)
- Guidance STR officielle (Annex A) : `https://fintrac-canafe.canada.ca/guidance-directives/transaction-operation/str-dod/str-dod-eng`

---

# SECTION 1 — Résumé exécutif

## 1.1 Qu'est-ce qu'un STRReport ?

Un **STRReport** (Suspicious Transaction Report / Déclaration d'opérations douteuses — DOD) est un rapport réglementaire qu'une entité déclarante canadienne doit soumettre à **CANAFE / FINTRAC** lorsqu'elle a des motifs raisonnables de soupçonner qu'une transaction est liée au blanchiment d'argent, au financement du terrorisme ou à l'évasion de sanctions.

Le code de type de rapport dans l'API est **`reportTypeCode = 102`**.

## 1.2 Obligations légales

- **Loi** : Loi sur le recyclage des produits de la criminalité et le financement des activités terroristes (LRPCFAT)
- **Aucun seuil monétaire** — tout montant peut déclencher un STR
- **Délai** : Dès que praticable après évaluation des motifs raisonnables
- Depuis **août 2024**, l'obligation couvre aussi l'**évasion de sanctions**
- **Tipping off interdit** : Ne pas informer le client de la déclaration

## 1.3 Structure du payload JSON

L'API `POST /api/v1/reports` attend un payload JSON avec ces blocs **tous required** dans le schéma :

| Bloc JSON | Required | Description |
|-----------|----------|-------------|
| `reportDetails` | ✅ | Métadonnées (entité déclarante, références, secteur) |
| `detailsOfSuspicion` | ✅ | Narratif + type de suspicion + PPP codes |
| `relatedReports` | ✅ | Rapports liés (peut être `[]` vide) |
| `definitions` | ✅ | Catalogue polymorphe personnes/entités (peut être `[]`) |
| `transactions` | ✅ `minItems:1` | Transactions avec starting/completing actions |

> **Blocs NON required au niveau racine :** `actionTaken` (objet optionnel)

## 1.4 Périmètre du modèle

Ce document couvre **exclusivement** :
1. Stocker les données cibles alimentant le JSON STRReport
2. Valider la conformité avant soumission
3. Générer le payload JSON conforme au schéma CANAFE
4. Soumettre via l'API et journaliser les résultats

> **Hors périmètre** : Case management AML, scoring, alertes, workflow d'investigation.

---

# SECTION 2 — Compréhension fonctionnelle du STRReport (corrigée YAML)

## 2.1 reportDetails

| Champ YAML exact | Type YAML | Required | Description |
|------------------|-----------|----------|-------------|
| `reportTypeCode` | integer | ✅ | Toujours `102` pour STR |
| `submitTypeCode` | integer | ✅ | `1`=Submit, `2`=Update, `5`=Delete |
| `activitySectorCode` | integer | ❌ schéma | Enum 28 valeurs (validé par business rules) |
| `reportingEntityNumber` | **number** | ✅ | Numéro CANAFE 7 chiffres |
| `submittingReportingEntityNumber` | **number** | ✅ | Si soumis par un tiers |
| `reportingEntityReportReference` | string | ✅ | `^[A-Za-z0-9-_]{1,100}$` unique |
| `reportingEntityContactId` | **number** | ✅ | Contact pour suivi |
| `ministerialDirectiveCode` | string | ❌ | Seule valeur : `IR2020` |

### Enum `activitySectorCode` (28 valeurs officielles)

| Code | EN | FR |
|------|----|----|
| 1 | Accountant | Comptable |
| 2 | Bank | Banque |
| 3 | Caisse populaire | Caisse populaire |
| 4 | Crown agent | Mandataire de Sa Majesté |
| 5 | Casino | Casino |
| 6 | Co-op credit society | Coopérative de crédit |
| 9 | Life insurance broker/agent | Courtier/agent d'assurance-vie |
| 10 | Life insurance company | Société d'assurance-vie |
| 11 | Money services business | ESM |
| 12 | Provincial savings office | Caisse d'épargne provinciale |
| 13 | Real estate | Immobilier |
| 14 | Credit union | Caisse d'épargne et de crédit |
| 15 | Securities dealer | Courtier en valeurs mobilières |
| 16 | Trust and/or loan company | Société de fiducie/prêt |
| 17 | BC notary | Notaire C.-B. |
| 18 | Dealer precious metals/stones | Négociant pierres/métaux précieux |
| 19 | Credit union central | Centrale de caisses de crédit |
| 20 | Financial services cooperative | Coopérative de services financiers |
| 21 | Foreign MSB | ESM étrangère |
| 22 | Mortgage administrators | Administrateurs hypothécaires |
| 24 | Mortgage brokers | Courtiers hypothécaires |
| 25 | Mortgage lenders | Prêteurs hypothécaires |
| 26 | Factor | Affactureur |
| 27 | Financing/Leasing Entities | Entité de financement/bail |
| 28 | Title Insurer | Assureurs de titres |

> **Note :** Codes 7, 8, 23 absents de l'enum officiel.

## 2.2 detailsOfSuspicion

| Champ YAML exact | Type | Required schéma |
|------------------|------|----------------|
| `descriptionOfSuspiciousActivity` | string | ❌ (business rules) |
| `suspicionTypeCode` | integer enum 1-7 | ❌ (business rules) |
| `publicPrivatePartnershipProjectNameCodes` | integer[] | ✅ (peut être `[]`) |
| `politicallyExposedPersonIncludedIndicator` | boolean | ❌ |

### Enum `suspicionTypeCode`

| Code | Description |
|------|-------------|
| 1 | Blanchiment d'argent |
| 2 | Financement du terrorisme |
| 3 | Blanchiment + Financement terrorisme |
| 4 | Évasion de sanctions |
| 5 | Blanchiment + Évasion sanctions |
| 6 | Financement terrorisme + Évasion sanctions |
| 7 | Blanchiment + Financement terrorisme + Évasion sanctions |

### Enum `publicPrivatePartnershipProjectNameCodes`

| Code | Projet |
|------|--------|
| 1 | ANTON |
| 2 | ATHENA |
| 3 | CHAMELEON |
| 5 | GUARDIAN |
| 6 | LEGION |
| 7 | PROTECT |
| 8 | SHADOW |

## 2.3 relatedReports[]

Required au niveau racine (peut être `[]`).

| Champ | Type | Required |
|-------|------|----------|
| `reportingEntityReportReference` | string `^[A-Za-z0-9-_]{1,100}$` | ✅ |
| `reportingEntityTransactionReferences` | string[] `^[A-Za-z0-9-_]{1,200}$` | ✅ |

## 2.4 actionTaken

NON required au niveau racine. Objet simple :

| Champ | Type |
|-------|------|
| `description` | string (texte libre) |

## 2.5 definitions[] — Catalogue polymorphe

Required au niveau racine (peut être `[]`). Utilise `oneOf` pour 6 types :

| typeCode | Schéma YAML | Description |
|----------|------------|-------------|
| **1** | `PersonName` | Nom simple (surname, givenName, otherNameInitial) |
| **2** | `EntityName` | Nom d'entité simple (nameOfEntity) |
| **3** | `PersonDetails` | Personne détaillée (adresse, téléphone, DOB, occupation, identifications[]) |
| **4** | `EntityDetails` | Entité détaillée (adresse, registrations[], identifications[], authorizedPersons[]) |
| **5** | `personAndEmployerDetails` | Personne + employeur (objet imbriqué `employerInformation`) |
| **6** | `entityAndBeneficialOwnershipDetails` | Entité + BO complet (7 arrays de personnes) |

### Champs exacts par typeCode

**PersonName (1) :**
```yaml
typeCode: 1, refId, givenName, surname, otherNameInitial
```

**EntityName (2) :**
```yaml
typeCode: 2, refId, nameOfEntity
```

**PersonDetails (3) :**
```yaml
typeCode: 3, refId, givenName, surname, otherNameInitial, alias,
telephoneNumber, extensionNumber, dateOfBirth, countryOfResidenceCode,
occupation, nameOfEmployer, addressTypeCode, address (oneOf Structured|Unstructured),
identifications[] (required)
```

**EntityDetails (4) :**
```yaml
typeCode: 4, refId, nameOfEntity, telephoneNumber, extensionNumber,
natureOfPrincipalBusiness, addressTypeCode, address, identifications[] (required),
authorizedPersons[] (required), registrationIncorporationIndicator,
registrationsIncorporations[] (required)
```

**personAndEmployerDetails (5) :**
```yaml
typeCode: 5, refId, surname, givenName, otherNameInitial, alias,
addressTypeCode, address, telephoneNumber, extensionNumber,
dateOfBirth, countryOfResidenceCode, countryOfCitizenshipCode,
occupation, identifications[] (required),
employerInformation: { name, addressTypeCode, address, telephoneNumber, extensionNumber }
```

**entityAndBeneficialOwnershipDetails (6) :**
```yaml
typeCode: 6, refId, nameOfEntity, addressTypeCode, address,
telephoneNumber, extensionNumber, identifications[] (required),
authorizedPersons[] (required), structureTypeCode (enum 1-4),
structureTypeOther, natureOfPrincipalBusiness,
registrationIncorporationIndicator, registrationsIncorporations[] (required),
directorsOfCorporation[] (required), personsOwningSharesOfCorporation[] (required),
trusteesOfTrust[] (required), settlorsOfTrust[] (required),
personsOwningUnitsOfTrust[] (required), beneficiariesOfTrust[] (required),
personsOwningEntityNotCorporationOrTrust[] (required)
```

### Enum `structureTypeCode`

| Code | Type |
|------|------|
| 1 | Corporation |
| 2 | Entity other than corporation or trust |
| 3 | Trust |
| 4 | Widely held or publicly traded trust |

### Addresses — Polymorphisme via addressTypeCode

Le champ `addressTypeCode` est au même niveau que `address` :

**StructuredAddress (typeCode: 1) :**
```yaml
typeCode: 1, unitNumber (10), buildingNumber (10), streetAddress (100),
city (100), district (100), provinceStateCode, provinceStateName (100),
subProvinceSubLocality (100), postalZipCode (20), countryCode
```

**UnstructuredAddress (typeCode: 2) :**
```yaml
typeCode: 2, countryCode, unstructured (500)
```

### Identifications — Personnes vs Entités

**personIdentificationWithJurisdiction :**

| identifierTypeCode | Type |
|--------------------|------|
| 1 | Birth certificate |
| 2 | Passport |
| 3 | Other |
| 4 | Driver's licence |
| 5 | Provincial health card |
| 14 | Citizenship card |
| 15 | Certificate of Indian Status |
| 27 | Social Insurance Number card |
| 32 | Permanent resident card |
| 33 | Record of landing |
| 34 | Credit file |
| 35 | Government issued ID |
| 36 | Insurance documents |
| 37 | Provincial/territorial identity card |
| 38 | Record of employment |
| 39 | Travel visa |
| 40 | Utility statement |

Champs : `identifierTypeCode, identifierTypeOther, number, jurisdictionOfIssueCountryCode, jurisdictionOfIssueProvinceStateCode, jurisdictionOfIssueProvinceStateName`

**entityIdentificationWithJurisdiction :**

| identifierTypeCode | Type |
|--------------------|------|
| 1 | Articles of association |
| 2 | Certificate of corporate status |
| 3 | Certificate of incorporation |
| 4 | Letter/Notice of assessment |
| 5 | Partnership agreement |
| 6 | Annual report |
| 7 | Other |

### registrationIncorporation (entités)

| Champ | Type |
|-------|------|
| `typeCode` | enum: 1=Registered, 2=Incorporated, 4=Both, 5=Unknown |
| `number` | string100 |
| `jurisdictionOfIssueCountryCode` | CountryCode |
| `jurisdictionOfIssueProvinceStateCode` | ProvinceStateCode |
| `jurisdictionOfIssueProvinceStateName` | string100 |

## 2.6 transactions[]

Required, `minItems: 1`.

### suspiciousTransactionDetails

| Champ YAML exact | Type | Required |
|------------------|------|----------|
| `attemptedTransactionIndicator` | boolean | ✅ |
| `reasonNotCompleted` | string200 | ❌ |
| `dateOfTransaction` | localDate `YYYY-MM-DD` | ❌ |
| `timeOfTransaction` | zonedTime `HH:MM:SS±HH:MM` | ❌ |
| `methodCode` | integer enum 1-12 | ❌ |
| `methodOther` | string200 | ❌ |
| `dateOfPosting` | localDate | ❌ |
| `timeOfPosting` | zonedTime | ❌ |
| `reportingEntityTransactionReference` | string `^[A-Za-z0-9-_]{1,200}$` | ❌ |
| `purpose` | string200 | ❌ |

### Enum `methodCode`

| Code | EN | FR |
|------|----|----|
| 1 | In person | En personne |
| 2 | ABM | Guichet automatique |
| 3 | Armoured car | Véhicule blindé |
| 4 | Courier | Messager |
| 5 | Mail deposit | Poste |
| 6 | Telephone | Téléphone |
| 7 | Other | Autre |
| 8 | Night deposit | Dépôt de nuit |
| 9 | Quick drop | Dépôt express |
| 10 | Self-redemption kiosk | Guichet de rachat |
| 11 | Virtual currency ATM | GAB monnaie virtuelle |
| 12 | Online | En ligne |

### Transaction required fields

```yaml
required:
  - reportingEntityLocationId    # string30
  - suspiciousTransactionDetails
  - startingActions              # array, min 1 implicite
  - completingActions            # array, peut être []
```

