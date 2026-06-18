## 2.7 startingActions[] (dans transaction)

Required array dans le schéma.

### startingAction.details

| Champ YAML exact | Type | Required |
|------------------|------|----------|
| `direction` | integer `1`=In, `2`=Out | ❌ schéma |
| `fundAssetVirtualCurrencyTypeCode` | integer enum | ❌ |
| `fundAssetVirtualCurrencyTypeOther` | string200 | ❌ |
| `amount` | **string** `^\d{1,17}(\.\d{2,10})?$` | ❌ |
| `currencyCode` | CurrencyCode | ❌ |
| `virtualCurrencyTypeCode` | VirtualCurrencyCode | ❌ |
| `virtualCurrencyTypeOther` | string200 | ❌ |
| `exchangeRate` | **string** `^\d{1,17}(\.\d{2,10})?$` | ❌ |
| `virtualCurrencyTransactionIds` | string200[] | ✅ (vide OK) |
| `sendingVirtualCurrencyAddresses` | string200[] | ✅ (vide OK) |
| `receivingVirtualCurrencyAddresses` | string200[] | ✅ (vide OK) |
| `referenceNumber` | string200 | ❌ |
| `referenceNumberOtherRelatedNumber` | string200 | ❌ |
| `account` | strAccount | ❌ |
| `accountStatusAtTimeOfTransaction` | integer enum 1-4 | ❌ |
| `howFundsOrVirtualCurrencyObtained` | string200 | ❌ |
| `sourcesOfFundsOrVirtualCurrencyIndicator` | boolean | ❌ |
| `conductorIndicator` | boolean | ❌ |

```yaml
# startingAction required:
- details
- sourcesOfFundsOrVirtualCurrency    # array, vide OK []
- conductors                          # array, vide OK []
```

### Enum `fundAssetVirtualCurrencyTypeCode`

| Direction=1 (In) | Direction=2 (Out) |
|-------------------|-------------------|
| 1 Bank draft | 3 Casino product |
| 2 Cash | 7 Funds withdrawal |
| 3 Casino product | 9 Investment product |
| 4 Cheque | 16 Virtual currency |
| 5 Domestic funds transfer | 17 Other |
| 6 Email money transfer | |
| 8 International funds transfer | |
| 9 Investment product | |
| 10 Jewellery | |
| 11 Mobile money transfer | |
| 12 Money order | |
| 13 Precious metals | |
| 14 Precious stones | |
| 16 Virtual currency | |
| 17 Other | |

> **Note :** Code 15 n'existe PAS dans le YAML officiel.

### Enum `accountStatusAtTimeOfTransaction`

| Code | Statut |
|------|--------|
| 1 | Active |
| 2 | Inactive |
| 3 | Dormant |
| 4 | Closed |

### conductors[] (dans startingAction)

Required array (vide OK). Chaque conductor :

```yaml
# conductor required:
- typeCode     # definitionType56 → 5 ou 6
- refId        # ^[A-Za-z0-9-_]{1,50}$
- details      # objet required
- onBehalfOfs  # array required, vide OK []
```

**conductor.details :**

| Champ | Type |
|-------|------|
| `clientNumber` | string100 |
| `emailAddress` | string200 |
| `url` | string200 |
| `typeOfDeviceCode` | integer enum 1-4 |
| `typeOfDeviceOther` | string200 |
| `username` | string100 |
| `deviceIdentifierNumber` | string200 |
| `internetProtocolAddress` | string200 |
| `dateTimeOfOnlineSession` | zonedDateTime |
| `onBehalfOfIndicator` | boolean |

### Enum `typeOfDeviceCode`

| Code | Type |
|------|------|
| 1 | Computer/Laptop |
| 2 | Mobile phone |
| 3 | Tablet |
| 4 | Other |

### onBehalfOfs[] (dans conductor)

Required array (vide OK). Chaque entry :

