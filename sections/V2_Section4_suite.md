## 4.6 DOMAINE TRANSACTIONS (3 tables)

### STR_TRANSACTION

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `transaction_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `re_location_id` | VARCHAR(30) | Non | `reportingEntityLocationId` |
| `attempted_indicator` | BOOLEAN | Non | `suspiciousTransactionDetails.attemptedTransactionIndicator` |
| `reason_not_completed` | VARCHAR(200) | Oui | `reasonNotCompleted` |
| `date_of_transaction` | VARCHAR(10) | Oui | `dateOfTransaction` |
| `time_of_transaction` | VARCHAR(25) | Oui | `timeOfTransaction` |
| `method_code` | SMALLINT | Oui | `methodCode` (1-12) |
| `method_other` | VARCHAR(200) | Oui | `methodOther` |
| `date_of_posting` | VARCHAR(10) | Oui | `dateOfPosting` |
| `time_of_posting` | VARCHAR(25) | Oui | `timeOfPosting` |
| `re_txn_reference` | VARCHAR(200) | Oui | `reportingEntityTransactionReference` |
| `purpose` | VARCHAR(200) | Oui | `purpose` |

### STR_STARTING_ACTION

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `starting_action_id` | BIGINT PK | Non | — |
| `transaction_id` | BIGINT FK | Non | — |
| `direction` | SMALLINT | Oui | `details.direction` (1=In, 2=Out) |
| `fund_type_code` | SMALLINT | Oui | `details.fundAssetVirtualCurrencyTypeCode` |
| `fund_type_other` | VARCHAR(200) | Oui | `details.fundAssetVirtualCurrencyTypeOther` |
| `amount` | VARCHAR(28) | Oui | `details.amount` — STRING pattern! |
| `currency_code` | VARCHAR(3) | Oui | `details.currencyCode` |
| `vc_type_code` | VARCHAR(10) | Oui | `details.virtualCurrencyTypeCode` |
| `vc_type_other` | VARCHAR(200) | Oui | `details.virtualCurrencyTypeOther` |
| `exchange_rate` | VARCHAR(28) | Oui | `details.exchangeRate` — STRING pattern! |
| `reference_number` | VARCHAR(200) | Oui | `details.referenceNumber` |
| `ref_number_other` | VARCHAR(200) | Oui | `details.referenceNumberOtherRelatedNumber` |
| `account_status_code` | SMALLINT | Oui | `details.accountStatusAtTimeOfTransaction` (1-4) |
| `how_funds_obtained` | VARCHAR(200) | Oui | `details.howFundsOrVirtualCurrencyObtained` |
| `source_funds_indicator` | BOOLEAN | Oui | `details.sourcesOfFundsOrVirtualCurrencyIndicator` |
| `conductor_indicator` | BOOLEAN | Oui | `details.conductorIndicator` |

### STR_COMPLETING_ACTION

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `completing_action_id` | BIGINT PK | Non | — |
| `transaction_id` | BIGINT FK | Non | — |
| `disposition_code` | SMALLINT | Oui | `details.dispositionCode` (28 valeurs) |
| `disposition_other` | VARCHAR(200) | Oui | `details.dispositionOther` |
| `amount` | VARCHAR(28) | Oui | `details.amount` — STRING! |
| `currency_code` | VARCHAR(3) | Oui | `details.currencyCode` |
| `vc_type_code` | VARCHAR(10) | Oui | `details.virtualCurrencyTypeCode` |
| `vc_type_other` | VARCHAR(200) | Oui | `details.virtualCurrencyTypeOther` |
| `exchange_rate` | VARCHAR(28) | Oui | `details.exchangeRate` — STRING! |
| `value_in_cad` | VARCHAR(28) | Oui | `details.valueInCanadianDollars` — STRING! |
| `reference_number` | VARCHAR(200) | Oui | `details.referenceNumber` |
| `ref_number_other` | VARCHAR(200) | Oui | `details.referenceNumberOtherRelatedNumber` |
| `account_status_code` | SMALLINT | Oui | `details.accountStatusAtTimeOfTransaction` (1-4) |
| `involvement_indicator` | BOOLEAN | Oui | `details.involvementIndicator` |
| `beneficiary_indicator` | BOOLEAN | Oui | `details.beneficiaryIndicator` |

## 4.7 DOMAINE RÔLES (5 tables)

### STR_CONDUCTOR

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `conductor_id` | BIGINT PK | Non | — |
| `starting_action_id` | BIGINT FK | Non | — |
| `type_code` | SMALLINT | Non | `typeCode` (5 ou 6) |
| `ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(100) | Oui | `details.clientNumber` |
| `email_address` | VARCHAR(200) | Oui | `details.emailAddress` |
| `url` | VARCHAR(200) | Oui | `details.url` |
| `device_type_code` | SMALLINT | Oui | `details.typeOfDeviceCode` (1-4) |
| `device_type_other` | VARCHAR(200) | Oui | `details.typeOfDeviceOther` |
| `username` | VARCHAR(100) | Oui | `details.username` |
| `device_id_number` | VARCHAR(200) | Oui | `details.deviceIdentifierNumber` |
| `ip_address` | VARCHAR(200) | Oui | `details.internetProtocolAddress` |
| `online_session_datetime` | VARCHAR(30) | Oui | `details.dateTimeOfOnlineSession` |
| `on_behalf_of_indicator` | BOOLEAN | Oui | `details.onBehalfOfIndicator` |

