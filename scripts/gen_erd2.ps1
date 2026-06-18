# Generate Draw.io ERD - inline approach (no functions)
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append('<?xml version="1.0" encoding="UTF-8"?><mxfile host="app.diagrams.net">')

# Styles
$B="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#dae8fc;strokeColor=#6c8ebf;"
$G="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#d5e8d4;strokeColor=#82b366;"
$O="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#ffe6cc;strokeColor=#d6b656;"
$P="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#e1d5e7;strokeColor=#9673a6;"
$Te="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#d5f5e3;strokeColor=#27ae60;"
$R="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#f8cecc;strokeColor=#b85450;"
$Gr="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#f5f5f5;strokeColor=#666666;"
$Y="rounded=1;whiteSpace=wrap;overflow=hidden;align=left;verticalAlign=top;fontSize=10;spacingLeft=4;spacingTop=2;fillColor=#fff2cc;strokeColor=#d6b656;"
$GS="rounded=1;fillColor=FILL;opacity=15;fontSize=14;fontStyle=1;verticalAlign=top;spacingTop=5;dashed=1;dashPattern=5 5;"
$ES="rounded=1;orthogonalLoop=1;fontSize=9;labelBackgroundColor=#FFFFFF;"

# Helper: table cell XML
function cell($id,$val,$style,$x,$y,$w,$h) {
  return "<mxCell id=`"$id`" value=`"$val`" style=`"$style`" vertex=`"1`" parent=`"1`"><mxGeometry x=`"$x`" y=`"$y`" width=`"$w`" height=`"$h`" as=`"geometry`"/></mxCell>"
}
function edge($id,$s,$t,$l) {
  return "<mxCell id=`"$id`" value=`"$l`" style=`"$ES`" edge=`"1`" source=`"$s`" target=`"$t`" parent=`"1`"><mxGeometry relative=`"1`" as=`"geometry`"/></mxCell>"
}
function tbl($name,$lines) {
  $h = ($lines | ForEach-Object { "&lt;br&gt;$_" }) -join ""
  return "&lt;b&gt;$name&lt;/b&gt;&lt;hr size=&quot;1&quot;&gt;$h"
}
function grp($id,$label,$x,$y,$w,$h,$fill) {
  $s=$GS.Replace("FILL",$fill)
  return "<mxCell id=`"$id`" value=`"$label`" style=`"$s`" vertex=`"1`" parent=`"1`"><mxGeometry x=`"$x`" y=`"$y`" width=`"$w`" height=`"$h`" as=`"geometry`"/></mxCell>"
}

