# Add explanatory notes - using StringBuilder to avoid & issues
$ns = "shape=note;whiteSpace=wrap;html=1;fillColor=#FFF9C4;strokeColor=#F9A825;fontSize=9;align=left;verticalAlign=top;spacingLeft=6;spacingTop=4;spacingRight=6;shadow=1;rounded=1;"

function MkNote($id,$text,$x,$y,$w,$h) {
  $t = $text.Replace("<","&lt;").Replace(">","&gt;").Replace('"',"&quot;")
  return "<mxCell id=""$id"" value=""$t"" style=""$ns"" vertex=""1"" parent=""1""><mxGeometry x=""$x"" y=""$y"" width=""$w"" height=""$h"" as=""geometry""/></mxCell>"
}

# ===== PAGE 1: Vue ensemble =====
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append((MkNote "n1" "<b>STR_REPORT</b><br>Le dossier principal. Contient toutes les infos du rapport : qui le soumet, pourquoi c est suspect, le statut. Tout le reste y est rattache." 30 410 300 60))
[void]$sb.Append((MkNote "n2" "<b>STR_DEFINITION</b><br>Le carnet d adresses. Chaque personne ou compagnie a une fiche avec un <b>refId</b> unique, reutilise partout dans le rapport." 30 390 280 55))
[void]$sb.Append((MkNote "n3" "<b>TRANSACTIONS</b><br>Starting Action = l argent ENTRE. Completing Action = l argent SORT. Chaque transaction a au moins 1 starting action." 30 720 270 55))
[void]$sb.Append((MkNote "n4" "<b>ROLES</b><br>Conducteur = qui apporte l argent. Beneficiaire = qui recoit. Source = d ou vient l argent. Involvement = tiers implique." 30 970 270 50))
[void]$sb.Append((MkNote "n5" "<b>AUDIT</b><br>Copie du JSON envoye + hash SHA-256 + erreurs de validation + journal de chaque action. Conservation min 5 ans." 1100 970 310 45))
$p1notes = $sb.ToString()
$f1 = Get-Content "diagrams/ERD_1_1___Vue_ensemble.drawio" -Raw
$f1 = $f1.Replace("</root>", "$p1notes</root>")
$f1 | Out-File "diagrams/ERD_1_1___Vue_ensemble.drawio" -Encoding UTF8 -NoNewline
Write-Host "P1 OK"

# ===== PAGE 2: Definitions =====
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append((MkNote "n10" "<b>Comment ca marche ?</b><br>1. On cree une DEFINITION avec un refId (ex: toto-01)<br>2. Le typeCode determine si c est une personne ou entite<br>3. Le refId est reutilise partout (conducteur, beneficiaire, etc.)<br><br>C est comme un contact favori : on l enregistre une fois et on le reutilise." 30 700 350 100))
[void]$sb.Append((MkNote "n11" "<b>Personnes :</b><br>TypeCode 1 = Nom seul<br>TypeCode 3 = Personne detaillee (+ adresse, ID)<br>TypeCode 5 = Personne complete (+ employeur)" 310 160 220 70))
[void]$sb.Append((MkNote "n12" "<b>Entites :</b><br>TypeCode 2 = Nom entite seul<br>TypeCode 4 = Entite detaillee<br>TypeCode 6 = Entite + proprietaires reels (7 tables BO)" 690 200 220 70))
[void]$sb.Append((MkNote "n13" "<b>STR_ADDRESS</b><br>Table partagee par tous. Le champ owner_type dit a qui appartient l adresse.<br>2 formats : Structuree (rue, ville) ou Non structuree (texte libre)." 780 540 260 70))
[void]$sb.Append((MkNote "n14" "<b>STR_IDENTIFICATION</b><br>Pieces d identite : passeport, permis, carte RP, etc. Partagee entre personnes et entites." 780 280 260 50))
[void]$sb.Append((MkNote "n15" "<b>STR_EMPLOYER_INFO</b><br>Infos employeur du conducteur. Requis seulement pour typeCode 5." 30 640 240 40))
$p2notes = $sb.ToString()
$f2 = Get-Content "diagrams/ERD_2_2___Definitions.drawio" -Raw
$f2 = $f2.Replace("</root>", "$p2notes</root>")
$f2 | Out-File "diagrams/ERD_2_2___Definitions.drawio" -Encoding UTF8 -NoNewline
Write-Host "P2 OK"

