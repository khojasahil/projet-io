# CORRECTIONS ET PRÉCISIONS — Post-analyse du swaggerExternal.yaml officiel

> Ce document identifie les **différences exactes** entre l'analyse initiale et le YAML officiel téléchargé.
> **Date :** 2026-06-16  
> **Source :** `swaggerExternal.yaml` (261 794 octets, 6 883 lignes)

---

## 1. CORRECTIONS SUR LES NOMS DE PROPRIÉTÉS JSON

Les noms camelCase exacts du YAML officiel diffèrent parfois de ceux utilisés dans l'analyse initiale.

| Propriété dans l'analyse initiale | Nom exact dans le YAML officiel | Emplacement |
|----------------------------------|--------------------------------|-------------|
| `otherInitial` | **`otherNameInitial`** | PersonName, PersonDetails, personAndEmployerDetails |
| `entityName` | **`nameOfEntity`** | EntityName, EntityDetails, entityAndBeneficialOwnershipDetails |
| `countryOfResidence` | **`countryOfResidenceCode`** | PersonDetails, personAndEmployerDetails |
| `countryOfCitizenship` | **`countryOfCitizenshipCode`** | personAndEmployerDetails (typeCode 5 seulement) |
| `nameOfEmployer` | **`employerInformation.name`** | personAndEmployerDetails (objet imbriqué) |
| `natureOfEntityPrincipalBusiness` | **`natureOfPrincipalBusiness`** | EntityDetails, entityAndBeneficialOwnershipDetails |
| `entityStructureType` | **`structureTypeCode`** (integer enum!) | entityAndBeneficialOwnershipDetails |
| `incorporatedOrRegistered` | **`registrationIncorporationIndicator`** (boolean) + `registrationsIncorporations[]` | EntityDetails, entityAndBeneficialOwnershipDetails |
| `accountNumber` (dans strAccount) | **`number`** | strAccount |
| `accountType` | **`typeCode`** (integer enum) | strAccount |
| `accountCurrency` | **`currencyCode`** | strAccount |
| `telephoneNumber` (adresse) | **`telephoneNumber`** ✅ confirmé | Partout |
| `extension` | **`extensionNumber`** | Partout |
| `otherReferenceNumber` | **`referenceNumberOtherRelatedNumber`** | starting/completing actions |
| `purposeOfTransaction` | **`purpose`** | suspiciousTransactionDetails |
| `dateAccountOpened` | **`dateOpened`** | strAccount |
| `dateAccountClosed` | **`dateClosed`** | strAccount |

---

## 2. CORRECTIONS SUR LES STRUCTURES (nesting)

### 2.1 `personAndEmployerDetails` (typeCode 5)
L'employeur est un **objet imbriqué** `employerInformation`, pas des champs plats :

```yaml
employerInformation:
  type: object
  properties:
    name: string100          # nom de l'employeur
    addressTypeCode: enum    # 1=structured, 2=unstructured
    address: oneOf           # StructuredAddress | UnstructuredAddress
    telephoneNumber: string20
    extensionNumber: string10
```

### 2.2 `entityAndBeneficialOwnershipDetails` (typeCode 6)
Le YAML officiel définit des **arrays séparés** par type de beneficial ownership :

```yaml
directorsOfCorporation: personContact[]     # Directeurs
personsOwningSharesOfCorporation: [surname, givenName, otherNameInitial][]  # 25%+ shares
trusteesOfTrust: personContact[]            # Fiduciaires
settlorsOfTrust: personContact[]            # Constituants
personsOwningUnitsOfTrust: personContact[]  # 25%+ units
beneficiariesOfTrust: personContact[]       # Bénéficiaires fiducie
personsOwningEntityNotCorporationOrTrust: [surname, givenName, otherNameInitial][]  # 25%+ autres
```

**Tous sont `required`** dans le schéma (peuvent être des arrays vides `[]`).

Le type `personContact` contient: `surname`, `givenName`, `otherNameInitial`, `addressTypeCode`, `address`, `telephoneNumber`, `extensionNumber`.

### 2.3 Address est polymorphe via `addressTypeCode`
L'adresse utilise un **discriminateur** `addressTypeCode` :
- `1` → `StructuredAddress` (unitNumber, buildingNumber, streetAddress, city, district, provinceStateCode, provinceStateName, subProvinceSubLocality, postalZipCode, countryCode)
- `2` → `UnstructuredAddress` (countryCode, unstructured max500)

Le champ `addressTypeCode` est **séparé** de l'objet address et doit être fourni au même niveau.

---

## 3. CORRECTIONS SUR LES ENUMS

### 3.1 `activitySectorCode` — Liste complète officielle (28 codes, pas 8)