# ==================== PAGE 1: VUE D'ENSEMBLE ====================
[void]$sb.Append('<diagram id="p1" name="1 - Vue ensemble"><mxGraphModel dx="2000" dy="1600" grid="1" gridSize="10" page="0"><root><mxCell id="0"/><mxCell id="1" parent="0"/>')
[void]$sb.Append((grp "g1" "1. RAPPORT" 10 10 560 200 "#dae8fc"))
[void]$sb.Append((grp "g2" "2. DEFINITIONS" 10 240 900 200 "#d5e8d4"))
[void]$sb.Append((grp "g3" "3. BENEFICIAL OWNERSHIP" 10 470 900 120 "#f8cecc"))
[void]$sb.Append((grp "g4" "4. IDENTITE" 960 240 260 200 "#fff2cc"))
[void]$sb.Append((grp "g5" "5. TRANSACTIONS" 10 620 560 200 "#ffe6cc"))
[void]$sb.Append((grp "g6" "6. ROLES" 10 850 700 120 "#e1d5e7"))
[void]$sb.Append((grp "g7" "7. COMPTES" 750 850 300 130 "#d5f5e3"))
[void]$sb.Append((grp "g8" "8. AUDIT" 1100 850 360 130 "#f5f5f5"))
# Tables
[void]$sb.Append((cell "a1" (tbl "STR_REPORT" @("PK str_report_id","16 colonnes")) $B 30 40 150 60))
[void]$sb.Append((cell "a2" (tbl "STR_PPP_PROJECT" @("FK str_report_id")) $B 210 40 140 45))
[void]$sb.Append((cell "a3" (tbl "STR_RELATED_REPORT" @("FK str_report_id")) $B 380 40 155 45))
[void]$sb.Append((cell "a4" (tbl "STR_RELATED_RPT_TXN" @("FK related_report_id")) $B 380 110 155 45))
[void]$sb.Append((cell "a5" (tbl "STR_DEFINITION" @("ref_id UNIQUE","type_code 1-6")) $G 30 270 160 55))
[void]$sb.Append((cell "a6" (tbl "STR_PERSON" @("tc 1,3,5")) $G 230 270 120 40))
[void]$sb.Append((cell "a7" (tbl "STR_ENTITY" @("tc 2,4,6")) $G 390 270 120 40))
[void]$sb.Append((cell "a8" (tbl "STR_EMPLOYER_INFO" @("tc5 only")) $G 230 340 130 40))
[void]$sb.Append((cell "a9" (tbl "STR_REG_INCORP" @("FK entity_id")) $G 550 270 130 40))
[void]$sb.Append((cell "a10" (tbl "STR_AUTH_PERSON" @("max 3")) $G 720 270 130 40))
[void]$sb.Append((cell "a11" (tbl "STR_ADDRESS" @("polymorphe, 15 cols")) $Y 980 270 220 40))
[void]$sb.Append((cell "a12" (tbl "STR_IDENTIFICATION" @("polymorphe, 9 cols")) $Y 980 340 220 40))
$boShort = @("DIRECTOR","SHARE_OWN","TRUSTEE","SETTLOR","UNIT_OWN","TRUST_BEN","OTHER_OWN")
$bx=30; $bi=20
foreach($bn in $boShort) {
  [void]$sb.Append((cell "b$bi" (tbl "STR_$bn" @("FK entity_id")) $R $bx 500 115 35))
  $bx+=130; $bi++
}
[void]$sb.Append((cell "a30" (tbl "STR_TRANSACTION" @("13 colonnes")) $O 30 650 170 55))
[void]$sb.Append((cell "a31" (tbl "STR_STARTING_ACTION" @("16 cols, amount=STR!")) $O 230 650 170 55))
[void]$sb.Append((cell "a32" (tbl "STR_COMPLETING_ACTION" @("15 cols, amount=STR!")) $O 430 650 160 55))
[void]$sb.Append((cell "a33" (tbl "STR_CONDUCTOR" @("ref_id")) $P 30 880 115 35))
[void]$sb.Append((cell "a34" (tbl "STR_ON_BEHALF_OF" @("ref_id")) $P 170 880 130 35))
[void]$sb.Append((cell "a35" (tbl "STR_SOURCE_FUNDS" @("ref_id")) $P 330 880 125 35))
[void]$sb.Append((cell "a36" (tbl "STR_INVOLVEMENT" @("ref_id")) $P 480 880 120 35))
[void]$sb.Append((cell "a37" (tbl "STR_BENEFICIARY" @("ref_id")) $P 625 880 110 35))
[void]$sb.Append((cell "a38" (tbl "STR_ACCOUNT" @("polymorphe")) $Te 770 880 140 35))
[void]$sb.Append((cell "a39" (tbl "STR_ACCT_HOLDER" @("ref_id")) $Te 930 880 120 35))
[void]$sb.Append((cell "a40" (tbl "STR_VC_DATA" @("3 arrays")) $Te 770 930 140 35))
[void]$sb.Append((cell "a41" (tbl "STR_API_SUBMISSION" @("FK report_id")) $Gr 1120 880 140 35))
[void]$sb.Append((cell "a42" (tbl "STR_SUBMIT_PAYLOAD" @("SHA-256")) $Gr 1290 880 130 35))
[void]$sb.Append((cell "a43" (tbl "STR_VALID_ERROR" @("FK report_id")) $Gr 1120 930 140 35))
[void]$sb.Append((cell "a44" (tbl "STR_AUDIT_EVENT" @("FK report_id")) $Gr 1290 930 130 35))
# Edges p1
$ei=50
foreach($e in @(
  @("a1","a2","1:N"),@("a1","a3","1:N"),@("a3","a4","1:N"),@("a1","a5","1:N"),@("a1","a30","1:N min1"),
  @("a5","a6","tc1,3,5"),@("a5","a7","tc2,4,6"),@("a6","a8","tc5"),
  @("a7","a9","1:N"),@("a7","a10","max3"),
  @("a6","a11","1:N"),@("a6","a12","1:N"),@("a7","a11","1:N"),@("a7","a12","1:N"),
  @("a30","a31","1:N min1"),@("a30","a32","req[]"),
  @("a31","a33","req[]"),@("a33","a34","req[]"),@("a31","a35","req[]"),
  @("a31","a38","0..1"),@("a31","a40","req[]"),
  @("a32","a36","req[]"),@("a32","a37","req[]"),@("a32","a38","0..1"),@("a32","a40","req[]"),
  @("a38","a39","min1"),
  @("a1","a41","1:N"),@("a41","a42","1:1"),@("a1","a43","1:N"),@("a1","a44","1:N")
)) {
  [void]$sb.Append((edge "e$ei" $e[0] $e[1] $e[2])); $ei++
}
foreach($bi2 in 20..26) { [void]$sb.Append((edge "e$ei" "a7" "b$bi2" "tc6")); $ei++ }
[void]$sb.Append('</root></mxGraphModel></diagram>')

