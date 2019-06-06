/*
KIHBS 2005/2006
Stephan Dietrich 3.1.2017
Prepare Shock Section/Coping Strategies
*/

clear
set more off
*global path "C:\Users\wb445085\Box Sync\KPGA\Social Protection data\KIBHS05_06" 
*Stephan*
global path "C:\Users\s.dietrich\Box Sync\KPGA\Social Protection data\KIBHS05_06" 

global in "${gsdDataRaw}/KIHBS05"
global out "${gsdData}/2-AnalysisOutput/C8-Vulnerability"

use "$in\Section T Recent Shocks.dta" , clear

*create unique hh identifier*
egen uhhid=concat(id_clust id_hh)
*create codes for shock and coping strategy types
egen shock_code=group(t01)
egen coping_code=group(t08_1)
/*
Some households reported more than one shock of the same category in the last 5 years e.g. 2 droughts, which was not foreseen in the survey. 
I drop observations of 17 households
*/
bysort uhhid t01: egen dupli = count(_n)
drop if dupli>1
drop dupli

*reshape data to wide to get one observation per household
reshape wide coping_code id_clust id_hh t01 t02 t03 t04 t05 t06 t07_1 t07_2 t08_1 t08_2 t08_3 weight, i(uhhid) j(shock_code)

*tag observations with incomplete shock section*
*several observations with t02=0 are replaced as missing (0 response not foreseen in response code)
gen missingshocks=0 
foreach num of numlist 1/20 {
replace t02`num'=. if t02`num'==0
replace missingshocks=1 if t02`num'==.
}
/*
More tahn 70% of hh responded to less than the 21 shock categories. it seems that in about 20% only the 3 most important shocks were recorded. 
Only focus on the 3 most important Shock Categories?
--> drop observation that were not among the 3 most severe shocks of hh (variable t03)
*/
foreach num of numlist 1/23 {
replace t02`num'=. if t02`num'==0
replace t02`num'=. if t03`num'==.
}
foreach num of numlist 1/23 {
replace t02`num'=. if t02`num'==0
}
**how many households suffered a shock in past 5 years? (96%)
egen shock=rownonmiss(t02*)
**75 households reported more than 3 shocks as 3 most important shocks. drop?
*drop if shock>3
*replace shock=1 if shock>1

**dummy variables for 23 shock categories (only if among the 3 most severe shocks in past 5 years!)
generate drought = 0 
replace drought=1 if t031<4 
generate croppest = 0 
replace croppest=1 if (t032<4)
generate livestock =0 
replace livestock=1 if (t033<4)  
generate business = 0 
replace business=1 if (t034<4)  
generate unemployment =0  
replace unemployment =1 if (t035<4) 
generate endassistance = 0 
replace endassistance=1 if (t036<4) 
generate cropprice = 0 
replace cropprice =1 if(t037<4) 
generate foodprice =0 
replace foodprice=1 if  (t038<4)
generate inputprice = 0 
replace inputprice=1 if (t039<4)
generate watershortage = 0 
replace watershortage=1 if (t0310<4) 
generate illness = 0 
replace illness=1 if (t0311<4) 
generate birth = 0 
replace birth=1 if (t0312<4)
generate deathhead = 0  
replace deathhead=1 if (t0313<4)
generate deathwork = 0 
replace deathwork=1 if (t0314<4)
generate deathother =0 
replace deathother=1 if (t0315<4)
generate breakuphh = 0 
replace breakuphh=1 if (t0316<4)
generate jail = 0  
replace jail=1 if (t0317<4)
generate fire = 0 
replace fire=1 if (t0318<4)
generate assault = 0 
replace assault=1 if (t0319<4)
generate dwelling =0 
replace dwelling=1 if  (t0320<4)
generate hiv = 0 
replace hiv=1 if (t0321<4) 
generate other1 = 0 
replace other1=1 if (t0322<4)
generate other2 = 0 
replace other2 =1 if (t0323<4) 
**classify shocks according to WB report 2008 (economic, random(?), health, violence). Classification of some shock types debatable.... **
generate economicshock=0
replace economicshock=1 if business==1 | unemployment==1 | endassistance==1 | foodprice==1 | inputprice==1 | dwelling==1 |  breakuphh==1
generate aggrshock=0
replace aggrshock=1 if drought==1 |  croppest==1 |  livestock==1 |  watershortage==1 
generate healthshock=0
replace healthshock=1 if illness==1 |  birth==1 |  deathhead==1 |  deathwork==1 |  deathother==1 |  hiv==1
gen crimeshock=0
replace crimeshock=1 if jail==1 |  assault==1

**create variable for value of losses of each of the 3 most severe shocks in past 5 years
generate lossdrought = t041
generate losscroppest = t042  
generate losslivestock = t043 
generate lossbusiness = t044 
generate lossunemployment = t045 
generate lossendassistance = t046 
generate losscropprice = t047 
generate lossfoodprice = t048 
generate lossinputprice = t049
generate losswatershortage = t0410 
generate lossillness = t0411 
/*
losses for the following shock categories were not recorded
generate lossbirth = t0412 
generate lossdeathhead = t0413
generate lossdeathwork = t0414 
generate lossdeathother = t0415
generate lossbreakuphh = t0416 
generate lossjail = t0417 
generate lossfire = t0418
generate lossassault = t0419  
*/
generate lossdwelling = t0420 
generate losshiv = t0421 
generate lossother1 = t0422 
generate lossother2 = t0423

**classify losses accorsing to shock categories (losses due to assaults and jail not covered)**
egen economicloss=rowtotal( lossbusiness lossunemployment lossendassistance lossfoodprice lossinputprice lossdwelling) 
egen aggrloss=rowtotal(lossdrought losscroppest losslivestock losswatershortage) 
egen healthloss=rowtotal(lossillness losshiv)
egen totalloss=rowtotal(economicloss aggrloss healthloss)


**did hh reduce income, assets, both, or nothing as consequence of shocks?
gen reduceincome =  0 
gen reduceassets =  0
gen reduceboth =  0
gen reduceneither =  0
foreach num of numlist 1/23{
replace reduceincome=1 if t05`num'==1
replace reduceassets=1 if t05`num'==2
replace reduceboth=1 if t05`num'==3
replace reduceneither=1 if t05`num'==4
}
**hh coping strategies (conditional on shock)**
global coping savings sentchildren sellassets sellfarmland rentfarmland sellanimals sellcrops workedmore  hhmemberswork  startbusiness childrenwork  migratework borrowedrelative borrowedmoneylender borrowedformal helpreligion helplocalngo helpinternationalngo helpgovernment helpfamily reducedfood consumedless reducednonfood  spiritual  othercoping 
foreach var of global coping {
gen `var'=0 if shock!=0
}
*up to 3 coping strategies reported for each of the 3 most severe shocks suffered in the last 5 years (23 shock and 25 coping categories)
*report 2008 focuses on the most important strategy only.
foreach round of numlist 1/3{
foreach num of numlist 1/23{
replace savings=1 if t08_`round'`num'==1
replace sentchildren=1 if t08_`round'`num'==2
replace sellassets=1 if t08_`round'`num'==3
replace sellfarmland=1 if t08_`round'`num'==4
replace rentfarmland=1 if t08_`round'`num'==5
replace sellanimals=1 if t08_`round'`num'==6
replace sellcrops=1 if t08_`round'`num'==7
replace workedmore=1 if t08_`round'`num'==8
replace hhmemberswork=1 if t08_`round'`num'==9
replace startbusiness=1 if t08_`round'`num'==10
replace childrenwork=1 if t08_`round'`num'==11
replace migratework=1 if t08_`round'`num'==12
replace borrowedrelative=1 if t08_`round'`num'==13
replace borrowedmoneylender=1 if t08_`round'`num'==14
replace borrowedformal=1 if t08_`round'`num'==15
replace helpreligion=1 if t08_`round'`num'==16
replace helplocalngo=1 if t08_`round'`num'==17
replace helpinternationalngo=1 if t08_`round'`num'==18
replace helpgovernment=1 if t08_`round'`num'==19
replace helpfamily=1 if t08_`round'`num'==20
replace reducedfood=1 if t08_`round'`num'==21
replace consumedless=1 if t08_`round'`num'==22
replace reducednonfood=1 if t08_`round'`num'==23
replace spiritual=1 if t08_`round'`num'==24
replace othercoping=1 if t08_`round'`num'==25
}
}
**how many households used multiple coping strategies after shocks? In total and for each shock separately*
foreach num of numlist 1/23{
egen multiple`num'=rownonmiss( t08_1`num'  t08_2`num'  t08_3`num')
replace multiple`num'=0 if multiple`num'==1
replace multiple`num'=1 if multiple`num'>1
}
egen manystrategies=rowtotal(multiple*) if shock>0
replace manystrategies=1 if manystrategies>0



***************************label and drop redundant varriables*******************
drop t01* t02* t03* t04* t05* t06* t07_1* t07_2* t08_1* t08_2* t08_3* id_clust* id_hh* weight* coping_code* multiple*

label var drought "HH suffered drought in past 5 years"
label var croppest "HH suffered crop pest in past 5 years"
label var livestock "HH suffered livestock loss in past 5 years"
label var business "HH suffered business losses in past 5 years"
label var unemployment "HH suffered unemployment in past 5 years"
label var endassistance "HH suffered from end of assistance in past 5 years"
label var cropprice "HH suffered from crop price increase in past 5 years"
label var foodprice "HH suffered from food price increase in past 5 years"
label var inputprice "HH suffered from input price increase in past 5 years"
label var watershortage "HH suffered water shortage in past 5 years"
label var illness "HH suffered illness in past 5 years"
label var birth "HH suffered loss due to new born in past 5 years"
label var deathhead "HH suffered death of hh head in past 5 years"
label var deathwork "HH suffered death of working hh member in past 5 years"
label var deathother "HH suffered death of other hh member in past 5 years"
label var breakuphh "HH suffered breakup of hh in past 5 years"
label var jail "HH suffered from jail in past 5 years"
label var fire "HH suffered from fire in past 5 years"
label var assault "HH suffered from assault in past 5 years"
label var dwelling "HH suffered from dwelling damage in past 5 years"
label var hiv "HH suffered from hiv in past 5 years"
label var other1 "HH suffered other 1 in past 5 years"
label var other2 "HH suffered other 2 in past 5 years"
label var lossdrought "losses due to drought in past 5 years"
label var losscroppest "losses due to crop pest in past 5 years"
label var losslivestock "losses due to livestock loss in past 5 years"
label var lossbusiness "losses due to business losses in past 5 years"
label var lossunemployment "losses due to unemployment in past 5 years"
label var lossendassistance "losses due to end of assistance in past 5 years"
label var losscropprice "losses due to crop price increase in past 5 years"
label var lossfoodprice"losses due to food price increase in past 5 years"
label var lossinputprice "losses due to input price increase in past 5 years"
label var losswatershortage "losses due to water shortage in past 5 years"
label var lossillness "losses due to illness in past 5 years"
label var lossdwelling "losses due to dwelling damage in past 5 years"
label var losshiv "losses due to hiv in past 5 years"
label var lossother1 "losses due to other 1 in past 5 years"
label var lossother2 "losses due to other 2 in past 5 years"
label var manystrategies "HH used multiple coping strategies per shock"
label var missingshocks " At least one shock response missing (out of 21)"
label var economicshock "HH suffered economic shock in past 5 years"
label var aggrshock "HH suffered weather shock in past 5 years"
label var healthshock "HH suffered health shock in past 5 years"
label var crimeshock "HH suffered from crime in past 5 years"
label var shock "HH suffered a shock in past 5 years"
label var savings "Savings to cope with shock"
label var sentchildren "sent children to relatives to cope with shock"
label var sellassets "sold assets to cope with shock"
label var sellfarmland "sold farmland to cope with shock"
label var rentfarmland "rented farmland to cope with shock"
label var sellanimals "sold animals to cope with shock"
label var sellcrops "sold more crops to cope with shock"
label var workedmore "worked more crops to cope with shock"
label var hhmemberswork "hh member started work to cope with shock"
label var startbusiness "started business to cope with shock"
label var childrenwork "children worked to cope with shock"
label var migratework "migrated to work to cope with shock"
label var borrowedrelative "borrowed from relative to cope with shock"
label var borrowedmoneylender "borrowed from moneylender to cope with shock"
label var borrowedformal "borrowed formal loan to cope with shock"
label var helpreligion "received help from church to cope with shock"
label var helplocalngo "received help local ngo to cope with shock"
label var helpinternationalngo "received help international ngo to cope with shock"
label var helpgovernment "received help government to cope with shock"
label var helpfamily "received help from family to cope with shock"
label var reducedfood "reduced food consumption to cope with shock"
label var consumedless "consumed less to cope with shock"
label var reducednonfood "reduced nonfood consumption to cope with shock"
label var spiritual "spiritual help to cope with shock"
label var othercoping "other strategy to cope with shock"
label var economicloss "Value economic shocks in past 5 years"
label var aggrloss "Value agricultural shocks in past 5 years"
label var healthloss "Value health shocks in past 5 years"
label var totalloss "Value all shocks in past 5 years"

sort uhhid              
save "$out\shocks", replace


********************************************************************************
*merge income data (Leonardo)
clear
use "$in\base_incomeagg0506_Leonardo.dta" , clear
destring hh, gen(id_hh)
destring cluster, gen(id_clust)
*household incomes*
/*
total income, and then what % comes from wage activities (perhaps broken into agr and non-agr), 
what percentage from agr self employment, etc… --> can't find the info in Leonardo's data. Go back to original data?
*/
gen wage_f = wages if activity == 1
gen wage_nf = wages if inlist(activity, 2, 3, 4, 5, 6, 7, 8, 9)
egen wage=rowtotal(wage_f wage_nf)

egen farminc = rowtotal(revagri wage_f)
egen nonfarminc = rowtotal(revenuenab wage_nf)

*hh level*
collapse (sum) farminc nonfarminc wage wage_f wage_nf, by(id_clust id_hh)
drop if (id_clust == . | id_hh == .)
egen uhhid=concat(id_clust id_hh)
*total income*
egen inc = rowtotal(farminc nonfarminc)
*share of wage income on total income
gen swage_f=wage_f/inc
gen swage_nf=wage_nf/inc
gen swage=wage/inc
*tag negative farm ncome (6%)
gen inc_fneg   = (farminc < 0)
replace farminc = 0 if farminc < 0

gen inc_fnone  = (farminc == 0)
gen nonffarm = nonfarminc/farminc
replace nonffarm = 0 if nonffarm == .

lab var wage "household wage income"
lab var swage "share of wages on total income"
lab var swage_f "share farm wage income"
lab var swage_nf "share non-farm wage income"
lab var inc "household income"
lab var farminc "household farm income"
lab var nonfarminc "household non-farm income"
lab var inc_fneg "controls for negative farm income"
lab var inc_fnone "controls for no farm income"
lab var nonffarm "share of non-farm to farm income"
lab var nonffarm "ratio farm non-farm income"
sort uhhid              
save "$out\income", replace

********************************************************************************
**merge with main data section*
use "$out\kibhs05_06.dta", clear

*create unique hh identifier*
sort uhhid
cd "$out"               
merge uhhid using shocks
tab _merge
*1,724 obs=1; 1 obs =2; 11,488 obs=3
drop _merge
sort uhhid
merge uhhid using income
tab _merge
*1  obs=1; 5 obs =2; 13,212 obs=3
drop _merge

/*
Stephan Dietrich 15.1.2017
Create Variables for Analysis
hh consumption: y2_i  
*/

*create consumption quintiles (correct weights?)
xtile hcquintile=hhtexpdr [aw=wta_hh], nq(5) 
**loss severity all shocks and per shock category (loss as share of hh consumption)**
gen lseverity=totalloss/y2_i 
gen leseverity=economicloss/y2_i 
gen laseverity=aggrloss/y2_i 
gen lhseverity=healthloss/y2_i 


*****************labels*************
*label var cquintile "Individual consumption Quintile"
label var hcquintile "Housheold consumption Quintile"
label var lseverity "Total losses (5 years) as share of hh consumption"
label var leseverity "Business losses (5 years) as share of hh consumption"
label var laseverity "Agricultural losses (5 years) as share of hh consumption"
label var lhseverity "Health losses (5 years) as share of hh consumption"


********************************************************************************
save "$out\kibhs05_06.dta", replace