| Code | Description EN | Description FR |
|------|---------------|---------------|
| 1 | Accountant | Comptable |
| 2 | Bank | Banque |
| 3 | Caisse populaire | Caisse populaire |
| 4 | Crown agent | Mandataire de Sa Majesté |
| 5 | Casino | Casino |
| 6 | Co-op credit society | Coopérative de crédit |
| 9 | Life insurance broker or agent | Courtier ou agent d'assurance-vie |
| 10 | Life insurance company | Société d'assurance-vie |
| 11 | Money services business | Entreprise de services monétaires |
| 12 | Provincial savings office | Caisse d'épargne provinciale |
| 13 | Real estate | Secteur de l'immobilier |
| 14 | Credit union | Caisse d'épargne et de crédit |
| 15 | Securities dealer | Courtier en valeurs mobilières |
| 16 | Trust and/or loan company | Société de fiducie et/ou de prêt |
| 17 | British Columbia notary | Notaire de la Colombie-Britannique |
| 18 | Dealer in precious metals and stones | Négociant en pierres et métaux précieux |
| 19 | Credit union central | Centrale de caisses de crédit |
| 20 | Financial services cooperative | Coopératives de services financiers |
| 21 | Foreign money services business | ESM étrangère |
| 22 | Mortgage administrators | Administrateurs hypothécaires |
| 24 | Mortgage brokers | Courtiers hypothécaires |
| 25 | Mortgage lenders | Prêteurs hypothécaires |
| 26 | Factor | Affactureur |
| 27 | Financing or Leasing Entities | Entité de financement ou de bail |
| 28 | Title Insurer | Assureurs de titres |

> **Note :** Codes 7, 8, 23 absents de l'enum.

### 3.2 `fundAssetVirtualCurrencyTypeCode` — Le code 15 n'existe PAS
L'enum officiel est : `[1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17]` — **pas de 15**.
- Quand `direction=1` (In): `[1,2,3,4,5,6,8,9,10,11,12,13,14,16,17]`
- Quand `direction=2` (Out): `[3,7,9,16,17]`

### 3.3 `dispositionCode` — Le code 2, 12, 13, 16 n'existent PAS
L'enum officiel est : `[1,3,4,5,6,7,8,9,10,11,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]`

| Code | Disposition (corrections) |
|------|--------------------------|
| 1 | Deposit to account / Dépôt au compte |
| 3 | Exchange to fiat currency / Échange en monnaie fiduciaire |
| 4 | Purchase of casino product / Achat de produits de casino |
| 5 | Purchase of bank draft / Achat de traite bancaire |
| 6 | Purchase of money order / Achat de mandat |
| 7 | Life insurance policy purchase/deposit |
| 8 | Investment product purchase/deposit |
| 9 | Real estate purchase/deposit |
| 10 | Cash out / Encaissement |
| 11 | Other / Autre |
| 14 | Purchase of jewellery / Achat de bijoux |
| 15 | Purchase precious metals / Métaux précieux |
| 17 | Added to virtual currency wallet |
| 18 | Exchange to virtual currency |
| 19 | Outgoing virtual currency transfer |
| 20 | Outgoing email money transfer |
| 21 | Holding funds |
| 22 | Purchase of precious stones |
| 23 | Issued cheque |
| 24 | Outgoing domestic funds transfer |
| 25 | Outgoing international funds transfer |
| 26 | Purchase of prepaid payment product/card |
| 27 | Denomination exchange |
| 28 | Payment to account |
| 29 | Purchase of / Payment for goods |
| 30 | Purchase of / Payment for services |
| 31 | Outgoing mobile money transfer |
| 32 | Cash withdrawal (account based) |

### 3.4 `structureTypeCode` (entité) — Enum integer, pas string

| Code | Type |
|------|------|
| 1 | Corporation |
| 2 | Entity other than a corporation or trust |
| 3 | Trust |
| 4 | Widely held or publicly traded trust |

### 3.5 `accountStatusAtTimeOfTransaction` — Enum integer (pas string)

| Code | Statut |
|------|--------|
| 1 | Active |
| 2 | Inactive |
| 3 | Dormant |
| 4 | Closed |

### 3.6 `IncorporationRegistrationTypeCode`

| Code | Type |
|------|------|
| 1 | Registered |
| 2 | Incorporated |
| 4 | Registered and incorporated |
| 5 | Unknown |

### 3.7 `personIdentificationWithJurisdiction.identifierTypeCode`

| Code | Type |
|------|------|
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
| 35 | Government issued identification |
| 36 | Insurance documents |
| 37 | Provincial or territorial identity card |
| 38 | Record of employment |
| 39 | Travel visa |
| 40 | Utility statement |