# ==================== PAGE 2: DEFINITIONS ====================
[void]$sb.Append('<diagram id="p2" name="2 - Definitions"><mxGraphModel dx="1800" dy="1200" grid="1" gridSize="10" page="0"><root><mxCell id="0"/><mxCell id="1" parent="0"/>')
[void]$sb.Append((grp "dg1" "DEFINITIONS - Catalogue polymorphe (definitions[])" 10 10 1100 700 "#d5e8d4"))
[void]$sb.Append((cell "d1" (tbl "STR_DEFINITION" @("PK definition_id BIGINT","FK str_report_id BIGINT","ref_id VARCHAR(50) UNIQUE","type_code INT (1-6)")) $G 30 50 240 90))
[void]$sb.Append((cell "d2" (tbl "STR_PERSON (tc 1,3,5)" @("PK person_id","FK definition_id UNIQUE","surname VARCHAR(100)","given_name VARCHAR(100)","other_name_initial VARCHAR(100)","alias VARCHAR(100)","telephone_number VARCHAR(20)","date_of_birth VARCHAR(10)","country_of_residence_code","country_of_citizenship_code (tc5)","occupation VARCHAR(200)","address_type_code INT")) $G 30 200 260 260))
[void]$sb.Append((cell "d3" (tbl "STR_EMPLOYER_INFO (tc5)" @("PK employer_id","FK person_id UNIQUE","name VARCHAR(100)","address_type_code INT","telephone_number VARCHAR(20)")) $G 30 500 240 110))
[void]$sb.Append((cell "d4" (tbl "STR_ENTITY (tc 2,4,6)" @("PK entity_id","FK definition_id UNIQUE","name_of_entity VARCHAR(100)","telephone_number VARCHAR(20)","nature_of_principal_business","address_type_code INT","structure_type_code (tc6)","registration_incorp_indicator")) $G 380 200 270 180))
[void]$sb.Append((cell "d5" (tbl "STR_REG_INCORPORATION" @("PK reg_inc_id","FK entity_id","type_code (1=Reg|2=Inc|4|5)","number, jurisdiction")) $G 380 430 250 90))
[void]$sb.Append((cell "d6" (tbl "STR_AUTHORIZED_PERSON" @("PK auth_id, FK entity_id","surname, given_name","other_name_initial")) $G 380 560 230 70))
[void]$sb.Append((cell "d7" (tbl "STR_ADDRESS" @("PK address_id","owner_type (PERSON|ENTITY|EMPLOYER)","owner_id BIGINT (FK polymorphe)","type_code 1=Structured|2=Unstruct","unit/building/street/city/district","province_state_code/name","sub_province_sub_locality","postal_zip_code, country_code","unstructured VARCHAR(500)")) $Y 750 50 280 200))
[void]$sb.Append((cell "d8" (tbl "STR_IDENTIFICATION" @("PK identification_id","owner_type (PERSON|ENTITY)","owner_id BIGINT","identifier_type_code INT","number VARCHAR(100)","jurisdiction_country/province")) $Y 750 300 280 130))
[void]$sb.Append((edge "de1" "d1" "d2" "tc 1,3,5"))
[void]$sb.Append((edge "de2" "d1" "d4" "tc 2,4,6"))
[void]$sb.Append((edge "de3" "d2" "d3" "tc5 only"))
[void]$sb.Append((edge "de4" "d2" "d7" "1:N"))
[void]$sb.Append((edge "de5" "d2" "d8" "1:N"))
[void]$sb.Append((edge "de6" "d4" "d7" "1:N"))
[void]$sb.Append((edge "de7" "d4" "d8" "1:N"))
[void]$sb.Append((edge "de8" "d4" "d5" "1:N"))
[void]$sb.Append((edge "de9" "d4" "d6" "max 3"))
[void]$sb.Append((edge "de10" "d3" "d7" "0..1"))
[void]$sb.Append('</root></mxGraphModel></diagram>')

