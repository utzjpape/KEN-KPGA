******************************************************
***   FY17-18 Kenya Poverty and Gender Assessment  ***
***   Urbanization Chapter                         ***
***   By Shohei Nakamura                           ***
******************************************************
/*
clear all
global path "C:/Users/WB377460/Documents/KPGA/"
global data "${path}data/"
global graph "${gsdOutput}/C5-Urban/"
global output "${path}output/"
global GIS "${path}GIS/"
cd "${path}" 
*/
//////////////////////////////
//     Check poverty        //
//////////////////////////////

//* check poverty
use "${gsdData}/2-AnalysisOutput/KIHBS_master_2015", clear

apoverty y2_i [aw=wta_pop], varpl(z2_i)
mean poor [aw=wta_pop]
tab poor [fw=round(wta_pop)]
tab poor urban [fw=round(wta_pop)], col
apoverty y2_i [aw=wta_pop] if urban==1, varpl(z2_i)
mean poor [aw=wta_pop] if urban==1


//* check poverty changes
use "${gsdData}/2-AnalysisOutput/KIHBS_master_2015", clear
append using "${gsdData}/2-AnalysisOutput/KIHBS_master_2005", force
svyset, clear
svyset clid [pw=wta_pop]
svy: mean poor if urban==1, over(year)
lincom [poor]2015 - [poor]2005 

* without Nairobi
svy: mean poor if urban==1 & province!=8, over(year)
lincom [poor]2015 - [poor]2005

* urban without Nairobi vs rural
svy: mean poor if province!=8 & year==2015, over(urban)
lincom [poor]1 - [poor]0



///////////////////////////////
//   County-level analysis   //
///////////////////////////////

use	"${gsdData}/2-AnalysisOutput/KIHBS_master_2005", clear
append using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"

gen pop = 1

collapse (sum) pop poor [fw=round(wta_pop)], by(year county COUNTY3_ID urban)

reshape wide pop poor, i(year county COUNTY3_ID) j(urban)

rename pop0 pop_r
rename poor0 poor_r
rename pop1 pop_u
rename poor1 poor_u

gen fgt1_u = (poor_u / pop_u) * 100
gen fgt1_r = (poor_r / pop_r) * 100

egen totpop = rowtotal(pop_u pop_r)
replace pop_r = 0 if pop_r==.
replace poor_r = 0 if poor_r==.
replace pop_u = 0 if pop_u==.
replace poor_u = 0 if poor_u==.

gen urban = pop_u / totpop * 100

order year COUNTY3_ID county totpop urban pop_u pop_r fgt1_u fgt1_r poor_u poor_r

reshape wide totpop - poor_r, i(county COUNTY3_ID) j(year)

gen fgt1_rc = (fgt1_r2005 / fgt1_r2015)-1
gen fgt1_uc = (fgt1_u2005 / fgt1_u2015)-1
gen urban_c = (urban2005 / urban2015)-1

export excel using "${gsdOutput}/C5-Urban/kenya_county_GIS.xls", ///
	first(var) replace
	
drop COUNTY3_ID
	
export excel using "${gsdOutput}/C5-Urban/kenya_county.xlsx", ///
	sheet("county") sheetreplace first(var)

gen log_pop_u2015 = log(pop_u2015)	
replace fgt1_r2015 = 0 if county==1|county==47
gen fgt1_2015 = (poor_u2015 + poor_r2015)/totpop2015*100

tw(scatter fgt1_u2015 log_pop_u2015, mlabel(county))
tw(scatter fgt1_u2015 log_pop_u2015 if urban2015>10, mlabel(county))
tw(scatter fgt1_u2015 urban2015, mlabel(county))
tw(scatter fgt1_u2015 urban2015 if urban2015>10, mlabel(county))
	

tw(scatter fgt1_r2015 fgt1_u2015, mlab(county)) ///
	(scatter fgt1_r2015 fgt1_u2015 ///
	if county==47|county==34|county==22|county==16|county==21, ///
	mc(orange) m(triangle) mlab(county))	
	
tw(scatter fgt1_r2015 fgt1_u2015) ///
	(scatter fgt1_r2015 fgt1_u2015 ///
	if county==47|county==34|county==22|county==16|county==21, ///
	mc(orange) m(triangle)), ///
	title("(A) Urban and rural poverty rates", size(medium)) ///
	xtitle("Urban poverty rate (%)") ///
	ytitle("Rural poverty rate (%)") ///
	legend(order(2 "Nairobi metro" 1 "Other counties")) ///
	name(a1, replace) nodraw
	
tw(scatter fgt1_2015 urban2015) ///
	(scatter fgt1_2015 urban2015 ///
	if county==47|county==34|county==22|county==16|county==21, ///
	mc(orange) m(triangle)), ///
	title("(B) Urbanization rate and national poverty rate", size(medium)) ///
	xtitle("Urbanization rate (%)") ///
	ytitle("Poverty rate (%)") ///
	legend(order(2 "Nairobi metro" 1 "Other counties")) ///
	name(a2, replace) nodraw	
	
tw(scatter fgt1_u2015 log_pop_u2015) ///
	(scatter fgt1_u2015 log_pop_u2015 ///
	if county==47|county==34|county==22|county==16|county==21, ///
	mc(orange) m(triangle)), ///
	title("(C) Urban population size and urban poverty rate", size(medium)) ///
	xtitle("Log of urban population") ///
	ytitle("Urban poverty rate (%)") ///
	legend(order(2 "Nairobi metro" 1 "Other counties")) ///
	name(a3, replace) nodraw	

graph combine a1 a2 a3, iscale(0.6)	
	
tw(scatter fgt1_r2015 fgt1_u2015) ///
	(qfit fgt1_r2015 fgt1_u2015), ///
	title("(a1) Urban and rural poverty rates", size(medium)) ///
	xtitle("Urban poverty rate (%)") ///
	ytitle("Rural poverty rate (%)") ///
	legend(off) ///
	name(a1, replace) nodraw
	
tw(scatter fgt1_u2015 urban2015)(qfit fgt1_u2015 urban2015), ///
	title("(b1) Urbanization rate and uban poverty rate", size(medium)) ///
	xtitle("Urbanization rate (%)") ///
	ytitle("Urban poverty rate (%)") ///
	legend(off) ///
	name(a2, replace) nodraw	
	
tw(scatter fgt1_u2015 log_pop_u2015)(qfit fgt1_u2015 log_pop_u2015), ///
	title("(c1) Urban population size and urban poverty rate", size(medium)) ///
	xtitle("Log of urban population") ///
	ytitle("Urban poverty rate (%)") ///
	legend(off) ///
	name(a3, replace) nodraw		

preserve
	* Drop counties in Nairobi/Mombasa metro areas
	drop if county==47|county==34|county==22|county==16|county==21| ///
		county==1|county==3|county==2
		
	tw(scatter fgt1_r2015 fgt1_u2015) ///
	(qfit fgt1_r2015 fgt1_u2015), ///
	title("(a2) Urban and rural poverty rates", size(medium)) ///
	xtitle("Urban poverty rate (%)") ///
	ytitle("Rural poverty rate (%)") ///
	legend(off) ///
	name(a4, replace) nodraw
	
tw(scatter fgt1_u2015 urban2015)(qfit fgt1_u2015 urban2015), ///
	title("(b2) Urbanization rate and uban poverty rate", size(medium)) ///
	xtitle("Urbanization rate (%)") ///
	ytitle("Urban poverty rate (%)") ///
	legend(off) ///
	name(a5, replace) nodraw	
	
tw(scatter fgt1_u2015 log_pop_u2015)(qfit fgt1_u2015 log_pop_u2015), ///
	title("(c2) Urban population size and urban poverty rate", size(medium)) ///
	xtitle("Log of urban population") ///
	ytitle("Urban poverty rate (%)") ///
	legend(off) ///
	name(a6, replace) nodraw
restore
	
graph combine a1 a4 a2 a5 a3 a6, iscale(0.4) row(3)	xsize(4)


