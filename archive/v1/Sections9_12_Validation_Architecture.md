# SECTION 9 — Règles de validation et contrôles qualité

## 9.1 Contrôles obligatoires avant soumission

### Présence des champs obligatoires

| Contrôle | Règle | Priorité |
|----------|-------|----------|
| `reportDetails.reportTypeCode` | Doit être 102 | BLOQUANT |
| `reportDetails.submitTypeCode` | Doit être 1, 2 ou 5 | BLOQUANT |
| `reportDetails.reportingEntityNumber` | Exactement 7 chiffres | BLOQUANT |
| `reportDetails.reportingEntityReportReference` | Non vide, unique, pattern `^[A-Za-z0-9_-]{1,100}$` | BLOQUANT |
| `transactions[]` | Au moins 1 transaction | BLOQUANT |
| `transactions[].startingActions[]` | Au moins 1 par transaction | BLOQUANT |
| `transactions[].suspiciousTransactionDetails.attemptedTransactionIndicator` | Requis | BLOQUANT |
| `detailsOfSuspicion.descriptionOfSuspiciousActivity` | Requis sauf directive ministérielle | BLOQUANT |
| `detailsOfSuspicion.suspicionTypeCode` | Requis sauf directive ministérielle | BLOQUANT |
| `actionTaken.description` | Requis sauf directive ministérielle | BLOQUANT |

### Format des dates

| Contrôle | Règle |
|----------|-------|
| `dateOfTransaction` | Format ISO 8601 (YYYY-MM-DD), pas dans le futur |
| `timeOfTransaction` | Format HH:MM:SS±ZZ:ZZ |
| `dateOfPosting` | ≠ `dateOfTransaction`, pas dans le futur |
| `dateOfBirth` | Pas dans le futur |
| `dateAccountOpened` | Avant `dateAccountClosed` si les deux présents |

### Montants et devises

| Contrôle | Règle |
|----------|-------|
| `amount` (starting/completing) | > 0, DECIMAL(18,2) |
| `currencyCode` | Code ISO 4217 valide ou "Other" + spécification |
| `exchangeRate` | > 0 si présent |
| `valueInCanadianDollars` | Requis si disposition non monétaire (bijoux, métaux) |
| Cohérence montant starting vs completing | À vérifier si une seule SA/CA |

### Cohérence des rôles et parties

| Contrôle | Règle |
|----------|-------|
| Chaque `refId` dans conductors/beneficiaries/etc. | Doit exister dans `definitions[]` |
| `typeCode` du rôle vs `typeCode` de la définition | Cohérence (conducteur = 5 ou 6, bénéficiaire = 3 ou 4) |
| `conductorIndicator` = true | Au moins 1 conductor dans `conductors[]` |
| `onBehalfOfIndicator` = true | Au moins 1 entry dans `onBehalfOfs[]` |
| `beneficiaryIndicator` = true | Au moins 1 entry dans `beneficiaries[]` |
| `involvementIndicator` = true | Au moins 1 entry dans `involvements[]` |
| `sourcesOfFundsOrVirtualCurrencyIndicator` = true | Au moins 1 entry dans `sourcesOfFundsOrVirtualCurrency[]` |

### Cohérence personnes / entités

| Contrôle | Règle |
|----------|-------|
| Personne avec nom unique | `givenName` = "XXX", `surname` = nom réel |
| Occupation | Descriptive (pas juste un code NOC) |
| Champs non applicables | Laisser vide — ne pas mettre "N/A", "x", "-", "unknown" |
| Adresse | Structurée OU non structurée, pas les deux |
| Téléphone | Format: CC-CCC-CCCC-CCCC |

### Présence des narratifs

| Contrôle | Règle |
|----------|-------|
| `descriptionOfSuspiciousActivity` | Non vide (sauf directive ministérielle) |
| Pas d'acronymes internes | Vérification textuelle |
| Pas de références internes | Pas de # de dossier interne |
| Pas de formatting | Pas de HTML/markdown/bold/italic |

### Directive ministérielle

