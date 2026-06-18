# Modèle de données cible V2 — Partie 2 : Transactions + Audit

---

# DIAGRAMME ER — Partie 4 : Transactions

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

# DIAGRAMME ER — Partie 5 : Rôles transactionnels

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

# DIAGRAMME ER — Partie 6 : Comptes et Monnaie Virtuelle

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

# DIAGRAMME ER — Partie 7 : Audit et Traçabilité

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

# SCHÉMA EXPLICATIF — Pattern de référencement `definitions[] ↔ refId`

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

**Explication :** Une même personne (person-green-01) peut être référencée comme **conductor**, **beneficiary** ET **account holder** via le même `refId`. La définition est stockée **une seule fois** dans `definitions[]`.

---

# SCHÉMA EXPLICATIF — Flux d'une transaction STR

```mermaid
sequenceDiagram
    participant SA as Starting Action<br/>(Entrée des fonds)
    participant TXN as Transaction
    participant CA as Completing Action<br/>(Disposition des fonds)

    Note over SA: direction: 1 (In)<br/>fundType: 2 (Cash)<br/>amount: 9900.00 CAD

    SA->>TXN: Fonds reçus
    Note over TXN: date: 2026-06-15<br/>method: 1 (In person)<br/>location: LOC-001

    TXN->>CA: Fonds disposés
    Note over CA: disposition: 1 (Deposit)<br/>amount: 9900.00 CAD<br/>account: 9876543-21

    Note over SA: Qui?
    SA-->>SA: conductor → refId person-green-01<br/>onBehalfOf → [] (vide)

    Note over CA: Pour qui?
    CA-->>CA: beneficiary → refId person-green-01<br/>involvement → [] (vide)
```

---

# TABLEAU DES CARDINALITÉS COMPLÈTES

| Parent | Enfant | Cardinalité | Required YAML | Peut être vide? |
|--------|--------|------------|--------------|-----------------|
| STR_REPORT | STR_TRANSACTION | 1→N | ✅ `minItems: 1` | ❌ Min 1 |
| STR_REPORT | STR_DEFINITION | 1→N | ✅ required | ✅ Oui `[]` |
| STR_REPORT | STR_PPP_PROJECT | 1→N | ✅ required | ✅ Oui `[]` |
| STR_REPORT | STR_RELATED_REPORT | 1→N | ✅ required | ✅ Oui `[]` |
| STR_TRANSACTION | STR_STARTING_ACTION | 1→N | ✅ required | ❌ Min 1 |
| STR_TRANSACTION | STR_COMPLETING_ACTION | 1→N | ✅ required | ✅ Oui `[]` |
| STR_STARTING_ACTION | STR_CONDUCTOR | 1→N | ✅ required | ✅ Oui `[]` |
| STR_STARTING_ACTION | STR_SOURCE_OF_FUNDS | 1→N | ✅ required | ✅ Oui `[]` |
| STR_CONDUCTOR | STR_ON_BEHALF_OF | 1→N | ✅ required | ✅ Oui `[]` |
| STR_COMPLETING_ACTION | STR_INVOLVEMENT | 1→N | ✅ required | ✅ Oui `[]` |
| STR_COMPLETING_ACTION | STR_BENEFICIARY | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ACCOUNT | STR_ACCOUNT_HOLDER | 1→N | ✅ required | ❌ Min 1 |
| STR_ENTITY | STR_AUTHORIZED_PERSON | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY | STR_REGISTRATION_INCORPORATION | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY (tc6) | STR_DIRECTOR | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY (tc6) | STR_SHARE_OWNER | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY (tc6) | STR_TRUSTEE | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY (tc6) | STR_SETTLOR | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY (tc6) | STR_TRUST_UNIT_OWNER | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY (tc6) | STR_TRUST_BENEFICIARY | 1→N | ✅ required | ✅ Oui `[]` |
| STR_ENTITY (tc6) | STR_OTHER_ENTITY_OWNER | 1→N | ✅ required | ✅ Oui `[]` |

**Note critique :** La colonne "Required YAML" signifie que le champ doit être **présent** dans le JSON. "Peut être vide" signifie qu'un array vide `[]` est accepté. Ceci est dû au `additionalProperties: false` — tout champ absent provoquera un rejet.

---

# TABLEAU DES TYPES typeCode PAR CONTEXTE

| Contexte d'utilisation | typeCodes acceptés | Schéma YAML |
|----------------------|-------------------|-------------|
| `definitions[]` | 1, 2, 3, 4, 5, 6 | oneOf PersonName\|EntityName\|PersonDetails\|EntityDetails\|personAndEmployerDetails\|entityAndBeneficialOwnershipDetails |
| `conductors[].typeCode` | **5, 6** | `definitionType56` |
| `onBehalfOfs[].typeCode` | **5, 6** | `definitionType56` |
| `sourcesOfFundsOrVirtualCurrency[].typeCode` | **1, 2** | `definitionType12` |
| `involvements[].typeCode` | **1, 2** | `definitionType12` |
| `beneficiaries[].typeCode` | **3, 4** | `definitionType34` |
| `account.holders[].typeCode` | **1, 2** | `definitionType12` |

**Règle :** Le `typeCode` dans le rôle transactionnel doit correspondre à un `typeCode` compatible dans `definitions[]`. Ex: un conductor avec `typeCode: 5` doit référencer un `refId` dont la définition est de `typeCode: 5` (personAndEmployerDetails).

---

# COMPTEUR FINAL DES TABLES

| Catégorie | Tables | Nombre |
|-----------|--------|--------|
| **Rapport** | STR_REPORT, STR_PPP_PROJECT, STR_RELATED_REPORT, STR_RELATED_REPORT_TXN_REF | 4 |
| **Définitions** | STR_DEFINITION, STR_PERSON, STR_ENTITY, STR_EMPLOYER_INFO | 4 |
| **Identité** | STR_ADDRESS, STR_IDENTIFICATION | 2 |
| **Entité détails** | STR_REGISTRATION_INCORPORATION, STR_AUTHORIZED_PERSON | 2 |
| **Beneficial Ownership** | STR_DIRECTOR, STR_SHARE_OWNER, STR_TRUSTEE, STR_SETTLOR, STR_TRUST_UNIT_OWNER, STR_TRUST_BENEFICIARY, STR_OTHER_ENTITY_OWNER | 7 |
| **Transactions** | STR_TRANSACTION, STR_STARTING_ACTION, STR_COMPLETING_ACTION | 3 |
| **Rôles** | STR_CONDUCTOR, STR_ON_BEHALF_OF, STR_SOURCE_OF_FUNDS, STR_INVOLVEMENT, STR_BENEFICIARY | 5 |
| **Comptes** | STR_ACCOUNT, STR_ACCOUNT_HOLDER, STR_VC_DATA | 3 |
| **Audit** | STR_API_SUBMISSION, STR_SUBMITTED_PAYLOAD, STR_VALIDATION_ERROR, STR_AUDIT_EVENT | 4 |
| **TOTAL** | | **34 tables** |

