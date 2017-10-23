*Do-file calculates household head poverty profile and runs Wald test on differneces in attributes of poor vs. non poor.

use "${gsdData}/1-CleanOutput/hh.dta" , clear
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
tabout   kihbs using "${gsdOutput}/ch2_headprofile_national.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Headcount_rate) replace
tabout   kihbs if poor==1 using "${gsdOutput}/ch2_headprofile_national.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_poor) append
tabout   kihbs using "${gsdOutput}/ch2_headprofile_national.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

*Household - Head Age Group
tabout  hhage_grp kihbs using "${gsdOutput}/ch2_headprofile_agegrp.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Headcount_rate) replace
tabout  hhage_grp kihbs if poor==1 using "${gsdOutput}/ch2_headprofile_agegrp.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_poor) append
tabout  hhage_grp kihbs using "${gsdOutput}/ch2_headprofile_agegrp.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

*Gender of Household - Head
tabout  malehead kihbs using "${gsdOutput}/ch2_headprofile_malehead.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Headcount_rate) replace
tabout  malehead kihbs if poor==1 using "${gsdOutput}/ch2_headprofile_malehead.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_poor) append
tabout  malehead kihbs using "${gsdOutput}/ch2_headprofile_malehead.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_population) append

*Marital Status of Household - Head
*Marhead is calculated excluding the 77 households in 2005 data where marital status is missing (marhead == 6)
tabout  marhead kihbs if inrange(marhead,1,5) using "${gsdOutput}/ch2_headprofile_marhead.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Headcount_rate) replace
tabout  marhead kihbs if poor==1 & inrange(marhead,1,5)  using "${gsdOutput}/ch2_headprofile_marhead.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_poor) append
tabout  marhead kihbs if inrange(marhead,1,5) using "${gsdOutput}/ch2_headprofile_marhead.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_population) append

*Education Status of Household - Head
tabout  hhedu kihbs using "${gsdOutput}/ch2_headprofile_hhedu.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(HHedu Headcount_rate) replace
tabout  hhedu kihbs if poor==1 using "${gsdOutput}/ch2_headprofile_hhedu.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_poor) append
tabout  hhedu kihbs using "${gsdOutput}/ch2_headprofile_hhedu.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_population) append

*Unemployment Status of Household - Head
tabout  hhunemp kihbs using "${gsdOutput}/ch2_headprofile_hhemploy.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Headcount_rate) replace
tabout  hhunemp kihbs if poor==1 using "${gsdOutput}/ch2_headprofile_hhemploy.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_poor) append
tabout  hhunemp kihbs using "${gsdOutput}/ch2_headprofile_hhemploy.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_population) append

*Employment Sector of Household Head
tabout  hhsector kihbs using "${gsdOutput}/ch2_headprofile_hhsector.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(HHsector Headcount_rate) replace
tabout  hhsector kihbs if poor==1 using "${gsdOutput}/ch2_headprofile_hhsector.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_poor) append
tabout  hhsector kihbs using "${gsdOutput}/ch2_headprofile_hhsector.xls" [aw=wta_pop], c(col) f(1) clab(Distribution_of_population) append

svyset clid [pweight=wta_pop] , strata(strat)

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

putexcel C1=("2005") H1=("2015") B2=("Non-poor") C2=("Poor") D2=("P-value") E2=("Total") G2=("Non-poor") H2=("Poor") I2=("P-value") J2=("Total") using "${gsdOutput}/ch2_headprofile_wald.xls" ,replace
putexcel B3=matrix(hcount_2005) using "${gsdOutput}/ch2_headprofile_wald.xls" ,modify
putexcel D3=matrix(hcount_diff_2005) using "${gsdOutput}/ch2_headprofile_wald.xls" ,modify
putexcel E3=matrix(hcount_tot_2005) using "${gsdOutput}/ch2_headprofile_wald.xls" ,modify
putexcel G3=matrix(hcount_2015) using "${gsdOutput}/ch2_headprofile_wald.xls" ,modify
putexcel I3=matrix(hcount_diff_2015) using "${gsdOutput}/ch2_headprofile_wald.xls" ,modify
putexcel J3=matrix(hcount_tot_2015) using "${gsdOutput}/ch2_headprofile_wald.xls" ,modify


putexcel A3=("HH size") A4=("Dependency ratio") A5=("Share of children (0-4)") A6=("Share of children (5-14)") A7=("Share of males (15-65)") A8=("Share of females (15-65)") A9=("Members - no edu (15+)") A10=("Ave. years sch. (15+)") A11=(">=1 member is literate (15+)") A12=(">=1 member is wage employed") A13=("Diversified HH (1+ Sector)") A14=("Imp. drinking water")  A15=("Improved sanitation")  A16=("Main source light (electricity)")  A17=("HH electricity access")  A18=("HH has garbage collected")  A19=("Owns house")  A20=("Owns land") A21=("Area of ag. land (acres)")  A22=("HH has title")  A23=("HH owns motorcycle")  A24=("HH owns bicycle")  A25=("HH owns radio")  A26=("HH owns cell phone")  A27=("HH owns kerosene stove")  A28=("HH owns charcoal jiko")  A29=("HH owns mosquito net")  A30=("HH owns fridge") A31=("HH owns sofa")  using "${gsdOutput}/ch2_headprofile_wald.xls" ,modify

*Run tabulations of those household heads missing chars
tabout kihbs if mi(agehead) using "${gsdOutput}/ch2_headprofile_national_m.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Headcount_rate) replace