# ==================== PAGE 3: BO ====================
[void]$sb.Append('<diagram id="p3" name="3 - Beneficial Ownership"><mxGraphModel dx="1600" dy="1000" grid="1" gridSize="10" page="0"><root><mxCell id="0"/><mxCell id="1" parent="0"/>')
[void]$sb.Append((grp "bg1" "BENEFICIAL OWNERSHIP - entityAndBeneficialOwnershipDetails (typeCode 6)" 10 10 1200 450 "#f8cecc"))
[void]$sb.Append((cell "b1" (tbl "STR_ENTITY (tc6)" @("entity_id PK","name_of_entity","structure_type_code 1-4")) $G 450 40 220 70))
$boFull = @(
  @("b2","STR_DIRECTOR","directorsOfCorporation","personContact","nom+adresse+tel",30,160,230,80),
  @("b3","STR_SHARE_OWNER","personsOwningSharesOfCorp","nom seulement","surname givenName otherNameInitial",290,160,240,70),
  @("b4","STR_TRUSTEE","trusteesOfTrust","personContact","nom+adresse+tel",560,160,220,80),
  @("b5","STR_SETTLOR","settlorsOfTrust","personContact","nom+adresse+tel",810,160,220,80),
  @("b6","STR_TRUST_UNIT_OWNER","personsOwningUnitsOfTrust","personContact","nom+adresse+tel",30,300,240,80),
  @("b7","STR_TRUST_BENEFICIARY","beneficiariesOfTrust","personContact","nom+adresse+tel",300,300,230,80),
  @("b8","STR_OTHER_ENTITY_OWNER","personsOwning...NotCorpOrTrust","nom seulement","surname givenName otherNameInitial",570,300,260,70)
)
foreach($bd in $boFull) {
  [void]$sb.Append((cell $bd[0] (tbl $bd[1] @("FK entity_id",$bd[2],$bd[3],$bd[4])) $R $bd[5] $bd[6] $bd[7] $bd[8]))
  [void]$sb.Append((edge "be$($bd[0])" "b1" $bd[0] "1:N req[]"))
}
[void]$sb.Append('</root></mxGraphModel></diagram>')

