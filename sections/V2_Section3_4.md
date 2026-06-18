---

# SECTION 3 — Structure logique du payload STRReport (corrigée YAML)

```
STRReport (additionalProperties: false)
├── reportDetails (required, additionalProperties: false)
│   ├── reportTypeCode: integer (102) ← required
│   ├── submitTypeCode: integer (1|2|5) ← required
│   ├── activitySectorCode: integer (28 valeurs)
│   ├── reportingEntityNumber: number ← required
│   ├── submittingReportingEntityNumber: number ← required
│   ├── reportingEntityReportReference: string ^[A-Za-z0-9-_]{1,100}$ ← required
│   ├── reportingEntityContactId: number ← required
│   └── ministerialDirectiveCode: string (IR2020)
│
├── detailsOfSuspicion (required, additionalProperties: false)
│   ├── descriptionOfSuspiciousActivity: string
│   ├── suspicionTypeCode: integer (1-7)
│   ├── publicPrivatePartnershipProjectNameCodes: integer[] ← required (vide OK)
│   └── politicallyExposedPersonIncludedIndicator: boolean
│
├── relatedReports: [] (required, vide OK)
│   └── [n] (additionalProperties: false)
│       ├── reportingEntityReportReference: string ← required
│       └── reportingEntityTransactionReferences: string[] ← required
│
├── actionTaken (NOT required)
│   └── description: string
│
├── definitions: [] (required, vide OK)
│   └── [n] oneOf:
│       ├── PersonName (typeCode=1): refId, givenName, surname, otherNameInitial
│       ├── EntityName (typeCode=2): refId, nameOfEntity
│       ├── PersonDetails (typeCode=3): refId, names, alias, phone, DOB, address, identifications[]
│       ├── EntityDetails (typeCode=4): refId, nameOfEntity, phone, address, identifications[], authorizedPersons[], registrationsIncorporations[]
│       ├── personAndEmployerDetails (typeCode=5): refId, names, alias, address, phone, DOB, countryOfResidence/Citizenship, occupation, identifications[], employerInformation{name, address, phone}
│       └── entityAndBeneficialOwnershipDetails (typeCode=6): refId, nameOfEntity, address, phone, identifications[], authorizedPersons[], structureTypeCode, registrationsIncorporations[], directorsOfCorporation[], personsOwningSharesOfCorporation[], trusteesOfTrust[], settlorsOfTrust[], personsOwningUnitsOfTrust[], beneficiariesOfTrust[], personsOwningEntityNotCorporationOrTrust[]
│
└── transactions: [] (required, minItems: 1)
    └── [n] (additionalProperties: false)
        ├── reportingEntityLocationId: string30 ← required
        ├── suspiciousTransactionDetails (required, additionalProperties: false)
        │   ├── attemptedTransactionIndicator: boolean ← required
        │   ├── reasonNotCompleted: string200
        │   ├── dateOfTransaction: localDate
        │   ├── timeOfTransaction: zonedTime
        │   ├── methodCode: integer (1-12)
        │   ├── methodOther: string200
        │   ├── dateOfPosting: localDate
        │   ├── timeOfPosting: zonedTime
        │   ├── reportingEntityTransactionReference: string ^[A-Za-z0-9-_]{1,200}$
        │   └── purpose: string200
        │
        ├── startingActions: [] (required)
        │   └── [n] (additionalProperties: false)
        │       ├── details (required, additionalProperties: false)
        │       │   ├── direction: integer (1=In | 2=Out)
        │       │   ├── fundAssetVirtualCurrencyTypeCode: integer
        │       │   ├── fundAssetVirtualCurrencyTypeOther: string200
        │       │   ├── amount: string (pattern)
        │       │   ├── currencyCode: CurrencyCode
        │       │   ├── virtualCurrencyTypeCode, virtualCurrencyTypeOther
        │       │   ├── exchangeRate: string (pattern)
        │       │   ├── virtualCurrencyTransactionIds: string[] ← required (vide OK)
        │       │   ├── sendingVirtualCurrencyAddresses: string[] ← required (vide OK)
        │       │   ├── receivingVirtualCurrencyAddresses: string[] ← required (vide OK)
        │       │   ├── referenceNumber, referenceNumberOtherRelatedNumber: string200
        │       │   ├── account: strAccount
        │       │   ├── accountStatusAtTimeOfTransaction: integer (1-4)
        │       │   ├── howFundsOrVirtualCurrencyObtained: string200
        │       │   ├── sourcesOfFundsOrVirtualCurrencyIndicator: boolean
        │       │   └── conductorIndicator: boolean
        │       │
        │       ├── sourcesOfFundsOrVirtualCurrency: [] (required, vide OK)
        │       │   └── [n]: typeCode (1|2), refId, details{accountNumber, policyNumber, identifyingNumber}
        │       │
        │       └── conductors: [] (required, vide OK)
        │           └── [n]: typeCode (5|6), refId, details{...deviceInfo, onBehalfOfIndicator},
        │               onBehalfOfs: [] (required, vide OK)
        │               └── [n]: typeCode (5|6), refId, details{clientNumber, email, url, relationshipCode}
        │
        └── completingActions: [] (required, vide OK)
            └── [n] (additionalProperties: false)
                ├── details (required, additionalProperties: false)
                │   ├── dispositionCode: integer (28 valeurs)
                │   ├── dispositionOther: string200
                │   ├── amount: string (pattern)
                │   ├── currencyCode, virtualCurrencyTypeCode/Other, exchangeRate
                │   ├── valueInCanadianDollars: string (pattern)
                │   ├── virtualCurrencyTransactionIds: string[] ← required (vide OK)
                │   ├── sendingVirtualCurrencyAddresses: string[] ← required (vide OK)
                │   ├── receivingVirtualCurrencyAddresses: string[] ← required (vide OK)
                │   ├── referenceNumber, referenceNumberOtherRelatedNumber
                │   ├── account: strAccount
                │   ├── accountStatusAtTimeOfTransaction: integer (1-4)
                │   ├── involvementIndicator: boolean
                │   └── beneficiaryIndicator: boolean
                │
                ├── involvements: [] (required, vide OK)
                │   └── [n]: typeCode (1|2), refId, details{accountNumber, identifyingNumber, policyNumber}
                │
                └── beneficiaries: [] (required, vide OK)
                    └── [n]: typeCode (3|4), refId, details{clientNumber, username, emailAddress}
```

