# ModÃ¨le de donnÃ©es cible V2 â€” STRReport CANAFE
## CorrigÃ© selon le swaggerExternal.yaml officiel (261 Ko, 6883 lignes)

**Version :** 2.0 | **Date :** 2026-06-16

---

# DIAGRAMME GÃ‰NÃ‰RAL â€” Vue d'ensemble

```mermaid
graph TB
    subgraph "RAPPORT"
        STR_REPORT["STR_REPORT<br/>(Rapport STR principal)"]
    end

    subgraph "MÃ‰TADONNÃ‰ES"
        STR_PPP["STR_PPP_PROJECT"]
        STR_RELATED["STR_RELATED_REPORT"]
        STR_REL_TXN["STR_RELATED_REPORT_TXN_REF"]
    end

    subgraph "DÃ‰FINITIONS (Catalogue polymorphe)"
        STR_DEF["STR_DEFINITION<br/>(refId unique)"]
        STR_PERSON["STR_PERSON<br/>(typeCode 1,3,5)"]
        STR_ENTITY["STR_ENTITY<br/>(typeCode 2,4,6)"]
        STR_EMPLOYER["STR_EMPLOYER_INFO<br/>(typeCode 5)"]
        STR_REG_INC["STR_REGISTRATION_INCORPORATION"]
        STR_AUTH["STR_AUTHORIZED_PERSON"]
        STR_DIRECTOR["STR_DIRECTOR"]
        STR_SHARE["STR_SHARE_OWNER"]
        STR_TRUSTEE["STR_TRUSTEE"]
        STR_SETTLOR["STR_SETTLOR"]
        STR_UNIT_OWN["STR_TRUST_UNIT_OWNER"]
        STR_TRUST_BEN["STR_TRUST_BENEFICIARY"]
        STR_OTHER_OWN["STR_OTHER_ENTITY_OWNER"]
    end

    subgraph "IDENTITÃ‰ & CONTACT"
        STR_ADDR["STR_ADDRESS"]
        STR_IDENT["STR_IDENTIFICATION"]
    end

    subgraph "TRANSACTIONS"
        STR_TXN["STR_TRANSACTION"]
        STR_SA["STR_STARTING_ACTION"]
        STR_CA["STR_COMPLETING_ACTION"]
    end

    subgraph "RÃ”LES TRANSACTIONNELS"
        STR_COND["STR_CONDUCTOR"]
        STR_OBO["STR_ON_BEHALF_OF"]
        STR_SRC["STR_SOURCE_OF_FUNDS"]
        STR_INV["STR_INVOLVEMENT"]
        STR_BEN["STR_BENEFICIARY"]
    end

    subgraph "COMPTES"
        STR_ACCT["STR_ACCOUNT"]
        STR_HOLD["STR_ACCOUNT_HOLDER"]
        STR_VC["STR_VC_DATA"]
    end

    subgraph "AUDIT"
        STR_SUB["STR_API_SUBMISSION"]
        STR_PAY["STR_SUBMITTED_PAYLOAD"]
        STR_ERR["STR_VALIDATION_ERROR"]
        STR_EVT["STR_AUDIT_EVENT"]
    end

    STR_REPORT --> STR_PPP
    STR_REPORT --> STR_RELATED
    STR_RELATED --> STR_REL_TXN
    STR_REPORT --> STR_DEF
    STR_REPORT --> STR_TXN

    STR_DEF --> STR_PERSON
    STR_DEF --> STR_ENTITY
    STR_PERSON --> STR_EMPLOYER
    STR_PERSON --> STR_ADDR
    STR_PERSON --> STR_IDENT
    STR_ENTITY --> STR_ADDR
    STR_ENTITY --> STR_IDENT
    STR_ENTITY --> STR_REG_INC
    STR_ENTITY --> STR_AUTH
    STR_ENTITY --> STR_DIRECTOR
    STR_ENTITY --> STR_SHARE
    STR_ENTITY --> STR_TRUSTEE
    STR_ENTITY --> STR_SETTLOR
    STR_ENTITY --> STR_UNIT_OWN
    STR_ENTITY --> STR_TRUST_BEN
    STR_ENTITY --> STR_OTHER_OWN

    STR_TXN --> STR_SA
    STR_TXN --> STR_CA
    STR_SA --> STR_COND
    STR_SA --> STR_SRC
    STR_SA --> STR_ACCT
    STR_SA --> STR_VC
    STR_COND --> STR_OBO
    STR_CA --> STR_INV
    STR_CA --> STR_BEN
    STR_CA --> STR_ACCT
    STR_CA --> STR_VC
    STR_ACCT --> STR_HOLD

    STR_REPORT --> STR_SUB
    STR_SUB --> STR_PAY
    STR_REPORT --> STR_ERR
    STR_REPORT --> STR_EVT
```