### 3.8 `entityIdentificationWithJurisdiction.identifierTypeCode`

| Code | Type |
|------|------|
| 1 | Articles of association |
| 2 | Certificate of corporate status |
| 3 | Certificate of incorporation |
| 4 | Letter/Notice of assessment |
| 5 | Partnership agreement |
| 6 | Annual report |
| 7 | Other |

### 3.9 `relationshipOfConductorCode` — Différences selon le contexte

**Pour les conductors (onBehalfOfs) :** `relationshipOfConductorCodeWithVendor` (1-14)
- Inclut `14` = Vendor/Supplier

**Pour les beneficiaries (completing actions) :** `relationshipOfConductorCodeWithSelf` (1-15)
- Inclut `14` = Vendor/Supplier ET `15` = Self/Moi

**Base sans vendor/self :** `relationshipOfConductorCode` (1-13)

---

## 4. CORRECTIONS SUR LES CHAMPS `required`

### 4.1 STRReport (racine)
```yaml
required:
  - reportDetails        # ✅
  - detailsOfSuspicion   # ⚠️ REQUIRED dans le schéma (était marqué optionnel)
  - relatedReports       # ⚠️ REQUIRED dans le schéma (peut être array vide [])
  - definitions          # ⚠️ REQUIRED dans le schéma (peut être array vide [])
  - transactions         # ✅
```

### 4.2 `reportDetails.required`
```yaml
required:
  - reportTypeCode
  - submitTypeCode
  - reportingEntityNumber
  - submittingReportingEntityNumber
  - reportingEntityReportReference
  - reportingEntityContactId
```
> `activitySectorCode` n'est **PAS required** dans le schéma (même s'il est mentionné comme mandatory dans la guidance). Il sera validé par les business rules CANAFE post-soumission.

### 4.3 `detailsOfSuspicion.required`
```yaml
required:
  - publicPrivatePartnershipProjectNameCodes  # ⚠️ Le champ PPP est REQUIRED (peut être array vide [])
```
> `descriptionOfSuspiciousActivity` et `suspicionTypeCode` ne sont **PAS** dans le `required` du schéma! Ils sont validés par les business rules.

### 4.4 Transaction `required`
```yaml
required:
  - reportingEntityLocationId
  - suspiciousTransactionDetails
  - startingActions
  - completingActions
```

### 4.5 Starting action `required`
```yaml
required:
  - details
  - sourcesOfFundsOrVirtualCurrency  # ⚠️ REQUIRED (peut être array vide [])
  - conductors                        # ⚠️ REQUIRED (peut être array vide [])
```

### 4.6 Starting action details `required`
```yaml
required:
  - virtualCurrencyTransactionIds      # ⚠️ REQUIRED (array, peut être vide [])
  - receivingVirtualCurrencyAddresses   # ⚠️ REQUIRED (array, peut être vide [])
  - sendingVirtualCurrencyAddresses     # ⚠️ REQUIRED (array, peut être vide [])
```

### 4.7 Conductor `required`
```yaml
required:
  - typeCode
  - refId
  - details        # ⚠️ Obligatoire
  - onBehalfOfs    # ⚠️ REQUIRED (peut être array vide [])
```

### 4.8 Completing action `required`
```yaml
required:
  - details
  - involvements    # ⚠️ REQUIRED (peut être array vide [])
  - beneficiaries   # ⚠️ REQUIRED (peut être array vide [])
```

### 4.9 entityAndBeneficialOwnershipDetails `required`
```yaml
required:
  - typeCode
  - refId
  - identifications                            # array vide OK
  - authorizedPersons                          # array vide OK
  - registrationsIncorporations                # array vide OK
  - directorsOfCorporation                     # array vide OK
  - personsOwningSharesOfCorporation           # array vide OK
  - trusteesOfTrust                            # array vide OK
  - settlorsOfTrust                            # array vide OK
  - personsOwningUnitsOfTrust                  # array vide OK
  - beneficiariesOfTrust                       # array vide OK
  - personsOwningEntityNotCorporationOrTrust   # array vide OK
```

---

## 5. CORRECTIONS SUR LES PATTERNS ET FORMATS