| Contrôle | Règle |
|----------|-------|
| Si `ministerialDirectiveCode` renseigné | Exactement 1 transaction, pas de suspicion, pas d'action |
| Transaction sous directive | Doit être complétée (pas attempted), avec SA et CA |

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
| `activitySectorCode` | 2, 3, 6, 10, 14, 16, 19, 20 (+ autres à confirmer) |

### Doublons

| Contrôle | Règle |
|----------|-------|
| `reportingEntityReportReference` | Unicité globale — jamais réutilisé |
| `refId` dans definitions | Unique dans le rapport |
| `reportingEntityTransactionReference` | Unique dans le rapport |

### Gestion des erreurs API

| Code HTTP | Action |
|-----------|--------|
| 200 | Succès — stocker l'acknowledgement |
| 400 | Erreur de validation — parser les erreurs, corriger, resoumettre |
| 401/403 | Erreur d'authentification — vérifier les clés API |
| 500 | Erreur serveur — retry avec backoff exponentiel |

---

# SECTION 10 — Architecture cible minimale

```
┌─────────────────────────────────────────────────────────────┐
│                    SYSTÈME AML / CASE MANAGEMENT            │
│  (Investigation, scoring, alertes, workflow interne)        │
└──────────────────────────┬──────────────────────────────────┘
                           │ Décision: soumettre STR
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              COUCHE D'EXTRACTION / MAPPING                  │
│  - Extract des données du case AML                          │
│  - Mapping vers le modèle cible STR                         │
│  - Enrichissement (KYC, comptes, identifications)           │
│  - Rédaction du narratif (assistance ou manuel)             │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   BASE DE DONNÉES CIBLE STR                 │
│  Tables: STR_REPORT, STR_TRANSACTION, STR_DEFINITION,       │
│  STR_PERSON, STR_ENTITY, STR_STARTING_ACTION, etc.          │
│  (Modèle Section 4)                                         │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  MOTEUR DE VALIDATION                       │
│  - Champs obligatoires                                      │
│  - Formats (dates, montants, téléphones)                    │
│  - Enums / domaines de valeurs                              │
│  - Cohérence inter-champs                                   │
│  - Cohérence refId definitions ↔ rôles                     │
│  - Résultat: PASS / FAIL + détails erreurs                  │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   GÉNÉRATEUR JSON                           │
│  - Assemblage bottom-up (Section 7)                         │
│  - Sérialisation JSON conforme au schéma CANAFE             │
│  - Validation contre le schéma OpenAPI (optionnel)          │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   CLIENT API CANAFE                         │
│  - Authentification (clés secrètes via portail API)         │
│  - POST /api/v1/reports                                     │
│  - Gestion TLS, timeout, retry                              │
│  - Parsing de la réponse                                    │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              JOURNALISATION & STOCKAGE                      │
│  - STR_API_SUBMISSION: statut, code HTTP, réponse           │
│  - STR_SUBMITTED_PAYLOAD: copie JSON + hash SHA-256         │
│  - STR_VALIDATION_ERROR: erreurs CANAFE parsées             │
│  - STR_AUDIT_EVENT: trace de chaque action                  │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│               MÉCANISME DE CORRECTION                       │
│  - Charger le rapport existant                              │
│  - Modifier les données                                     │
│  - submitTypeCode = 2 (Update)                              │
│  - Resoumettre dans les 20 jours                            │
│  - Journaliser la correction et sa raison                   │
└─────────────────────────────────────────────────────────────┘
```

### Composants et responsabilités

| Composant | Responsabilité | Technologie recommandée |
|-----------|---------------|------------------------|
| Base cible STR | Stockage normalisé | PostgreSQL / Oracle |
| Moteur de validation | Règles métier pré-soumission | Java/Python + bibliothèque de règles |
| Générateur JSON | Assemblage du payload | Service dédié avec mapping ORM |
| Client API | Communication HTTPS avec CANAFE | Client HTTP avec auth OAuth2/API Key |
| Journalisation | Audit trail complet | Tables dédiées + logs applicatifs |
| Conservation | Copie 5 ans minimum | Archivage du JSON soumis avec hash |

---

# SECTION 11 — Recommandations d'implémentation

## 11.1 Modélisation relationnelle vs JSON natif