---

# DIAGRAMME ER DÃ‰TAILLÃ‰ â€” Partie 1 : Rapport + DÃ©finitions

```mermaid
erDiagram
    STR_REPORT {
        bigint str_report_id PK
        int report_type_code "102"
        int submit_type_code "1|2|5"
        int activity_sector_code "enum 28 valeurs"
        numeric reporting_entity_number "7 chiffres"
        numeric submitting_re_number "7 chiffres"
        varchar re_report_reference "^[A-Za-z0-9-_]{1,100}$"
        numeric re_contact_id
        varchar ministerial_directive_code "IR2020|null"
        int suspicion_type_code "1-7"
        text suspicious_activity_desc
        boolean pep_included_indicator
        text action_taken_desc
        varchar status "DRAFT|VALIDATED|SUBMITTED..."
        timestamp created_at
        timestamp submitted_at
    }

    STR_PPP_PROJECT {
        bigint ppp_id PK
        bigint str_report_id FK
        int project_name_code "1|2|3|5|6|7|8"
    }

    STR_RELATED_REPORT {
        bigint related_report_id PK
        bigint str_report_id FK
        varchar re_report_reference
    }

    STR_RELATED_REPORT_TXN_REF {
        bigint id PK
        bigint related_report_id FK
        varchar txn_reference
    }

    STR_DEFINITION {
        bigint definition_id PK
        bigint str_report_id FK
        varchar ref_id "^[A-Za-z0-9-_]{1,50}$"
        int type_code "1|2|3|4|5|6"
    }

    STR_REPORT ||--o{ STR_PPP_PROJECT : "has"
    STR_REPORT ||--o{ STR_RELATED_REPORT : "references"
    STR_RELATED_REPORT ||--o{ STR_RELATED_REPORT_TXN_REF : "has"
    STR_REPORT ||--o{ STR_DEFINITION : "defines"
```

---

# DIAGRAMME ER DÃ‰TAILLÃ‰ â€” Partie 2 : Personnes et EntitÃ©s

