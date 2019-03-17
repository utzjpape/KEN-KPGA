/*
KIHBS 2005/2006
Stephan Dietrich 13.2.2017
poverty profile
*/

clear
set more off
*Carolina*
*global path "C:\Users\wb445085\Box Sync\KPGA\Social Protection data\KIBHS05_06" 
*Stephan*

global in "${gsdData}/2-AnalysisOutput/C8-Vulnerability"
global out "${gsdOutput}/C8-Vulnerability"

*log using "$log/povertyprofile.log", replace

use "$in\kibhs05_06.dta" , clear
cd "$out"

**wich weights: wta_pop or wta_hh
global weight [w=wta_pop]
*psu? strata?*
svyset $weight


*1. Distribtion of consumption (distribution around the poverty line)
egen vll=max(y2_i) if vulnerable1==1 & rururb==1
egen vllr=max(y2_i) if vulnerable1==1  & rururb==2
egen vll2=max(y2_i) if vulnerable2==1 & rururb==1
egen vllr2=max(y2_i) if vulnerable2==1  & rururb==2

sum vll // 1952.452 
sum vllr // 3640.563
sum vll2 // 2342.243
sum vllr2 // 4368.579
sum z2_i if  rururb==1 // 1562.179
sum z2_i if rururb==2 // 2912.798

*kernel density Graph (only below 20000(!) to make the graph more compact
/*
quietly kdensity y2_i if y2_i<10000 & rururb==1, xline(1562.179) xline(1952.452) // xline(2342.243)
graph save rural, replace
quietly kdensity y2_i if y2_i<10000 & rururb==2, xline(2912.798) xline(3640.563) // xline(4368.579) 
graph save urban, replace
graph combine rural.gph urban.gph, ycommon
*/
**summarize vulnerability measures*
local char poor vulnerable4 vulnerable1 vulnerable2
local row = 1
foreach var in `char' {
svy: mean `var'
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel set povertyprofile , sheet("vulnerability") modify

putexcel A`row'=("`varlabel'")
putexcel B`row' = matrix(e(b)) B1=("Population Share")
}

**tabulate vulnerable - poor
svy: tabulate vulnerable4 poor , col row
svy: tabulate vulnerable1 poor , row


** POVERTY & VULNERABILITY PROFILE tables (total poor vulnerable1 vulnerable(estimate) strtucturally poor  transitory vulnerable)**
putexcel set povertyprofile , sheet("profile") modify

*Poverty headcount rate by household head demographic characteristics
putexcel B1=("Total") C1=("Poor") D1=("Vulnerable (Prob poor>46.6%)") E1=("Vulnerable (cons<1.25 pline)") F1=("Structurally poor") G1=("Vulnerable to transitory Poverty")
local char ah24 ah2465 ah65 malehead edulevel1 edulevel2 edulevel3 edulevel4 christian  hhsize depen1 depen2 depen3 depen4 hhunemp hhsector1 hhsector2 hhsector3 hhsector4
local row = 1

foreach var in `char' {
svy: mean `var'
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'")
putexcel B`row' = matrix(e(b))

svy: mean `var' if poor==1
matrix list e(b)
local varlabel: var label `var'
putexcel C`row' = matrix(e(b)) 

svy: mean `var' if vulnerable4==1
matrix list e(b)
local varlabel: var label `var'
putexcel D`row' = matrix(e(b)) 

svy: mean `var' if vulnerable1==1
matrix list e(b)
local varlabel: var label `var'
putexcel E`row' = matrix(e(b)) 

svy: mean `var' if vt_fgls==1
matrix list e(b)
local varlabel: var label `var'
putexcel F`row' = matrix(e(b)) 

svy: mean `var' if vs_fgls==1
matrix list e(b)
local varlabel: var label `var'
putexcel G`row' = matrix(e(b)) 
}

putexcel set povertyprofile , sheet("urbanrural") modify

**Access to services/utilities by poverty status and region**
*rural
putexcel B1=("RURAL") B2=("Total") C2=("Poor") D2=("Vulnerable (Prob poor>29%)") E2=("Vulnerable (cons<1.25 pline)") F2=("Structurally poor") G2=("Vulnerable to transitory Poverty") 
local row = 2
local urbanrural credit bank nocreditaccess credittd ownhouse earthfloor ownsland area_own title dlivestock p04 elec_acc impwater garcoll

foreach var in `urbanrural' {
svy: mean `var' if  rururb==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") 
putexcel B`row' = matrix(e(b)) 
*poor
svy: mean `var' if poor==1 & rururb==1
matrix list e(b)
putexcel C`row' = matrix(e(b)) 
*vulnerable
svy: mean `var'  if vulnerable4==1 & rururb==1
matrix list e(b)
putexcel D`row' = matrix(e(b)) 
svy: mean `var'  if vulnerable1==1 & rururb==1
matrix list e(b)
putexcel E`row' = matrix(e(b)) 
svy: mean `var'  if vs_fgls==1 & rururb==1
matrix list e(b)
putexcel F`row' = matrix(e(b)) 
svy: mean `var'  if vt_fgls==1 & rururb==1
matrix list e(b)
putexcel G`row' = matrix(e(b)) 
}


