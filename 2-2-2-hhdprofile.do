*-------------------------------------------------------------------------*
* Chapter 2: THE EXTENT AND EVOLUTION OF POVERTY AND INEQUALITY IN KENYA
*	Household profile
*By Nduati Kariuki (nkariuki@worldbank.org)
*-------------------------------------------------------------------------*
*Do-file calculates household head poverty profile and runs Wald test on differneces in attributes of poor vs. non poor.
use "${gsdData}/1-CleanOutput/hh.dta" , clear
svyset clid [pw=wta_hh] , strata(strata)

*Distribution of poor and distribution of population are calculated as proportions of those where values are not missing. 

*Age of household head groups. (13 - 24 , 25-59, 60+)
gen hhage_grp = 1 if inrange(agehead,13,24)
replace hhage_grp = 2 if inrange(agehead,25,59)
replace hhage_grp = 3 if inrange(agehead,60,97)

label define lhhage 1"13 - 24" 2 "25 - 69" 3"60+" , replace
label values hhage_grp lhhage

label define lmalhead 0"Female" 1 "Male" 3"60+" , replace
label values malehead lmalhead


*broader age group (working age)
egen shama15_65 = rsum(shama15_24 shama25_65)
egen shafe15_65 = rsum(shafe15_24 shafe25_65)

*National numbers
tabout   kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_national.xls" ,svy c(mean poor se poor) sum f(3 3 3 3)  clab(Headcount_rate SE) sebnone replace
tabout   kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_headprofile_national.xls" [aw=wta_hh],c(col) f(1)  clab(Distribution_of_poor) append
tabout   kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_national.xls" [aw=wta_hh],c(col) f(1)  clab(Distribution_of_population) append

*Household - Head Age Group
tabout  hhage_grp kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_agegrp.xls" [aw=wta_hh],svy c(mean poor se poor) sum f(3 3 3 3)  clab(Headcount_rate SE) sebnone replace
tabout  hhage_grp kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_headprofile_agegrp.xls" [aw=wta_hh],c(col) f(1)  clab(Distribution_of_poor) append
tabout  hhage_grp kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_agegrp.xls" [aw=wta_hh],c(col) f(1)  clab(Distribution_of_population) append

*Gender of Household - Head
tabout  malehead kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_malehead.xls" [aw=wta_hh], svy c(mean poor se poor) sum f(3 3 3 3)  clab(Headcount_rate SE) sebnone replace
tabout  malehead kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_headprofile_malehead.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_poor) append
tabout  malehead kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_malehead.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_population) append

*Marital Status of Household - Head
*Marhead is calculated excluding the 77 households in 2005 data where marital status is missing (marhead == 6)
tabout  marhead kihbs if inrange(marhead,1,5) using "${gsdOutput}/C2-Trends/ch2_headprofile_marhead.xls" [aw=wta_hh], svy c(mean poor se poor) sum f(3 3 3 3)  clab(Headcount_rate SE) sebnone replace
tabout  marhead kihbs if poor==1 & inrange(marhead,1,5)  using "${gsdOutput}/C2-Trends/ch2_headprofile_marhead.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_poor) append
tabout  marhead kihbs if inrange(marhead,1,5) using "${gsdOutput}/C2-Trends/ch2_headprofile_marhead.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_population) append

*Education Status of Household - Head
tabout  hhedu kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhedu.xls" [aw=wta_hh], svy c(mean poor se poor) sum f(3 3 3 3)  clab(Headcount_rate SE) sebnone replace
tabout  hhedu kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_headprofile_hhedu.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_poor) append
tabout  hhedu kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhedu.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_population) append

*Unemployment Status of Household - Head
tabout  hhunemp kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhemploy.xls" [aw=wta_hh], svy c(mean poor se poor) sum f(3 3 3 3)  clab(Headcount_rate SE) sebnone replace
tabout  hhunemp kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_headprofile_hhemploy.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_poor) append
tabout  hhunemp kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhemploy.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_population) append

*Employment Sector of Household Head
tabout  hhsector kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhsector.xls" [aw=wta_hh], svy c(mean poor se poor) sum f(3 3 3 3)  clab(Headcount_rate SE) sebnone replace
tabout  hhsector kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_headprofile_hhsector.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_poor) append
tabout  hhsector kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhsector.xls" [aw=wta_hh], c(col) f(1) clab(Distribution_of_population) append