```mermaid
erDiagram
    STR_DEFINITION {
        bigint definition_id PK
        varchar ref_id
        int type_code
    }

    STR_PERSON {
        bigint person_id PK
        bigint definition_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
        varchar alias "string100"
        varchar telephone_number "string20"
        varchar extension_number "string10"
        varchar date_of_birth "localDate"
        varchar country_of_residence_code "CountryCode"
        varchar country_of_citizenship_code "CountryCode typeCode5"
        varchar occupation "string200"
        int address_type_code "1=structured 2=unstructured"
    }

    STR_EMPLOYER_INFO {
        bigint employer_id PK
        bigint person_id FK
        varchar name "string100"
        int address_type_code "1|2"
        varchar telephone_number "string20"
        varchar extension_number "string10"
    }

    STR_ENTITY {
        bigint entity_id PK
        bigint definition_id FK
        varchar name_of_entity "string100"
        varchar telephone_number "string20"
        varchar extension_number "string10"
        varchar nature_of_principal_business "string200"
        int address_type_code "1|2"
        int structure_type_code "1|2|3|4"
        varchar structure_type_other "string200"
        boolean registration_incorporation_indicator
    }

    STR_ADDRESS {
        bigint address_id PK
        varchar owner_type "PERSON|ENTITY|EMPLOYER|DIRECTOR..."
        bigint owner_id
        int type_code "1=structured 2=unstructured"
        varchar unit_number "string10"
        varchar building_number "string10"
        varchar street_address "string100"
        varchar city "string100"
        varchar district "string100"
        varchar province_state_code "ProvinceStateCode"
        varchar province_state_name "string100"
        varchar sub_province_sub_locality "string100"
        varchar postal_zip_code "max20"
        varchar country_code "CountryCode"
        varchar unstructured "string500"
    }

    STR_IDENTIFICATION {
        bigint identification_id PK
        varchar owner_type "PERSON|ENTITY"
        bigint owner_id
        int identifier_type_code "enum person ou entity"
        varchar identifier_type_other "string200"
        varchar number "string100"
        varchar jurisdiction_country_code "CountryCode"
        varchar jurisdiction_province_state_code "ProvinceStateCode"
        varchar jurisdiction_province_state_name "string100"
    }

    STR_REGISTRATION_INCORPORATION {
        bigint reg_inc_id PK
        bigint entity_id FK
        int type_code "1=Registered 2=Incorporated 4=Both 5=Unknown"
        varchar number "string100"
        varchar jurisdiction_country_code "CountryCode"
        varchar jurisdiction_province_state_code "ProvinceStateCode"
        varchar jurisdiction_province_state_name "string100"
    }

    STR_AUTHORIZED_PERSON {
        bigint auth_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
    }

    STR_DEFINITION ||--o| STR_PERSON : "if typeCode 1,3,5"
    STR_DEFINITION ||--o| STR_ENTITY : "if typeCode 2,4,6"
    STR_PERSON ||--o| STR_EMPLOYER_INFO : "if typeCode 5"
    STR_PERSON ||--o{ STR_ADDRESS : "has"
    STR_PERSON ||--o{ STR_IDENTIFICATION : "has"
    STR_ENTITY ||--o{ STR_ADDRESS : "has"
    STR_ENTITY ||--o{ STR_IDENTIFICATION : "has"
    STR_ENTITY ||--o{ STR_REGISTRATION_INCORPORATION : "has"
    STR_ENTITY ||--o{ STR_AUTHORIZED_PERSON : "max 3"
    STR_EMPLOYER_INFO ||--o| STR_ADDRESS : "has"
```

---

# DIAGRAMME ER â€” Partie 3 : Beneficial Ownership (typeCode 6)

```mermaid
erDiagram
    STR_ENTITY {
        bigint entity_id PK
        varchar name_of_entity
        int structure_type_code "1=Corp 2=Other 3=Trust 4=PublicTrust"
    }

    STR_DIRECTOR {
        bigint director_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
        int address_type_code "1|2"
        varchar telephone_number "string20"
        varchar extension_number "string10"
    }

    STR_SHARE_OWNER {
        bigint share_owner_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
    }

    STR_TRUSTEE {
        bigint trustee_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
        int address_type_code "1|2"
        varchar telephone_number "string20"
        varchar extension_number "string10"
    }

    STR_SETTLOR {
        bigint settlor_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
        int address_type_code "1|2"
        varchar telephone_number "string20"
        varchar extension_number "string10"
    }

    STR_TRUST_UNIT_OWNER {
        bigint unit_owner_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
        int address_type_code "1|2"
        varchar telephone_number "string20"
        varchar extension_number "string10"
    }

    STR_TRUST_BENEFICIARY {
        bigint trust_ben_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
        int address_type_code "1|2"
        varchar telephone_number "string20"
        varchar extension_number "string10"
    }

    STR_OTHER_ENTITY_OWNER {
        bigint other_owner_id PK
        bigint entity_id FK
        varchar surname "string100"
        varchar given_name "string100"
        varchar other_name_initial "string100"
    }

    STR_ENTITY ||--o{ STR_DIRECTOR : "directorsOfCorporation"
    STR_ENTITY ||--o{ STR_SHARE_OWNER : "personsOwningSharesOfCorporation"
    STR_ENTITY ||--o{ STR_TRUSTEE : "trusteesOfTrust"
    STR_ENTITY ||--o{ STR_SETTLOR : "settlorsOfTrust"
    STR_ENTITY ||--o{ STR_TRUST_UNIT_OWNER : "personsOwningUnitsOfTrust"
    STR_ENTITY ||--o{ STR_TRUST_BENEFICIARY : "beneficiariesOfTrust"
    STR_ENTITY ||--o{ STR_OTHER_ENTITY_OWNER : "personsOwningEntityNotCorpOrTrust"

    STR_DIRECTOR ||--o| STR_ADDRESS : "has address"
    STR_TRUSTEE ||--o| STR_ADDRESS : "has address"
    STR_SETTLOR ||--o| STR_ADDRESS : "has address"
    STR_TRUST_UNIT_OWNER ||--o| STR_ADDRESS : "has address"
    STR_TRUST_BENEFICIARY ||--o| STR_ADDRESS : "has address"
```