### STR_ON_BEHALF_OF

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `obo_id` | BIGINT PK | Non | — |
| `conductor_id` | BIGINT FK | Non | — |
| `type_code` | SMALLINT | Non | `typeCode` (5 ou 6) |
| `ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(100) | Oui | `details.clientNumber` |
| `email_address` | VARCHAR(200) | Oui | `details.emailAddress` |
| `url` | VARCHAR(200) | Oui | `details.url` |
| `relationship_code` | SMALLINT | Oui | `details.relationshipOfConductorCode` (1-14) |
| `relationship_other` | VARCHAR(200) | Oui | `details.relationshipOfConductorOther` |

### STR_SOURCE_OF_FUNDS

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `source_id` | BIGINT PK | Non | — |
| `starting_action_id` | BIGINT FK | Non | — |
| `type_code` | SMALLINT | Non | `typeCode` (1 ou 2) |
| `ref_id` | VARCHAR(50) | Non | `refId` |
| `account_number` | VARCHAR(200) | Oui | `details.accountNumber` |
| `policy_number` | VARCHAR(100) | Oui | `details.policyNumber` |
| `identifying_number` | VARCHAR(100) | Oui | `details.identifyingNumber` |

### STR_INVOLVEMENT

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `involvement_id` | BIGINT PK | Non | — |
| `completing_action_id` | BIGINT FK | Non | — |
| `type_code` | SMALLINT | Non | `typeCode` (1 ou 2) |
| `ref_id` | VARCHAR(50) | Non | `refId` |
| `account_number` | VARCHAR(200) | Oui | `details.accountNumber` |
| `identifying_number` | VARCHAR(100) | Oui | `details.identifyingNumber` |
| `policy_number` | VARCHAR(100) | Oui | `details.policyNumber` |

### STR_BENEFICIARY

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `beneficiary_id` | BIGINT PK | Non | — |
| `completing_action_id` | BIGINT FK | Non | — |
| `type_code` | SMALLINT | Non | `typeCode` (3 ou 4) |
| `ref_id` | VARCHAR(50) | Non | `refId` |
| `client_number` | VARCHAR(100) | Oui | `details.clientNumber` |
| `username` | VARCHAR(100) | Oui | `details.username` |
| `email_address` | VARCHAR(200) | Oui | `details.emailAddress` |

## 4.8 DOMAINE COMPTES (3 tables)

### STR_ACCOUNT

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `account_id` | BIGINT PK | Non | — |
| `action_type` | VARCHAR(10) | Non | STARTING ou COMPLETING |
| `action_id` | BIGINT | Non | FK polymorphe |
| `fi_number` | VARCHAR(50) | Oui | `financialInstitutionNumber` |
| `branch_number` | VARCHAR(50) | Oui | `branchNumber` |
| `number` | VARCHAR(100) | Oui | `number` |
| `type_code` | SMALLINT | Oui | `typeCode` (1-5) |
| `type_other` | VARCHAR(200) | Oui | `typeOther` |
| `currency_code` | VARCHAR(3) | Oui | `currencyCode` |
| `vc_type_code` | VARCHAR(10) | Oui | `virtualCurrencyTypeCode` |
| `vc_type_other` | VARCHAR(200) | Oui | `virtualCurrencyTypeOther` |
| `date_opened` | VARCHAR(10) | Oui | `dateOpened` |
| `date_closed` | VARCHAR(10) | Oui | `dateClosed` |

### STR_ACCOUNT_HOLDER

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `holder_id` | BIGINT PK | Non | — |
| `account_id` | BIGINT FK | Non | — |
| `type_code` | SMALLINT | Non | `typeCode` (1 ou 2) |
| `ref_id` | VARCHAR(50) | Non | `refId` |

### STR_VC_DATA

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `vc_data_id` | BIGINT PK | Non | — |
| `action_type` | VARCHAR(10) | Non | STARTING ou COMPLETING |
| `action_id` | BIGINT | Non | FK polymorphe |
| `data_type` | VARCHAR(20) | Non | TXN_ID, SENDING_ADDR, RECEIVING_ADDR |
| `value` | VARCHAR(200) | Non | valeur |

## 4.9 DOMAINE AUDIT (4 tables)

### STR_API_SUBMISSION

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `submission_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `submitted_at` | TIMESTAMP | Non | — |
| `http_status_code` | SMALLINT | Oui | — |
| `api_response_body` | TEXT | Oui | — |
| `canafe_acknowledgement_id` | VARCHAR(100) | Oui | — |
| `success_indicator` | BOOLEAN | Non | — |

### STR_SUBMITTED_PAYLOAD

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `payload_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `submission_id` | BIGINT FK | Non | — |
| `payload_json` | TEXT | Non | JSON intégral soumis |
| `payload_hash_sha256` | VARCHAR(64) | Non | Non-répudiation |
| `created_at` | TIMESTAMP | Non | — |

### STR_VALIDATION_ERROR

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `error_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `instance_path` | VARCHAR(500) | Oui | `validationMessages[n].instancePath` |
| `schema_path` | VARCHAR(500) | Oui | `validationMessages[n].schemaPath` |
| `keyword` | VARCHAR(100) | Oui | `validationMessages[n].keyword` |
| `message_en` | TEXT | Oui | `validationMessages[n].message.en` |
| `message_fr` | TEXT | Oui | `validationMessages[n].message.fr` |
| `detected_at` | TIMESTAMP | Non | — |

### STR_AUDIT_EVENT

| Colonne | Type SQL | Null | YAML |
|---------|----------|------|------|
| `event_id` | BIGINT PK | Non | — |
| `str_report_id` | BIGINT FK | Non | — |
| `event_type` | VARCHAR(30) | Non | CREATED, EDITED, VALIDATED, SUBMITTED, CORRECTED |
| `event_user` | VARCHAR(100) | Oui | — |
| `event_timestamp` | TIMESTAMP | Non | — |
| `event_details` | TEXT | Oui | — |