*Table showing ownership of assets / access to utilities given non-poor vs. poor plus testing if difference is statistcally significant
foreach year in 2005 2015 {
	foreach var of varlist hhsize depen sha0_4 sha5_14 shama15_65 shafe15_65 no_edu  aveyrsch literacy hwage dive impwater impsan elec_light elec_acc garcoll ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa  {
		svy: mean `var' if kihbs==`year' , over(poor)
		matrix `var' = e(b)
		test [`var']0 = [`var']1
		matrix `var'_diff = `r(p)'
		
		svy: mean `var' if kihbs==`year'
		matrix `var'_tot = e(b)
}
matrix hcount_`year' = [hhsize \ depen \ sha0_4 \ sha5_14 \ shama15_65 \ shafe15_65 \ no_edu \  aveyrsch \ literacy \ hwage \ dive \ impwater \ impsan \ elec_light \ elec_acc \ garcoll \ ownhouse \ ownsland \ area_own \ title \ motorcycle \ bicycle \ radio \ cell_phone \ kero_stove \ char_jiko \ mnet \ fridge \ sofa]

matrix hcount_diff_`year' = [hhsize_diff \ depen_diff \ sha0_4_diff \ sha5_14_diff \ shama15_65_diff \ shafe15_65_diff \ no_edu_diff \  aveyrsch_diff \ literacy_diff \ hwage_diff \ dive_diff \ impwater_diff \ impsan_diff \ elec_light_diff \ elec_acc_diff \ garcoll_diff \ ownhouse_diff \ ownsland_diff \ area_own_diff \ title_diff \ motorcycle_diff \ bicycle_diff \ radio_diff \ cell_phone_diff \ kero_stove_diff \ char_jiko_diff \ mnet_diff \ fridge_diff \ sofa_diff]

matrix hcount_tot_`year' = [hhsize_tot \ depen_tot \ sha0_4_tot \ sha5_14_tot \ shama15_65_tot \ shafe15_65_tot \ no_edu_tot \  aveyrsch_tot \ literacy_tot \ hwage_tot \ dive_tot \ impwater_tot \ impsan_tot \ elec_light_tot \ elec_acc_tot \ garcoll_tot \ ownhouse_tot \ ownsland_tot \ area_own_tot \ title_tot \ motorcycle_tot \ bicycle_tot \ radio_tot \ cell_phone_tot \ kero_stove_tot \ char_jiko_tot \ mnet_tot \ fridge_tot \ sofa_tot]
}
putexcel set "${gsdOutput}/C2-Trends/ch2_headprofile_wald.xls" , replace
putexcel A3=("HH size") A4=("Dependency ratio") A5=("Share of children (0-4)") A6=("Share of children (5-14)") A7=("Share of males (15-65)") A8=("Share of females (15-65)") A9=("Members - no edu (15+)") A10=("Ave. years sch. (15+)") A11=(">=1 member is literate (15+)") A12=(">=1 member is wage employed") A13=("Diversified HH (1+ Sector)") A14=("Imp. drinking water")  A15=("Improved sanitation")  A16=("Main source light (electricity)")  A17=("HH electricity access")  A18=("HH has garbage collected")  A19=("Owns house")  A20=("Owns land") A21=("Area of ag. land (acres)")  A22=("HH has title")  A23=("HH owns motorcycle")  A24=("HH owns bicycle")  A25=("HH owns radio")  A26=("HH owns cell phone")  A27=("HH owns kerosene stove")  A28=("HH owns charcoal jiko")  A29=("HH owns mosquito net")  A30=("HH owns fridge") A31=("HH owns sofa")
putexcel C1=("2005") H1=("2015") B2=("Non-poor") C2=("Poor") D2=("P-value") E2=("Total") G2=("Non-poor") H2=("Poor") I2=("P-value") J2=("Total")
putexcel B3=matrix(hcount_2005)
putexcel D3=matrix(hcount_diff_2005)
putexcel E3=matrix(hcount_tot_2005)
putexcel G3=matrix(hcount_2015)
putexcel I3=matrix(hcount_diff_2015)
putexcel J3=matrix(hcount_tot_2015)