**Note :** Les BO avec `personContact` (Director, Trustee, Settlor, TrustUnitOwner, TrustBeneficiary) ont adresse+tÃ©lÃ©phone. Les BO avec uniquement nom (ShareOwner, OtherEntityOwner) n'ont pas d'adresse.

# ModÃ¨le de donnÃ©es cible V2 â€” Partie 2 : Transactions + Audit

---

# DIAGRAMME ER â€” Partie 4 : Transactions

```mermaid
erDiagram
    STR_REPORT {
        bigint str_report_id PK
    }

    STR_TRANSACTION {
        bigint transaction_id PK
        bigint str_report_id FK
        varchar re_location_id "string30 required"
        boolean attempted_indicator "required"
        varchar reason_not_completed "string200"
        varchar date_of_transaction "localDate YYYY-MM-DD"
        varchar time_of_transaction "zonedTime HH:MM:SS+-HH:MM"
        int method_code "enum 1-12"
        varchar method_other "string200"
        varchar date_of_posting "localDate"
        varchar time_of_posting "zonedTime"
        varchar re_txn_reference "^[A-Za-z0-9-_]{1,200}$"
        varchar purpose "string200"
    }

    STR_STARTING_ACTION {
        bigint starting_action_id PK
        bigint transaction_id FK
        int direction "1=In 2=Out required"
        int fund_type_code "enum voir note"
        varchar fund_type_other "string200"
        varchar amount "pattern digits required"
        varchar currency_code "CurrencyCode"
        varchar vc_type_code "VirtualCurrencyCode"
        varchar vc_type_other "string200"
        varchar exchange_rate "pattern digits"
        varchar reference_number "string200"
        varchar ref_number_other_related "string200"
        varchar how_funds_obtained "string200"
        boolean source_funds_indicator
        boolean conductor_indicator
        int account_status_code "1-4"
    }

    STR_COMPLETING_ACTION {
        bigint completing_action_id PK
        bigint transaction_id FK
        int disposition_code "enum 28 valeurs"
        varchar disposition_other "string200"
        varchar amount "pattern digits"
        varchar currency_code "CurrencyCode"
        varchar vc_type_code "VirtualCurrencyCode"
        varchar vc_type_other "string200"
        varchar exchange_rate "pattern digits"
        varchar value_in_cad "pattern digits"
        varchar reference_number "string200"
        varchar ref_number_other_related "string200"
        boolean involvement_indicator
        boolean beneficiary_indicator
        int account_status_code "1-4"
    }

    STR_REPORT ||--|{ STR_TRANSACTION : "1..N required"
    STR_TRANSACTION ||--|{ STR_STARTING_ACTION : "1..N required"
    STR_TRANSACTION ||--o{ STR_COMPLETING_ACTION : "0..N required array"
```

---

# DIAGRAMME ER â€” Partie 5 : RÃ´les transactionnels

