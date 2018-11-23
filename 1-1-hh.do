*Run 00-init.do before running this do-file
clear all
set more off

**********************************
*2005 household identification
**********************************
use "${gsdDataRaw}/KIHBS05/consumption aggregated data.dta", clear
order nfdrnthh , before(fpindex)
*rent aggregate in data is nominal, household-level and annualised
gen rent = nfdrnthh / fpindex / ctry_adq / 12

drop fdbrdby-nfditexp
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
label var id_clust "Cluster number"
isid uhhid

*generate urban dummy and label rurural / urban classification
gen urban= rururb - 1
label var urban "Urban"
ren (rururb) (resid)
label define lresid 1 "Rural" 2 "Urban" , modify
label values resid lresid

ren nfdtepdr nfdtexpdr

*Poverty 
gen poor_food=(y_i<z_i)
label var poor "Poor under food pl"
gen poor=(y2_i<z2_i) 
label var poor "Poor under pl"
tabstat poor* [aw=wta_pop]
tabstat poor [aw=wta_pop], by(resid)

*Create additional pov / expenditure measures
*Measure of 2x poverty line.
gen twx_poor = (y2_i<(z2_i*2)) 
label var twx_poor "poor under 2x pl"
order twx_poor, after (poor)
*Merge in mapping of 2015 counties / peri-urban to 2005 data (list provided by KNBS)
merge 1:1 id_clust id_hh  using "${gsdDataRaw}/KIHBS05/county.dta"  , assert(match) keepusing(county eatype) nogen 
distinct county
assert `r(ndistinct)' == 47
distinct eatype
assert  `r(ndistinct)' == 3

gen province = . 
replace province = 1 if inrange(county,1,6)
replace province = 2 if inrange(county,7,9)
replace province = 3 if inrange(county,10,17)
replace province = 4 if inrange(county,18,22)
replace province = 5 if inrange(county,23,36)
replace province = 6 if inrange(county,37,40)
replace province = 7 if inrange(county,41,46)
replace province = 8 if county == 47
assert !mi(county)

label define lprovince 1"Coast" 2"North Eastern"  3"Eastern"  4"Central" 5"Rift Valley" 6"Western" 7"Nyanza" 8"Nairobi" ,  replace
label values province lprovince 


