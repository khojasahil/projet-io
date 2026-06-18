# SECTION 4 — Modèle de données cible recommandé

> **Source :** Schéma STRReport du Swagger CANAFE + Guidance officielle Annex A

## 4.1 Table `STR_REPORT`

**Objectif :** Enregistrement principal d'un STRReport. Un enregistrement = un rapport soumis ou à soumettre.

| Colonne | Type SQL | Nullable | Validation | JSON CANAFE |
|---------|----------|----------|------------|-------------|
| `str_report_id` (PK) | BIGINT AUTO | Non | — | — (interne) |
| `report_type_code` | SMALLINT | Non | Toujours 102 | `reportDetails.reportTypeCode` |
| `submit_type_code` | SMALLINT | Non | 1,2,5 | `reportDetails.submitTypeCode` |
| `activity_sector_code` | SMALLINT | Non | Enum (2,3,6,10,14,16,19,20...) | `reportDetails.activitySectorCode` |
| `reporting_entity_number` | VARCHAR(7) | Non | 7 chiffres | `reportDetails.reportingEntityNumber` |
| `submitting_re_number` | VARCHAR(7) | Non | 7 chiffres | `reportDetails.submittingReportingEntityNumber` |
| `re_report_reference` | VARCHAR(100) | Non | Unique, `^[A-Za-z0-9-_]{1,100}$` | `reportDetails.reportingEntityReportReference` |
| `re_contact_id` | VARCHAR(100) | Non | — | `reportDetails.reportingEntityContactId` |
| `ministerial_directive_code` | VARCHAR(10) | Oui | Ex: IR2020 | `reportDetails.ministerialDirectiveCode` |
| `suspicion_type_code` | SMALLINT | Oui | 1-7 | `detailsOfSuspicion.suspicionTypeCode` |
| `suspicious_activity_desc` | TEXT | Oui | — | `detailsOfSuspicion.descriptionOfSuspiciousActivity` |
| `pep_included_indicator` | BOOLEAN | Oui | — | `detailsOfSuspicion.politicallyExposedPersonIncludedIndicator` |
| `action_taken_desc` | TEXT | Oui | — | `actionTaken.description` |
| `status` | VARCHAR(20) | Non | DRAFT/VALIDATED/SUBMITTED/ACCEPTED/REJECTED | — (interne) |
| `created_at` | TIMESTAMP | Non | — | — (interne) |
| `updated_at` | TIMESTAMP | Non | — | — (interne) |
| `submitted_at` | TIMESTAMP | Oui | — | — (interne) |

**Cardinalité :** 1 STR_REPORT → N STR_TRANSACTION, N STR_DEFINITION, N STR_RELATED_REPORT

---

## 4.2 Table `STR_PPP_PROJECT`

**Objectif :** Codes de projet partenariat public-privé associés au rapport.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `ppp_id` (PK) | BIGINT AUTO | Non | — |
| `str_report_id` (FK) | BIGINT | Non | — |
| `project_name_code` | SMALLINT | Non | `detailsOfSuspicion.publicPrivatePartnershipProjectNameCodes[]` |

**Cardinalité :** STR_REPORT 1→N STR_PPP_PROJECT

---

## 4.3 Table `STR_RELATED_REPORT`

**Objectif :** Références aux rapports précédemment soumis liés à l'activité suspecte.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `related_report_id` (PK) | BIGINT AUTO | Non | — |
| `str_report_id` (FK) | BIGINT | Non | — |
| `re_report_reference` | VARCHAR(100) | Non | `relatedReports[].reportingEntityReportReference` |

**Cardinalité :** STR_REPORT 1→N STR_RELATED_REPORT

---

## 4.4 Table `STR_RELATED_REPORT_TXN_REF`

**Objectif :** Références de transaction des rapports liés.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `id` (PK) | BIGINT AUTO | Non | — |
| `related_report_id` (FK) | BIGINT | Non | — |
| `txn_reference` | VARCHAR(100) | Non | `relatedReports[].reportingEntityTransactionReferences[]` |

---

## 4.5 Table `STR_DEFINITION`

**Objectif :** Catalogue polymorphe des personnes et entités. Un `refId` unique par définition dans le rapport.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `definition_id` (PK) | BIGINT AUTO | Non | — |
| `str_report_id` (FK) | BIGINT | Non | — |
| `ref_id` | VARCHAR(50) | Non | `definitions[].refId` |
| `type_code` | SMALLINT | Non | `definitions[].typeCode` (1-6) |

**Cardinalité :** STR_REPORT 1→N STR_DEFINITION. Le `ref_id` est unique au sein d'un rapport.

---

## 4.6 Table `STR_PERSON`