```mermaid
erDiagram
    STR_STARTING_ACTION {
        bigint starting_action_id PK
    }

    STR_CONDUCTOR {
        bigint conductor_id PK
        bigint starting_action_id FK
        int type_code "5|6 required"
        varchar definition_ref_id "refId required"
        varchar client_number "string100"
        varchar email_address "string200"
        varchar url "string200"
        int device_type_code "1|2|3|4"
        varchar device_type_other "string200"
        varchar username "string100"
        varchar device_id_number "string200"
        varchar ip_address "string200"
        varchar online_session_datetime "zonedDateTime"
        boolean on_behalf_of_indicator
    }

    STR_ON_BEHALF_OF {
        bigint obo_id PK
        bigint conductor_id FK
        int type_code "5|6 required"
        varchar definition_ref_id "refId required"
        varchar client_number "string100"
        varchar email_address "string200"
        varchar url "string200"
        int relationship_code "1-14 withVendor"
        varchar relationship_other "string200"
    }

    STR_SOURCE_OF_FUNDS {
        bigint source_id PK
        bigint starting_action_id FK
        int type_code "1=Person 2=Entity required"
        varchar definition_ref_id "refId required"
        varchar account_number "string200"
        varchar policy_number "string100"
        varchar identifying_number "string100"
    }

    STR_COMPLETING_ACTION {
        bigint completing_action_id PK
    }

    STR_INVOLVEMENT {
        bigint involvement_id PK
        bigint completing_action_id FK
        int type_code "1=PersonName 2=EntityName"
        varchar definition_ref_id "refId required"
        varchar account_number "string200"
        varchar identifying_number "string100"
        varchar policy_number "string100"
    }

    STR_BENEFICIARY {
        bigint beneficiary_id PK
        bigint completing_action_id FK
        int type_code "3=PersonDetails 4=EntityDetails"
        varchar definition_ref_id "refId required"
        varchar client_number "string100"
        varchar username "string100"
        varchar email_address "string200"
        int relationship_code "1-15 withSelf"
        varchar relationship_other "string200"
    }

    STR_STARTING_ACTION ||--o{ STR_CONDUCTOR : "conductors[] required array"
    STR_CONDUCTOR ||--o{ STR_ON_BEHALF_OF : "onBehalfOfs[] required array"
    STR_STARTING_ACTION ||--o{ STR_SOURCE_OF_FUNDS : "sources[] required array"
    STR_COMPLETING_ACTION ||--o{ STR_INVOLVEMENT : "involvements[] required array"
    STR_COMPLETING_ACTION ||--o{ STR_BENEFICIARY : "beneficiaries[] required array"
```

---

# DIAGRAMME ER â€” Partie 6 : Comptes et Monnaie Virtuelle

```mermaid
erDiagram
    STR_ACCOUNT {
        bigint account_id PK
        varchar action_type "STARTING|COMPLETING"
        bigint action_id FK
        varchar fi_number "string50"
        varchar branch_number "string50"
        varchar number "string100"
        int type_code "1=Personal 2=Business 3=Trust 4=Other 5=Casino"
        varchar type_other "string200"
        varchar currency_code "CurrencyCode"
        varchar vc_type_code "VirtualCurrencyCode"
        varchar vc_type_other "string200"
        varchar date_opened "localDate"
        varchar date_closed "localDate"
    }

    STR_ACCOUNT_HOLDER {
        bigint holder_id PK
        bigint account_id FK
        int type_code "1=PersonName 2=EntityName"
        varchar definition_ref_id "refId"
    }

    STR_VC_DATA {
        bigint vc_data_id PK
        varchar action_type "STARTING|COMPLETING"
        bigint action_id FK
        varchar data_type "TXN_ID|SENDING_ADDR|RECEIVING_ADDR"
        varchar value "string200"
    }

    STR_ACCOUNT ||--|{ STR_ACCOUNT_HOLDER : "holders[] required"
    STR_STARTING_ACTION ||--o| STR_ACCOUNT : "account"
    STR_COMPLETING_ACTION ||--o| STR_ACCOUNT : "account"
    STR_STARTING_ACTION ||--o{ STR_VC_DATA : "VC arrays required"
    STR_COMPLETING_ACTION ||--o{ STR_VC_DATA : "VC arrays required"
```

---

# DIAGRAMME ER â€” Partie 7 : Audit et TraÃ§abilitÃ©

```mermaid
erDiagram
    STR_API_SUBMISSION {
        bigint submission_id PK
        bigint str_report_id FK
        timestamp submitted_at
        int http_status_code
        text api_response_body
        varchar canafe_acknowledgement_id
        boolean success_indicator
    }

    STR_SUBMITTED_PAYLOAD {
        bigint payload_id PK
        bigint str_report_id FK
        bigint submission_id FK
        text payload_json
        varchar payload_hash_sha256
        timestamp created_at
    }

    STR_VALIDATION_ERROR {
        bigint error_id PK
        bigint str_report_id FK
        varchar instance_path "JSON path"
        varchar schema_path
        varchar keyword
        text message_en
        text message_fr
        timestamp detected_at
    }

    STR_AUDIT_EVENT {
        bigint event_id PK
        bigint str_report_id FK
        varchar event_type "CREATED|EDITED|VALIDATED|SUBMITTED"
        varchar event_user
        timestamp event_timestamp
        text event_details
    }

    STR_REPORT ||--o{ STR_API_SUBMISSION : "submissions"
    STR_API_SUBMISSION ||--o| STR_SUBMITTED_PAYLOAD : "payload copy"
    STR_REPORT ||--o{ STR_VALIDATION_ERROR : "errors"
    STR_REPORT ||--o{ STR_AUDIT_EVENT : "audit trail"
```

