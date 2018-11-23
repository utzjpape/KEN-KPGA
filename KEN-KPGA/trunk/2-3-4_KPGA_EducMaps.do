clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* EducMaps														*
* -> maps with indicators of educational performance			*
*	 (based on input data from Simon Lange)						*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

set more off

local indicatorlist stunting u5mortality ger_primary ger_secondary u10_provider uwezo_math		/* list of indicators */

local stunting 		"stunting"
local ger_primary 	"ger primary"
local ger_secondary "ger secondary"
local u10_provider 	"u10 taken to provider kihbs"
local uwezo_math 	"uwezomath proficiency 10yrs"

foreach ind of local indicatorlist {

	import excel "$dir_educstats/for_isis.xlsx", sheet(``ind'') clear first	/* import from excel */
	
	if "`ind'"=="uwezo_math" {
		rename County countyname									/* deal with inconsistencies in variable names */
	}
	
	cap rename meanbm bm
	cap rename meanbf bf
	
	drop if countyname==""											/* 1 empty row in first two sheets */
	
	gen cname = lower(countyname)
	replace cname="elgeyo marakwet" if cname=="elgeyo marak"		/* deal with inconsistencies in county spellings */
	replace cname="elgeyo marakwet" if cname=="emc"
	replace cname="trans nzoia" 	if cname=="trans-nzoia"
	replace cname="nakuru"			if cname==" nakuru"
	replace cname="nakuru" 			if cname=="nakuru "
	replace cname="tharaka"			if cname=="tharaka nithi"
	
	rename bm `ind'_m												/* male */
	rename bf `ind'_f												/* female */
	gen    `ind'_g = `ind'_f/`ind'_m								/* gender gap */
	
	if "`ind'"=="stunting" {										/* need to county id in one file to match with gis data, correct 1 code switch */
		destring county, replace
		rename county county_code
		replace county_code=603 if cname=="homa bay"
		replace county_code=604 if cname=="migori"
		
		keep county_code cname `ind'_m `ind'_f `ind'_g 
	}
	
	if "`ind'"!="stunting" {
		keep cname `ind'_m `ind'_f `ind'_g 
	}

	tempfile `ind'
	save ``ind''
}


foreach ind of local indicatorlist {								/* merge all files */
	if "`ind'"=="stunting" {
		use ``ind'', clear
	}
	else {
		merge 1:1 cname using ``ind''
		assert _m==3
		drop _m
	}
}

drop if county==1													/* drop 'all kenya' statistics */

* preserve

merge 1:1 county_code using "$dir_gisnew/counties_3.dta"				/* merge on gis data */
assert _m==3
drop _m

cd "$dir_gisnew"
merge 1:1 _ID using "County Polys.dta"
drop if _m==2
drop _m

spmap ger_primary_g using "KenyaCountyPolys_coord.dta", id(_ID)  clmethod(custom) fcolor(RdBu) clbreaks(0.7 0.8 0.9 1 1.1 1.2 1.3) ///
	  title(Gender parity index) subtitle(Gross Primary Enrollment Rates)  legend(position(8))
graph save "$dir_graphs/Fig3-4_left - ger_primary_formated_cleared", replace	

spmap ger_secondary_g using "KenyaCountyPolys_coord.dta", id(_ID)  clmethod(custom) fcolor(RdBu) clbreaks(0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5) ///
	  title(Gender parity index) subtitle(Gross Secondary Enrollment Rates)  legend(position(8))
graph save "$dir_graphs/Fig3-4_center - ger_secondary_formated_cleared", replace		

spmap uwezo_math_g using "KenyaCountyPolys_coord.dta", id(_ID)  clmethod(custom) fcolor(RdBu) clbreaks(0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8) ///
	  title(Gender parity index) subtitle(Uwezo - Math proficiency)  legend(position(8))
graph save "$dir_graphs/Fig3-4_right - uwezo_math_formated_cleared", replace	

exit