**Objectif :** Détails d'une personne (typeCode 1, 3 ou 5). Liée à STR_DEFINITION.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `person_id` (PK) | BIGINT AUTO | Non | — |
| `definition_id` (FK) | BIGINT | Non | — |
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

**Objectif :** Détails d'une entité (typeCode 2, 4 ou 6).

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `entity_id` (PK) | BIGINT AUTO | Non | — |
| `definition_id` (FK) | BIGINT | Non | — |
| `entity_name` | VARCHAR(200) | Non | `entityName` |
| `client_number` | VARCHAR(50) | Oui | `clientNumber` |
| `entity_structure_type` | VARCHAR(50) | Oui | `entityStructureType` (Corporation/Trust/...) |
| `principal_business` | VARCHAR(200) | Oui | `natureOfEntityPrincipalBusiness` |
| `is_incorporated_registered` | VARCHAR(30) | Oui | `incorporatedOrRegistered` |
| `email_address` | VARCHAR(200) | Oui | `emailAddress` |
| `url` | VARCHAR(500) | Oui | `url` |

---

## 4.8 Table `STR_ADDRESS`

**Objectif :** Adresses structurées ou non structurées pour personnes, entités, employeurs.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `address_id` (PK) | BIGINT AUTO | Non | — |
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
| `phone_id` (PK) | BIGINT AUTO | Non | — |
| `owner_type` | VARCHAR(20) | Non | — |
| `owner_id` | BIGINT | Non | — |
| `phone_number` | VARCHAR(30) | Non | `telephoneNumber` |
| `extension` | VARCHAR(10) | Oui | `extension` |

---

## 4.10 Table `STR_IDENTIFICATION`

**Objectif :** Pièces d'identité pour personnes ou entités.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `identification_id` (PK) | BIGINT AUTO | Non | — |
| `owner_type` | VARCHAR(20) | Non | 'PERSON' ou 'ENTITY' |
| `owner_id` | BIGINT | Non | — |
| `identifier_type` | VARCHAR(50) | Non | `identifierType` |
| `identifier_type_other` | VARCHAR(200) | Oui | si "Other" |
| `identifier_number` | VARCHAR(100) | Non | `numberAssociatedWithIdentifierType` |
| `jurisdiction_country` | VARCHAR(3) | Oui | `jurisdictionOfIssueCountry` |
| `jurisdiction_province` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceState` |

---

## 4.11 Table `STR_INCORPORATION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `incorporation_id` (PK) | BIGINT AUTO | Non | — |
| `entity_id` (FK) | BIGINT | Non | — |
| `incorporation_number` | VARCHAR(100) | Non | `incorporationNumber` |
| `country` | VARCHAR(3) | Oui | `jurisdictionOfIssueCountry` |
| `province_state` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceState` |

---

## 4.12 Table `STR_REGISTRATION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `registration_id` (PK) | BIGINT AUTO | Non | — |
| `entity_id` (FK) | BIGINT | Non | — |
| `registration_number` | VARCHAR(100) | Non | `registrationNumber` |
| `country` | VARCHAR(3) | Oui | `jurisdictionOfIssueCountry` |
| `province_state` | VARCHAR(100) | Oui | `jurisdictionOfIssueProvinceState` |

---

## 4.13 Table `STR_BENEFICIAL_OWNER`