```yaml
# onBehalfOf required:
- typeCode    # definitionType56 → 5 ou 6
- refId
```

**onBehalfOf.details :**

| Champ | Type |
|-------|------|
| `clientNumber` | string100 |
| `emailAddress` | string200 |
| `url` | string200 |
| `relationshipOfConductorCode` | integer enum 1-14 (withVendor) |
| `relationshipOfConductorOther` | string200 |

### sourcesOfFundsOrVirtualCurrency[] (dans startingAction)

Required array (vide OK).

```yaml
# sourceOfFunds required:
- typeCode    # definitionType12 → 1 ou 2
- refId
```

**details :** `accountNumber` (string200), `policyNumber` (string100), `identifyingNumber` (string100)

## 2.8 completingActions[] (dans transaction)

Required array (vide OK).

### completingAction.details

| Champ YAML exact | Type | Required |
|------------------|------|----------|
| `dispositionCode` | integer enum 28 valeurs | ❌ |
| `dispositionOther` | string200 | ❌ |
| `amount` | **string** pattern | ❌ |
| `currencyCode` | CurrencyCode | ❌ |
| `virtualCurrencyTypeCode` | VirtualCurrencyCode | ❌ |
| `virtualCurrencyTypeOther` | string200 | ❌ |
| `exchangeRate` | **string** pattern | ❌ |
| `valueInCanadianDollars` | **string** pattern | ❌ |
| `virtualCurrencyTransactionIds` | string200[] | ✅ (vide OK) |
| `sendingVirtualCurrencyAddresses` | string200[] | ✅ (vide OK) |
| `receivingVirtualCurrencyAddresses` | string200[] | ✅ (vide OK) |
| `referenceNumber` | string200 | ❌ |
| `referenceNumberOtherRelatedNumber` | string200 | ❌ |
| `account` | strAccount | ❌ |
| `accountStatusAtTimeOfTransaction` | integer enum 1-4 | ❌ |
| `involvementIndicator` | boolean | ❌ |
| `beneficiaryIndicator` | boolean | ❌ |

```yaml
# completingAction required:
- details
- involvements    # array, vide OK []
- beneficiaries   # array, vide OK []
```

### Enum `dispositionCode` (28 valeurs)

| Code | EN | FR |
|------|----|----|
| 1 | Deposit to account | Dépôt au compte |
| 3 | Exchange to fiat currency | Échange en monnaie fiduciaire |
| 4 | Purchase of casino product | Achat produits casino |
| 5 | Purchase of bank draft | Achat traite bancaire |
| 6 | Purchase of money order | Achat mandat |
| 7 | Life insurance purchase/deposit | Assurance-vie |
| 8 | Investment product purchase/deposit | Produit d'investissement |
| 9 | Real estate purchase/deposit | Biens immobiliers |
| 10 | Cash out | Encaissement |
| 11 | Other | Autre |
| 14 | Purchase of jewellery | Achat bijoux |
| 15 | Purchase precious metals | Métaux précieux |
| 17 | Added to VC wallet | Portefeuille monnaie virtuelle |
| 18 | Exchange to virtual currency | Échange en MV |
| 19 | Outgoing VC transfer | Transfert MV |
| 20 | Outgoing email money transfer | Virement par courriel |
| 21 | Holding funds | Fonds retenus |
| 22 | Purchase precious stones | Pierres précieuses |
| 23 | Issued cheque | Émission chèque |
| 24 | Outgoing domestic funds transfer | Virement domestique |
| 25 | Outgoing international funds transfer | Virement international |
| 26 | Purchase prepaid card | Carte prépayée |
| 27 | Denomination exchange | Échange coupures |
| 28 | Payment to account | Paiement au compte |
| 29 | Purchase/Payment for goods | Achat biens |
| 30 | Purchase/Payment for services | Achat services |
| 31 | Outgoing mobile money transfer | Virement mobile |
| 32 | Cash withdrawal (account based) | Retrait (lié au compte) |