**Recommandation : Modèle relationnel normalisé** (tel que proposé en Section 4).

| Approche | Avantages | Inconvénients |
|----------|-----------|---------------|
| Relationnel normalisé | Requêtable, indexable, auditable, validable par contraintes SQL | Plus de tables, mapping JSON nécessaire |
| JSON natif (JSONB) | Fidélité directe au schéma CANAFE, moins de mapping | Difficile à requêter, valider, auditer |
| **Hybride (recommandé)** | Tables relationnelles + colonne JSONB pour payload soumis | Meilleur des deux mondes |

## 11.2 Historisation

- Chaque modification d'un STR_REPORT doit créer un événement dans `STR_AUDIT_EVENT`
- Conserver le payload JSON de chaque soumission dans `STR_SUBMITTED_PAYLOAD`
- Ne jamais supprimer physiquement un rapport — utiliser un statut `DELETED` ou `ARCHIVED`
- Conservation minimum : **5 ans** après soumission (obligation légale)

## 11.3 Gestion des versions du schéma CANAFE

- Stocker la version du schéma utilisée dans chaque rapport
- Maintenir un mécanisme de migration si CANAFE modifie le schéma
- Surveiller les mises à jour du Swagger et les bulletins techniques CANAFE
- Tester dans l'**environnement de test CANAFE** avant toute mise en production

## 11.4 Séparation données structurées / narratifs

- Les narratifs (`descriptionOfSuspiciousActivity`, `actionTaken.description`) sont des champs TEXT libres
- Les stocker séparément permet une rédaction indépendante du remplissage structuré
- Implémenter un contrôle de cohérence narratif ↔ données structurées

## 11.5 Gestion des erreurs de validation

- **Pré-soumission** : Moteur de validation interne (Section 9)
- **Post-soumission** : Parser la réponse API CANAFE et stocker dans `STR_VALIDATION_ERROR`
- Implémenter un workflow de correction avec notification
- Le rapport corrigé doit être soumis dans les **20 jours**

## 11.6 Gouvernance des enums

- Créer des **tables de référence** pour chaque enum CANAFE (`REF_SUSPICION_TYPE`, `REF_METHOD_CODE`, `REF_DISPOSITION_CODE`, etc.)
- Mettre à jour ces tables lorsque CANAFE publie de nouvelles valeurs
- Utiliser des contraintes FK pour empêcher les valeurs invalides

## 11.7 Tests unitaires de génération JSON

- Test unitaire pour chaque type de définition (PersonName, EntityDetails, etc.)
- Test d'intégration pour un rapport complet avec multiple transactions
- Validation du JSON généré contre le schéma OpenAPI
- Tests de régression lors des mises à jour du schéma
- Utiliser les scénarios de l'Annex B de la guidance CANAFE comme cas de test

## 11.8 Environnement de test CANAFE

- CANAFE fournit un **Report Ingest Test API** pour valider les soumissions
- Utiliser cet environnement pour chaque release
- Tester les cas limites : transactions tentées, directive ministérielle, monnaie virtuelle
- Contacter `tech@fintrac-canafe.gc.ca` pour support technique

## 11.9 Stratégie de preuve / audit

- **Non-répudiation** : Hash SHA-256 du payload soumis
- **Traçabilité** : Chaque action (création, édition, validation, soumission) est journalisée avec utilisateur et timestamp
- **Intégrité** : La copie du JSON soumis est immuable
- **Preuve de soumission** : Stocker la réponse API CANAFE (acknowledgement ID, timestamp)
- **Preuve de conservation** : Mécanisme d'archivage avec rétention 5 ans

---

# SECTION 12 — Liste des zones à confirmer

> Les éléments suivants nécessitent une validation auprès de CANAFE, dans le Swagger authentifié (portail API), ou dans la documentation technique officielle.

## 12.1 Champs ambigus