*As above for rural households only
foreach year in 2005 2015 {
	foreach var of varlist hhsize depen sha0_4 sha5_14 shama15_65 shafe15_65 no_edu  aveyrsch literacy hwage dive impwater impsan elec_light elec_acc garcoll ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa  {
		svy: mean `var' if kihbs==`year' & urban==0 , over(poor)
		matrix `var' = e(b)
		test [`var']0 = [`var']1
		matrix `var'_diff = `r(p)'
		
		svy: mean `var' if kihbs==`year' & urban==0
		matrix `var'_tot = e(b)
}
matrix hcount_`year' = [hhsize \ depen \ sha0_4 \ sha5_14 \ shama15_65 \ shafe15_65 \ no_edu \  aveyrsch \ literacy \ hwage \ dive \ impwater \ impsan \ elec_light \ elec_acc \ garcoll \ ownhouse \ ownsland \ area_own \ title \ motorcycle \ bicycle \ radio \ cell_phone \ kero_stove \ char_jiko \ mnet \ fridge \ sofa]

matrix hcount_diff_`year' = [hhsize_diff \ depen_diff \ sha0_4_diff \ sha5_14_diff \ shama15_65_diff \ shafe15_65_diff \ no_edu_diff \  aveyrsch_diff \ literacy_diff \ hwage_diff \ dive_diff \ impwater_diff \ impsan_diff \ elec_light_diff \ elec_acc_diff \ garcoll_diff \ ownhouse_diff \ ownsland_diff \ area_own_diff \ title_diff \ motorcycle_diff \ bicycle_diff \ radio_diff \ cell_phone_diff \ kero_stove_diff \ char_jiko_diff \ mnet_diff \ fridge_diff \ sofa_diff]

matrix hcount_tot_`year' = [hhsize_tot \ depen_tot \ sha0_4_tot \ sha5_14_tot \ shama15_65_tot \ shafe15_65_tot \ no_edu_tot \  aveyrsch_tot \ literacy_tot \ hwage_tot \ dive_tot \ impwater_tot \ impsan_tot \ elec_light_tot \ elec_acc_tot \ garcoll_tot \ ownhouse_tot \ ownsland_tot \ area_own_tot \ title_tot \ motorcycle_tot \ bicycle_tot \ radio_tot \ cell_phone_tot \ kero_stove_tot \ char_jiko_tot \ mnet_tot \ fridge_tot \ sofa_tot]
}
putexcel set "${gsdOutput}/C2-Trends/ch2_headprofile_wald_rural.xls" , replace
putexcel A3=("HH size") A4=("Dependency ratio") A5=("Share of children (0-4)") A6=("Share of children (5-14)") A7=("Share of males (15-65)") A8=("Share of females (15-65)") A9=("Members - no edu (15+)") A10=("Ave. years sch. (15+)") A11=(">=1 member is literate (15+)") A12=(">=1 member is wage employed") A13=("Diversified HH (1+ Sector)") A14=("Imp. drinking water")  A15=("Improved sanitation")  A16=("Main source light (electricity)")  A17=("HH electricity access")  A18=("HH has garbage collected")  A19=("Owns house")  A20=("Owns land") A21=("Area of ag. land (acres)")  A22=("HH has title")  A23=("HH owns motorcycle")  A24=("HH owns bicycle")  A25=("HH owns radio")  A26=("HH owns cell phone")  A27=("HH owns kerosene stove")  A28=("HH owns charcoal jiko")  A29=("HH owns mosquito net")  A30=("HH owns fridge") A31=("HH owns sofa")
putexcel C1=("2005") H1=("2015") B2=("Non-poor") C2=("Poor") D2=("P-value") E2=("Total") G2=("Non-poor") H2=("Poor") I2=("P-value") J2=("Total")
putexcel B3=matrix(hcount_2005)
putexcel D3=matrix(hcount_diff_2005)
putexcel E3=matrix(hcount_tot_2005)
putexcel G3=matrix(hcount_2015)
putexcel I3=matrix(hcount_diff_2015)
putexcel J3=matrix(hcount_tot_2015)