---

# SCHÃ‰MA EXPLICATIF â€” Pattern de rÃ©fÃ©rencement `definitions[] â†” refId`

```mermaid
graph LR
    subgraph "definitions[]"
        D1["refId: person-green-01<br/>typeCode: 5<br/>(PersonAndEmployer)"]
        D2["refId: entity-bank-01<br/>typeCode: 6<br/>(EntityAndBO)"]
        D3["refId: person-smith-01<br/>typeCode: 3<br/>(PersonDetails)"]
    end

    subgraph "Transaction 1 - Starting Action"
        C1["conductor<br/>typeCode: 5<br/>refId: person-green-01"]
        S1["sourceOfFunds<br/>typeCode: 2<br/>refId: entity-bank-01"]
    end

    subgraph "Transaction 1 - Completing Action"
        B1["beneficiary<br/>typeCode: 3<br/>refId: person-green-01"]
        I1["involvement<br/>typeCode: 1<br/>refId: person-smith-01"]
    end

    subgraph "Account Holders"
        H1["holder<br/>typeCode: 1<br/>refId: person-green-01"]
    end

    C1 -.->|"refId lookup"| D1
    S1 -.->|"refId lookup"| D2
    B1 -.->|"refId lookup"| D1
    I1 -.->|"refId lookup"| D3
    H1 -.->|"refId lookup"| D1

    style D1 fill:#2d6a4f,color:#fff
    style D2 fill:#1d3557,color:#fff
    style D3 fill:#6a040f,color:#fff
```

**Explication :** Une mÃªme personne (person-green-01) peut Ãªtre rÃ©fÃ©rencÃ©e comme **conductor**, **beneficiary** ET **account holder** via le mÃªme `refId`. La dÃ©finition est stockÃ©e **une seule fois** dans `definitions[]`.

---

# SCHÃ‰MA EXPLICATIF â€” Flux d'une transaction STR

```mermaid
sequenceDiagram
    participant SA as Starting Action<br/>(EntrÃ©e des fonds)
    participant TXN as Transaction
    participant CA as Completing Action<br/>(Disposition des fonds)

    Note over SA: direction: 1 (In)<br/>fundType: 2 (Cash)<br/>amount: 9900.00 CAD

    SA->>TXN: Fonds reÃ§us
    Note over TXN: date: 2026-06-15<br/>method: 1 (In person)<br/>location: LOC-001

    TXN->>CA: Fonds disposÃ©s
    Note over CA: disposition: 1 (Deposit)<br/>amount: 9900.00 CAD<br/>account: 9876543-21

    Note over SA: Qui?
    SA-->>SA: conductor â†’ refId person-green-01<br/>onBehalfOf â†’ [] (vide)

    Note over CA: Pour qui?
    CA-->>CA: beneficiary â†’ refId person-green-01<br/>involvement â†’ [] (vide)
```

---

# TABLEAU DES CARDINALITÃ‰S COMPLÃˆTES