# ===== PAGE 3: BO =====
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append((MkNote "n20" "<b>Pourquoi 7 tables ?</b><br>CANAFE veut savoir qui est VRAIMENT derriere une compagnie. Chaque type de proprietaire a son propre array JSON.<br><br>Ces tables ne sont remplies que pour typeCode 6." 30 420 300 80))
[void]$sb.Append((MkNote "n21" "<b>personContact</b> = nom + adresse + telephone<br>DIRECTOR, TRUSTEE, SETTLOR, TRUST_UNIT_OWNER, TRUST_BENEFICIARY" 400 420 260 50))
[void]$sb.Append((MkNote "n22" "<b>nom seulement</b> = surname + givenName + otherNameInitial<br>SHARE_OWNER, OTHER_ENTITY_OWNER" 700 420 250 40))
[void]$sb.Append((MkNote "n23" "<b>structureTypeCode :</b><br>1 = Corporation -> directeurs + actionnaires<br>3 = Fiducie -> fiduciaires + constituants + beneficiaires<br>2 = Autre -> other entity owners" 450 120 300 65))
$p3notes = $sb.ToString()
$f3 = Get-Content "diagrams/ERD_3_3___Beneficial_Ownership.drawio" -Raw
$f3 = $f3.Replace("</root>", "$p3notes</root>")
$f3 | Out-File "diagrams/ERD_3_3___Beneficial_Ownership.drawio" -Encoding UTF8 -NoNewline
Write-Host "P3 OK"

# ===== PAGE 4: Transactions =====
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append((MkNote "n30" "<b>Le flux :</b><br>1. L argent ENTRE (Starting Action) : cash, virement, etc.<br>2. L argent SORT (Completing Action) : depot, virement international, etc.<br>Chaque transaction a au moins 1 starting action." 800 40 320 80))
[void]$sb.Append((MkNote "n31" "<b>PIEGE : amount = STRING !</b><br>Les montants sont du texte (ex: 11000.00), pas des nombres. CANAFE valide avec une regex. Ne jamais utiliser DECIMAL dans le JSON." 340 280 250 60))
[void]$sb.Append((MkNote "n32" "<b>STR_CONDUCTOR</b><br>La personne qui fait la transaction (en personne ou en ligne). Toujours typeCode 5 ou 6." 290 590 230 45))
[void]$sb.Append((MkNote "n33" "<b>STR_ON_BEHALF_OF</b><br>Si le conducteur agit pour quelqu un d autre. Ex: un avocat pour son client." 290 740 230 40))
[void]$sb.Append((MkNote "n34" "<b>STR_BENEFICIARY</b><br>Qui recoit l argent au final. TypeCode 3 ou 4." 1150 700 200 40))
[void]$sb.Append((MkNote "n35" "<b>STR_ACCOUNT</b><br>Compte bancaire implique. Peut etre cote starting (source) ou completing (destination)." 570 950 250 40))
[void]$sb.Append((MkNote "n36" "<b>STR_VC_DATA</b><br>Donnees crypto. Vide pour les transactions classiques mais les 3 arrays JSON sont toujours requis (vides = [])." 830 880 250 50))
[void]$sb.Append((MkNote "n37" "<b>req[]</b> sur les fleches = array requis dans le JSON, meme s il est vide. Toujours emettre [] jamais omettre." 1200 280 220 50))
$p4notes = $sb.ToString()
$f4 = Get-Content "diagrams/ERD_4_4___Transactions_et_Roles.drawio" -Raw
$f4 = $f4.Replace("</root>", "$p4notes</root>")
$f4 | Out-File "diagrams/ERD_4_4___Transactions_et_Roles.drawio" -Encoding UTF8 -NoNewline
Write-Host "P4 OK"

# ===== PAGE 5: Audit =====
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append((MkNote "n40" "<b>Pourquoi l audit ?</b><br>CANAFE peut auditer votre banque. Vous devez prouver :<br>- Ce que vous avez envoye (copie JSON)<br>- Quand vous l avez envoye<br>- Que personne ne l a modifie (hash SHA-256)<br>- Les erreurs rencontrees<br><br>Conservation : minimum 5 ans." 30 450 300 110))
[void]$sb.Append((MkNote "n41" "<b>STR_API_SUBMISSION</b><br>Le recu : quand on a envoye, code HTTP (200=OK, 400=erreur), ID accuse de reception CANAFE." 530 40 250 50))
[void]$sb.Append((MkNote "n42" "<b>STR_SUBMITTED_PAYLOAD</b><br>Copie exacte du JSON envoye + empreinte SHA-256. Preuve d integrite." 530 190 250 40))
[void]$sb.Append((MkNote "n43" "<b>STR_VALIDATION_ERROR</b><br>Erreurs CANAFE. Le champ instance_path dit exactement ou est l erreur dans le JSON." 250 140 250 45))
[void]$sb.Append((MkNote "n44" "<b>STR_AUDIT_EVENT</b><br>Journal de bord : qui a cree, modifie, valide et soumis le rapport. Trace complete." 250 310 250 40))
$p5notes = $sb.ToString()
$f5 = Get-Content "diagrams/ERD_5_5___Audit.drawio" -Raw
$f5 = $f5.Replace("</root>", "$p5notes</root>")
$f5 | Out-File "diagrams/ERD_5_5___Audit.drawio" -Encoding UTF8 -NoNewline
Write-Host "P5 OK"

Write-Host "`nAll 5 pages annotated!"