> **Note :** Codes 2, 12, 13, 16 absents du YAML officiel.

### involvements[] (dans completingAction)

Required array (vide OK).

```yaml
# involvement required:
- typeCode    # definitionType12 → 1 ou 2
- refId
```

**details :** `accountNumber` (string200), `identifyingNumber` (string100), `policyNumber` (string100)

### beneficiaries[] (dans completingAction)

Required array (vide OK).

```yaml
# beneficiary required:
- typeCode    # definitionType34 → 3 ou 4
- refId
```

**details :** `clientNumber` (string100), `username` (string100), `emailAddress` (string200)

> **Note :** Pas de `relationshipOfConductorCode` sur les beneficiaries du STR (contrairement au LCTR). Le champ existe seulement dans le LCTR completing action beneficiaries.

## 2.9 strAccount

Utilisé dans les starting et completing actions.

| Champ | Type | Required |
|-------|------|----------|
| `financialInstitutionNumber` | string50 | ❌ |
| `branchNumber` | string50 | ❌ |
| `number` | string100 | ❌ |
| `typeCode` | integer enum 1-5 | ❌ |
| `typeOther` | string200 | ❌ |
| `currencyCode` | CurrencyCode | ❌ |
| `virtualCurrencyTypeCode` | VirtualCurrencyCode | ❌ |
| `virtualCurrencyTypeOther` | string200 | ❌ |
| `dateOpened` | localDate | ❌ |
| `dateClosed` | localDate | ❌ |
| `holders` | array | ✅ |

### Enum `typeCode` (AccountTypeCode)

| Code | Type |
|------|------|
| 1 | Personal |
| 2 | Business |
| 3 | Trust |
| 4 | Other |
| 5 | Casino |

### holders[] (required dans strAccount)

```yaml
# holder required:
- typeCode    # definitionType12 → 1 ou 2
- refId
```

## 2.10 Formats et patterns critiques

| Type YAML | Pattern | Exemple |
|-----------|---------|---------|
| `refId` | `^[A-Za-z0-9-_]{1,50}$` | `person-green-01` |
| `externalReportReference` | `^[A-Za-z0-9-_]{1,100}$` | `STR-2026-00142` |
| `externalTransactionReference` | `^[A-Za-z0-9-_]{1,200}$` | `TXN-2026-A1` |
| `currencyAmount` | `^\d{1,17}(\.\d{2,10})?$` | `9900.00` |
| `exchangeRate` | `^\d{1,17}(\.\d{2,10})?$` | `501.7966918945` |
| `localDate` | `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` | `2026-06-15` |
| `zonedTime` | `^[0-9]{2}:[0-9]{2}:[0-9]{2}[\-\+][0-9]{2}:[0-9]{2}$` | `14:30:00-04:00` |
| `zonedDateTime` | `^..T..[+-]..` | `2026-06-15T14:30:00-04:00` |

> **CRITIQUE :** `amount`, `exchangeRate`, `valueInCanadianDollars` sont des **strings** (pas des numbers). La validation de format se fait par regex.

## 2.11 Contrainte `additionalProperties: false`

Quasiment **tous** les objets du YAML ont `additionalProperties: false`. Cela signifie que l'API CANAFE **rejettera** tout champ non déclaré dans le schéma. Il est interdit d'ajouter des propriétés custom.

## 2.12 Authentification API

L'API utilise un **token Bearer OAuth2** :

```yaml
AccessTokenResponse:
  token_type: string      # "Bearer"
  expires_in: number
  ext_expires_in: number
  access_token: string
```

## 2.13 Réponse d'erreur de validation

```yaml
ErrorWithValidation:
  code: number
  message: { en: string, fr: string }
  payload:
    validationMessages[]:
      instancePath: string    # "/transactions/0/startingActions/0/details/amount"
      schemaPath: string
      keyword: string
      params: object
      message: { en: string, fr: string }
```