| Parent | Enfant | CardinalitÃ© | Required YAML | Peut Ãªtre vide? |
|--------|--------|------------|--------------|-----------------|
| STR_REPORT | STR_TRANSACTION | 1â†’N | âœ… `minItems: 1` | âŒ Min 1 |
| STR_REPORT | STR_DEFINITION | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_REPORT | STR_PPP_PROJECT | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_REPORT | STR_RELATED_REPORT | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_TRANSACTION | STR_STARTING_ACTION | 1â†’N | âœ… required | âŒ Min 1 |
| STR_TRANSACTION | STR_COMPLETING_ACTION | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_STARTING_ACTION | STR_CONDUCTOR | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_STARTING_ACTION | STR_SOURCE_OF_FUNDS | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_CONDUCTOR | STR_ON_BEHALF_OF | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_COMPLETING_ACTION | STR_INVOLVEMENT | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_COMPLETING_ACTION | STR_BENEFICIARY | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ACCOUNT | STR_ACCOUNT_HOLDER | 1â†’N | âœ… required | âŒ Min 1 |
| STR_ENTITY | STR_AUTHORIZED_PERSON | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY | STR_REGISTRATION_INCORPORATION | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY (tc6) | STR_DIRECTOR | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY (tc6) | STR_SHARE_OWNER | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY (tc6) | STR_TRUSTEE | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY (tc6) | STR_SETTLOR | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY (tc6) | STR_TRUST_UNIT_OWNER | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY (tc6) | STR_TRUST_BENEFICIARY | 1â†’N | âœ… required | âœ… Oui `[]` |
| STR_ENTITY (tc6) | STR_OTHER_ENTITY_OWNER | 1â†’N | âœ… required | âœ… Oui `[]` |

**Note critique :** La colonne "Required YAML" signifie que le champ doit Ãªtre **prÃ©sent** dans le JSON. "Peut Ãªtre vide" signifie qu'un array vide `[]` est acceptÃ©. Ceci est dÃ» au `additionalProperties: false` â€” tout champ absent provoquera un rejet.

---

# TABLEAU DES TYPES typeCode PAR CONTEXTE

| Contexte d'utilisation | typeCodes acceptÃ©s | SchÃ©ma YAML |
|----------------------|-------------------|-------------|
| `definitions[]` | 1, 2, 3, 4, 5, 6 | oneOf PersonName\|EntityName\|PersonDetails\|EntityDetails\|personAndEmployerDetails\|entityAndBeneficialOwnershipDetails |
| `conductors[].typeCode` | **5, 6** | `definitionType56` |
| `onBehalfOfs[].typeCode` | **5, 6** | `definitionType56` |
| `sourcesOfFundsOrVirtualCurrency[].typeCode` | **1, 2** | `definitionType12` |
| `involvements[].typeCode` | **1, 2** | `definitionType12` |
| `beneficiaries[].typeCode` | **3, 4** | `definitionType34` |
| `account.holders[].typeCode` | **1, 2** | `definitionType12` |

**RÃ¨gle :** Le `typeCode` dans le rÃ´le transactionnel doit correspondre Ã  un `typeCode` compatible dans `definitions[]`. Ex: un conductor avec `typeCode: 5` doit rÃ©fÃ©rencer un `refId` dont la dÃ©finition est de `typeCode: 5` (personAndEmployerDetails).

---

# COMPTEUR FINAL DES TABLES

| CatÃ©gorie | Tables | Nombre |
|-----------|--------|--------|
| **Rapport** | STR_REPORT, STR_PPP_PROJECT, STR_RELATED_REPORT, STR_RELATED_REPORT_TXN_REF | 4 |
| **DÃ©finitions** | STR_DEFINITION, STR_PERSON, STR_ENTITY, STR_EMPLOYER_INFO | 4 |
| **IdentitÃ©** | STR_ADDRESS, STR_IDENTIFICATION | 2 |
| **EntitÃ© dÃ©tails** | STR_REGISTRATION_INCORPORATION, STR_AUTHORIZED_PERSON | 2 |
| **Beneficial Ownership** | STR_DIRECTOR, STR_SHARE_OWNER, STR_TRUSTEE, STR_SETTLOR, STR_TRUST_UNIT_OWNER, STR_TRUST_BENEFICIARY, STR_OTHER_ENTITY_OWNER | 7 |
| **Transactions** | STR_TRANSACTION, STR_STARTING_ACTION, STR_COMPLETING_ACTION | 3 |
| **RÃ´les** | STR_CONDUCTOR, STR_ON_BEHALF_OF, STR_SOURCE_OF_FUNDS, STR_INVOLVEMENT, STR_BENEFICIARY | 5 |
| **Comptes** | STR_ACCOUNT, STR_ACCOUNT_HOLDER, STR_VC_DATA | 3 |
| **Audit** | STR_API_SUBMISSION, STR_SUBMITTED_PAYLOAD, STR_VALIDATION_ERROR, STR_AUDIT_EVENT | 4 |
| **TOTAL** | | **34 tables** |