---

# SECTION 4 — Modèle de données cible (34 tables — corrigé YAML)

## 4.1 DOMAINE RAPPORT (4 tables)

### STR_REPORT

| Colonne | Type SQL | Null | Validation | YAML |
|---------|----------|------|-----------|------|
| `str_report_id` | BIGINT PK | Non | Auto | — |
| `report_type_code` | SMALLINT | Non | = 102 | `reportDetails.reportTypeCode` |
| `submit_type_code` | SMALLINT | Non | 1, 2, 5 | `reportDetails.submitTypeCode` |
| `activity_sector_code` | SMALLINT | Oui | 28 valeurs | `reportDetails.activitySectorCode` |
| `reporting_entity_number` | NUMERIC(7) | Non | 7 chiffres | `reportDetails.reportingEntityNumber` |
| `submitting_re_number` | NUMERIC(7) | Non | — | `reportDetails.submittingReportingEntityNumber` |
| `re_report_reference` | VARCHAR(100) | Non | regex, unique | `reportDetails.reportingEntityReportReference` |
| `re_contact_id` | NUMERIC | Non | — | `reportDetails.reportingEntityContactId` |
| `ministerial_directive_code` | VARCHAR(10) | Oui | IR2020 | `reportDetails.ministerialDirectiveCode` |
| `suspicion_type_code` | SMALLINT | Oui | 1-7 | `detailsOfSuspicion.suspicionTypeCode` |
| `suspicious_activity_desc` | TEXT | Oui | — | `detailsOfSuspicion.descriptionOfSuspiciousActivity` |
| `pep_included_indicator` | BOOLEAN | Oui | — | `detailsOfSuspicion.politicallyExposedPersonIncludedIndicator` |
| `action_taken_desc` | TEXT | Oui | — | `actionTaken.description` |
| `status` | VARCHAR(20) | Non | Interne | — |
| `created_at` | TIMESTAMP | Non | — | — |
| `submitted_at` | TIMESTAMP | Oui | — | — |