foreach var of varlist _all {
	assert !mi(`var')
}
order resid county eatype id_clust id_hh hhsize
save "${gsdData}/1-CleanTemp/poverty05.dta", replace

**********************************
*2015 household identification
**********************************
use "${gsdDataRaw}/KIHBS15/hh.dta", clear

keep clid hhid county resid eatype hhsize cycle ctry_adq iday
label var cycle "2-week data collection period"

*interview day to interview month in cmc (as in 2005)
gen year=year(iday)
gen month= month(iday)
gen doi = (year - 1900)*12 + month
label var doi "Date of interview (CMC)"
drop year month iday

*generate urban dummy and label rurural / urban classification
gen urban= (eatype ==2)
label var urban "Urban"

gen province = . 
replace province = 1 if inrange(county,1,6)
replace province = 2 if inrange(county,7,9)
replace province = 3 if inrange(county,10,17)
replace province = 4 if inrange(county,18,22)
replace province = 5 if inrange(county,23,36)
replace province = 6 if inrange(county,37,40)
replace province = 7 if inrange(county,41,46)
replace province = 8 if county == 47
assert !mi(county)

label define lprovince 1"Coast" 2"North Eastern"  3"Eastern"  4"Central" 5"Rift Valley" 6"Western" 7"Nyanza" 8"Nairobi" ,  replace
label values province lprovince 


foreach var of varlist _all {
	assert !mi(`var')
}	
save "${gsdData}/1-CleanTemp/section_a.dta", replace
****************************************
*Merge in consumption data and weights
****************************************
use "${gsdData}/1-CleanTemp/section_a.dta" , clear
merge 1:1 clid hhid using  "${gsdDataRaw}/KIHBS15/poverty.dta" , assert(match) keepusing(wta_hh wta_pop wta_adq ctry_adq clid hhid fdtexp nfdtexp hhtexp fpindex y2_i y_i z2_i z_i urban fdtexpdr nfdtexpdr hhtexpdr adqexp adqexpdr poor_food poor twx_poor) nogen
save "${gsdData}/1-CleanTemp/hhpoverty.dta" , replace


**********************************
*2005 Housing Characteristics
**********************************
*Owns house
use id_clust id_hh g01 g09* using "${gsdDataRaw}/KIHBS05/Section G Housing", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid 

*set max number of rooms in dwelling to 20 (9 obvs >20)
egen rooms = rsum(g09a g09b)
replace rooms = 20 if rooms>20 & !mi(rooms)
label var rooms "number of rooms in household"
*household ownership dummy
gen ownhouse= (g01==1 | g01==2)
lab var ownhouse "Owns house" 

keep uhhid ownhouse rooms
sort uhhid 
save "${gsdData}/1-CleanTemp/housing05.dta", replace

**********************************
*2015 Housing Characteristics
**********************************
use "${gsdDataRaw}/KIHBS15/hh.dta", clear

*set max number of rooms in dwelling to 20
egen rooms = rsum(i12_1 i12_2)
replace rooms = 20 if rooms>20 & !mi(rooms)
label var rooms "number of rooms in household"
*household ownership dummy
gen ownhouse = (i02==1)
lab var ownhouse "Owns house" 
keep clid hhid ownhouse rooms
save "${gsdData}/1-CleanTemp/housing15.dta", replace

**********************************
*2005 Water and Sanitation 
**********************************
use "${gsdDataRaw}/KIHBS05/Section H1 Water Sanitation", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid 

* assume that the category other is typically not improved
*Improved:
*piped (1,2)
*public tab (3)
*tubewell/borehole with pump (4)
*protected well / spring (5, 6)
*rain water collection (7)
gen impwater = (inlist(h01a, 1, 2, 3, 4, 5, 6, 7,10,11))
lab var impwater "Improved drinking water source"
gen impsan = (inlist(h13, 1, 2, 4))
lab var impsan "Improved sanitation facility"

*Electricity
gen elec_light=(h18a_1==5)
replace elec_light=. if h18a_1==.
lab var elec_light "Main source light is electricity"
gen elec_acc=(h24!=.)
tab elec_acc
lab var elec_acc "HH has access to electricity"

*Garbage collection 
*collected by local authority / collected by private firm
gen garcoll= (h17==1 | h17==2)
replace garcoll=. if h17==. 
lab var garcoll "HH with garbage collection"

keep uhhid impwater impsan elec_light elec_acc garcoll
sort uhhid  
save "${gsdData}/1-CleanTemp/housing2_05.dta", replace 

**********************************
*2015 Water and Sanitation 
**********************************
use "${gsdDataRaw}/KIHBS15/hh.dta", clear
*Improved water sources are as follows:
	*Any water piped into hh (1,2,3,4)
	*Protected well (5)
	*protected spring (7)
	*Collected rain water(9)
	*Any Water delivered by a vendor (10,11,12)
	*bottled water (14)
gen impwater = inlist(j01_dr,1,2,3,4,5,7,9,10,11,12,14)
lab var impwater "Improved drinking water source"
assert !mi(impwater)

*Improved sanitation facility defined as follows:
	*Any flushed system (11,12,13,14,15)
	*Ventilated improved pit latrine (21)
	*pit latrine with slab (22)
gen impsan = (inlist(j10,11,12,13,14,15,21,22))
lab var impsan "Improved sanitation facility"
assert !mi(impsan)

*Electricity
*main source of lighting is electricity
gen elec_light = inlist(j17,1)
assert !mi(elec_light)
lab var elec_light "Main source light is electricity"
*household skips access to electricty questions if source of energy for lighting / cooking is electricity (j17==1 | j18==2)
gen elec_acc=(j17==1 | j18==2 | j20 == 1)
tab elec_acc
lab var elec_acc "HH has access to electricity"
*Garbage collection 
*collected by local authority / collected by private firm / community association
gen garcoll= inlist(j14,1,2,3)
replace garcoll=. if j14==. 
lab var garcoll "HH with garbage collection"

keep clid hhid impwater impsan elec_light elec_acc garcoll
sort clid hhid  
save "${gsdData}/1-CleanTemp/housing2_15.dta", replace 

**********************************
*2005 Land ownership  
**********************************
use "${gsdDataRaw}/KIHBS05/Section N Agriculture Holding.dta", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

recode n_id .=0

duplicates tag id_clust id_hh n_id, gen(tag)
*keep 1 for land ownership purposes
bysort id_clust id_hh n_id: keep if _n==1 

assert n05==. if n01==2
count if n05!=.	& n01==1

* these variables refers to all parcels combined
gen ownsland = (n05>0 & n09==1)
gen area_own=n05 if n09==1 
gen title = (n05>0 & n10==1)

collapse (sum) area_own (max) ownsland title, by(uhhid)

lab var area_own "Area of land owned"
lab var ownsland "HH owns land"
lab var title "household has landtitle"

sort uhhid

save "${gsdData}/1-CleanTemp/land05.dta", replace
 
**********************************
*2015 Land ownership  
**********************************
use  "${gsdDataRaw}/KIHBS15/k1.dta", clear
*merge full set of households and module filter(k01)
merge m:1 clid hhid using "${gsdDataRaw}/KIHBS15/hh.dta" , keepusing(clid hhid k01) keep(using match)

recode k02 .=0
duplicates tag clid hhid k02, gen(tag)
*dropping 6 observations with duplicae parcel id
bysort clid hhid k02: keep if _n==1 


*these variables refers to all parcels combined
gen ownsland = (k06>0 & k07==1 & k06!=.)
gen area_own = k06 if k07==1 
gen title = (k06>0 & k08==1)

collapse (sum) area_own (max) ownsland title, by(clid hhid)

lab var area_own "Area of land owned (acres)"
lab var ownsland "HH owns land"
lab var title "household has land title"

sort clid hhid

save "${gsdData}/1-CleanTemp/land15.dta", replace
 
**********************************
*2005 Transfers
**********************************
use "${gsdDataRaw}/KIHBS05/Section R Transfers", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

*drop duplicates
duplicates tag uhhid, gen(tag)
drop if tag>0

forvalues x = 1/5 {
	egen traa_`x' = rsum(r03_`x' r04_`x' r05_`x')
	replace traa_`x'=. if traa_`x'==0 
	gen tra_`x' = (traa_`x'>0 & traa_`x'!=.)
	tab traa_`x' tra_`x'
}
rename traa_1 traa_ind 
lab var traa_ind "Transfers (amount) by individuals"
rename tra_1 tra_ind 
lab var tra_ind "Transfers individuals"