*As above for urban households
foreach year in 2005 2015 {
	foreach var of varlist hhsize depen sha0_4 sha5_14 shama15_65 shafe15_65 no_edu  aveyrsch literacy hwage dive impwater impsan elec_light elec_acc garcoll ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa  {
		svy: mean `var' if kihbs==`year' & urban==1 , over(poor)
		matrix `var' = e(b)
		test [`var']0 = [`var']1
		matrix `var'_diff = `r(p)'
		
		svy: mean `var' if kihbs==`year' & urban==1
		matrix `var'_tot = e(b)
}
matrix hcount_`year' = [hhsize \ depen \ sha0_4 \ sha5_14 \ shama15_65 \ shafe15_65 \ no_edu \  aveyrsch \ literacy \ hwage \ dive \ impwater \ impsan \ elec_light \ elec_acc \ garcoll \ ownhouse \ ownsland \ area_own \ title \ motorcycle \ bicycle \ radio \ cell_phone \ kero_stove \ char_jiko \ mnet \ fridge \ sofa]

matrix hcount_diff_`year' = [hhsize_diff \ depen_diff \ sha0_4_diff \ sha5_14_diff \ shama15_65_diff \ shafe15_65_diff \ no_edu_diff \  aveyrsch_diff \ literacy_diff \ hwage_diff \ dive_diff \ impwater_diff \ impsan_diff \ elec_light_diff \ elec_acc_diff \ garcoll_diff \ ownhouse_diff \ ownsland_diff \ area_own_diff \ title_diff \ motorcycle_diff \ bicycle_diff \ radio_diff \ cell_phone_diff \ kero_stove_diff \ char_jiko_diff \ mnet_diff \ fridge_diff \ sofa_diff]

matrix hcount_tot_`year' = [hhsize_tot \ depen_tot \ sha0_4_tot \ sha5_14_tot \ shama15_65_tot \ shafe15_65_tot \ no_edu_tot \  aveyrsch_tot \ literacy_tot \ hwage_tot \ dive_tot \ impwater_tot \ impsan_tot \ elec_light_tot \ elec_acc_tot \ garcoll_tot \ ownhouse_tot \ ownsland_tot \ area_own_tot \ title_tot \ motorcycle_tot \ bicycle_tot \ radio_tot \ cell_phone_tot \ kero_stove_tot \ char_jiko_tot \ mnet_tot \ fridge_tot \ sofa_tot]
}
putexcel set "${gsdOutput}/C2-Trends/ch2_headprofile_wald_urban.xls" , replace
putexcel A3=("HH size") A4=("Dependency ratio") A5=("Share of children (0-4)") A6=("Share of children (5-14)") A7=("Share of males (15-65)") A8=("Share of females (15-65)") A9=("Members - no edu (15+)") A10=("Ave. years sch. (15+)") A11=(">=1 member is literate (15+)") A12=(">=1 member is wage employed") A13=("Diversified HH (1+ Sector)") A14=("Imp. drinking water")  A15=("Improved sanitation")  A16=("Main source light (electricity)")  A17=("HH electricity access")  A18=("HH has garbage collected")  A19=("Owns house")  A20=("Owns land") A21=("Area of ag. land (acres)")  A22=("HH has title")  A23=("HH owns motorcycle")  A24=("HH owns bicycle")  A25=("HH owns radio")  A26=("HH owns cell phone")  A27=("HH owns kerosene stove")  A28=("HH owns charcoal jiko")  A29=("HH owns mosquito net")  A30=("HH owns fridge") A31=("HH owns sofa")
putexcel C1=("2005") H1=("2015") B2=("Non-poor") C2=("Poor") D2=("P-value") E2=("Total") G2=("Non-poor") H2=("Poor") I2=("P-value") J2=("Total")
putexcel B3=matrix(hcount_2005)
putexcel D3=matrix(hcount_diff_2005)
putexcel E3=matrix(hcount_tot_2005)
putexcel G3=matrix(hcount_2015)
putexcel I3=matrix(hcount_diff_2015)
putexcel J3=matrix(hcount_tot_2015)

