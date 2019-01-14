clear
set more off 

*** Assign gender of decision maker

************************************************
		*SECTION N: AGRICULTURE HOLDING
************************************************
use "${gsdDataRaw}/KIHBS15/k1", clear
merge m:1 clid hhid using  "${gsdDataRaw}/KIHBS15/hh", keepusing(k01)
keep if _merge == 3

label define YesNo 1 "Yes" 0 "No"
label define YesNoMissing 1 "Yes" 0 "No" 99 "Missing"

egen uhhid= concat(hhid clid)				//Unique HH ID
label var uhhid "Unique HH ID"
rename k01 farmhh							
recode farmhh (2=0)						
replace farmhh = 1 if farmhh == . & k03 != ""		//replace missing
replace farmhh = 0 if farmhh == . & _merge == 2
label var farmhh "Did any HH member engage in crop farming, past 12month"     // This does not seem like accurate information. Check with Habtamu
label value farmhh YesNo
rename k02 parcel_id

**************************************************

*** Find Decision maker gender
gen b01 = k05
drop _merge
merge m:1 clid hhid b01 using "${gsdDataRaw}/KIHBS15/hhm", keepusing(b04 b05_yy)
rename b04 sex_dmaker
rename b05_yy age_dmaker
drop if _merge == 2
drop _merge

*** Find Number of plots
bysort clid hhid: egen Num_plots = max(parcel_id)

*** Calculate Area managed by male/female
bysort clid hhid sex_dmaker: egen area_gender = sum(k06)

*** Crude measure of primary decision maker
bysort clid hhid : egen primary_DM_mode = mode(sex_dmaker)


preserve
collapse (sum) k06, by(uhhid sex_dmaker)
drop if sex_dmaker == .

duplicates tag uhhid k06, gen(tag)

*** 13 HH observations where male and female manage same amount of land drop these observations

drop if tag ==  1

bysort uhhid: egen max_area_gender = max(k06)
gen check3 = 1 if  max_area_gender - k06 < 0.001 & max_area_gender - k06 > -0.001
*** Format change requires above code. We are finding where k06 == max_area_gender 
*** (for some reason, when I try gen check = 1 if k06 == max_area_gender, this does not work properly.
*** These observations specifies who mostly manages land

drop if check3 != 1

*** Only 58 observations deleted. These household members were those where that both male/female managed land, 
*** but the dropped observation were not the primary manager of farm land.

keep uhhid sex_dmaker
rename sex_dmaker primary_DM

tempfile gender_land
save "`gender_land'", replace

restore



merge m:1 uhhid using "`gender_land'"
drop _merge


*** In this way, we are able to identify all but 711 households (10665 HHs are identified). Farm decision makers that 
*** are not identified are for households that may have someone else managing the land (relative,
*** employee, etc). Sometimes, they have identified their spouse as managing the land, but this individual is not
*** part of the survey (for these we can eventually identify gender of the person managing the land,
*** but won't have information on). The 14 observations that were deleted because male and female
*** manage the same amount of land would also lead to observations where no primary decision maker is identified.


replace b01 = 1



merge m:1 clid hhid b01 using "${gsdDataRaw}/KIHBS15/hhm", keepusing(b04 b05_yy)
rename b04 sex_head
rename b05_yy age_head
keep if _merge == 3


*** Sex of HH head matches closely with farm decision maker. Of 10665 households,
*** 10033 households have same gender of primary farm decision maker as HH head.
*** For 632, we have difference in these two.


collapse (first) primary_DM sex_head clid hhid, by(uhhid)
lab val primary_DM B04
lab val sex_head B04


*** Replace primary decicion maker of agrarian household with household head if not identified
replace primary_DM = sex_head if primary_DM == .
count
count if primary_DM == sex_head


save "${gsdData}/2-AnalysisOutput/C4-Rural/primary_DM15.dta", replace

exit
