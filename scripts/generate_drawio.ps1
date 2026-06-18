$header = @'
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2026-06-17" type="device">
<diagram id="canafe-str-erd" name="CANAFE STR ERD - 34 Tables">
<mxGraphModel dx="2500" dy="2500" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="0" pageScale="1" pageWidth="4000" pageHeight="3000" math="0" shadow="0">
<root>
<mxCell id="0"/>
<mxCell id="1" parent="0"/>
'@

$footer = @'
</root>
</mxGraphModel>
</diagram>
</mxfile>
'@

# Style definitions
$hdrBlue = "fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;"
$hdrGreen = "fillColor=#d5e8d4;strokeColor=#82b366;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;"
$hdrOrange = "fillColor=#ffe6cc;strokeColor=#d6b656;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;"
$hdrPurple = "fillColor=#e1d5e7;strokeColor=#9673a6;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;"
$hdrTeal = "fillColor=#d5f5e3;strokeColor=#27ae60;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;"
$hdrRed = "fillColor=#f8cecc;strokeColor=#b85450;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;"
$hdrGray = "fillColor=#f5f5f5;strokeColor=#666666;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;"

$edgeStyle = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;exitX=1;exitY=0.5;exitDx=0;exitDy=0;"
$edgeStyleL = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;"

function MakeTable($id, $name, $cols, $style, $x, $y, $w, $h) {
    $colHtml = ($cols | ForEach-Object { "&lt;br&gt;$_" }) -join ""
    $val = "&lt;b&gt;$name&lt;/b&gt;&lt;hr size=&quot;1&quot;&gt;$colHtml"
    return "<mxCell id=`"$id`" value=`"$val`" style=`"$style`" vertex=`"1`" parent=`"1`"><mxGeometry x=`"$x`" y=`"$y`" width=`"$w`" height=`"$h`" as=`"geometry`"/></mxCell>"
}

function MakeEdge($id, $src, $tgt, $label) {
    return "<mxCell id=`"$id`" value=`"$label`" style=`"$edgeStyleL`" edge=`"1`" source=`"$src`" target=`"$tgt`" parent=`"1`"><mxGeometry relative=`"1`" as=`"geometry`"/></mxCell>"
}

$cells = @()

# === GROUP LABELS ===
$cells += '<mxCell id="g1" value="RAPPORT" style="text;fontSize=16;fontStyle=1;fillColor=#dae8fc;strokeColor=#6c8ebf;rounded=1;spacingLeft=10;spacingRight=10;" vertex="1" parent="1"><mxGeometry x="10" y="0" width="120" height="30" as="geometry"/></mxCell>'
$cells += '<mxCell id="g2" value="DEFINITIONS" style="text;fontSize=16;fontStyle=1;fillColor=#d5e8d4;strokeColor=#82b366;rounded=1;spacingLeft=10;spacingRight=10;" vertex="1" parent="1"><mxGeometry x="10" y="430" width="160" height="30" as="geometry"/></mxCell>'
$cells += '<mxCell id="g3" value="BENEFICIAL OWNERSHIP (tc6)" style="text;fontSize=14;fontStyle=1;fillColor=#f8cecc;strokeColor=#b85450;rounded=1;spacingLeft=8;spacingRight=8;" vertex="1" parent="1"><mxGeometry x="10" y="1010" width="260" height="26" as="geometry"/></mxCell>'
$cells += '<mxCell id="g4" value="TRANSACTIONS" style="text;fontSize=16;fontStyle=1;fillColor=#ffe6cc;strokeColor=#d6b656;rounded=1;spacingLeft=10;spacingRight=10;" vertex="1" parent="1"><mxGeometry x="10" y="1250" width="160" height="30" as="geometry"/></mxCell>'
$cells += '<mxCell id="g5" value="ROLES" style="text;fontSize=16;fontStyle=1;fillColor=#e1d5e7;strokeColor=#9673a6;rounded=1;spacingLeft=10;spacingRight=10;" vertex="1" parent="1"><mxGeometry x="10" y="1830" width="100" height="30" as="geometry"/></mxCell>'
$cells += '<mxCell id="g6" value="COMPTES" style="text;fontSize=16;fontStyle=1;fillColor=#d5f5e3;strokeColor=#27ae60;rounded=1;spacingLeft=10;spacingRight=10;" vertex="1" parent="1"><mxGeometry x="1400" y="1830" width="120" height="30" as="geometry"/></mxCell>'
$cells += '<mxCell id="g7" value="AUDIT" style="text;fontSize=16;fontStyle=1;fillColor=#f5f5f5;strokeColor=#666666;rounded=1;spacingLeft=10;spacingRight=10;" vertex="1" parent="1"><mxGeometry x="2100" y="0" width="100" height="30" as="geometry"/></mxCell>'
$cells += '<mxCell id="g8" value="IDENTITE (partage)" style="text;fontSize=14;fontStyle=1;fillColor=#fff2cc;strokeColor=#d6b656;rounded=1;spacingLeft=8;spacingRight=8;" vertex="1" parent="1"><mxGeometry x="1400" y="430" width="190" height="26" as="geometry"/></mxCell>'

# === RAPPORT (Blue) ===
$cells += MakeTable "t1" "STR_REPORT" @("PK str_report_id BIGINT","report_type_code INT (102)","submit_type_code INT (1|2|5)","activity_sector_code INT","reporting_entity_number NUM(7)","submitting_re_number NUM(7)","re_report_reference VARCHAR(100)","re_contact_id NUMERIC","ministerial_directive_code VARCHAR(10)","suspicion_type_code INT (1-7)","suspicious_activity_desc TEXT","pep_included_indicator BOOLEAN","action_taken_desc TEXT","status VARCHAR(20)","created_at TIMESTAMP","submitted_at TIMESTAMP") $hdrBlue 20 40 300 350
$cells += MakeTable "t2" "STR_PPP_PROJECT" @("PK ppp_id BIGINT","FK str_report_id BIGINT","project_name_code INT (1-8)") $hdrBlue 400 40 240 80
$cells += MakeTable "t3" "STR_RELATED_REPORT" @("PK related_report_id BIGINT","FK str_report_id BIGINT","re_report_reference VARCHAR(100)") $hdrBlue 400 160 240 80
$cells += MakeTable "t4" "STR_RELATED_REPORT_TXN_REF" @("PK id BIGINT","FK related_report_id BIGINT","txn_reference VARCHAR(200)") $hdrBlue 700 160 260 80

# === DEFINITIONS (Green) ===
$cells += MakeTable "t5" "STR_DEFINITION" @("PK definition_id BIGINT","FK str_report_id BIGINT","ref_id VARCHAR(50) UNIQUE","type_code INT (1-6)") $hdrGreen 20 470 260 100

$cells += MakeTable "t6" "STR_PERSON (tc 1,3,5)" @("PK person_id BIGINT","FK definition_id BIGINT UNIQUE","surname VARCHAR(100)","given_name VARCHAR(100)","other_name_initial VARCHAR(100)","alias VARCHAR(100)","telephone_number VARCHAR(20)","extension_number VARCHAR(10)","date_of_birth VARCHAR(10)","country_of_residence_code VARCHAR(2)","country_of_citizenship_code VARCHAR(2)","occupation VARCHAR(200)","name_of_employer VARCHAR(100) tc3","address_type_code INT (1|2)") $hdrGreen 340 470 290 300

$cells += MakeTable "t7" "STR_ENTITY (tc 2,4,6)" @("PK entity_id BIGINT","FK definition_id BIGINT UNIQUE","name_of_entity VARCHAR(100)","telephone_number VARCHAR(20)","extension_number VARCHAR(10)","nature_of_principal_business VARCHAR(200)","address_type_code INT (1|2)","structure_type_code INT (1-4) tc6","structure_type_other VARCHAR(200)","registration_incorp_indicator BOOL") $hdrGreen 700 470 300 230

$cells += MakeTable "t8" "STR_EMPLOYER_INFO (tc5)" @("PK employer_id BIGINT","FK person_id BIGINT UNIQUE","name VARCHAR(100)","address_type_code INT (1|2)","telephone_number VARCHAR(20)","extension_number VARCHAR(10)") $hdrGreen 340 800 260 140

# === IDENTITY (Yellow) ===
$cells += MakeTable "t9" "STR_ADDRESS" @("PK address_id BIGINT","owner_type VARCHAR(20)","owner_id BIGINT","type_code INT (1=Struct|2=Unstruct)","unit_number VARCHAR(10)","building_number VARCHAR(10)","street_address VARCHAR(100)","city VARCHAR(100)","district VARCHAR(100)","province_state_code VARCHAR(10)","province_state_name VARCHAR(100)","sub_province_sub_locality VARCHAR(100)","postal_zip_code VARCHAR(20)","country_code VARCHAR(2)","unstructured VARCHAR(500)") "fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;" 1400 470 290 340

$cells += MakeTable "t10" "STR_IDENTIFICATION" @("PK identification_id BIGINT","owner_type VARCHAR(20)","owner_id BIGINT","identifier_type_code INT","identifier_type_other VARCHAR(200)","number VARCHAR(100)","jurisdiction_country_code VARCHAR(2)","jurisdiction_prov_state_code VARCHAR(10)","jurisdiction_prov_state_name VARCHAR(100)") "fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;fontSize=11;align=left;verticalAlign=top;whiteSpace=wrap;overflow=hidden;" 1400 840 290 210

# === ENTITY DETAILS ===
$cells += MakeTable "t11" "STR_REGISTRATION_INCORPORATION" @("PK reg_inc_id BIGINT","FK entity_id BIGINT","type_code INT (1=Reg|2=Inc|4|5)","number VARCHAR(100)","jurisdiction_country_code VARCHAR(2)","jurisdiction_prov_state_code VARCHAR(10)") $hdrGreen 1060 470 280 150

$cells += MakeTable "t12" "STR_AUTHORIZED_PERSON" @("PK auth_id BIGINT","FK entity_id BIGINT","surname VARCHAR(100)","given_name VARCHAR(100)","other_name_initial VARCHAR(100)") $hdrGreen 1060 650 260 120

# === BENEFICIAL OWNERSHIP (Red) tc6 ===
$cells += MakeTable "t13" "STR_DIRECTOR" @("PK director_id BIGINT","FK entity_id BIGINT","surname, given_name, other_name_initial","address_type_code, telephone, extension") $hdrRed 20 1050 240 100
$cells += MakeTable "t14" "STR_SHARE_OWNER" @("PK share_owner_id BIGINT","FK entity_id BIGINT","surname, given_name, other_name_initial") $hdrRed 280 1050 230 80
$cells += MakeTable "t15" "STR_TRUSTEE" @("PK trustee_id BIGINT","FK entity_id BIGINT","surname, given_name, other_name_initial","address_type_code, telephone, extension") $hdrRed 530 1050 240 100
$cells += MakeTable "t16" "STR_SETTLOR" @("PK settlor_id BIGINT","FK entity_id BIGINT","surname, given_name, other_name_initial","address_type_code, telephone, extension") $hdrRed 790 1050 230 100
$cells += MakeTable "t17" "STR_TRUST_UNIT_OWNER" @("PK unit_owner_id BIGINT","FK entity_id BIGINT","name, address, telephone") $hdrRed 1040 1050 220 80
$cells += MakeTable "t18" "STR_TRUST_BENEFICIARY" @("PK trust_ben_id BIGINT","FK entity_id BIGINT","name, address, telephone") $hdrRed 1280 1050 220 80
$cells += MakeTable "t19" "STR_OTHER_ENTITY_OWNER" @("PK other_owner_id BIGINT","FK entity_id BIGINT","surname, given_name, other_name_initial") $hdrRed 1520 1050 240 80

# === TRANSACTIONS (Orange) ===
$cells += MakeTable "t20" "STR_TRANSACTION" @("PK transaction_id BIGINT","FK str_report_id BIGINT","re_location_id VARCHAR(30)","attempted_indicator BOOLEAN","reason_not_completed VARCHAR(200)","date_of_transaction VARCHAR(10)","time_of_transaction VARCHAR(25)","method_code INT (1-12)","method_other VARCHAR(200)","date_of_posting VARCHAR(10)","time_of_posting VARCHAR(25)","re_txn_reference VARCHAR(200)","purpose VARCHAR(200)") $hdrOrange 600 1290 290 290

$cells += MakeTable "t21" "STR_STARTING_ACTION" @("PK starting_action_id BIGINT","FK transaction_id BIGINT","direction INT (1=In|2=Out)","fund_type_code INT","fund_type_other VARCHAR(200)","amount VARCHAR(28) STRING!","currency_code VARCHAR(3)","vc_type_code VARCHAR(10)","exchange_rate VARCHAR(28) STRING!","account_status_code INT (1-4)","how_funds_obtained VARCHAR(200)","source_funds_indicator BOOLEAN","conductor_indicator BOOLEAN") $hdrOrange 20 1290 280 290

$cells += MakeTable "t22" "STR_COMPLETING_ACTION" @("PK completing_action_id BIGINT","FK transaction_id BIGINT","disposition_code INT (28 vals)","disposition_other VARCHAR(200)","amount VARCHAR(28) STRING!","currency_code VARCHAR(3)","exchange_rate VARCHAR(28) STRING!","value_in_cad VARCHAR(28) STRING!","account_status_code INT (1-4)","involvement_indicator BOOLEAN","beneficiary_indicator BOOLEAN") $hdrOrange 1100 1290 280 260

# === ROLES (Purple) ===
$cells += MakeTable "t23" "STR_CONDUCTOR" @("PK conductor_id BIGINT","FK starting_action_id BIGINT","type_code INT (5|6)","ref_id VARCHAR(50)","client_number VARCHAR(100)","email_address VARCHAR(200)","device_type_code INT (1-4)","username VARCHAR(100)","ip_address VARCHAR(200)","online_session_datetime VARCHAR(30)","on_behalf_of_indicator BOOLEAN") $hdrPurple 20 1870 270 250

$cells += MakeTable "t24" "STR_ON_BEHALF_OF" @("PK obo_id BIGINT","FK conductor_id BIGINT","type_code INT (5|6)","ref_id VARCHAR(50)","client_number VARCHAR(100)","relationship_code INT (1-14)","relationship_other VARCHAR(200)") $hdrPurple 20 2150 260 160

$cells += MakeTable "t25" "STR_SOURCE_OF_FUNDS" @("PK source_id BIGINT","FK starting_action_id BIGINT","type_code INT (1|2)","ref_id VARCHAR(50)","account_number VARCHAR(200)","policy_number VARCHAR(100)","identifying_number VARCHAR(100)") $hdrPurple 350 1870 260 160

$cells += MakeTable "t26" "STR_INVOLVEMENT" @("PK involvement_id BIGINT","FK completing_action_id BIGINT","type_code INT (1|2)","ref_id VARCHAR(50)","account_number VARCHAR(200)","identifying_number VARCHAR(100)","policy_number VARCHAR(100)") $hdrPurple 700 1870 260 160

$cells += MakeTable "t27" "STR_BENEFICIARY" @("PK beneficiary_id BIGINT","FK completing_action_id BIGINT","type_code INT (3|4)","ref_id VARCHAR(50)","client_number VARCHAR(100)","username VARCHAR(100)","email_address VARCHAR(200)") $hdrPurple 1020 1870 260 160

# === COMPTES (Teal) ===
$cells += MakeTable "t28" "STR_ACCOUNT" @("PK account_id BIGINT","action_type VARCHAR(10)","action_id BIGINT","fi_number VARCHAR(50)","branch_number VARCHAR(50)","number VARCHAR(100)","type_code INT (1-5)","type_other VARCHAR(200)","currency_code VARCHAR(3)","date_opened VARCHAR(10)","date_closed VARCHAR(10)") $hdrTeal 1400 1870 270 250

$cells += MakeTable "t29" "STR_ACCOUNT_HOLDER" @("PK holder_id BIGINT","FK account_id BIGINT","type_code INT (1|2)","ref_id VARCHAR(50)") $hdrTeal 1400 2150 240 100

$cells += MakeTable "t30" "STR_VC_DATA" @("PK vc_data_id BIGINT","action_type VARCHAR(10)","action_id BIGINT","data_type VARCHAR(20)","value VARCHAR(200)") $hdrTeal 1720 1870 240 120

# === AUDIT (Gray) ===
$cells += MakeTable "t31" "STR_API_SUBMISSION" @("PK submission_id BIGINT","FK str_report_id BIGINT","submitted_at TIMESTAMP","http_status_code INT","api_response_body TEXT","canafe_acknowledgement_id VARCHAR(100)","success_indicator BOOLEAN") $hdrGray 2100 40 280 170

$cells += MakeTable "t32" "STR_SUBMITTED_PAYLOAD" @("PK payload_id BIGINT","FK str_report_id BIGINT","FK submission_id BIGINT","payload_json TEXT","payload_hash_sha256 VARCHAR(64)","created_at TIMESTAMP") $hdrGray 2100 240 280 140

$cells += MakeTable "t33" "STR_VALIDATION_ERROR" @("PK error_id BIGINT","FK str_report_id BIGINT","instance_path VARCHAR(500)","schema_path VARCHAR(500)","keyword VARCHAR(100)","message_en TEXT","message_fr TEXT","detected_at TIMESTAMP") $hdrGray 2100 410 280 190

$cells += MakeTable "t34" "STR_AUDIT_EVENT" @("PK event_id BIGINT","FK str_report_id BIGINT","event_type VARCHAR(30)","event_user VARCHAR(100)","event_timestamp TIMESTAMP","event_details TEXT") $hdrGray 2100 630 280 150

# === EDGES (Relationships) ===
$eid = 100
$edges = @()
# Report relations
$edges += MakeEdge ($eid++) "t1" "t2" "1:N"
$edges += MakeEdge ($eid++) "t1" "t3" "1:N"
$edges += MakeEdge ($eid++) "t3" "t4" "1:N"
$edges += MakeEdge ($eid++) "t1" "t5" "1:N"
$edges += MakeEdge ($eid++) "t1" "t20" "1:N min1"
$edges += MakeEdge ($eid++) "t1" "t31" "1:N"
$edges += MakeEdge ($eid++) "t1" "t33" "1:N"
$edges += MakeEdge ($eid++) "t1" "t34" "1:N"
$edges += MakeEdge ($eid++) "t31" "t32" "1:1"
# Definition relations
$edges += MakeEdge ($eid++) "t5" "t6" "0..1 (tc1,3,5)"
$edges += MakeEdge ($eid++) "t5" "t7" "0..1 (tc2,4,6)"
$edges += MakeEdge ($eid++) "t6" "t8" "0..1 (tc5)"
$edges += MakeEdge ($eid++) "t6" "t9" "1:N"
$edges += MakeEdge ($eid++) "t6" "t10" "1:N"
$edges += MakeEdge ($eid++) "t7" "t9" "1:N"
$edges += MakeEdge ($eid++) "t7" "t10" "1:N"
$edges += MakeEdge ($eid++) "t7" "t11" "1:N"
$edges += MakeEdge ($eid++) "t7" "t12" "1:N max3"
# BO relations
$edges += MakeEdge ($eid++) "t7" "t13" "1:N (tc6)"
$edges += MakeEdge ($eid++) "t7" "t14" "1:N (tc6)"
$edges += MakeEdge ($eid++) "t7" "t15" "1:N (tc6)"
$edges += MakeEdge ($eid++) "t7" "t16" "1:N (tc6)"
$edges += MakeEdge ($eid++) "t7" "t17" "1:N (tc6)"
$edges += MakeEdge ($eid++) "t7" "t18" "1:N (tc6)"
$edges += MakeEdge ($eid++) "t7" "t19" "1:N (tc6)"
# Transaction relations
$edges += MakeEdge ($eid++) "t20" "t21" "1:N min1"
$edges += MakeEdge ($eid++) "t20" "t22" "1:N req[]"
# Starting action relations
$edges += MakeEdge ($eid++) "t21" "t23" "1:N req[]"
$edges += MakeEdge ($eid++) "t21" "t25" "1:N req[]"
$edges += MakeEdge ($eid++) "t21" "t28" "0..1"
$edges += MakeEdge ($eid++) "t21" "t30" "1:N req[]"
$edges += MakeEdge ($eid++) "t23" "t24" "1:N req[]"
# Completing action relations
$edges += MakeEdge ($eid++) "t22" "t26" "1:N req[]"
$edges += MakeEdge ($eid++) "t22" "t27" "1:N req[]"
$edges += MakeEdge ($eid++) "t22" "t28" "0..1"
$edges += MakeEdge ($eid++) "t22" "t30" "1:N req[]"
# Account relations
$edges += MakeEdge ($eid++) "t28" "t29" "1:N min1"

# Build final XML
$xml = $header + "`n" + ($cells -join "`n") + "`n" + ($edges -join "`n") + "`n" + $footer

$xml | Out-File -FilePath "CANAFE_STR_ERD.drawio" -Encoding UTF8
Write-Host "Generated CANAFE_STR_ERD.drawio successfully - 34 tables"