| Champ | Pattern officiel | Commentaire |
|-------|-----------------|-------------|
| `refId` | `^[A-Za-z0-9-_]{1,50}$` | Max 50 chars (pas 100 comme pour reportReference) |
| `externalReportReference` | `^[A-Za-z0-9-_]{1,100}$` | Confirmé max 100 |
| `externalTransactionReference` | `^[A-Za-z0-9-_]{1,200}$` | Max 200 (pas 100) |
| `currencyAmount` | `^\d{1,17}(\.\d{2,10})?$` | String, pas number! Max 17 entiers, 2-10 décimales |
| `exchangeRate` | `^\d{1,17}(\.\d{2,10})?$` | String, pas number! |
| `localDate` | `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` | YYYY-MM-DD |
| `zonedTime` | `^[0-9]{2}:[0-9]{2}:[0-9]{2}[\-\+][0-9]{2}:[0-9]{2}$` | HH:MM:SS±HH:MM |
| `zonedDateTime` | `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}[\-\+][0-9]{2}:[0-9]{2}$` | ISO 8601 |
| `reportingEntityNumber` | `type: number` | ⚠️ C'est un `number`, pas string! |
| `reportingEntityContactId` | `type: number` | ⚠️ C'est un `number`, pas string! |

---

## 6. CORRECTION SUR `additionalProperties: false`

Le YAML contient `additionalProperties: false` sur **presque tous les objets**. Cela signifie que CANAFE **rejettera** tout champ JSON non déclaré dans le schéma. Il est donc **interdit** d'ajouter des propriétés custom dans le payload.

---

## 7. CORRECTION SUR L'AUTHENTIFICATION API

Le YAML contient le schema `AccessTokenResponse` :
```yaml
AccessTokenResponse:
  token_type: string        # "Bearer"
  expires_in: number
  ext_expires_in: number
  access_token: string
```

L'authentification utilise un **token OAuth2 / bearer token**.

---

## 8. CORRECTION SUR LA RÉPONSE D'ERREUR DE VALIDATION

```yaml
ErrorWithValidation:
  code: number              # HTTP status code
  message:
    en: string              # "You need to correct the following issues..."
    fr: string              # "Vous devez corriger les erreurs suivantes..."
  payload:
    validationMessages:     # Array de SchemaValidationMessages
      - instancePath: string    # ex: "/transactions/0/startingActions/0/details/amount"
        schemaPath: string
        keyword: string
        params: object
        message:
          en: string
          fr: string
```

---

## 9. IMPACT SUR LE MODÈLE DE DONNÉES

Les corrections ci-dessus nécessitent les ajustements suivants au modèle SQL :

### Table STR_REPORT
- `reporting_entity_number` → type `NUMERIC(7)` (pas VARCHAR)
- `re_contact_id` → type `NUMERIC` (pas VARCHAR)

### Table STR_PERSON
- `other_initial` → renommer en `other_name_initial` (pour fidélité au YAML)
- Ajouter `country_of_citizenship_code` (présent dans typeCode 5 uniquement)
- `employer_name` → supprimer, remplacer par lien vers objet `STR_EMPLOYER_INFO`

### Nouvelle table STR_EMPLOYER_INFO
Pour le typeCode 5 (personAndEmployerDetails), l'employeur est un objet imbriqué :
- `name`, `address` (structurée/non), `telephoneNumber`, `extensionNumber`

### Table STR_ENTITY
- `entity_name` → `name_of_entity` (fidélité YAML)
- `entity_structure_type` → `structure_type_code` (integer enum 1-4)
- `principal_business` → `nature_of_principal_business`
- `is_incorporated_registered` → `registration_incorporation_indicator` (boolean)

### Table STR_BENEFICIAL_OWNER → éclater en tables séparées
Le YAML utilise des arrays séparés, pas une table unique avec role_type :
- `STR_DIRECTOR` (directors of corporation)
- `STR_SHARE_OWNER` (persons owning 25%+ shares) — uniquement nom
- `STR_TRUSTEE` (trustees of trust) — personContact
- `STR_SETTLOR` (settlors of trust) — personContact
- `STR_TRUST_UNIT_OWNER` (25%+ trust units) — personContact
- `STR_TRUST_BENEFICIARY` (beneficiaries of trust) — personContact
- `STR_OTHER_ENTITY_OWNER` (25%+ other entity) — uniquement nom

### Table STR_ACCOUNT
- `account_number` → `number` (nom YAML)
- `account_type` → `type_code` (integer enum 1-5)
- `account_status` → `type: integer` enum 1-4 (pas string)

### Table STR_STARTING_ACTION
- `amount` → type `VARCHAR(28)` (string pattern, PAS DECIMAL!)
- `exchange_rate` → type `VARCHAR(28)` (string pattern)
- Ajouter: `virtualCurrencyTransactionIds`, `sendingVirtualCurrencyAddresses`, `receivingVirtualCurrencyAddresses` comme **required arrays** (peuvent être vides)

### Table STR_ADDRESS
- Restructurer: `addressTypeCode` (1 ou 2) au niveau parent, puis `StructuredAddress` OU `UnstructuredAddress`
- Champ `subProvinceLocality` → **`subProvinceSubLocality`**
- Adresse non structurée: `unstructured` (string500), pas `unstructuredAddressDetails`