# ==================== PAGE 4: TRANSACTIONS ====================
[void]$sb.Append('<diagram id="p4" name="4 - Transactions et Roles"><mxGraphModel dx="1800" dy="1400" grid="1" gridSize="10" page="0"><root><mxCell id="0"/><mxCell id="1" parent="0"/>')
[void]$sb.Append((grp "tg1" "TRANSACTIONS" 10 10 1400 950 "#ffe6cc"))
[void]$sb.Append((cell "t1" (tbl "STR_TRANSACTION" @("PK transaction_id","FK str_report_id","re_location_id VARCHAR(30)","attempted_indicator BOOLEAN","date/time_of_transaction","method_code INT (1-12)","re_txn_reference VARCHAR(200)","purpose VARCHAR(200)")) $O 500 40 260 180))
[void]$sb.Append((cell "t2" (tbl "STR_STARTING_ACTION" @("PK starting_action_id","FK transaction_id","direction (1=In|2=Out)","fund_type_code INT","amount VARCHAR(28) =STRING!","currency_code VARCHAR(3)","exchange_rate VARCHAR(28) =STRING!","account_status_code (1-4)","conductor_indicator BOOL")) $O 30 280 260 200))
[void]$sb.Append((cell "t3" (tbl "STR_COMPLETING_ACTION" @("PK completing_action_id","FK transaction_id","disposition_code (28 vals)","amount VARCHAR(28) =STRING!","value_in_cad VARCHAR(28) =STRING!","account_status_code (1-4)","beneficiary_indicator BOOL")) $O 900 280 260 170))
[void]$sb.Append((cell "t4" (tbl "STR_CONDUCTOR" @("PK conductor_id","FK starting_action_id","type_code (5|6), ref_id","client_number, email","device_type_code, ip_address","on_behalf_of_indicator")) $P 30 540 230 140))
[void]$sb.Append((cell "t5" (tbl "STR_ON_BEHALF_OF" @("PK obo_id","FK conductor_id","type_code (5|6), ref_id","relationship_code (1-14)")) $P 30 730 210 90))
[void]$sb.Append((cell "t6" (tbl "STR_SOURCE_OF_FUNDS" @("PK source_id","FK starting_action_id","type_code (1|2), ref_id","account/policy/identifying_number")) $P 310 540 220 90))
[void]$sb.Append((cell "t7" (tbl "STR_INVOLVEMENT" @("PK involvement_id","FK completing_action_id","type_code (1|2), ref_id","account/policy/identifying_number")) $P 900 540 220 90))
[void]$sb.Append((cell "t8" (tbl "STR_BENEFICIARY" @("PK beneficiary_id","FK completing_action_id","type_code (3|4), ref_id","client_number, username, email")) $P 1150 540 220 90))
[void]$sb.Append((cell "t9" (tbl "STR_ACCOUNT" @("PK account_id","action_type, action_id","fi/branch/number","type_code (1-5), currency","date_opened, date_closed")) $Te 570 540 230 120))
[void]$sb.Append((cell "t10" (tbl "STR_ACCOUNT_HOLDER" @("PK holder_id, FK account_id","type_code (1|2), ref_id")) $Te 570 700 200 50))
[void]$sb.Append((cell "t11" (tbl "STR_VC_DATA" @("PK vc_data_id","action_type, action_id","data_type (TXN_ID|SEND|RECV)","value VARCHAR(200)")) $Te 570 790 200 90))
foreach($te in @(
  @("te1","t1","t2","1:N min1"),@("te2","t1","t3","1:N req[]"),
  @("te3","t2","t4","req[]"),@("te4","t4","t5","req[]"),@("te5","t2","t6","req[]"),
  @("te6","t2","t9","0..1"),@("te7","t2","t11","req[]"),
  @("te8","t3","t7","req[]"),@("te9","t3","t8","req[]"),
  @("te10","t3","t9","0..1"),@("te11","t3","t11","req[]"),
  @("te12","t9","t10","1:N min1")
)) { [void]$sb.Append((edge $te[0] $te[1] $te[2] $te[3])) }
[void]$sb.Append('</root></mxGraphModel></diagram>')

# ==================== PAGE 5: AUDIT ====================
[void]$sb.Append('<diagram id="p5" name="5 - Audit"><mxGraphModel dx="1000" dy="800" grid="1" gridSize="10" page="0"><root><mxCell id="0"/><mxCell id="1" parent="0"/>')
[void]$sb.Append((grp "ag1" "AUDIT ET TRACABILITE" 10 10 650 400 "#f5f5f5"))
[void]$sb.Append((cell "u1" (tbl "STR_REPORT" @("str_report_id PK")) $B 30 50 150 35))
[void]$sb.Append((cell "u2" (tbl "STR_API_SUBMISSION" @("PK submission_id","FK str_report_id","submitted_at, http_status_code","canafe_acknowledgement_id","success_indicator BOOLEAN")) $Gr 250 40 260 120))
[void]$sb.Append((cell "u3" (tbl "STR_SUBMITTED_PAYLOAD" @("PK payload_id","FK submission_id","payload_json TEXT","payload_hash_sha256 VARCHAR(64)")) $Gr 250 190 260 90))
[void]$sb.Append((cell "u4" (tbl "STR_VALIDATION_ERROR" @("PK error_id","FK str_report_id","instance_path, keyword","message_en/fr TEXT")) $Gr 30 140 200 90))
[void]$sb.Append((cell "u5" (tbl "STR_AUDIT_EVENT" @("PK event_id","FK str_report_id","event_type, event_user","event_timestamp, event_details")) $Gr 30 270 200 90))
[void]$sb.Append((edge "ue1" "u1" "u2" "1:N"))
[void]$sb.Append((edge "ue2" "u2" "u3" "1:1"))
[void]$sb.Append((edge "ue3" "u1" "u4" "1:N"))
[void]$sb.Append((edge "ue4" "u1" "u5" "1:N"))
[void]$sb.Append('</root></mxGraphModel></diagram>')

[void]$sb.Append('</mxfile>')
$sb.ToString() | Out-File "CANAFE_STR_ERD_v2.drawio" -Encoding UTF8 -NoNewline
"OK: CANAFE_STR_ERD_v2.drawio generated - $($sb.Length) chars, 5 pages"