| Élément | Ambiguïté | Source |
|---------|-----------|--------|
| `definitions[].typeCode` | La correspondance exacte typeCode ↔ structure JSON imbriquée doit être validée dans le schéma OpenAPI authentifié | Swagger public limité |
| `accountType` enum values | La liste complète des types de comptes n'est pas visible dans le Swagger public | À confirmer dans le portail API |
| `accountStatusAtTimeOfTransaction` | Format libre ou enum ? (active, inactive, dormant, closed mentionnés dans la guidance mais pas comme enum formel) | Guidance vs Swagger |
| `virtualCurrencyTypeCode` | Liste complète des codes VC non exposée publiquement | Portail API |

## 12.2 Règles conditionnelles non explicites

| Règle | Question |
|-------|----------|
| Night deposit / Quick drop | Exemption du conductor — le champ `conductorIndicator` doit-il être `false` automatiquement ? |
| Transaction tentée | Les champs mandatory (*) deviennent-ils tous "reasonable measures" ? Comment le schéma JSON gère-t-il ce changement de cardinalité ? |
| Directive ministérielle | La validation API rejette-t-elle si `detailsOfSuspicion` est renseigné avec une directive ? |

## 12.3 Cardinalités non évidentes

| Élément | Question |
|---------|----------|
| `transactions[]` maximum | Y a-t-il une limite au nombre de transactions par rapport ? (guidance mentionne des limites de soumission) |
| `definitions[]` maximum | Limite au nombre de définitions ? |
| `personsAuthorized[]` | Maximum 3 confirmé par guidance, mais validé par le schéma ? |
| `completingActions[]` minimum | Requis pour transaction complétée, optionnel pour tentée ? |

## 12.4 Valeurs permises non exposées

| Enum | Statut |
|------|--------|
| `activitySectorCode` | Liste partielle connue (2,3,6,10,14,16,19,20) — liste complète à confirmer |
| `currencyCode` | ISO 4217 supposé — confirmé ? Ou sous-ensemble CANAFE ? |
| `identifierType` | Liste fermée ou ouverte avec "Other" ? |
| `accountType` | Liste fermée ou ouverte avec "Other" ? |
| `relationshipOfConductorCode` | 1-14 visible, signification exacte de chaque code à confirmer |
| `publicPrivatePartnershipProjectNameCodes` | Liste de 8 codes visible — peut évoluer |

## 12.5 Contraintes API non visibles

| Élément | Question |
|---------|----------|
| Rate limiting | Combien de rapports par minute/heure ? |
| Taille maximale du payload | Limite en Ko/Mo du JSON ? |
| Authentification | OAuth2, API Key, ou autre mécanisme ? |
| Idempotence | Que se passe-t-il si le même `reportingEntityReportReference` est soumis deux fois ? |
| Réponse API | Structure exacte de la réponse (acknowledgement ID, erreurs) ? |
| Certificats TLS | Mutual TLS requis ? |

## 12.6 Exigences de correction / modification

| Élément | Question |
|---------|----------|
| `submitTypeCode = 2` (Update) | Faut-il renvoyer le rapport complet ou seulement les champs modifiés ? |
| `submitTypeCode = 5` (Delete) | Quelles conditions permettent la suppression ? |
| Délai de correction | 20 jours confirmé dans la guidance — validé dans l'API ? |
| Raison de modification | Où/comment fournir la raison du changement dans le JSON ? |
| Versioning | CANAFE conserve-t-il l'historique des versions ? |

## 12.7 Éléments du schéma non confirmés publiquement

| Élément | Statut |
|---------|--------|
| Structure exacte de `details` dans `definitions[]` selon `typeCode` | Schéma polymorphe (oneOf) à valider dans le Swagger authentifié |
| `strAccount` — structure exacte des champs imbriqués | À confirmer |
| Noms exacts des propriétés JSON (camelCase) | Basés sur l'analyse du Swagger public — à valider |
| Champs `required` dans les sous-objets | La profondeur des validations requises n'est pas entièrement visible publiquement |

---

## Contacts CANAFE pour validation

| Besoin | Contact |
|--------|---------|
| Questions techniques API | tech@fintrac-canafe.gc.ca |
| Accès au portail API | F2R@fintrac-canafe.gc.ca |
| Questions réglementaires | guidelines-lignesdirectrices@fintrac-canafe.gc.ca |
| Téléphone | 1-866-346-8722 |