*Select hh characteristics, asset ownership and access to services by province.
tabout  province kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhprovchars.xls", svy c(mean hhsize se hhsize) sum f(3 3)  clab(hhsize SE) sebnone replace
foreach var of varlist depen  aveyrsch  literacy  impwater impsan  elec_light  elec_acc {
	tabout  province kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhprovchars.xls" , svy c(mean `var' se `var') sum f(3 3)  clab(`var' SE) sebnone append
}
*Select hh characteristics, asset ownership and access to services by NEDI category.
tabout  nedi kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhnedichars.xls", svy c(mean hhsize se hhsize) sum f(3 3)  clab(hhsize SE) sebnone replace
foreach var of varlist depen  aveyrsch  literacy  impwater impsan  elec_light  elec_acc {
	tabout  nedi kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhnedichars.xls" , svy c(mean `var' se `var') sum f(3 3)  clab(`var' SE) sebnone append
}
*Select hh characteristics, asset ownership and access to services by poverty category.
tabout  poor kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhpovchars.xls", svy c(mean hhsize se hhsize) sum f(3 3)  clab(hhsize SE) sebnone replace
foreach var of varlist depen  aveyrsch  literacy  impwater impsan  elec_light  elec_acc {
	tabout  poor kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhpovchars.xls" , svy c(mean `var' se `var') sum f(3 3)  clab(`var' SE) sebnone append
}
*National & Rural / Urban
tabout kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhrurbchars.xls", svy c(mean hhsize se hhsize) sum f(3 3)  clab(hhsize SE) sebnone replace
tabout urban kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhrurbchars.xls", svy c(mean hhsize se hhsize) sum f(3 3)  clab(hhsize SE) sebnone append

foreach var of varlist depen  aveyrsch  literacy  impwater impsan  elec_light  elec_acc {
	tabout  kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhrurbchars.xls" , svy c(mean `var' se `var') sum f(3 3)  clab(`var' SE) sebnone append
	tabout  urban kihbs using "${gsdOutput}/C2-Trends/ch2_headprofile_hhrurbchars.xls" , svy c(mean `var' se `var') sum f(3 3)  clab(`var' SE) sebnone append
}

*The following file requires An externally generated income dataset
clear
set more off 

global path "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Income\" 

global in "$path\Data"
global out "$path\Data"
global log "$path\Do files"
global dofile "$path\Do files"

use "${gsdData}/1-CleanOutput/hh.dta" , clear
*match & master as / households do not have a reported income source
merge 1:1 kihbs clid hhid using "${gsdData}/1-CleanOutput/Income05_15.dta" , assert(match master) keep(match master) nogen keepusing(income_source* Ag_NAg_source* maj_income_s*)
svyset clid [pw=wta_hh], strata(strata)
drop Ag_NAg_source1 Ag_NAg_source2 Ag_NAg_source3