rename traa_2 traa_ngo 
lab var traa_ngo "Transfers (amount) by NGOs"
rename tra_2 tra_ngo 
lab var tra_ngo "Transfers NGOs"

rename traa_3 traa_gvmt 
lab var traa_gvmt "Transfers (amount) by government"
rename tra_3 tra_gvmt 
lab var tra_gvmt "Transfers government"

rename traa_4 traa_cor 
lab var traa_cor "Transfers (amount) by corporate sector"
rename tra_4 tra_cor 
lab var tra_cor "Transfers corporate sector"

rename traa_5 traa_int 
lab var traa_int "Transfers (amount) outside Kenya"
rename tra_5 tra_int
lab var tra_int "Transfers outside Kenya"

egen traa_all=rsum(traa*)
replace traa_all=. if traa_all==0 
*received transfers from outside HH
gen tra_all=(traa_all>0 & !mi(traa_all)) 
lab var tra_all "HH received transfers last year" 

lab var traa_all "Transfers all (amount)"

keep uhhid tra* traa*
sort uhhid 
save "${gsdData}/1-CleanTemp/transfers05.dta", replace

 **********************************
*2015 Transfers
**********************************
 use "${gsdDataRaw}/KIHBS15/hh.dta", clear
*keep only households that received transfers
egen osum = rsum(o02_a o02_b o02_c o02_d o02_e o02_f o02_g o02_h o11_a o11_b o11_c o11_d o11_e o12_a o12_b o12_c o12_d o12_e o10_a o10_b o10_c o10_d o10_e)
assert osum==0 if o01==2

*5 vars for sources of transfer are not structured identically so no loop can be used
egen traa_1 = rsum(o02_a o10_a o11_a o12_a o13_a)
egen traa_2 = rsum(o02_b o10_b o11_b o12_b o13_b)
egen traa_3 = rsum(o02_c o02_d o10_c o11_c o12_c o13_c)
egen traa_4 = rsum(o02_e o10_d o11_d o12_d o13_d)
egen traa_5 = rsum(o02_g o10_e o11_e o12_e o13_e)

forvalues x = 1/5 {
	replace traa_`x'=. if traa_`x'==0 
	gen tra_`x' = (traa_`x'>0 & traa_`x'!=.)
	tab traa_`x' tra_`x'
}
rename traa_1 traa_ind 
lab var traa_ind "Transfers (amount) by individuals"
rename tra_1 tra_ind 
lab var tra_ind "Transfers individuals"

rename traa_2 traa_ngo 
lab var traa_ngo "Transfers (amount) by NGOs"
rename tra_2 tra_ngo 
lab var tra_ngo "Transfers NGOs"

rename traa_3 traa_gvmt 
lab var traa_gvmt "Transfers (amount) by government"
rename tra_3 tra_gvmt 
lab var tra_gvmt "Transfers government"

rename traa_4 traa_cor 
lab var traa_cor "Transfers (amount) by corporate sector"
rename tra_4 tra_cor 
lab var tra_cor "Transfers corporate sector"

rename traa_5 traa_int 
lab var traa_int "Transfers (amount) outside Kenya"
rename tra_5 tra_int
lab var tra_int "Transfers outside Kenya"