* with metropolitan areas
foreach x in "fgt1_r2015 fgt1_u2015" {

tw(scatter `x', msize(small) mc(gs10)) ///
	(scatter `x' ///
	if county==47|county==34|county==22|county==16|county==21, ///
	mc(orange)) ///
	(scatter `x' if county==1|county==3|county==2, m(triangle)) ///
	(scatter `x' if county==27|county==32, mc(blue) m(square)) ///
	(scatter `x' if county==37|county==42) ///
	(scatter `x' if county==15|county==12|county==11) ///
	(scatter `x' if county==8|county==7|county==9, ///
	m(diamond) msize(small)) ///
	, ///
	title("(a) Urban and rural poverty rates", size(medium)) ///
	xtitle("Urban poverty rate (%)") ///
	ytitle("Rural poverty rate (%)") ///
	legend(order(2 "Nairobi metro" 3 "Mombasa metro" ///
	4 "Nakuru metro" 5 "Kisumu metro" 6 "Kitui metro" 7 "Wajir metro" ///
	1 "Others")) 
}	
		
foreach x in 2005 2015 {
tw (scatter fgt1_r`x' fgt1_u`x') ///
	(lfit fgt1_r`x' fgt1_u`x'), ///
	title("`x'", size(medium)) ///
	xtitle("Urban poverty rate (%)") ytitle("Rural poverty rate (%)") ///
	legend(order(1 "County poverty rate" 2 "Fitted values")) ///
	name(a`x', replace) nodraw
}
graph combine a2005 a2015, iscale(0.8) xsize(8) ycommon xcommon


foreach x in 2005 2015 {
tw (scatter fgt1_u`x' urban`x') ///
	(lfit fgt1_u`x' urban`x'), ///
	title("`x'", size(medium)) ///
	xtitle("Urbanization rate(%)") ytitle("Urban poverty rate (%)") ///
	legend(order(1 "County poverty rate" 2 "Fitted values")) ///
	name(b`x', replace) nodraw
}
graph combine b2005 b2015, iscale(0.8) xsize(8) ycommon xcommon

foreach x in 2005 2015 {
tw (scatter fgt1_u`x' urban`x') ///
	(lfit fgt1_u`x' urban`x') if urban`x'!=100, ///
	title("`x' (without Nairobi and Mombasa)", size(medium)) ///
	xtitle("Urbanization rate(%)") ytitle("Urban poverty rate (%)") ///
	legend(order(1 "County poverty rate" 2 "Fitted values")) ///
	name(b`x', replace) nodraw
}
graph combine b2005 b2015, iscale(0.8) xsize(8) ycommon xcommon

tw (scatter fgt1_rc fgt1_uc if fgt1_uc<0.3) (lfit fgt1_rc fgt1_uc if fgt1_uc<0.3), ///
	title("County-level urban/rural poverty rates", size(medium)) ///
	xtitle("Changes in urban poverty rate (%)") ///
	ytitle("Changes in rural poverty rate (%)") ///
	legend(order(1 "County poverty rate" 2 "Fitted values")) ///
	name(a_c, replace) 


///////////////////////////////
//   Province-level analysis //
///////////////////////////////	

use	"${gsdData}/2-AnalysisOutput/KIHBS_master_2005", clear
append using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"

gen pop = 1

collapse (sum) pop poor [fw=round(wta_pop)], by(year province urban)

gen fgt1 = poor / pop * 100
gen temp = fgt1 * urban
bysort year province: egen fgt1_u = max(temp)
rename fgt1 fgt1_r
bysort year province: egen totpop = sum(pop)

drop if urban==1 & province!=8
drop temp urban poor

rename pop pop_r
gen pop_u = totpop - pop_r
replace pop_u = pop_r if province==8
replace pop_r = 0 if province==8
replace fgt1_r = . if province==8
gen urban = pop_u / totpop * 100
gen poor_u = pop_u * fgt1_u / 100
gen poor_r = pop_r * fgt1_r / 100

order year province totpop pop_u pop_r fgt1_u fgt1_r poor_u poor_r

	
foreach x in 2005 2015 {
tw (scatter fgt1_r fgt1_u if year==`x' /*[w=pop], msymbol(circle_hollow)*/) ///
	(lfit fgt1_r fgt1_u if year==`x'), ///
	title("Province-level urban/rural poverty rates (`x')", size(medium)) ///
	xtitle("Urban poverty rate (%)") ytitle("Rural poverty rate (%)") ///
	legend(order(1 "Province poverty rate" 2 "Fitted values")) ///
	name(a`x', replace) nodraw
}
graph combine a2005 a2015, iscale(0.8) xsize(8) ycommon xcommon


foreach x in 2005 2015 {
tw (scatter fgt1_u urban if year==`x' /*[w=pop], msymbol(circle_hollow)*/) ///
	(lfit fgt1_u urban if year==`x'), ///
	title("Province-level urban/rural poverty rates (`x')", size(medium)) ///
	xtitle("Urbanization rate(%)") ytitle("Urban poverty rate (%)") ///
	legend(order(1 "Province poverty rate" 2 "Fitted values")) ///
	name(b`x', replace) nodraw
}
graph combine b2005 b2015, iscale(0.8) xsize(8) ycommon xcommon


reshape wide totpop - urban, i(province) j(year)

export excel using "${gsdOutput}/C5-Urban/kenya_county.xlsx", ///
	sheet("province") sheetreplace first(var)

gen fgt1_rc = (fgt1_r2005 / fgt1_r2015)-1
gen fgt1_uc = (fgt1_u2005 / fgt1_u2015)-1
gen urban_c = (urban2005 / urban2015)-1

tw (scatter fgt1_rc fgt1_uc if fgt1_uc<0.3) (lfit fgt1_rc fgt1_uc if fgt1_uc<0.3), ///
	title("Province-level urban/rural poverty rates", size(medium)) ///
	xtitle("Changes in urban poverty rate (%)") ///
	ytitle("Changes in rural poverty rate (%)") ///
	legend(order(1 "Province poverty rate" 2 "Fitted values")) ///
	name(a_c, replace) 
	
	
/////////////////////////////////////////////	
// ** Huppi and Ravallion decomposition ** //
/////////////////////////////////////////////

* net install sedecomposition, replace from(http://adeptanalytics.org/downlaod/ado)

tempfile data15
** over sector
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear

merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"
drop if _merge==2
drop _merge

keep if b03==1
mean poor if urban==1 [aw=wta_pop]

save `data15', replace

use "${gsdDataRaw}/KIHBS05/Section E Labour", clear

keep if e_id==1

rename id_clust clid
rename id_hh hhid

merge 1:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2005"
drop if _merge==1
drop _merge

mean poor if urban==1 [aw=wta_pop]

*Unemployment 
gen unemp=.
*unemployed if "Seeking Work" or "Doing nothing"
replace unemp= 1 if inlist(e03, 6, 7)
*employed if active in the past 7d
replace unemp= 0 if inlist(e03, 1, 2, 3, 4, 5)
*employed if "Seeking work" with activity to return to
replace unemp= 0 if inlist(e03, 6, 7) & (e09==1)
*removing retired respondents    				
replace unemp= . if inlist(e10, 2) | e03==8		

*Sector 
gen ocusec=.
replace ocusec=1 if e16>=1000 & e16<2000
replace ocusec=2 if e16>=2000 & e16<3000
replace ocusec=3 if e16>=3000 & e16<4000
replace ocusec=4 if e16>=4000 & e16<5000
replace ocusec=5 if e16>=5000 & e16<6000
replace ocusec=6 if e16>=6000 & e16<7000
replace ocusec=7 if e16>=7000 & e16<8000
replace ocusec=8 if e16>=8000 & e16<9000
replace ocusec=9 if e16>=9000 & e16<10000

*207 observations contain a sector of employment for unemployed individuals, all individuals are either seeking work or doing nothing.
assert inlist(e03,6,7) if unemp== 1 & !mi(ocusec)
replace ocusec = . if unemp==1

lab var ocusec "Sector of occupation"

lab def ocusec 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Electricity/water" 5 "Construction" 6 "Trade/Restaurant/Tourism" 7 "Transport/Comms" 8 "Finance" 9 "Social Services" 
lab val ocusec ocusec
tab ocusec, gen(ocusec_)

*Sector short
gen sector=.
replace sector=1 if ocusec==1
replace sector=2 if (ocusec==2 | ocusec==3)
replace sector=3 if (inlist(ocusec,4,6,7,8,9) )
replace sector=4 if ocusec==5
lab var sector "Sector of occupation"
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction"
lab val sector sector

rename sector sector_pri

sedecomposition using `data15' [w=wta_pop] if urban==1, sector(sector_pri) var1(y2_i) var2(y2_i) ///
	pline1(z2_i) pline2(z2_i) hc
	
	forvalues i = 1/7 {
 	
	tempfile data15 
	use "${gsdData}/2-AnalysisOutput/KIHBS_master_2015", clear
	keep if province==`i'
	save `data15', replace

	use "${gsdData}/2-AnalysisOutput/KIHBS_master_2005", clear
	keep if province==`i'
	
	tab province
	sedecomposition using `data15' [w=wta_pop], sector(urban) ///
		var1(y2_i) var2(y2_i) ///
		pline1(z2_i) pline2(z2_i) hc	
}

** over rural/urban
tempfile data15 
use "${gsdData}/2-AnalysisOutput/KIHBS_master_2015", clear
save `data15', replace

use "${gsdData}/2-AnalysisOutput/KIHBS_master_2005", clear

sedecomposition using `data15' [w=wta_pop], sector(urban) var1(y2_i) var2(y2_i) ///
	pline1(z2_i) pline2(z2_i) hc
	
	
forvalues i = 1/7 {
 	
	tempfile data15 
	use "${gsdData}/2-AnalysisOutput/KIHBS_master_2015", clear
	keep if province==`i'
	save `data15', replace

	use "${gsdData}/2-AnalysisOutput/KIHBS_master_2005", clear
	keep if province==`i'
	
	tab province
	sedecomposition using `data15' [w=wta_pop], sector(urban) ///
		var1(y2_i) var2(y2_i) ///
		pline1(z2_i) pline2(z2_i) hc	
}



***********************
//*** Consumption ***//
***********************

//*** 2005 ***//
* adjust to monthly adult equivalent deflated expenditure 

use	"${gsdData}/2-AnalysisOutput/KIHBS_master_2005", clear

gen kihbs=2005

merge 1:1 kihbs clid hhid using "${gsdData}/1-CleanOutput/hh", ///
	keepusing(rcons)
	
drop if _merge==2
drop _merge

gen pricedef = rcons / (adqexpdr/12)
gen adeq = hhtexpdr / adqexpdr
gen deflater = adqexpdr / adqexp
gen total = adqexpdr
gen food = fdtexpdr / adeq
gen nonfood = nfdtepdr / adeq
gen edu = edtexp / adeq * deflater
gen housing = nfdrnthh / adeq * deflater
gen utilities = (nfdwater + nfdfuel + nfdutil) / adeq * deflater
gen trans = nfdtrans / adeq * deflater

gen otherexp = nonfood - housing - edu - utilities - trans

foreach x in total food nonfood housing utilities trans edu otherexp {
	replace `x' = (`x'/12) * pricedef // adjust to 2015 prices
}


** urban, nairobi, and other urban areas
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	*/
	/*
	preserve
		collapse (mean) total food nonfood housing utilities trans edu otherexp ///
			[aw=wta_hh] if `condition`i'', by(`Q`i'')
		
		export excel using "kenya_expenditure.xlsx", ///
			sheet("expabs05_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) total food nonfood housing utilities trans edu otherexp ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_expenditure.xlsx", ///
			sheet("expabs05_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) total food nonfood housing utilities trans edu otherexp ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_expenditure.xlsx", ///
			sheet("expabs05_`i'_national") sheetreplace first(var)
	restore
	
	
}


** 2015/16
	
use	"${gsdData}/2-AnalysisOutput/KIHBS_master_2015", clear

merge 1:1 clid hhid using "${gsdDataRaw}/KIHBS15/nfexpcat"
drop _merge

* adjust to monthly adult equivalent deflated expenditure 

gen adeq = hhtexpdr / y2_i
gen total = y2_i
gen nonfood = nfdtexpdr / adeq
gen food = fdtexpdr / adeq
gen housing = nfdrent
gen edu = nfdedcons
gen utilities = (nfdwater + nfdrefuse + nfdegycons) 
gen trans = nfdtrans

gen otherexp = nonfood - housing - edu - utilities - trans

// housing expenditure share
tempfile temp
preserve
	use "${gsdDataRaw}/KIHBS15/eastatus", clear
	duplicates drop clid, force
	save `temp', replace
restore

merge m:1 clid using `temp'
drop if _merge==2
drop _merge

gen slum = (eastat==4)

gen hsg = housing / total * 100

// in Nairobi and Mombasa slums
foreach x in 47 1 {
	
	local title47 Nairobi
	local title1 Mombasa
	preserve
		qui keep if county==`x' // 
		tw(kdensity hsg [aw=wta_pop] if slum==1, lw(thick)) ///
			(kdensity hsg [aw=wta_pop] if slum==0, lw(thick) lpattern(shortdash)), ///
		title("Expenditure share on housing (`title`x'')", size(medium)) ///
		ytitle("Kernel density") ///
		xtitle("Expenditure share on housing (%)") ///
		legend(order(1 "Slum" 2 "Non-slum")) ///
		name(a`x', replace) nodraw
	restore
	
}
graph combine a47 a1 , xsize(10) iscale(1)


cap drop median
gen median = .

forvalues i = 1/47 {
	qui sum hsg if urban==1 & county==`i' [aw=wta_hh], de
	qui replace median = r(p50) if county==`i'
}
 
graph hbox hsg if urban==1 [aw=wta_hh], ///
	over(county, sort(median)) nooutside ///
	title("(A) Urban households", size(medium)) ///
	ytitle("Expenditure share on housing (%)") ///
	name(a1, replace) nodraw 

drop median
gen median = .

forvalues i = 1/47 {
	qui sum hsg if urban==1 & county==`i' & poor==1 [aw=wta_hh], de
	replace median = r(p50) if county==`i' & poor==1
}
 	
	
graph hbox hsg if urban==1 & poor==1 [aw=wta_hh], ///
	over(county, sort(median)) nooutside ///
	title("(B) Urban poor households", size(medium)) ///
	ytitle("Expenditure share on housing (%)") ///
	name(a2, replace) nodraw

graph combine a1 a2, iscale(0.6)

tempfile temp1 temp2

preserve
	keep if urban==1 & poor==1
	collapse (median) hsg_poor =hsg [aw=wta_hh], by(county)
	save `temp1', replace
restore
preserve
	keep if urban==1 & poor==0
	collapse (median) hsg_npoor =hsg [aw=wta_hh], by(county)
	save `temp2', replace
restore

preserve
	keep if urban==1
	gen n = 1
	collapse (median) hsg (sum) n [fw=round(wta_hh)], by(county)
	gen ln_pop = log(n)
	merge 1:1 county using `temp1'
	drop _merge
	merge 1:1 county using `temp2'
	
	tw (scatter hsg ln_pop) (lfit hsg ln_pop), ///
		title("(A) Urban households", size(medium)) xtitle("Log of urban population") ///
		ytitle("Median expenditure share on housing (%)") ///
		legend(order(1 "County" 2 "Fitted line")) ///
		name(a1, replace) nodraw
		
	tw (scatter hsg_poor hsg_npoor) (lfit hsg_poor hsg_npoor), ///
		title("(B) Poor and non-poor", size(medium)) ///
		xtitle("Median expenditure share on housing among non-poor (%)") ///
		ytitle("Median expenditure share on housing among poor (%)") ///
		legend(order(1 "County" 2 "Fitted line")) ///
		name(a2, replace) nodraw	
restore
graph combine a1 a2, iscale(0.8) xsize(8)

	
** urban, nairobi, and other urban areas
cd "${gsdOutput}/C5-Urban"
forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	*/
	/*
	preserve
		collapse (mean) total food nonfood housing utilities trans edu otherexp ///
			[aw=wta_hh] if `condition`i'', by(`Q`i'')
		
		export excel using "kenya_expenditure.xlsx", ///
			sheet("expabs15_`i'") sheetreplace first(var)
	restore
	*/

	preserve
		collapse (mean) total food nonfood housing utilities trans edu otherexp ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_expenditure.xlsx", ///
			sheet("expabs15_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) total food nonfood housing utilities trans edu otherexp ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_expenditure.xlsx", ///
			sheet("expabs15_`i'_national") sheetreplace first(var)
	restore
	
}

///////////////////////////////	
//   Water and sanitation	 //
///////////////////////////////

tempfile temp
use "${gsdDataRaw}/KIHBS15/hh", clear

merge 1:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"
drop _merge

tab j01_dr

foreach x in j01_dr {

	gen water1 = (`x'==1)
	replace water1 = . if `x'==.
	gen water2 = (`x'==2)
	replace water2 = . if `x'==.
	gen water3 = (`x'==3)
	replace water3 = . if `x'==.
	gen water4 = (inlist(`x', 4, 5, 7, 10, 14))
	replace water4 = . if `x'==.
	gen water5 = (inlist(`x', 6, 8, 9, 11, 12, 13))
	replace water5 = . if `x'==.
}

gen imptoilet1 = (inlist(j10, 11, 12, 13, 14, 15, 21))
replace imptoilet = . if j10==.
gen imptoilet2 = (inlist(j10, 11, 12, 13, 14, 15, 21, 22))
replace imptoilet2 = . if j10==.

gen toilet1 = (inlist(j10, 11, 12, 13, 14, 15))
replace toilet1 = . if j10==.
gen toilet2 = (j10==21)
replace toilet2 = . if j10==.
gen toilet3 = (j10==22)
replace toilet3 = . if j10==.
gen toilet4 = (j10==23)
replace toilet4 = . if j10==.
gen toilet5 = (inlist(j10, 31, 41, 51, 61, 96))
replace toilet5 = . if j10==.

save `temp', replace

use "${gsdDataRaw}/KIHBS05/Section H1 Water Sanitation", clear

merge 1:1 id_clust id_hh using "${gsdData}/2-AnalysisOutput/KIHBS_master_2005"
drop if _merge==2
drop _merge

foreach x in h01a {

	gen water1 = (`x'==1) // piped within dwelling
	replace water1 = . if `x'==.
	gen water2 = (`x'==2) // piped outside dwelling
	replace water2 = . if `x'==.
	gen water3 = (`x'==3) // public tap / standpipe
	replace water3 = . if `x'==.
	gen water4 = (inlist(`x', 4, 5, 6, 10, 11)) // other improved
	replace water4 = . if `x'==. 
	gen water5 = (inlist(`x', 7, 8, 9)) // not improved
	replace water5 = . if `x'==.
}

gen imptoilet1 = (h13==1|h13==2)
replace imptoilet1 = . if h13==.
gen imptoilet2 = (h13==1|h13==2|h13==4)
replace imptoilet2 = . if h13==.

gen toilet1 = (h13==1)
replace toilet1 = . if h13==.
gen toilet2 = (h13==2)
replace toilet2 = . if h13==.
gen toilet3 = (h13==4)
replace toilet3 = . if h13==.
gen toilet4 = (h13==3)
replace toilet4 = . if h13==.
gen toilet5 = (h13==5|h13==6|h13==7)
replace toilet5 = . if h13==.

append using `temp'

cap drop impwater
gen impwater = (water5==0)
replace impwater = . if water5==.

** by urban/rural
preserve
	collapse (mean) impwater [aw=wta_hh], by(year urban)
	replace impwater = impwater * 100
	export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
		sheet("water_national") sheetreplace first(var)
restore

preserve
	collapse (mean) imptoilet* [aw=wta_hh], by(year urban)
	replace imptoilet1 = imptoilet1 * 100
	replace imptoilet2 = imptoilet2 * 100
	export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
		sheet("toilet_national") sheetreplace first(var)
restore

** by province
preserve
	collapse (mean) impwater [aw=wta_hh], by(year province urban)
	replace impwater = impwater * 100
	export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
		sheet("water_province") sheetreplace first(var)
restore

preserve
	collapse (mean) imptoilet* [aw=wta_hh], by(year province urban)
	replace imptoilet1 = imptoilet1 * 100
	replace imptoilet2 = imptoilet2 * 100
	export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
		sheet("toilet_province") sheetreplace first(var)
restore

** urban, nairobi, and other urban areas
forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	*/
	* water
	/*
	preserve
		collapse (mean) water* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/5 {
			qui replace water`x' = water`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
			sheet("water_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) water* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/5 {
			qui replace water`x' = water`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
			sheet("water_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) water* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/5 {
			qui replace water`x' = water`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
			sheet("water_pov`i'") sheetreplace first(var)
	restore
	
	* sanitation
	/*
	preserve
		collapse (mean) toilet* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/5 {
			qui replace toilet`x' = toilet`x'*100
		}
		export excel using "${path}graph\kenya_water.xlsx", ///
			sheet("toilet_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) toilet* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/5 {
			qui replace toilet`x' = toilet`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
			sheet("toilet_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) toilet* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/5 {
			qui replace toilet`x' = toilet`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_water.xlsx", ///
			sheet("toilet_pov`i'") sheetreplace first(var)
	restore
}

////////////////////////////////
//        Electricity         //
////////////////////////////////

tempfile temp
use "${gsdDataRaw}/KIHBS15/hh", clear

merge 1:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"
drop _merge

tab j17

foreach x in j17 {

	gen elec1 = (`x'==1) // electricity
	replace elec1 = . if `x'==.
	gen elec2 = (inlist(`x', 4, 5, 6, 8, 11)) // gas
	replace elec2 = . if `x'==.
	gen elec3 = (inlist(`x', 2, 3, 7, 9, 10, 96)) // others
	replace elec3 = . if `x'==.
}

save `temp', replace

use "${gsdDataRaw}/KIHBS05/Section H2 Energy", clear

keep if h35==4 // only for lighting
bysort id_clust id_hh: egen elec = max(icode)
keep id_clust id_hh icode elec
duplicates drop id_clust id_hh, force

merge 1:1 id_clust id_hh using "${gsdData}/2-AnalysisOutput/KIHBS_master_2005"
drop if _merge==1
drop _merge

foreach x in elec {

	gen elec1 = (`x'==8) // electricity
	replace elec1 = . if `x'==.
	gen elec2 = (inlist(`x', 6, 7)) // gas
	replace elec2 = . if `x'==.
	gen elec3 = (inlist(`x', 1, 2, 3, 4, 5)) // others
	replace elec3 = . if `x'==.
}

append using `temp'


** by urban/rural
preserve
	collapse (mean) elec1 [aw=wta_hh], by(year urban)
	replace elec1 = elec1 * 100
	export excel using "${gsdOutput}/C5-Urban/kenya_elec.xlsx", ///
		sheet("elec_national") sheetreplace first(var)
restore

** by province
preserve
	collapse (mean) elec1 [aw=wta_hh], by(year province urban)
	replace elec1 = elec1 * 100
	export excel using "${gsdOutput}/C5-Urban/kenya_elec.xlsx", ///
		sheet("elec_province") sheetreplace first(var)
restore


** urban, nairobi, and other urban areas
forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	*/
	/*
	preserve
		drop elec
		collapse (mean) elec* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/3 {
			qui replace elec`x' = elec`x'*100
		}
		export excel using "${path}graph\kenya_elec.xlsx", ///
			sheet("elec_`i'") sheetreplace first(var)
	restore
	*/	
	preserve
		drop elec
		collapse (mean) elec* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/3 {
			qui replace elec`x' = elec`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_elec.xlsx", ///
			sheet("elec_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		drop elec
		collapse (mean) elec* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/3 {
			qui replace elec`x' = elec`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_elec.xlsx", ///
			sheet("elec_pov`i'") sheetreplace first(var)
	restore
	
	
}


	
////////////////////////////////
//  Commuting mode and time   //
////////////////////////////////

tempfile temp
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
*drop _merge

merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"
drop if _merge==2
drop _merge

tab d32 [aw=wta_hh]
sum d33

tab d32, gen(tmode15_)

clonevar tmode15 = d32

save `temp', replace

use "${gsdDataRaw}/KIHBS05/Section E Labour", clear

rename id_clust clid
rename id_hh hhid

merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2005"
drop if _merge==2
drop _merge

tab e29, gen(tmode05_)

append using `temp'

** urban, nairobi, and other urban areas
forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	
	* commuting mode
	preserve
		collapse (mean) tmode05_* tmode15_* [aw=wta_hh] if `condition`i'', by(`Q`i'')
		
		export excel using "${path}graph\kenya_mobility.xlsx", ///
			sheet("mode_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) tmode05_* tmode15_* [aw=wta_hh] if `condition`i''
		
		export excel using "${gsdOutput}/C5-Urban/kenya_mobility.xlsx", ///
			sheet("mode_`i'_national") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) tmode05_* tmode15_* [aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "${gsdOutput}/C5-Urban/kenya_mobility.xlsx", ///
			sheet("mode_pov`i'") sheetreplace first(var)
	restore
	
	
}
	
//////////////////////
//    Slums        ///
//////////////////////

use "${gsdDataRaw}/KIHBS15/hh", clear

merge 1:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"
drop _merge

keep if county==1|county==47 // keep only Mombasa and Nairobi

* merge slum status
tempfile temp
preserve
	use "${gsdDataRaw}/KIHBS15/eastatus", clear
	duplicates drop clid, force
	save `temp', replace
restore

merge m:1 clid using `temp'
drop if _merge==2
drop _merge

gen slum = (eastat==4) if eastat!=.
tab slum
	
tab slum county [aw=wta_hh], col	

gen tenure = .
replace tenure = 1 if i02==1 // owned
replace tenure = 2 if i02==2 // rent-paying tenant
replace tenure = 3 if i02==3|i02==4 // rent-free
tab tenure, gen(tenure_)

gen nroom = .
replace nroom = 1 if i12_1==1 // 1 room
replace nroom = 2 if i12_1==2 // 2 rooms
replace nroom = 3 if i12_1==3 // 3 rooms
replace nroom = 4 if i12_1==4 // 4 rooms
replace nroom = 5 if i12_1>=5 & i12_1<=23 // more than 5 rooms
tab nroom, gen(nroom_)

gen wall = .
replace wall = 1 if (inlist(i13,4,5,6,7)) // Mud
replace wall = 2 if (inlist(i13,1,2,3,9 )) // Other non-durables
replace wall = 3 if (inlist(i13,11)) // Corrugated iron sheets
replace wall = 4 if (inlist(i13,8,10,17)) // Wood 
replace wall = 5 if (inlist(i13,12,13,14,15,16)) // Stone, Cement, Bricks
replace wall = 6 if (inlist(i13,96)) // Others
tab wall, gen(wall_)

gen roof = .
replace roof = 1 if (inlist(i14,1,2)) // Grass/thatch/makuti/mud
replace roof = 2 if (inlist(i14,3,4,5)) // Corrugated iron/tin/asbestos sheets
replace roof = 3 if (inlist(i14,6)) // concrete
replace roof = 4 if (inlist(i14,7)) // tiles
replace roof = 5 if (inlist(i14,96)) // others
tab roof, gen(roof_)

gen floor = .
replace floor = 1 if (inlist(i15,1,2)) // earth/sand/dung
replace floor = 2 if (inlist(i15,3,4,5)) // wood/bamboo
replace floor = 3 if (inlist(i15,6,7)) // tiles 
replace floor = 4 if (inlist(i15,8)) // cement
replace floor = 5 if (inlist(i15,9,96)) // other
tab floor, gen(floor_)

foreach x in j01_dr {

	gen water = .
	replace water = 1 if `x'==1
	replace water = 2 if `x'==2
	replace water = 3 if `x'==3
	replace water = 4 if (inlist(`x', 4, 5, 7, 10, 14))
	replace water = 5 if (inlist(`x', 6, 8, 9, 11, 12, 13))
}
tab water, gen(water_)

gen toilet = .
replace toilet = 1 if (inlist(j10, 11, 12, 13, 14, 15))
replace toilet = 2 if j10==21
replace toilet = 3 if j10==22
replace toilet = 4 if j10==23
replace toilet = 5 if (inlist(j10, 31, 41, 51, 61, 96))
tab toilet, gen(toilet_)

gen electricity = .
replace electricity = 1 if j17==1
replace electricity = 0 if (inlist(j17, 3,4,5,6,7,9,10,96))

gen garbage = .
replace garbage = 1 if j14==1|j14==2|j14==3
replace garbage = 0 if (inlist( j14, 4,5,6,7,8,96))


* compare consumption and rent distributions over slum/non-slum

foreach x in 47 1 {
	
	local title47 Nairobi
	local title1 Mombasa
	preserve
		qui keep if county==`x' // 
		qui sum y2_i [aw=wta_pop], de
		drop if y2_i > r(p99)
		tw(kdensity y2_i [aw=wta_pop] if slum==1, lw(thick)) ///
			(kdensity y2_i [aw=wta_pop] if slum==0, lw(thick) lpattern(shortdash)), ///
		title("Consumption", size(medium)) ///
		ytitle("Kernel density") ///
		xtitle("Per adult-equivalent monthly consumption") ///
		legend(order(1 "Slum" 2 "Non-slum")) ///
		name(a`x', replace) nodraw
	restore
	preserve
		qui keep if county==`x' // 
		qui sum i10 [aw=wta_pop], de
		drop if i10 > r(p99)
		tw(kdensity i10 [aw=wta_pop] if slum==1, lw(thick)) ///
			(kdensity i10 [aw=wta_pop] if slum==0, lw(thick) lpattern(shortdash)), ///
		title("Rent", size(medium)) ///
		ytitle("Kernel density") ///
		xtitle("Monthly rent") ///
		legend(order(1 "Slum" 2 "Non-slum")) ///
		name(b`x', replace) nodraw
	restore
}
graph combine a47 b47, xsize(10) iscale(1)

foreach x in 47 1 {
	tab slum poor [aw=wta_pop] if county==`x', row
	mean poor [aw=wta_pop] if county==`x'
	mean poor [aw=wta_pop] if county==`x' & slum==1
	mean poor [aw=wta_pop] if county==`x' & slum==0
}



* Compare housing characteristics over slum/non-slum

svyset [pw=wta_hh]

foreach x in 1 /*47 1*/ {
	
	preserve
	
	keep if county==`x'
	tabstat tenure_* nroom_* wall_* roof_* floor_* ///
		water_* toilet_* electricity garbage [aw=wta_hh] ///
		, by(slum) stat(mean) save

	qui tabstatmat temp
	matrix temp = temp'
	mat li temp, noheader
	
	foreach y of varlist tenure_* nroom_* wall_* roof_* floor_* ///
		water_* toilet_* electricity garbage {
		
		svy: mean `y', over(slum)
		lincom [`y']1 - [`y']0
	}
	restore

}
	
///////////////////////
//     Housing       //
///////////////////////

tempfile temp
use "${gsdDataRaw}/KIHBS15/hh", clear

merge 1:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"
drop _merge

gen tenure = .
replace tenure = 1 if i02==1 // owned
replace tenure = 2 if i02==2 // rent-paying tenant
replace tenure = 3 if i02==3|i02==4 // rent-free

gen nroom = .
replace nroom = 1 if i12_1==1 // 1 room
replace nroom = 2 if i12_1==2 // 2 rooms
replace nroom = 3 if i12_1==3 // 3 rooms
replace nroom = 4 if i12_1==4 // 4 rooms
replace nroom = 5 if i12_1>=5 & i12_1<=23 // more than 5 rooms

gen wall = .
replace wall = 1 if (inlist(i13,4,5,6,7)) // Mud
replace wall = 2 if (inlist(i13,1,2,3,9 )) // Other non-durables
replace wall = 3 if (inlist(i13,11)) // Corrugated iron sheets
replace wall = 4 if (inlist(i13,8,10,17)) // Wood 
replace wall = 5 if (inlist(i13,12,13,14,15,16)) // Stone, Cement, Bricks
replace wall = 6 if (inlist(i13,96)) // Others

gen roof = .
replace roof = 1 if (inlist(i14,1,2)) // Grass/thatch/makuti/mud
replace roof = 2 if (inlist(i14,3,4,5)) // Corrugated iron/tin/asbestos sheets
replace roof = 3 if (inlist(i14,6)) // concrete
replace roof = 4 if (inlist(i14,7)) // tiles
replace roof = 5 if (inlist(i14,96)) // others

gen floor = .
replace floor = 1 if (inlist(i15,1,2)) // earth/sand/dung
replace floor = 2 if (inlist(i15,3,4,5)) // wood/bamboo
replace floor = 3 if (inlist(i15,6,7)) // tiles 
replace floor = 4 if (inlist(i15,8)) // cement
replace floor = 5 if (inlist(i15,9,96)) // other


save `temp', replace

use "${gsdDataRaw}/KIHBS05/Section G Housing", clear

merge 1:1 id_clust id_hh using "${gsdData}/2-AnalysisOutput/KIHBS_master_2005"
drop if _merge==2
drop _merge

gen tenure = .
replace tenure = 1 if g01==1|g01==2 // owned
replace tenure = 2 if g01==3|g01==5 // rent-paying tenant
replace tenure = 3 if g01==4|g01==6 // rent-free

gen nroom = .
replace nroom = 1 if g09a==1 // 1 room
replace nroom = 2 if g09a==2 // 2 rooms
replace nroom = 3 if g09a==3 // 3 rooms
replace nroom = 4 if g09a==4 // 4 rooms
replace nroom = 5 if g09a>=5 & g09a<=30 // more than 5 rooms

gen wall = .
replace wall = 1 if (inlist(g12,3)) // Mud
replace wall = 2 if (inlist(g12,7)) // Other non-durables
replace wall = 3 if (inlist(g12,6,8)) // Corrugated iron sheets
replace wall = 4 if (inlist(g12,5)) // Wood 
replace wall = 5 if (inlist(g12,1,2,4)) // Stone, Cement, Bricks
replace wall = 6 if (inlist(g12,9)) // Others

gen roof = .
replace roof = 1 if (inlist(g13,5,6)) // Grass/thatch/makuti/mud
replace roof = 2 if (inlist(g13,1,4,7)) // Corrugated iron/tin/asbestos sheets
replace roof = 3 if (inlist(g13,3)) // concrete
replace roof = 4 if (inlist(g13,2)) // tiles
replace roof = 5 if (inlist(g13,8)) // others

gen floor = .
replace floor = 1 if (inlist(g14,4)) // earth/sand/dung
replace floor = 2 if (inlist(g14,3)) // wood/bamboo
replace floor = 3 if (inlist(g14,2)) // tiles 
replace floor = 4 if (inlist(g14,1)) // cement
replace floor = 5 if (inlist(g14,5)) // other

append using `temp'

** create durable/non-durable category
gen wall_d = (wall==4|wall==5)
gen roof_d = (roof==3|roof==4)
gen floor_d = (floor==2|floor==3|floor==4)
gen score_d = wall_d + roof_d + floor_d
tab score_d

tab score_d year if urban==1 [fw=round(wta_hh)], col missing
tab score_d year if urban==1 & poor==1 [fw=round(wta_hh)], col

foreach x in tenure nroom wall roof floor {
	tab `x', gen(`x')
	drop `x'
}

xtile y2_5_u = y2_i [aw=wta_hh] if urban==1, n(5) 
xtile y2_5_n = y2_i [aw=wta_hh] if province==8, n(5) 
xtile y2_5_o = y2_i [aw=wta_hh] if urban==1 & province!=8, n(5) 

** urban, nairobi, and other urban areas
forvalues i = 1/3 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "urban==1 & province!=8"
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	
	* tenure

	preserve
		collapse (mean) tenure* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/3 {
			qui replace tenure`x' = tenure`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("tenure_`i'") sheetreplace first(var)
	restore

	
		preserve
		collapse (mean) tenure* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/3 {
			qui replace tenure`x' = tenure`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("tenure_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) tenure* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/3 {
			qui replace tenure`x' = tenure`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("tenure_pov`i'") sheetreplace first(var)
	restore
	
	* Number of rooms
	
	preserve
		collapse (mean) nroom* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/5 {
			qui replace nroom`x' = nroom`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("nroom_`i'") sheetreplace first(var)
	restore

		preserve
		collapse (mean) nroom* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/5 {
			qui replace nroom`x' = nroom`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("nroom_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) nroom* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/5 {
			qui replace nroom`x' = nroom`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("nroom_pov`i'") sheetreplace first(var)
	restore
	
	* wall
	
	preserve
		collapse (mean) wall* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/6 {
			qui replace wall`x' = wall`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("wall_`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) wall* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/6 {
			qui replace wall`x' = wall`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("wall_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) wall* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/6 {
			qui replace wall`x' = wall`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("wall_pov`i'") sheetreplace first(var)
	restore
	
		* roof
	
	preserve
		collapse (mean) roof* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/5 {
			qui replace roof`x' = roof`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("roof_`i'") sheetreplace first(var)
	restore

	preserve
		collapse (mean) roof* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/5 {
			qui replace roof`x' = roof`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("roof_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) roof* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/5 {
			qui replace roof`x' = roof`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("roof_pov`i'") sheetreplace first(var)
	restore
	
		* floor

	preserve
		collapse (mean) floor* [aw=wta_hh] if `condition`i'', by(year `Q`i'')
		forvalues x = 1/5 {
			qui replace floor`x' = floor`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("floor_`i'") sheetreplace first(var)
	restore

	preserve
		collapse (mean) floor* [aw=wta_hh] if `condition`i'', by(year)
		forvalues x = 1/5 {
			qui replace floor`x' = floor`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("floor_nat`i'") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) floor* [aw=wta_hh] if `condition`i'', by(year poor)
		forvalues x = 1/5 {
			qui replace floor`x' = floor`x'*100
		}
		export excel using "${gsdOutput}/C5-Urban/kenya_housing.xlsx", ///
			sheet("floor_pov`i'") sheetreplace first(var)
	restore
}

***************************
//*****   Labor   *******//
***************************

** 2015/16

tempfile temp
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear

merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2015"
drop if _merge==2
drop _merge

* labor force status
keep if urban==1
keep if b05_yy>=15 & b05_yy<=64 // keep only working-age populations

* individuals not eligible for employment module need to be dropped (e02 = filter);
keep if d01 == 1


*Active if worked in one of the 6 activities in the last 7 days
gen active_7d = 1 if d02_1 == 1 | d02_2 == 1 | d02_3 == 1 | d02_4 == 1 | d02_5 == 1 | d02_6 == 1 
replace active_7d = 0 if (d02_1==2 & d02_2==2 & d02_3==2 & d02_4==2 & d02_5==2 & d02_6==2)

*Unemployment 
*An individual is considered unemployed if:
	* They were not economically active in the past 7 days
	* AND they do not have an activity to return to OR have an activity but no certain return date.
	* Unemployment must also exclude those not considered as part of the labour force (those unavailable to start in <=4 weeks,incapactated, homemakers, full time students, the sick, those that don't need work and the retired.)

gen unemp = .
*UNEMPLOYED
*Inactive & does not have a defined return date & no activity to return to.
*Inactive & does not have a defined return date Or inactive and no activity to return to.
replace unemp = 1 if (active_7d==0 & !inlist(d07,1,2,3))
replace unemp = 1 if (active_7d==0 & d04_1=="G" )
*Active in the last 7d OR Inactive with defined return date 
replace unemp = 0 if active_7d==1
replace unemp = 0 if active_7d==0 & inlist(d07,1,2,3)
*EXCLUDED
replace unemp = . if inlist(d13,5,8)
replace unemp = . if inlist(d14,2,4,8,14,15,17)

tab unemp [aw=wta_hh] if province==8


*Not in the Labour force
*persons are in the labour force if they are employed or unemployed
gen nilf = 0 if inlist(unemp,0,1)
*NILF if retired, homemaker, student, incapacitated
replace nilf = 1 if inlist(d13,5,8)
replace nilf = 1 if inlist(d14,2,4,8,14,15,17)
gen LF = (nilf==0)
replace LF = . if nilf==.

gen worked = (d02_1==1|d02_2==1|d02_3==1|d02_4==1|d02_5==1|d02_6==1)
replace worked = 1 if inlist(d04_1, "A","B","C","D","E","F")
cap drop laborforce
gen laborforce = (worked==1)
replace laborforce = 1 if d11_1y>=1 & d11_1y<=16
tab worked laborforce, missing col
/*
gen unemp = (worked==0 & laborforce==1)
tab unemp laborforce [fw=round(wta_pop)], col
*/

* Employment type
tab d10_p

gen jobtype = .
replace jobtype = 1 if d10_p==1|d10_p==2 // paid employee
replace jobtype = 2 if d10_p==3 // working employer
replace jobtype = 3 if d10_p==4 // own-account worker
replace jobtype = 4 if d10_p>=5 & d10_p<=96 // other
label define jobtype ///
	1 "Paid employee" 2 "Working employer" 3 "Own-account worker" 4 "Other"
label values jobtype jobtype

tab jobtype, gen(jobtype_)

*Employment sectors
local privar d16
local secvar d36 

foreach x in pri /*sec*/ {

	gen occ_sector_`x' = .
	replace occ_sector_`x' = 1 if inrange(``x'var',111 , 322 )
	replace occ_sector_`x' = 2 if inrange(``x'var',510 , 3900 )
	replace occ_sector_`x' = 3 if inrange(``x'var',1010 , 3320 )
	replace occ_sector_`x' = 4 if inrange(``x'var',4100 , 4390 )
	replace occ_sector_`x' = 5 if inrange(``x'var',4610 , 4799 ) ///
		| inlist(``x'var',4510,4530)
	replace occ_sector_`x' = 6 if inrange(``x'var',9511,9529) ///
		| inlist(``x'var',4520,4540) | inrange(``x'var',4911,5320)
	replace occ_sector_`x' = 7 if inrange(``x'var',5510,5630)
	replace occ_sector_`x' = 8 if inrange(``x'var',6910,8299) ///
		| inrange(``x'var',9000,9329) | inrange(``x'var',8411,8413) ///
		| inrange(``x'var',8421,8423)
	replace occ_sector_`x' = 9 if inrange(``x'var',8510 , 8890 ) ///
		| ``x'var'==8430 
	replace occ_sector_`x' = 10 if inrange(``x'var',9601,9609) ///
		| inrange(``x'var',5811,6820) | inrange(``x'var',9411,9499) ///
		| inrange(``x'var',9700,9900)

	label define lsector 1	"Agriculture"	 , modify
	label define lsector 2	"Mining and Quarrying"	 , modify
	label define lsector 3	"Manufacturing"	 , modify
	label define lsector 4	"Construction"	 , modify
	label define lsector 5	"Wholesale and retail trade"	 , modify
	label define lsector 6	"Transportation & storage, Vehicle repair"	 , modify
	label define lsector 7	"Accomodation and food service activities"	 , modify
	label define lsector 8	"Professional, scientific and technical activities"	 , modify
	label define lsector 9	"Education, human health and social work"	 , modify
	label define lsector 10 "Others"	 , modify

	label values occ_sector_`x' lsector
	gen sector_`x' =  .
	replace sector_`x' = 1 if inlist(occ_sector_`x',1,2)
	replace sector_`x' = 2 if occ_sector_`x'==3
	replace sector_`x' = 3 if inlist(occ_sector_`x',5,6,7,8,9,10)
	replace sector_`x' = 4 if occ_sector_`x'==4

	lab var sector_`x' "Sector of occupation"
	lab def sector_`x' 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction",  replace
	lab val sector_`x' sector_`x'
	
}

tab occ_sector_pri, gen(occ_sector_pri_)
tab sector_pri, gen(sector_pri_)
tab sector_pri if urban==1 [aw=wta_pop]
tab sector_pri if urban==1 & b04==1 [aw=wta_pop] // male
tab sector_pri if urban==1 & b04==2 [aw=wta_pop] // female

** Wage ***
sum d18 // hours per week
tab d23 jobtype // working pattern (casual etc)
tab d24 // how many days last month
sum d25 // daily wage of casual work 
sum d26, de // salary last month
sum d27, de // house allowance
tab d30 jobtype // contract (written, verbal etc)
sum d43 // income last month from secondary job

gen edu = .
replace edu = 1 if c10_l==1|c10_l==2
replace edu = 2 if c10_l==3|c10_l==4
replace edu = 3 if c10_l>=5 & c10_l<=8

gen worktime = d23
tab worktime, gen(worktime_)
tab d23 sector_pri [aw=wta_pop], col
tab d23 sector_pri [aw=wta_pop], row

gen wage = d26
egen wageh = rowtotal(d26 d27)
sum wageh, de
gen ln_wage = log(wage)
gen ln_wageh = log(wageh)
hist ln_wage
hist ln_wageh

* wage by sector
table sector_pri [aw=wta_hh] if urban==1, c(median wageh)
table sector_pri [aw=wta_hh] if county==47, c(median wageh)
table sector_pri [aw=wta_hh] if county==1, c(median wageh)
table sector_pri [aw=wta_hh] if urban==1 & county!=1 & county!=47, c(median wageh)
table sector_pri [aw=wta_hh] if poor==1 & urban==1, c(median wageh)
table sector_pri [aw=wta_hh] if poor==1 &county==47, c(median wageh)
table sector_pri [aw=wta_hh] if poor==1 &county==1, c(median wageh)
table sector_pri [aw=wta_hh] if poor==1 &urban==1 & county!=1 & county!=47, c(median wageh)
table sector_pri [aw=wta_hh] if poor==0 & urban==1, c(median wageh)
table sector_pri [aw=wta_hh] if poor==0 &county==47, c(median wageh)
table sector_pri [aw=wta_hh] if poor==0 &county==1, c(median wageh)
table sector_pri [aw=wta_hh] if poor==0 &urban==1 & county!=1 & county!=47, c(median wageh)

sum wageh [aw=wta_hh] if county==1 & sector_pri==1, de


* full time/part-time
tab d23 poor [aw=wta_pop] if urban==1, col
tab d23 poor [aw=wta_pop] if urban==1 & county==47, col

* unemployment by slum/poor
tempfile temp
preserve
	use "${gsdDataRaw}/KIHBS15/eastatus", clear
	duplicates drop clid, force
	save `temp', replace
restore

merge m:1 clid using `temp'
drop if _merge==2
drop _merge

gen slum = (eastat==4)

tab unemp slum [aw=wta_pop] if county==47, col
tab unemp poor [aw=wta_pop] if county==47, col
mean unemp [aw=wta_pop] if county==47
table slum poor [aw=wta_pop] if county==47, c(mean unemp) // Nairobi


* urban Kenya
eststo clear

eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu ///
	[aw=wta_hh] if urban==1, absorb(county)

eststo: areg ln_wageh b3.sector_pri ///
	[aw=wta_hh] if urban==1, absorb(county)

eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 b3.sector_pri ///
	[aw=wta_hh] if urban==1, absorb(county)
	
eststo: areg ln_wageh c.b05_yy##c.b05_yy i.edu b3.sector_pri ///
	[aw=wta_hh] if urban==1, absorb(county)		

eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu b3.sector_pri ///
	[aw=wta_hh] if urban==1, absorb(county)	
	
eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu b3.sector_pri i.d30 ///
	[aw=wta_hh] if urban==1, absorb(county)

esttab ///
	using "${gsdOutput}/KIHBS_wage_Nairobi.rtf", replace ///
	se unstack nogap onecell star(* 0.1 ** 0.05 *** 0.01) ///
	stats(r2_a N, labels("Adj-R2" "Obs.")) ///
	title({\b Table.} Wage equations)
eststo clear	
	

* Nairobi
eststo clear

eststo: reg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu ///
	[aw=wta_hh] if province==8

eststo: reg ln_wageh b3.sector_pri ///
	[aw=wta_hh] if province==8

eststo: reg ln_wageh c.b05_yy##c.b05_yy i.b04 b3.sector_pri ///
	[aw=wta_hh] if province==8
	
eststo: reg ln_wageh c.b05_yy##c.b05_yy i.edu b3.sector_pri ///
	[aw=wta_hh] if province==8		

eststo: reg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu b3.sector_pri ///
	[aw=wta_hh] if province==8
	
eststo: reg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu b3.sector_pri i.d30 ///
	[aw=wta_hh] if province==8

esttab ///
	using "${gsdOutput}/KIHBS_wage_Nairobi.rtf", replace ///
	se unstack nogap onecell star(* 0.1 ** 0.05 *** 0.01) ///
	stats(r2_a N, labels("Adj-R2" "Obs.")) ///
	title({\b Table.} Wage equations)
eststo clear		
		
	
* Other urban
eststo clear
eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu ///
	[aw=wta_hh] if province!=8 & urban==1, absorb(county)

eststo: areg ln_wageh b3.sector_pri ///
	[aw=wta_hh] if province!=8 & urban==1, absorb(county)

eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 b3.sector_pri ///
	[aw=wta_hh] if province!=8 & urban==1, absorb(county)
	
eststo: areg ln_wageh c.b05_yy##c.b05_yy i.edu b3.sector_pri ///
	[aw=wta_hh] if province!=8 & urban==1, absorb(county)

eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu b3.sector_pri ///
	[aw=wta_hh] if province!=8 & urban==1, absorb(county)
	
eststo: areg ln_wageh c.b05_yy##c.b05_yy i.b04 i.edu b3.sector_pri i.d30 ///
	[aw=wta_hh] if province!=8 & urban==1, absorb(county)

esttab ///
	using "${gsdOutput}/KIHBS_wage_otherurban.rtf", replace ///
	se unstack nogap onecell star(* 0.1 ** 0.05 *** 0.01) ///
	stats(r2_a N, labels("Adj-R2" "Obs.")) ///
	title({\b Table.} Wage equations)
eststo clear	
	

** urban, nairobi, and other urban areas
// laborforce participation rate
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	*/
	/*
	preserve
		collapse (mean) LF ///
			[aw=wta_hh] if `condition`i'', by(`Q`i'')
		
		export excel using "kenya_labor.xlsx", ///
			sheet("LF15_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) LF ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("LF15_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) LF ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("LF15_`i'_national") sheetreplace first(var)
	restore
	
	
}

cd "${path}"
// unemployment rate
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	*/
	/*
	preserve
		collapse (mean) unemp ///
			[aw=wta_hh] if nilf==0 & `condition`i'', by(`Q`i'')
		
		export excel using "kenya_labor.xlsx", ///
			sheet("unemp15_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) unemp ///
			[aw=wta_hh] if nilf==0 &`condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("unemp15_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) unemp ///
			[aw=wta_hh] if nilf==0 &`condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("unemp15_`i'_national") sheetreplace first(var)
	restore
	
	
}
cd "${path}"

// employment type
cd "${gsdOutput}/C5-Urban"	
	
forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	
	preserve
		collapse (mean) jobtype_* ///
			[aw=wta_hh] if `condition`i'', by(`Q`i'')
		
		export excel using "kenya_labor.xlsx", ///
			sheet("jobtype15_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) jobtype_* ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("jobtype15_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) jobtype_* ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("jobtype15_`i'_national") sheetreplace first(var)
	restore
	
}

cd "${path}"

// work time
cd "${gsdOutput}/C5-Urban"	
	
forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	
	preserve
		collapse (mean) worktime_* ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("worktime15_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) worktime_* ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("worktime15_`i'_national") sheetreplace first(var)
	restore
	
}

cd "${path}"


// economic sectors
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	
	preserve
		collapse (mean) occ_sector_pri_*  ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("sector15_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) occ_sector_pri_*  ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("sector15_`i'_national") sheetreplace first(var)
	restore
	
	
}
cd "${path}"

* economic sector by county
tab county sector_pri [fw=round(wta_hh)]


* Unemployment rate
// All age
tab unemp if laborforce==1 [fw=round(wta_hh)]
tab unemp if laborforce==1 & b04==1 [fw=round(wta_hh)]
tab unemp if laborforce==1 & b04==2 [fw=round(wta_hh)]
tab county unemp if laborforce==1 [fw=round(wta_hh)]
tab county unemp if laborforce==1 & b04==1 [fw=round(wta_hh)] // men
tab county unemp if laborforce==1 & b04==2 [fw=round(wta_hh)] // women

// Youth 15-29 yrs old
tab unemp if laborforce==1 & b05_yy>=15 & b05_yy<=29 [fw=round(wta_hh)]
tab unemp if laborforce==1 & b04==1 & b05_yy>=15 & b05_yy<=29 [fw=round(wta_hh)]
tab unemp if laborforce==1 & b04==2 & b05_yy>=15 & b05_yy<=29 [fw=round(wta_hh)]
tab county unemp if laborforce==1 & b05_yy>=15 & b05_yy<=29 [fw=round(wta_hh)]
tab county unemp if laborforce==1 & b04==1 & b05_yy>=15 & b05_yy<=29 [fw=round(wta_hh)]
tab county unemp if laborforce==1 & b04==2 & b05_yy>=15 & b05_yy<=29 [fw=round(wta_hh)]

** 2005/6
use "${gsdDataRaw}/KIHBS05/Section E Labour", clear

rename id_clust clid
rename id_hh hhid

merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/KIHBS_master_2005"
drop if _merge==2
drop _merge

rename e_id b_id 
drop id_clust id_hh
rename clid id_clust
rename hhid id_hh

merge 1:1 id_clust id_hh b_id ///
	using "${gsdDataRaw}/KIHBS05/Section B Household member Information", ///
	keepusing(b04 b05a)
	
drop if _merge==2
drop _merge

keep if urban==1
keep if b05a>=15 & b05a<=64

tab e03, missing
tab e04, missing
tab e10, missing
tab e11, missing

** Assing sectors **
* individuals not eligible for employment module need to be dropped (e02 = filter);
drop if e02 == 1

*Unemployment 
gen unemp=.
*unemployed if "Seeking Work" or "Doing nothing"
replace unemp= 1 if inlist(e03, 6, 7)
*employed if active in the past 7d
replace unemp= 0 if inlist(e03, 1, 2, 3, 4, 5)
*employed if "Seeking work" with activity to return to
replace unemp= 0 if inlist(e03, 6, 7) & (e09==1)
*removing retired respondents    				
replace unemp= . if inlist(e10, 2) | e03==8								

egen hours=rsum(e05-e07) 
*remioving employed, with no hours, no job to return
replace unemp= . if (unemp==0 & e09==2 & hours==0) 					
lab var unemp "Unemployed"

*Not in the Labour force
*persons are in the labour force if they are employed or unemployed
gen nilf = 0 if inlist(unemp,0,1)
*NILF if retired, homemaker, student, incapacitated
replace nilf = 1 if inlist(e03,8,9,10,11) & unemp==.
gen LF = (nilf==0)
replace LF = . if nilf==.

*Employment Status
gen empstat=.
*wage employee*
replace empstat=1 if (unemp==0 & e04==1) 
*self employed   			  
replace empstat=2 if (unemp==0 & (e04==2 | e04==3)) 
*unpaid family   
replace empstat=3 if (unemp==0 & e04==4) 
*apprentice   		   
replace empstat=4 if (unemp==0 & e04==5) 
*other   		    
replace empstat=5 if (unemp==0 & e04==6)    		    
*respondent is not asked e04 if inactive in the past 7d yet they have an activity to return to
replace empstat=6 if (unemp==0 & mi(e04) & e09==1)    		    

lab var empstat "Employment Status"

lab def empstat 1 "Wage employed" 2 "Self employed" 3 "Unpaid fam worker" 4 "Apprentice" 5 "Other" 6"Missing status"
lab val empstat empstat
tab empstat unemp

*Sector 
gen ocusec=.
replace ocusec=1 if e16>=1000 & e16<2000
replace ocusec=2 if e16>=2000 & e16<3000
replace ocusec=3 if e16>=3000 & e16<4000
replace ocusec=4 if e16>=4000 & e16<5000
replace ocusec=5 if e16>=5000 & e16<6000
replace ocusec=6 if e16>=6000 & e16<7000
replace ocusec=7 if e16>=7000 & e16<8000
replace ocusec=8 if e16>=8000 & e16<9000
replace ocusec=9 if e16>=9000 & e16<10000

*207 observations contain a sector of employment for unemployed individuals, all individuals are either seeking work or doing nothing.
assert inlist(e03,6,7) if unemp== 1 & !mi(ocusec)
replace ocusec = . if unemp==1

lab var ocusec "Sector of occupation"

lab def ocusec 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Electricity/water" 5 "Construction" 6 "Trade/Restaurant/Tourism" 7 "Transport/Comms" 8 "Finance" 9 "Social Services" 
lab val ocusec ocusec
tab ocusec, gen(ocusec_)

*Sector short
gen sector=.
replace sector=1 if ocusec==1
replace sector=2 if (ocusec==2 | ocusec==3)
replace sector=3 if (inlist(ocusec,4,6,7,8,9) )
replace sector=4 if ocusec==5
lab var sector "Sector of occupation"
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction"
lab val sector sector


/*
* unemployment rate
cap drop worked laborforce
gen worked = inlist(e03,1,2,3,4,5)
replace worked = 1 if e09==1
gen laborforce = (worked==1)
replace laborforce = 1 if worked==0 & (e10==3)
tab worked laborforce [fw=round(wta_hh)], missing col
gen unemp = (laborforce==1 & worked==0)
*/

* Employment types
gen jobtype = .
replace jobtype = 1 if e04==1 // paid employee
replace jobtype = 2 if e04==2 // working employer
replace jobtype = 3 if e04==3 // own-account worker
replace jobtype = 4 if e04>=4 & e04<=9
tab jobtype, gen(jobtype_)

** urban, nairobi, and other urban areas
// laborforce participation rate
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	
	preserve
		collapse (mean) LF ///
			[aw=wta_hh] if  `condition`i'', by(`Q`i'')
		
		export excel using "kenya_labor.xlsx", ///
			sheet("LF05_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) LF ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("LF05_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) LF ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("LF05_`i'_national") sheetreplace first(var)
	restore
	
	
}
cd "${path}"

// unemployment rate
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	
	preserve
		collapse (mean) unemp ///
			[aw=wta_hh] if nilf==0 & `condition`i'', by(`Q`i'')
		
		export excel using "kenya_labor.xlsx", ///
			sheet("unemp05_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) unemp ///
			[aw=wta_hh] if nilf==0 &`condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("unemp05_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) unemp ///
			[aw=wta_hh] if nilf==0 &`condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("unemp05_`i'_national") sheetreplace first(var)
	restore
	
	
}
cd "${path}"

// jobtype
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	
	preserve
		collapse (mean) jobtype_* ///
			[aw=wta_hh] if  `condition`i'', by(`Q`i'')
		
		export excel using "kenya_labor.xlsx", ///
			sheet("jobtype05_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) jobtype_* ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("jobtype05_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) jobtype_* ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("jobtype05_`i'_national") sheetreplace first(var)
	restore
	
	
}

// Economic sectors
cd "${gsdOutput}/C5-Urban"

forvalues i = 1/4 {

	local condition1 "urban==1"
	local condition2 "province==8"
	local condition3 "county==1"
	local condition4 "urban==1 & province!=8 & county!=1"
	/*
	local Q1 y2_5_u
	local Q2 y2_5_n
	local Q3 y2_5_o
	
	preserve
		collapse (mean) ocusec_* ///
			[aw=wta_hh] if  `condition`i'', by(`Q`i'')
		
		export excel using "kenya_labor.xlsx", ///
			sheet("sector05_`i'") sheetreplace first(var)
	restore
	*/
	preserve
		collapse (mean) ocusec_* ///
			[aw=wta_hh] if `condition`i'', by(poor)
		
		export excel using "kenya_labor.xlsx", ///
			sheet("sector05_`i'_pov") sheetreplace first(var)
	restore
	
	preserve
		collapse (mean) ocusec_* ///
			[aw=wta_hh] if `condition`i''
		
		export excel using "kenya_labor.xlsx", ///
			sheet("sector05_`i'_national") sheetreplace first(var)
	restore
	
	
}
cd "${path}"

sort id_clust id_hh b_id
sum id_clust id_hh b_id

tab e03 [iw=weight] // occupation status
tab e04 [iw=weight] // employment status
sum e05 [aw=weight], de // number of hours working
tab e15 [iw=weight] // KNOCS codes
tab e16 [iw=weight] // ISIC REV 2 codes
tab e17 [iw=weight] // types of employer
sum e20 [aw=weight], de // wage last month
sum e21 [aw=weight], de // house allowance
sum e22 [aw=weight], de // medical allowance
sum e23 [aw=weight], de // other allowance
sum e25 [aw=weight], de // days for casual labor during the last 3 months
sum e26 [aw=weight], de // average daily wage for casual labor

gen wage = e20
gen wage_all = e20 + e21 + e22 + e23 // wage + allowances
replace wage = . if wage==0
replace wage_all = . if wage_all==0
sum wage*, de

table e04 [aw=weight], c(mean wage mean wage_all)

tempfile temp
preserve
	use "${gsdDataRaw}/KIHBS05/Section B Household member Information", clear
	*rename b_id e_id
	sort id_clust id_hh b_id
	sum id_clust id_hh b_id
	save `temp', replace
restore

merge 1:1 id_clust id_hh b_id using `temp'
drop if _merge==2
drop _merge

tempfile temp
preserve
	use "${gsdDataRaw}/KIHBS05/Section A Identification", clear
	sort id_clust id_hh
	sum id_clust id_hh
	save `temp', replace
restore

merge m:1 id_clust id_hh using `temp'
drop if _merge==2
drop _merge

tempfile temp
preserve
	use "${gsdDataRaw}/KIHBS05/Section C education", clear
	*rename b_id e_id
	sort id_clust id_hh b_id
	sum id_clust id_hh b_id
	save `temp', replace
restore

merge 1:1 id_clust id_hh b_id using `temp'
drop if _merge==2
drop _merge	

tempfile temp
preserve
	use "${gsdDataRaw}/KIHBS05/consumption aggregated data", clear
	sort id_clust id_hh 
	sum id_clust id_hh 
	save `temp', replace
restore

merge m:1 id_clust id_hh using `temp'
drop if _merge==2
drop _merge	

*gen urban = (rururb==2)
label define urban 1 "Urban" 0 "Rural"
label values urban urban
gen nairobi = (prov==1)
gen otherurban = (urban==1 & nairobi==0)

xtile y_10 = y_i [aw=wta_hh], n(10) 
xtile y2_10 = y2_i [aw=wta_hh], n(10) 
label var y_10 "Decile of food per capita household consumption"
label var y2_10 "Decile of total per capita household consumption"

xtile y_10_u = y_i [aw=wta_hh] if urban==1, n(10) 
xtile y2_10_u = y2_i [aw=wta_hh] if urban==1, n(10) 
label var y_10_u "Decile of food per capita household consumption (urban only)"
label var y2_10_u "Decile of total per capita household consumption (urban only)"

xtile y_5_n = y_i [aw=wta_hh] if nairobi==1, n(5) 
xtile y2_5_n = y2_i [aw=wta_hh] if nairobi==1, n(5) 
label var y_5_n "Quintile of food per capita household consumption (Nairobi only)"
label var y2_5_n "Quintile of total per capita household consumption (Nairobi only)"


// commuting time
tab e28 [iw=weight] // district of job
tab e29 [iw=weight] // travel mode to job
sum e30a [aw=weight], de // travel time to job (peak)
sum e30b [aw=weight], de // travel time to job (off-peak)

gen mode1 = (e29==1) // walk
replace mode1 = . if e29==.
gen mode2 = (e29==3) // matatu
replace mode2 = . if e29==.
gen mode3 = (e29==7) // private vehicle
replace mode3 = . if e29==.	
gen mode4 = (e29==6) // employer provided	
replace mode4 = . if e29==.	
gen mode5 = (e29==4) // bus	
replace mode5 = . if e29==.	
gen mode6 = (e29==2|e29==5|e29==8) // bicycle/train/etc	
replace mode6 = . if e29==.	

graph box e30a, over(y2_5_n) nooutside ///
	title("Commuting time in Nairobi", size(medium)) ///
	b1title("Quintile of household consumption") ///
	name(a1, replace) nodraw

preserve
	collapse (mean) mode* if nairobi==1, by(y2_5_n)
	forvalues i = 1/6 {
		replace mode`i' = mode`i' * 100
	}
	graph bar mode*, over(y2_5_n) stack ///
		title("Travel mode in Nairobi", size(medium)) ///
		ytitle("Percentage of households") ///
		b1title("Quintile of household consumption") ///
		legend(order(1 "Walk" 2 "Matatu" 3 "Private vehicle" ///
		4 "Employer provided" 5 "Bus" 6 "Bicycle/train/others")) ///
		name(a2, replace) nodraw
restore
graph combine a1 a2, xsize(8) iscale(0.8)
graph export "${gsdOutput}/C5-Urban/travel_Nairobi2006.png", replace 

// focus on only wage workers
gen ln_wage = log(wage)
gen ln_wage_all = log(wage_all)
sum ln_wage*

gen female = (b04==2)
replace female = . if b04==.
label define female 1 "female" 0 "male"
label values female female
gen age = b05a
gen married = (b19==1|b19==2|b19==3)
replace married = . if b19==.
label define married 1 "married" 0 "not married"
label values married married
gen schyr = c04a
replace schyr = 0 if schyr==20
replace schyr = . if schyr==21
gen ln_schyr = log(schyr)

reg ln_wage female#married c.age##c.age c.schyr##c.schyr i.rururb i.prov

reg ln_wage female#married c.age##c.age c.schyr##c.schyr i.prov ///
	if rururb==2

reg ln_wage female#married c.age##c.age c.schyr##prov ///
	if rururb==2
margins prov, at(schyr = (0(1)19)) vsquish 
marginsplot, noci 

reg ln_wage female#married c.age##c.age c.schyr##c.schyr##prov ///
	if rururb==2
margins prov, at(schyr = (0(1)19)) vsquish 
marginsplot, noci xtitle("Years of schooling")

preserve
	replace wage = wage/1000
	glm wage female#married c.age##c.age c.schyr##c.schyr##prov ///
		if rururb==2, link(log)
	margins prov, at(schyr = (0(1)19))
	marginsplot, noci ///
		xtitle("Years of schooling") ///
		title("Wage and education in urban areas", size(medium))
	graph export "${gsdOutput}/C5-Urban/edureturn2006.png", replace 
restore

gen edu = .
replace edu = 0 if schyr==0 // no education
replace edu = 1 if schyr>=1 & schyr<8 // primary incomplete
replace edu = 2 if schyr==8 // primary complete
replace edu = 3 if schyr>8 & schyr<14 // secondary incomplete
replace edu = 4 if schyr>=14 & schyr!=. // secondary completed

tab edu prov if rururb==2

reg ln_wage female#married c.age##c.age i.edu i.prov ///
	if rururb==2

reg ln_wage female#married c.age##c.age i.edu##i.prov ///
	if rururb==2	

margins prov, at(edu = (0(1)4)) vsquish 
marginsplot, noci 	

// Livelihood of urban residents
tab e03 if rururb==2
tab e04 if rururb==2
tab e03 e04 if rururb==2

gen workpay = (e03==1)
gen workown = (e03==4)
gen workagr = (e03==5)
gen worker = (e03==1|e03==4|e03==5)
gen hour = e05 + e06 + e07

preserve
	collapse (sum) workpay workown workagr if rururb==2 [aw=weight], by(prov)
	gen total = workpay + workown + workagr
	foreach var of varlist workpay workown workagr {
		replace `var' = `var' / total
	}
	graph bar workpay workown workagr, ///
	over(prov, label(angle(45) labsize(small))) stack ///
	legend(order(1 "Work for pay" 2 "Work on family business" ///
	3 "Work on agriculture") size(small))
restore

preserve
	cap drop y_10
	xtile y_10 = y2_i if rururb==2 [aw=weight], n(10)
	collapse (sum) workpay workown workagr, by(y_10)
	gen total = workpay + workown + workagr
	foreach var of varlist workpay workown workagr {
		replace `var' = `var' / total
	}
	graph bar workpay workown workagr, ///
	over(y_10) b1title("Decile of food and non-food consumption") stack ///
	legend(order(1 "Work for pay" 2 "Work on family business" ///
	3 "Work on agriculture") col(1) size(small)) ///
	title("Types of work by consumption decile in urban areas", size(medium))
	graph export "${gsdOutput}/C5-Urban/emp2006.png", replace 
restore

bysort id_clust id_hh: egen nworker = sum(worker) if rururb==2
tab nworker prov, col nofreq

tabstat hour if rururb==2, by(prov) stat(mean p25 p50 p75)



//*** Housing ***//
use "${gsdDataRaw}/KIHBS05/Section G Housing", clear

sort id_clust id_hh
sum id_clust id_hh

tab g01 [iw=weights] // housing tenure
tab g11 [iw=weights] // dwelling type
tab g12 [iw=weights] // walls
tab g13 [iw=weights] // roof
tab g14 [iw=weights] // floor

********************************
//*** Water and sanitation ***//
********************************
use "${gsdDataRaw}/KIHBS05/Section H1 Water Sanitation", clear

sort id_clust id_hh
sum id_clust id_hh

merge 1:1 id_clust id_hh using "${gsdDataRaw}/KIHBS05/Section A Identification"
drop if _merge==2
drop _merge

merge 1:1 id_clust id_hh using "${gsdDataRaw}/KIHBS05/consumption aggregated data"
drop if _merge==2
drop _merge

gen urban = (rururb==2)
label define urban 1 "Urban" 0 "Rural"
label values urban urban
gen nairobi = (prov==1)
gen otherurban = (urban==1 & nairobi==0)

xtile y_10 = y_i [aw=wta_hh], n(10) 
xtile y2_10 = y2_i [aw=wta_hh], n(10) 
label var y_10 "Decile of food per capita household consumption"
label var y2_10 "Decile of total per capita household consumption"

xtile y_10_u = y_i [aw=wta_hh] if urban==1, n(10) 
xtile y2_10_u = y2_i [aw=wta_hh] if urban==1, n(10) 
label var y_10_u "Decile of food per capita household consumption (urban only)"
label var y2_10_u "Decile of total per capita household consumption (urban only)"

xtile y_5_n = y_i [aw=wta_hh] if nairobi==1, n(5) 
xtile y2_5_n = y2_i [aw=wta_hh] if nairobi==1, n(5) 
label var y_5_n "Quintile of food per capita household consumption (Nairobi only)"
label var y2_5_n "Quintile of total per capita household consumption (Nairobi only)"

xtile y_5_o = y_i [aw=wta_hh] if nairobi==0&urban==1, n(5) 
xtile y2_5_o = y2_i [aw=wta_hh] if nairobi==0&urban==1, n(5) 
label var y_5_o "Quintile of food per capita household consumption (Other urban)"
label var y2_5_o "Quintile of total per capita household consumption (Other urban)"



tab h01a [iw=weights] // source of drinking water
sum h02a [aw=weights], de // time to get water for drinking
sum h08a [aw=weights], de // cost of drinking water
sum h08e [aw=weights], de // total cost of water

tab h13 [iw=weights] // toilet facility
tab h15 [iw=weights] // toilet shared

tab h24 [iw=weights] // electricity
sum h25 [aw=weights], de // cost of electricity last month
tab h27 [iw=weights] // electricity working


// Access to improved water
gen impwater = 0
replace impwater = 1 if (h01a>=1 & h01a<=6)|h01a==11
replace impwater = . if h01a==.

gen water1 = (h01a==1)
replace water1 = . if h01a==.
gen water2 = (h01a==2)
replace water2 = . if h01a==.
gen water3 = (h01a==3)
replace water3 = . if h01a==.
gen water4 = (h01a==4|h01a==5|h01a==6|h01a==11)
replace water4 = . if h01a==.
gen water5 = (h01a==7|h01a==8|h01a==9|h01a==10|h01a==12)
replace water5 = . if h01a==.

** By province
preserve
	drop if prov==1 & urban==0
	collapse (mean) impwater [iw=weights], by(prov urban)
	replace impwater = impwater * 100
	graph hbar impwater, over(urban) over(prov) asy ///
	title("Access to improved water", size(medium)) ///
	ytitle("Percentage of households with access")
	graph export "${gsdOutput}/C5-Urban/water2006.png", replace 
restore


** by Urban Kenya, Nairobi, and other urban
local title1 "Urban Kenya"
local title2 "Nairobi"
local title3 "Other urban areas"
local y1 y2_10_u
local y2 y2_5_n
local y3 y2_5_o

forvalues i = 1/3 {

	graph bar water*, over(`y`i'') stack ///
		title("`title`i''", size(medium)) ///
		b1title("Rank of per capita household consumption") ///
		legend(order(1 "Piped within dwelling" 2 "Piped outside dwelling" ///
		3 "Public tap" 4 "Other improved" 5 "Non-improved")) ///
		name(a`i', replace) nodraw
	
}

graph combine a1 a2 a3, row(1) xsize(12) iscale(0.9)
graph export "${gsdOutput}/C5-Urban/water_urban2006.png", replace 

// Access to improved sanitation
gen imptoilet = 0
replace imptoilet = 1 if h13==1|h13==2
replace imptoilet = . if h13==.
gen imptoilet2 = 0
replace imptoilet2 = 1 if h13==1|h13==2|h13==4
replace imptoilet2 = . if h13==.

gen toilet1 = (h13==1)
replace toilet1 = . if h13==.
gen toilet2 = (h13==2)
replace toilet2 = . if h13==.
gen toilet3 = (h13==4)
replace toilet3 = . if h13==.
gen toilet4 = (h13==3)
replace toilet4 = . if h13==.
gen toilet5 = (h13==5|h13==6|h13==7)
replace toilet5 = . if h13==.

** By province
preserve
	drop if prov==1 & urban==0
	collapse (mean) imptoilet [iw=weights], by(prov urban)
	replace imptoilet = imptoilet * 100
	graph hbar imptoilet, over(urban) over(prov) asy ///
		title("Access to improved sanitation", size(medium)) ///
		ytitle("Percentage of households with access") ///
		name(a1, replace) nodraw
restore
preserve
	drop if prov==1 & urban==0
	collapse (mean) imptoilet2 [iw=weights], by(prov urban)
	replace imptoilet2 = imptoilet2 * 100
	graph hbar imptoilet2, over(urban) over(prov) asy ///
		title("Covered latrine as improved", size(medium)) ///
		ytitle("Percentage of households with access") ///
		name(a2, replace) nodraw
restore
graph combine a1 a2, xsize(6) iscale(0.7)
graph export "${gsdOutput}/C5-Urban/sanitation2006.png", replace 

** By urban Kenya, Nairobi, and other urban
local title1 "Urban Kenya"
local title2 "Nairobi"
local title3 "Other urban areas"
local y1 y2_10_u
local y2 y2_5_n
local y3 y2_5_o

forvalues i = 1/3 {
		
	graph bar toilet*, over(`y`i'') stack ///
		title("`title`i''", size(medium)) ///
		b1title("Rank of household consumption in urban area") ///
		legend(order(1 "Flush toilet" 2 "VIP latrine" ///
		3 "Covered pit latrine" 4 "Uncovered latrine" 5 "Others")) ///
		name(a`i', replace) nodraw
	

}
graph combine a1 a2 a3, row(1) xsize(12) iscale(0.9)
graph export "${gsdOutput}/C5-Urban/sanitation_urban2006.png", replace 
