### STR_PPP_PROJECT

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `ppp_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `project_name_code` | SMALLINT | Non | `detailsOfSuspicion.publicPrivatePartnershipProjectNameCodes[n]` |

### STR_RELATED_REPORT

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `related_report_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `re_report_reference` | VARCHAR(100) | Non | `relatedReports[n].reportingEntityReportReference` |

### STR_RELATED_REPORT_TXN_REF

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `id` | BIGINT PK | Non | — |
| `related_report_id` | BIGINT FK | Non | — |
| `txn_reference` | VARCHAR(200) | Non | `relatedReports[n].reportingEntityTransactionReferences[n]` |

## 4.2 DOMAINE DÉFINITIONS (4 tables)

### STR_DEFINITION

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `definition_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `ref_id` | VARCHAR(50) | Non | `definitions[n].refId` — unique dans le rapport |
| `type_code` | SMALLINT | Non | `definitions[n].typeCode` (1-6) |

### STR_PERSON (typeCode 1, 3, 5)

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `person_id` | BIGINT PK | Non | — |
| `definition_id` | BIGINT FK UNIQUE | Non | — |
| `surname` | VARCHAR(100) | Oui | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_name_initial` | VARCHAR(100) | Oui | `otherNameInitial` |
| `alias` | VARCHAR(100) | Oui | `alias` (tc 3,5) |
| `telephone_number` | VARCHAR(20) | Oui | `telephoneNumber` (tc 3,5) |
| `extension_number` | VARCHAR(10) | Oui | `extensionNumber` (tc 3,5) |
| `date_of_birth` | VARCHAR(10) | Oui | `dateOfBirth` (tc 3,5) |
| `country_of_residence_code` | VARCHAR(2) | Oui | `countryOfResidenceCode` (tc 3,5) |
| `country_of_citizenship_code` | VARCHAR(2) | Oui | `countryOfCitizenshipCode` (tc 5 seul) |
| `occupation` | VARCHAR(200) | Oui | `occupation` (tc 3,5) |
| `name_of_employer` | VARCHAR(100) | Oui | `nameOfEmployer` (tc 3 seul) |
| `address_type_code` | SMALLINT | Oui | `addressTypeCode` (tc 3,5) |

### STR_EMPLOYER_INFO (typeCode 5 seulement)

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `employer_id` | BIGINT PK | Non | — |
| `person_id` | BIGINT FK UNIQUE | Non | — |
| `name` | VARCHAR(100) | Oui | `employerInformation.name` |
| `address_type_code` | SMALLINT | Oui | `employerInformation.addressTypeCode` |
| `telephone_number` | VARCHAR(20) | Oui | `employerInformation.telephoneNumber` |
| `extension_number` | VARCHAR(10) | Oui | `employerInformation.extensionNumber` |

### STR_ENTITY (typeCode 2, 4, 6)

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `entity_id` | BIGINT PK | Non | — |
| `definition_id` | BIGINT FK UNIQUE | Non | — |
| `name_of_entity` | VARCHAR(100) | Oui | `nameOfEntity` |
| `telephone_number` | VARCHAR(20) | Oui | `telephoneNumber` (tc 4,6) |
| `extension_number` | VARCHAR(10) | Oui | `extensionNumber` (tc 4,6) |
| `nature_of_principal_business` | VARCHAR(200) | Oui | `natureOfPrincipalBusiness` (tc 4,6) |
| `address_type_code` | SMALLINT | Oui | `addressTypeCode` (tc 4,6) |
| `structure_type_code` | SMALLINT | Oui | `structureTypeCode` (tc 6) enum 1-4 |
| `structure_type_other` | VARCHAR(200) | Oui | `structureTypeOther` (tc 6) |
| `registration_incorporation_indicator` | BOOLEAN | Oui | `registrationIncorporationIndicator` (tc 4,6) |

## 4.3 DOMAINE IDENTITÉ (2 tables partagées)