gen femhead = (malehead==0)
forvalues i = 1/4 {
	gen hhedu`i'= (hhedu==`i')
	replace hhedu`i'=. if mi(hhedu)
}
gen aginc1 = (Ag_NAg_source4==0)
replace aginc1 = . if mi(Ag_NAg_source4)
gen aginc2 = (Ag_NAg_source4==1) & !mi(Ag_NAg_source4)
replace aginc2 = . if mi(Ag_NAg_source4)
gen aginc3 = (Ag_NAg_source4==2) & !mi(Ag_NAg_source4)
replace aginc3 = . if mi(Ag_NAg_source4)

label var hhedu1 "No education dummy"
label var hhedu2 "At least some primary educ. dummy"	
label var hhedu3 "At least some secondary educ. dummy"	
label var hhedu4 "At least some tertiary educ. dummy"	

label var aginc1 "non. agricultural income dummy"
label var aginc2 "agricultural income dummy"
label var aginc3 "mixed income dummy"


local controls1 "agehead femhead hhsize depen urban aveyrsch hhedu1 hhedu2 hhedu3 hhedu4 aginc1 aginc2 aginc3 impwater impsan elec_light elec_acc radio cell_phone kero_stove char_jiko mnet fridge sofa"

/*
foreach year in 2005 2015 			{
	foreach var of local controls1 {
		svy: mean `var' if kihbs==`year' , over(poor)
		matrix `var' = e(b)
		test [`var']0 = [`var']1
		matrix `var'_diff = `r(p)'
		
		svy: mean `var' if kihbs==`year'
		matrix `var'_tot = e(b)
}
matrix wald_`year' = [agehead \ femhead \ hhsize \ depen \ urban \ aveyrsch \ impwater \ impsan \ elec_light \ elec_acc \ radio \ cell_phone \ kero_stove \ char_jiko \ mnet \ fridge \ sofa]
matrix pdiff_`year' = [agehead_diff \ femhead_diff \ hhsize_diff \ depen_diff \ urban_diff \ aveyrsch_diff \ impwater_diff \ impsan_diff \ elec_light_diff \ elec_acc_diff \ radio_diff \ cell_phone_diff \ kero_stove_diff \ char_jiko_diff \ mnet_diff \ fridge_diff \ sofa_diff]
}
*/
foreach year in 2005 2015 			{
	foreach var of local controls1 {
		svy: mean `var' if kihbs==`year' , over(poor)
		matrix `var' = e(b)
		test [`var']0 = [`var']1
		matrix `var'_diff = `r(p)'
		
		svy: mean `var' if kihbs==`year'
		matrix `var'_tot = e(b)
}
matrix wald_`year' = [agehead \ femhead \ hhsize \ depen \ urban \ aveyrsch \ hhedu1 \ hhedu2 \ hhedu3\ hhedu4 \ aginc1 \ aginc2 \ aginc3 \ impwater \ impsan \ elec_light \ elec_acc \ radio \ cell_phone \ kero_stove \ char_jiko \ mnet \ fridge \ sofa]
matrix pdiff_`year' = [agehead_diff \ femhead_diff \ hhsize_diff \ depen_diff \ urban_diff \ aveyrsch_diff \ hhedu1_diff \ hhedu2_diff \ hhedu3_diff \ hhedu4_diff \ aginc1_diff \ aginc2_diff \ aginc3_diff \  impwater_diff \ impsan_diff \ elec_light_diff \ elec_acc_diff \ radio_diff \ cell_phone_diff \ kero_stove_diff \ char_jiko_diff \ mnet_diff \ fridge_diff \ sofa_diff]
}
putexcel set "${gsdOutput}/C2-Trends/ch2_headprofile_wald2.xls" , replace
putexcel A3=("Age of head") A4=("Female HH head") A5=("HH size") A6=("Share of dependents") A7=("Urban") A8=("Ave. years sch. (15+)") A9=("No education") A10=("Primary ed. (some / complete)") A11=("Seondary ed. (some / complete)") A12=("Tertiary ed. (some / complete)") A13=("Non ag. income only ") A14=("ag. income only") A15=("Mixed income") A16=("Improved water") A17=("Improved sanitation") A18=("Main source light (electricity)") A19=("HH electricity access")  A20=("HH owns radio")  A21=("HH owns cell phone")  A22=("HH owns kerosene stove")  A23=("HH owns charcoal jiko")  A24=("HH owns mosquito net")  A25=("HH owns fridge") A26=("HH owns sofa")
putexcel B3=matrix(wald_2005)
putexcel D3=matrix(pdiff_2005)
putexcel F3=matrix(wald_2015)
putexcel H3=matrix(pdiff_2015)

* Regression
gen double lnrcons = ln(rcons)
local controls2 "agehead femhead hhsize depen urban aveyrsch i.hhedu i.Ag_NAg_source4 impwater impsan elec_light elec_acc radio cell_phone kero_stove char_jiko mnet fridge sofa i.province"
reg lnrcons `controls2' if kihbs==2005 , robust
estimates store reg_lncons_0_2005
reg lnrcons `controls2' if kihbs==2015 , robust
estimates store reg_lncons_0_2015
esttab reg_lncons_0_2005 using "${gsdOutput}/C2-Trends/ch2_reg_lncons_0_2005.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(r2 N, fmt(%9.2f %12.0f) labels("R-squared" "Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace
esttab reg_lncons_0_2015 using "${gsdOutput}/C2-Trends/ch2_reg_lncons_0_2015.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(r2 N, fmt(%9.2f %12.0f) labels("R-squared" "Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace

