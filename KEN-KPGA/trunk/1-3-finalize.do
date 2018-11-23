 
***********************************************************
*Merging all databases and appending the two years of data
*Generating PPP (2011 $1.20,$1.90, $3.20) poverty lines
*Generating poor dummies
***********************************************************

use "${gsdDataRaw}/KIHBS05/Section A Identification.dta", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid 
drop a11 a13
sort uhhid 

*Keep only those observations with household information
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hheadcomposition05.dta", assert(match) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/poverty05.dta", keep(match master) nogen
*replacing cmissing county and peri-urban dummy for households not used in poverty estimation with values within cluster.
bys id_clust: egen a01 = min(county)
replace county = a01 if mi(county)
assert !mi(county)
drop a01
bys id_clust: egen purban = min(eatype)
replace eatype = purban if mi(eatype)
assert !mi(eatype)
drop purban
bys id_clust: egen zy = min(resid)
replace resid = zy if mi(resid)
assert !mi(resid)
drop zy

merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hheadchars05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhedu05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhedhead05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhlab05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hheadlabor05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/housing05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/housing2_05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/land05.dta" ,keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/transfers05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/assets05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/shocks05.dta", keep(match master) nogen

*Generating survey dummy
gen kihbs = 2005
label var kihbs "Survey year"
ren (id_clust id_hh ) (clid hhid )
egen strata = group(county urban)

save "${gsdData}/1-CleanOutput/kihbs05_06.dta", replace


*Keep only those observations with household information
use "${gsdData}/1-CleanTemp/hhpoverty" , clear
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhcomposition15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hheadchars15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhedu15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhedhead15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhlab15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hheadlabor15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/housing15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/housing2_15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/land15.dta" ,keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/transfers15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/assets15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/shocks15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdDataRaw}/KIHBS15\nfexpcat.dta" , keepusing(nfdrent) assert(match) nogen

*Generating survey dummy
gen kihbs = 2015
label var kihbs "Survey year"
egen strata = group(county urban)

save "${gsdData}/1-CleanOutput/kihbs15_16.dta", replace

**********************************
*appending 2 datasets
use "${gsdData}/1-CleanOutput/kihbs15_16.dta" , clear
append using   "${gsdData}/1-CleanOutput/kihbs05_06.dta"
*dropping households not used in 05 pov. estimation from 05 sample.
keep if filter == 1 | kihbs==2015

*Create dummies for poverty using international poverty line
*generate per capita aggregate (excluding rent) and divide by 2011 private consumption PPP conversion factor
gen cons_pp_agg = y2_i
replace cons_pp_agg = y2_i - nfdrent if urban==1 & kihbs==2015
replace cons_pp_agg =  y2_i - rent if urban==1 & kihbs==2005

gen cons_pp =  (cons_pp_agg*ctry_adq)/hhsize
replace cons_pp = cons_pp / 35.4296

*Generate per capita aggregate without spatial deflation (PovcalNet compatible)
gen double cons_pp_nsd = ((cons_pp_agg*fpindex*ctry_adq)/hhsize)
replace cons_pp_nsd = cons_pp_nsd / 35.4296

drop cons_pp_agg

assert !mi(cons_pp)
assert !mi(cons_pp_nsd)