### STR_ADDRESS

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `address_id` | BIGINT PK | Non | — |
| `owner_type` | VARCHAR(20) | Non | PERSON, ENTITY, EMPLOYER, DIRECTOR, etc. |
| `owner_id` | BIGINT | Non | FK polymorphe |
| `type_code` | SMALLINT | Non | 1=Structured, 2=Unstructured |
| `unit_number` | VARCHAR(10) | Oui | `unitNumber` |
| `building_number` | VARCHAR(10) | Oui | `buildingNumber` |
| `street_address` | VARCHAR(100) | Oui | `streetAddress` |
| `city` | VARCHAR(100) | Oui | `city` |
| `district` | VARCHAR(100) | Oui | `district` |
| `province_state_code` | VARCHAR(10) | Oui | `provinceStateCode` |
| `province_state_name` | VARCHAR(100) | Oui | `provinceStateName` |
| `sub_province_sub_locality` | VARCHAR(100) | Oui | `subProvinceSubLocality` |
| `postal_zip_code` | VARCHAR(20) | Oui | `postalZipCode` |
| `country_code` | VARCHAR(2) | Oui | `countryCode` |
| `unstructured` | VARCHAR(500) | Oui | `unstructured` (si type_code=2) |

### STR_IDENTIFICATION

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `identification_id` | BIGINT PK | Non | — |
| `owner_type` | VARCHAR(20) | Non | PERSON ou ENTITY |
| `owner_id` | BIGINT | Non | FK polymorphe |
| `identifier_type_code` | SMALLINT | Oui | enum (17 codes personne, 7 codes entité) |
| `identifier_type_other` | VARCHAR(200) | Oui | `identifierTypeOther` |
| `number` | VARCHAR(100) | Oui | `number` |
| `jurisdiction_country_code` | VARCHAR(2) | Oui | `jurisdictionOfIssueCountryCode` |
| `jurisdiction_province_state_code` | VARCHAR(10) | Oui | `jurisdictionOfIssueProvinceStateCode` |
| `jurisdiction_province_state_name` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceStateName` |

## 4.4 DOMAINE ENTITÉ — DÉTAILS (2 tables)

### STR_REGISTRATION_INCORPORATION

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `reg_inc_id` | BIGINT PK | Non | — |
| `entity_id` | BIGINT FK | Non | — |
| `type_code` | SMALLINT | Oui | 1=Reg, 2=Inc, 4=Both, 5=Unknown |
| `number` | VARCHAR(100) | Oui | `number` |
| `jurisdiction_country_code` | VARCHAR(2) | Oui | `jurisdictionOfIssueCountryCode` |
| `jurisdiction_province_state_code` | VARCHAR(10) | Oui | `jurisdictionOfIssueProvinceStateCode` |
| `jurisdiction_province_state_name` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceStateName` |

### STR_AUTHORIZED_PERSON

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `auth_id` | BIGINT PK | Non | — |
| `entity_id` | BIGINT FK | Non | — |
| `surname` | VARCHAR(100) | Oui | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_name_initial` | VARCHAR(100) | Oui | `otherNameInitial` |

## 4.5 DOMAINE BENEFICIAL OWNERSHIP — typeCode 6 (7 tables)

### STR_DIRECTOR (personContact)

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `director_id` | BIGINT PK | Non | — |
| `entity_id` | BIGINT FK | Non | — |
| `surname` | VARCHAR(100) | Oui | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_name_initial` | VARCHAR(100) | Oui | `otherNameInitial` |
| `address_type_code` | SMALLINT | Oui | `addressTypeCode` |
| `telephone_number` | VARCHAR(20) | Oui | `telephoneNumber` |
| `extension_number` | VARCHAR(10) | Oui | `extensionNumber` |

### STR_SHARE_OWNER (nom seulement)

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `share_owner_id` | BIGINT PK | Non | — |
| `entity_id` | BIGINT FK | Non | — |
| `surname` | VARCHAR(100) | Oui | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_name_initial` | VARCHAR(100) | Oui | `otherNameInitial` |

### STR_TRUSTEE, STR_SETTLOR, STR_TRUST_UNIT_OWNER, STR_TRUST_BENEFICIARY

> Même structure que STR_DIRECTOR (personContact) : surname, givenName, otherNameInitial, addressTypeCode, telephoneNumber, extensionNumber + adresse via STR_ADDRESS.

### STR_OTHER_ENTITY_OWNER (nom seulement)

> Même structure que STR_SHARE_OWNER : surname, givenName, otherNameInitial.