*urban
putexcel H1=("URBAN") H2=("Total") I2=("Poor") J2=("Vulnerable (Prob poor>29%)") K2=("Vulnerable (cons<1.25 pline)") L2=("Structurally poor") M2=("Vulnerable to transitory Poverty") 
local row = 2

foreach var in `urbanrural' {
svy: mean `var' if rururb==2
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel H`row' = matrix(e(b)) 
*poor
svy: mean `var' if poor==1 & rururb==2
matrix list e(b)
putexcel I`row' = matrix(e(b)) 
*vulnerable
svy: mean `var' if vulnerable4==1 & rururb==2
matrix list e(b)
putexcel J`row' = matrix(e(b)) 
svy: mean `var' if vulnerable1==1 & rururb==2
matrix list e(b)
putexcel K`row' = matrix(e(b)) 
svy: mean `var' if vs_fgls==1 & rururb==2
matrix list e(b)
putexcel L`row' = matrix(e(b)) 
svy: mean `var' if vt_fgls==1 & rururb==2
matrix list e(b)
putexcel M`row' = matrix(e(b)) 
}

putexcel set povertyprofile , sheet("province") modify

*Pov & Vul by province
putexcel B1=("Pop. Share") C1=("Poor") D1=("Vulnerable (Prob poor>29%)") E1=("Vulnerable (cons<1.25 pline)") F1=("Vulnerable (cons<1.5 pline)")
local char province1 province2 province3 province4 province5 province6 province7 province8
local row = 1

foreach var in `char' {
svy: mean `var'
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") 
putexcel B`row' = matrix(e(b)) 

svy: mean poor if `var' ==1
matrix list e(b)
local varlabel: var label `var'
putexcel C`row' = matrix(e(b)) 

svy: mean vulnerable4 if  `var' ==1
matrix list e(b)
local varlabel: var label `var'
putexcel D`row' = matrix(e(b)) 

svy: mean vulnerable1  if `var'==1
matrix list e(b)
local varlabel: var label `var'
putexcel E`row' = matrix(e(b)) 

svy: mean vulnerable2  if `var'==1
matrix list e(b)
local varlabel: var label `var'
putexcel F`row' = matrix(e(b)) 
}

putexcel set povertyprofile , sheet("vuln source") modify

**Sources of vulnerability by province**
putexcel B1=("Vulnerable (Prob poor>29%)") C1=("structurally poor") D1=("vulnerable to transitory poverty")
local char province1 province2 province3 province4 province5 province6 province7 province8
local row = 1

foreach var in `char' {
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") 

svy: mean vs_fgls if  `var' ==1
matrix list e(b)
local varlabel: var label `var'
putexcel c`row' = matrix(e(b)) 

svy: mean vt_fgls  if `var'==1
matrix list e(b)
local varlabel: var label `var'
putexcel D`row' = matrix(e(b)) 
}


*graph on estimated distribution of vulnerability
glcurve vulnerable_fgls if !missing(vulnerable_fgls) ,gl(g1) p(p1) lorenz nograph
glcurve vulnerable_fgls if !missing(vulnerable_fgls) & poor==0,gl(g2) p(p2) lorenz nograph
glcurve vulnerable_fgls if !missing(vulnerable_fgls) & poor==1,gl(g3) p(p3) lorenz nograph
twoway (line g1 p1, sort) (line g2 p2, sort) (line g3 p3, sort)  


*comparison of observed poverty rate and estimated vulnerability on the district level
collapse poor vulnerable_fgls $weight, by(district)
scatter vulnerable_fgls poor