egen traa_all=rsum(traa*)
replace traa_all=. if traa_all==0 
*received transfers from outside HH
gen tra_all=(traa_all>0 & !mi(traa_all)) 
lab var tra_all "HH received transfers last year" 

lab var traa_all "Transfers all (amount)"

keep clid hhid tra* traa*
sort clid hhid 
save "${gsdData}/1-CleanTemp/transfers15.dta", replace
 
*********************************
*Asset ownership
use "${gsdDataRaw}/KIHBS05/Section M Durables.dta" , clear
egen uhhid=concat(id_clust id_hh)
gen car = (m04==1 & m02==5215)
gen motorcycle = (m04==1 & m02==5217)
gen radio = (m04==1 & m02==5224)
gen tv = (m04==1 & m02==5225)
gen kero_stove = (m04==1 & m02==4907)
gen char_jiko = (m04==1 & m02==4905)
gen mnet = (m04==1 & m02==5112)
gen bicycle = (m04==1 & m02==5218)
gen fan = (m04==1 & m02==4910)
gen cell_phone = (m04==1 & m02==5213)
gen sofa = (m04==1 & m02==4701)
*fridge is grouped with freezer in the 2015 survey so the same is done here
gen fridge = (m04==1 & (m02==4901 | m02==4902))
gen wash_machine = (m04==1 & m02==4903)
gen microwave = (m04==1 & m02==4906)
gen kettle = (m04==1 & m02==4917)
gen computer = (m04==1 & m02==5222)

collapse (max) car motorcycle radio tv kero_stove char_jiko mnet bicycle fan cell_phone sofa fridge wash_machine microwave kettle computer, by(uhhid)
foreach var of varlist car motorcycle radio tv kero_stove char_jiko mnet bicycle fan cell_phone sofa fridge wash_machine microwave kettle computer {
	label var `var' "HH owns a `var' "
}
label var mnet "HH owns a mosquito net"
label var kero_stove "HH owns a kerosene stove"
label var char_jiko "HH owns a charcoal jiko"
label var wash_machine "HH owns a washing machine"

save "${gsdData}/1-CleanTemp/assets05.dta", replace

use  "${gsdDataRaw}/KIHBS15/assets.dta",clear
*creating one single variable "computer" to combine "Laptop" , "Tablet" & "Desktop"
gen computer = (inlist(1,laptop,tablet,desktop))
label var computer "HH owns a computer"
drop laptop desktop tablet
save "${gsdData}/1-CleanTemp/assets15.dta" , replace

*********************************
*Household Shocks 
*********************************
use "${gsdDataRaw}/KIHBS05/Section T Recent Shocks.dta" , clear
egen uhhid=concat(id_clust id_hh)

gen shock_drought = 	(t02==1 & t01==101)
gen shock_crop = 		(t02==1 & t01==102)
gen shock_lstockdeath = 		(t02==1 & t01==103)
gen shock_famdeath = 	(t02==1 & t01==115)
gen shock_prise = 		(t02==1 & t01==108)
collapse (max) shock_drought shock_prise shock_lstockdeath shock_crop shock_famdeath , by(uhhid)
label var shock_drought "HH shock -  Drought or floods"
label var shock_prise "HH shock -  Large rise in food prices"
label var shock_lstockdeath "HH shock -   Livestock died"
label var shock_crop "HH shock -  Crop disease / pests"
label var shock_famdeath "HH shock -   Death of other fam. member"
save "${gsdData}/1-CleanTemp/shocks05.dta" , replace


*2015 - Section Q
use "${gsdDataRaw}/KIHBS15/hhshocks.dta" , clear
gen shock_drought = 	(q03==1 & q01==101)
gen shock_prise = 		(q03==1 & q01==109)
gen shock_lstockdeath = 		(q03==1 & q01==103)
gen shock_crop = 		(q03==1 & q01==102)
gen shock_famdeath = 	(q03==1 & q01==115)

*the timespan of relevant shocks is set to five years
replace q08_ye = 5 if q08_ye>5 & !mi(q08_ye)
replace q08_mo = 12 if q08_mo>5 & !mi(q08_mo)
replace q08_mo = 0 if q08_ye==5

collapse (max) shock_drought shock_prise shock_lstockdeath shock_crop shock_famdeath , by(clid hhid)
label var shock_drought "HH shock -  Drought or floods"
label var shock_prise "HH shock -  Large rise in food prices"
label var shock_lstockdeath "HH shock -   Livestock died"
label var shock_crop "HH shock -  Crop disease / pests"
label var shock_famdeath "HH shock -   Death of other fam. member"
save "${gsdData}/1-CleanTemp/shocks15.dta" , replace