**Objectif :** Propriétaire effectif, directeur, fiduciaire, constituant d'entité (typeCode 6).

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `bo_id` (PK) | BIGINT AUTO | Non | — |
| `entity_id` (FK) | BIGINT | Non | — |
| `role_type` | VARCHAR(30) | Non | 'DIRECTOR','OWNER_25PCT','TRUSTEE','SETTLOR','TRUST_BENEFICIARY' |
| `surname` | VARCHAR(100) | Oui | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_initial` | VARCHAR(100) | Oui | `otherInitial` |

**Note :** Chaque BO peut avoir des adresses et téléphones (via STR_ADDRESS, STR_PHONE avec owner_type approprié).

---

## 4.14 Table `STR_PERSON_AUTHORIZED`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `auth_id` (PK) | BIGINT AUTO | Non | — |
| `entity_id` (FK) | BIGINT | Non | — |
| `surname` | VARCHAR(100) | Non | `surname` |
| `given_name` | VARCHAR(100) | Oui | `givenName` |
| `other_initial` | VARCHAR(100) | Oui | `otherInitial` |

---

## 4.15 Table `STR_TRANSACTION`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `transaction_id` (PK) | BIGINT AUTO | Non | — |
| `str_report_id` (FK) | BIGINT | Non | — |
| `re_location_id` | VARCHAR(30) | Non | `reportingEntityLocationId` |
| `attempted_indicator` | BOOLEAN | Non | `attemptedTransactionIndicator` |
| `reason_not_completed` | VARCHAR(200) | Oui | `reasonNotCompleted` |
| `date_of_transaction` | DATE | Oui | `dateOfTransaction` |
| `time_of_transaction` | VARCHAR(25) | Oui | `timeOfTransaction` (HH:MM:SS±ZZ:ZZ) |
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
| `starting_action_id` (PK) | BIGINT AUTO | Non | — |
| `transaction_id` (FK) | BIGINT | Non | — |
| `direction_code` | SMALLINT | Non | `direction` (1=In, 2=Out) |
| `fund_type_code` | SMALLINT | Oui | `fundAssetVirtualCurrencyTypeCode` |
| `fund_type_other` | VARCHAR(200) | Oui | — |
| `amount` | DECIMAL(18,2) | Non | `amount` |
| `currency_code` | VARCHAR(3) | Oui | `currencyCode` |
| `currency_other` | VARCHAR(50) | Oui | — |
| `vc_type_code` | VARCHAR(10) | Oui | `virtualCurrencyTypeCode` |
| `vc_type_other` | VARCHAR(50) | Oui | — |
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
| `completing_action_id` (PK) | BIGINT AUTO | Non | — |
| `transaction_id` (FK) | BIGINT | Non | — |
| `disposition_code` | SMALLINT | Non | `dispositionCode` (1-32) |
| `disposition_other` | VARCHAR(200) | Oui | — |
| `amount` | DECIMAL(18,2) | Oui | `amount` |
| `currency_code` | VARCHAR(3) | Oui | `currencyCode` |
| `currency_other` | VARCHAR(50) | Oui | — |
| `vc_type_code` | VARCHAR(10) | Oui | `virtualCurrencyTypeCode` |
| `exchange_rate` | DECIMAL(18,8) | Oui | `exchangeRate` |
| `value_in_cad` | DECIMAL(18,2) | Oui | `valueInCanadianDollars` |
| `reference_number` | VARCHAR(100) | Oui | `referenceNumber` |
| `other_reference_number` | VARCHAR(100) | Oui | — |
| `involvement_indicator` | BOOLEAN | Oui | `involvementIndicator` |
| `beneficiary_indicator` | BOOLEAN | Oui | `beneficiaryIndicator` |

---

## 4.18 Table `STR_ACCOUNT`

**Objectif :** Comptes liés aux starting/completing actions.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `account_id` (PK) | BIGINT AUTO | Non | — |
| `action_type` | VARCHAR(10) | Non | 'STARTING' ou 'COMPLETING' |
| `action_id` | BIGINT | Non | FK vers starting/completing action |
| `fi_number` | VARCHAR(10) | Oui | `financialInstitutionNumber` |
| `branch_number` | VARCHAR(10) | Oui | `branchNumber` |
| `account_number` | VARCHAR(50) | Oui | `accountNumber` |
| `account_type` | VARCHAR(50) | Oui | `accountType` |
| `account_type_other` | VARCHAR(100) | Oui | — |
| `account_currency` | VARCHAR(3) | Oui | `accountCurrency` |
| `account_currency_other` | VARCHAR(50) | Oui | — |
| `account_vc_type` | VARCHAR(20) | Oui | `accountVirtualCurrencyType` |
| `date_opened` | DATE | Oui | `dateAccountOpened` |
| `date_closed` | DATE | Oui | `dateAccountClosed` |
| `status_at_txn` | VARCHAR(50) | Oui | `accountStatusAtTimeOfTransaction` |

---

## 4.19 Table `STR_ACCOUNT_HOLDER`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `holder_id` (PK) | BIGINT AUTO | Non | — |
| `account_id` (FK) | BIGINT | Non | — |
| `type_code` | SMALLINT | Non | 1=Person, 2=Entity |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` → référence à STR_DEFINITION |

---

## 4.20 Table `STR_VC_ADDRESS`

**Objectif :** Adresses de monnaie virtuelle (sending/receiving) et transaction IDs.

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `vc_address_id` (PK) | BIGINT AUTO | Non | — |
| `action_type` | VARCHAR(10) | Non | 'STARTING' ou 'COMPLETING' |
| `action_id` | BIGINT | Non | — |
| `address_type` | VARCHAR(10) | Non | 'SENDING','RECEIVING','TXN_ID' |
| `address_value` | VARCHAR(200) | Non | Adresse VC ou hash de transaction |

---

## 4.21 Table `STR_CONDUCTOR`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `conductor_id` (PK) | BIGINT AUTO | Non | — |
| `starting_action_id` (FK) | BIGINT | Non | — |
| `type_code` | SMALLINT | Non | 5 ou 6 |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(50) | Oui | `clientNumber` |
| `device_type_code` | SMALLINT | Oui | `typeOfDeviceCode` |
| `device_type_other` | VARCHAR(100) | Oui | — |
| `username` | VARCHAR(200) | Oui | `username` |
| `device_id_number` | VARCHAR(100) | Oui | `deviceIdentifierNumber` |
| `ip_address` | VARCHAR(50) | Oui | `internetProtocolAddress` |
| `online_session_datetime` | TIMESTAMP | Oui | `dateTimeOfOnlineSession` |
| `on_behalf_of_indicator` | BOOLEAN | Oui | `onBehalfOfIndicator` |