gen cpi2011 =.
*2005/06 - CPI Deflator
local cpi2005_cpi = 8/13*(72.5720268908468/121.165396064531)
local cpi2006_cpi=5/13*(76.949915626827/121.165396064531)
replace cpi2011= 1/(`cpi2005_cpi'+`cpi2006_cpi') if kihbs==2005
*2015/16 - CPI Deflator
local cpi2015_cpi = 4/12*(159.598887706963/121.165396064531)
local cpi2016_cpi=8/12*(169.64908107332/121.165396064531)
replace cpi2011 = 1/(`cpi2015_cpi'+`cpi2016_cpi') if kihbs==2015

gen pline120 = (1.20*(365/12))/cpi2011
gen poor120 = (cons_pp_nsd < pline120)
gen pline190 = (1.90*(365/12))/cpi2011
gen poor190 = (cons_pp_nsd < pline190)
gen pline320 = (3.20*(365/12))/cpi2011
gen poor320 = (cons_pp_nsd < pline320)

label var cons_pp "Per capita aggregate (2011 US$)"
label var cons_pp_nsd "Per capita aggregate (2011 US$) - No spatial deflation"

label var cpi2011 "CPI deflator"
label var pline120 "$1.20 2011 poverty line deflated to 2005/06 & inflated to 2015/16 - Official"
label var poor120 "Poor under $1.20 poverty line (2011 US$) - aggregate not spatially deflated"
label var pline190 "$1.90 2011 poverty line deflated to 2005/06 & inflated to 2015/16 - Official"
label var poor190 "Poor under $1.90 poverty line (2011 US$) - aggregate not spatially deflated"
label var pline320 "$3.20 2011 poverty line deflated to 2005/06 & inflated to 2015/16 - Official"
label var poor320 "Poor under $3.20 poverty line (2011 US$)  - aggregate not spatially deflated"

order kihbs resid urban eatype county cycle
order hhsizec ctry_adq, after(hhsize) 
label var province "Province"
label var hhsizec "hhsize (ind. missing age not counted) - only 2005"
label var rent "Rent (imputed and actual - for urban hh only)"
replace urban = (resid - 1) if mi(urban)
drop rururb
sort kihbs county resid clid hhid
*dropping vars that aren't in the 2015 dataset
drop prov district doi weight_hh weight_pop uhhid fao_adq fpl absl hcl filter
label var province "Province"

tabstat poor [aw=wta_pop], by(kihbs)

*generating a real consumption aggregate in 2015/16 prices. 
*The poverty lines used for generate a comparable aggregate are those created using the 2015/16 basket of goods and their 2005/06 prices.

gen z1 = 1584 if urban==0 & kihbs==2005
gen z2 = 2779  if urban==1 & kihbs==2005
gen z3 = z2_i if urban==0 & kihbs==2015
gen z4 = z2_i if urban==1 & kihbs==2015

egen rural_05pline = max(z1)
egen urban_05pline = max(z2)
egen rural_15pline = max(z3)
egen urban_15pline = max(z4)

drop z1 z2 z3 z4

*generating factor to "inflate" the 2005 aggregate, to allow real comparison
*Rural Factor = 2.053 implying 105% increase.
*Urban Factor = 2.157 implying 115% increase.
gen double pfactor =.
replace pfactor =  rural_15pline / rural_05pline if urban == 0
replace pfactor =  urban_15pline / urban_05pline if urban == 1
replace pfactor = 1 if kihbs==2015
gen rcons = .
replace rcons = y2_i if kihbs==2015
replace rcons = y2_i * pfactor if (kihbs==2005)

label var rcons "Real consumption aggregate (2015 prices)"
label var pfactor "Factor used to inflate 2005/06 prices to 2015/16"
drop rural_15pline rural_05pline urban_15pline urban_05pline

*replacing 2005 absolute and food poverty lines with comparable versions
gen z2_i_old = z2_i if kihbs==2005 
*Old rural absolute line = 1474
replace z2_i = 1584 if urban == 0 & kihbs==2005
*Old urban absolute line = 2913
replace z2_i = 2779 if urban == 1 & kihbs==2005

*keep old food poverty line to replicate 2005 hardcore poverty
gen z_i_old = z_i if kihbs==2005
*Old rural food line = 988
replace z_i = 1002 if urban == 0 & kihbs==2005
*Old urban food line = 1562
replace z_i = 1237 if urban == 1 & kihbs==2005
*recalculate the poverty dummy as the line for 2005 has changed
replace poor = (y2_i<z2_i) if kihbs==2005
*recalculate the poverty dummy as the line for 2005 has changed
gen poor_old = poor
replace poor_old = (y2_i<z2_i_old) if kihbs==2005

label var z_i "Food poverty line used for comparable 2005/06 estimates"
label var z_i_old "Food poverty line used to replicate 2005/06 estimates"
label var z2_i "Absolute poverty line used for comparable 2005/06 estimates"
label var z2_i_old "Absolute poverty line used to replicate 2005/06 estimates"
label var poor_old "Dummy used to replicate 2005/06 noncomparable poverty estimates"
*Generate NEDI dummy for 10 counties included in North-Eastern Development initiative
*10 NEDI counties are: Garissa, Isiolo, Lamu, Mandera, Marsabit, Samburu, Tana River, Turkana, Wajir and West Pokot. 
gen nedi = inlist(county,5,7,9,10,25,4,23,8,24,11)
label define lnedi 0"Non-NEDI County" 1"NEDI County" , replace
label values nedi lnedi
label var nedi "Dummy for NEDI Counties"

order strata , after(county)
order fdtexp fdtexpdr nfdtexp nfdtexpdr hhtexp hhtexpdr adqexp adqexpdr rcons , after(wta_adq)
compress
save "${gsdData}/1-CleanOutput/hh.dta" , replace

use "${gsdDataRaw}/KIHBS05/Expenditure05.dta" , clear
save "${gsdData}/1-CleanTemp/Expenditure05.dta" , replace

use "${gsdDataRaw}/KIHBS15/Expenditure15.dta" , clear
save "${gsdData}/1-CleanTemp/Expenditure15.dta" , replace

use "${gsdDataRaw}/KIHBS05/c_Agriculture_Output05.dta" , clear
save "${gsdData}/1-CleanTemp/c_Agriculture_Output05.dta" , replace

use "${gsdDataRaw}/KIHBS15/c_Agriculture_Output15.dta" , clear
save "${gsdData}/1-CleanTemp/c_Agriculture_Output15.dta" , replace

use "${gsdDataRaw}/kihbs15/nfexpcat.dta" ,clear
save "${gsdData}/1-CleanOutput/nfexpcat15.dta" ,replace

use "${gsdDataRaw}/KIHBS05/consumption aggregated data.dta", clear
keep id_clust id_hh nfdfoth nfdrnthh nfdtrans nfdcloth nfdutil nfdfuel nfdwater y_i y2_i edtexp fpindex
save "${gsdData}/1-CleanOutput/nfexpcat05.dta" ,replace

use "${gsdDataRaw}/SHP/County Polys.dta", clear
save "${gsdData}/1-CleanOutput/County Polys.dta", replace

use "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta", clear
save "${gsdData}/1-CleanOutput/KenyaCountyPolys_coord.dta", replace

use "${gsdDataRaw}/SHP/centroids.dta", clear
save "${gsdData}/1-CleanOutput/centroids.dta", replace