---

## 4.22 Table `STR_ON_BEHALF_OF`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `obo_id` (PK) | BIGINT AUTO | Non | — |
| `conductor_id` (FK) | BIGINT | Non | — |
| `type_code` | SMALLINT | Non | 5 ou 6 |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(50) | Oui | — |
| `relationship_code` | SMALLINT | Oui | `relationshipOfConductorCode` (1-14) |
| `relationship_other` | VARCHAR(200) | Oui | — |
| `device_type_code` | SMALLINT | Oui | — |
| `username` | VARCHAR(200) | Oui | — |
| `ip_address` | VARCHAR(50) | Oui | — |

---

## 4.23 Table `STR_SOURCE_OF_FUNDS`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `source_id` (PK) | BIGINT AUTO | Non | — |
| `starting_action_id` (FK) | BIGINT | Non | — |
| `type_code` | SMALLINT | Non | 1=Person, 2=Entity |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `account_number` | VARCHAR(50) | Oui | `accountNumber` |
| `policy_number` | VARCHAR(50) | Oui | `policyNumber` |
| `identifying_number` | VARCHAR(50) | Oui | `identifyingNumber` |

---

## 4.24 Table `STR_INVOLVEMENT`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `involvement_id` (PK) | BIGINT AUTO | Non | — |
| `completing_action_id` (FK) | BIGINT | Non | — |
| `type_code` | SMALLINT | Non | 1=PersonName, 2=EntityName |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `account_number` | VARCHAR(50) | Oui | `accountNumber` |
| `policy_number` | VARCHAR(50) | Oui | `policyNumber` |
| `identifying_number` | VARCHAR(50) | Oui | `identifyingNumber` |

---

## 4.25 Table `STR_BENEFICIARY`

| Colonne | Type SQL | Nullable | JSON CANAFE |
|---------|----------|----------|-------------|
| `beneficiary_id` (PK) | BIGINT AUTO | Non | — |
| `completing_action_id` (FK) | BIGINT | Non | — |
| `type_code` | SMALLINT | Non | 3=PersonDetails, 4=EntityDetails |
| `definition_ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(50) | Oui | `clientNumber` |
| `username` | VARCHAR(200) | Oui | `username` |
| `email_address` | VARCHAR(200) | Oui | `emailAddress` |

---

## 4.26 Tables d'audit et traçabilité (recommandation architecturale)

> ⚠️ Ces tables ne sont **pas** exigées par le schéma CANAFE mais sont des **recommandations d'architecture** essentielles.

### `STR_API_SUBMISSION`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `submission_id` (PK) | BIGINT AUTO | — |
| `str_report_id` (FK) | BIGINT | — |
| `submitted_at` | TIMESTAMP | Date/heure de soumission |
| `http_status_code` | SMALLINT | 200, 400, 401, 500... |
| `api_response_body` | TEXT | Réponse JSON complète |
| `canafe_acknowledgement_id` | VARCHAR(100) | ID de confirmation CANAFE |
| `success_indicator` | BOOLEAN | Succès ou échec |

### `STR_VALIDATION_ERROR`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `error_id` (PK) | BIGINT AUTO | — |
| `str_report_id` (FK) | BIGINT | — |
| `error_code` | VARCHAR(20) | Code erreur CANAFE (ex: 300, 324) |
| `field_path` | VARCHAR(200) | Chemin JSON du champ en erreur |
| `error_message` | TEXT | Message descriptif |
| `detected_at` | TIMESTAMP | — |

### `STR_AUDIT_EVENT`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `event_id` (PK) | BIGINT AUTO | — |
| `str_report_id` (FK) | BIGINT | — |
| `event_type` | VARCHAR(30) | CREATED/EDITED/VALIDATED/SUBMITTED/CORRECTED |
| `event_user` | VARCHAR(100) | Utilisateur |
| `event_timestamp` | TIMESTAMP | — |
| `event_details` | TEXT | Détails/diff |

### `STR_SUBMITTED_PAYLOAD`

| Colonne | Type SQL | Description |
|---------|----------|-------------|
| `payload_id` (PK) | BIGINT AUTO | — |
| `str_report_id` (FK) | BIGINT | — |
| `submission_id` (FK) | BIGINT | — |
| `payload_json` | TEXT | Copie intégrale du JSON soumis |
| `payload_hash` | VARCHAR(64) | SHA-256 du payload (intégrité) |
| `created_at` | TIMESTAMP | — |

