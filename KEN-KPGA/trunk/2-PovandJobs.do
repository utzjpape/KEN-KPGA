*Creating variables required (Education level of head)
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
keep clid hhid b* c* d*
merge 1:1 clid hhid b01 using "${gsdData}/1-CleanTemp/demo15.dta" , assert(match) nogen keepusing(age famrel)
merge m:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs15_16.dta", assert(match) keepusing(poor wta_pop wta_hh strata province urban) nogen
drop b05_yy 


*drop observations where age <3 OR age filter is either no or don't know. 
drop if age<3
*Edu vars for the hhead
keep if famrel == 1

*=====================================*
*Education level of head
*=====================================*
*In order to maintain data structure one variable will be created for the highest level ed. completed.
gen yrsch = .
*pre-priamry
replace yrsch = 0 if c10_l==1
*Primary
replace yrsch = 1 if c10_l==2 & c10_g==1
replace yrsch = 2 if c10_l==2 & c10_g==2
replace yrsch = 3 if c10_l==2 & c10_g==3
replace yrsch = 4 if c10_l==2 & c10_g==4
replace yrsch = 5 if c10_l==2 & c10_g==5
replace yrsch = 6 if c10_l==2 & c10_g==6
replace yrsch = 7 if c10_l==2 & c10_g==7
replace yrsch = 8 if c10_l==2 & c10_g==8
*post-primary
replace yrsch = 8 if c10_l==3
*Secondary
replace yrsch = 9 if c10_l==4 & c10_g==1
replace yrsch = 10 if c10_l==4 & c10_g==2
replace yrsch = 11 if c10_l==4 & c10_g==3
replace yrsch = 12 if c10_l==4 & c10_g==4
replace yrsch = 13 if c10_l==4 & c10_g==5
replace yrsch = 14 if c10_l==4 & c10_g==6
*college (middle-level)
replace yrsch = 14 if c10_l==5
*University undergraduate
replace yrsch = 15 if c10_l==6 & c10_g==1
replace yrsch = 16 if c10_l==6 & c10_g==2
replace yrsch = 17 if c10_l==6 & c10_g==3
replace yrsch = 18 if c10_l==6 & c10_g==4
*capping years of undergraduate ed. at 4
replace yrsch = 18 if c10_l==6 & inlist(c10_g,5,6)
*University postgraduate (any postgraduate)
replace yrsch = 19 if c10_l==7
*according to skip pattern c04a is missing if individual never attended school
replace yrsch = 0 if c02 == 2
*Madrasa / Duksi + Other are set to none (~<1%)
replace yrsch = 0 if inlist(c10_l,8,96)
*certain respondents do not have a highest grade / level completed. but do have a level currently attending
replace yrsch = 0 if c06_l==1 & mi(c10_l)

gen educhead = yrsch
lab var educhead "Years of schooling of head"
gen hhedu=.
* No Edu
replace hhedu=1 if educhead==0  
* Primary (some/comp)		
replace hhedu=2 if (educhead>0 & educhead<=8) 
* Secondary (some/comp)
replace hhedu=3 if (educhead>8 & educhead<=14)	
* Tertiary (some/comp)
replace hhedu=4 if (educhead>14)				
replace hhedu=5 if (educhead==.)
lab var hhedu "HH head edu level"
lab def edulev 1 "No Education" 2 "Primary (some/comp.)" 3 "Secondary(some/comp.)" 4 "Tertiary(some/comp.)" 5"Other / Not Known / Missing" , replace
lab val hhedu edulev

*=====================================*
*Skill level of head (derived from d15)
*=====================================*
*Skilled categories from 1 to 4 (namely Managers, Professionals, Technicians and associate professionals, and Clerical support workers)
*Unskilled from 5 to 9 (namely Service and sales workers, Skilled agricultural, forestry and fishery workers, Craft and related trades workers, Plant and machine operators, and assemblers, Elementary occupations)
gen hhskill = .
replace hhskill = 1 if inrange(d15,110,423)
replace hhskill = 2 if inrange(d15,510,934)
replace hhskill = 3 if mi(hhskill)

label define lskill 1"Skilled" 2"Unskilled" 3"Unknown" , replace
label values hhskil lskill
label var hhskil "Skill level of HH head"
*=====================================*
*Employment type  of head (derived from d10_p)
*=====================================*
gen empstat=.
*wage employee   
replace empstat=1 if (inlist(d10_p,1,2))  
*self employed			
replace empstat=2 if (inlist(d10_p,3,4))  
*unpaid family
replace empstat=3 if (d10_p==6)
*apprentice
replace empstat=4 if (d10_p==7)
*Other / not known / missing*
replace empstat=5 if (inlist(d10_p,5,8,96)) | d10_p==.  

lab def empstat 1 "Wage employed" 2 "Self employed" 3 "Unpaid fam. worker" 4 "Apprentice" 5 "Other / Not Known / Missing status" , replace
label values empstat empstat
label var empstat "Employement type of HH head"
*=====================================*
*Private / public sector status  of head (derived from d17)
*=====================================*
*Private sector employers  - Private sector enterprise, International NGO ,Local NGO/CBO ,Faith based organization, Self emplyed - modern, Informal sector jua kali (employed),	Self employed -  informal, Small scale agriculture (employed), Self small scale agriculture, Pastoralist activities (employed), Self pastoralist activities, Individual/private household
gen employer = 1 if inrange(d17,8,20)
*Public sector employers - Civil service ministries	Judiciary ,Parliament, Commissions, State owned entrprise/institution ,Teachers service commission (TSC),County government
replace employer = 2  if inrange(d17,1,7)
*Others
replace employer = 3 if inlist(d17,96,.)
label define lemployer 1"Private" 2"Public" 3"Others / Not Known / Missing" , replace
label values employer lemployer

*=====================================*
*Industrial sector (derived from d16) - list included in interviewer manual is incorrect. ISIC rev 4 is correct https://unstats.un.org/unsd/cr/registry/isic-4.asp
*=====================================*
/*
*Agriculture and Forestry
gen ind_sector = 1 if inrange(d16,1000,1999) | inrange(d16,100,199)
*Mining and Quarrying
replace ind_sector = 2 if inrange(d16,2001,2999) | inrange(d16,200,299)
*Manufacturing
replace ind_sector = 3 if inrange(d16,3001,3999) | inrange(d16,300,399)
*Electricity and Water
replace ind_sector = 4 if inrange(d16,4001,4999) | inrange(d16,400,499)
*Construction
replace ind_sector = 5 if inrange(d16,5001,5999) | inrange(d16,500,599)
*Wholesale and Retail trade
replace ind_sector = 6 if inrange(d16,6001,6999) | inrange(d16,600,699)
*Transport and Communication
replace ind_sector = 7 if inrange(d16,7001,7999) | inrange(d16,700,799)
*Finance, Insurance and Real estate
replace ind_sector = 8 if inrange(d16,8001,8999) | inrange(d16,800,899)
*Community and Social services
replace ind_sector = 9 if inrange(d16,9000,9999) | inrange(d16,900,999)
assert !mi(ind_sector) if !mi(d16)
*Not known / Missing
replace ind_sector = 10 if mi(d16)
label define lsector 1"Agriculture and Forestry" 2"Mining and Quarrying" 3"Manufacturing" 4"Electricity and Water" 5"Construction" 6"Wholesale and Retail trade" 7"Transport and Communication" 8"Finance, Insurance and Real estate" 9"Community and Social services" 10"Not known / Missing" , replace
label values ind_sector lsector
*/

*Employment sectors
gen occ_sector = .
replace occ_sector = 1 if inrange(d16,111 , 322 )
replace occ_sector = 2 if inrange(d16,510 , 3900 )
replace occ_sector = 3 if inrange(d16,1010 , 3320 )
replace occ_sector = 4 if inrange(d16,4100 , 4390 )
replace occ_sector = 5 if inrange(d16,4610 , 4799 ) | inlist(d16,4510,4530)
replace occ_sector = 6 if inrange(d16,9511,9529) | inlist(d16,4520,4540) | inrange(d16,4911,5320)
replace occ_sector = 7 if inrange(d16,5510,5630)
replace occ_sector = 8 if inrange(d16,6910,8299) | inrange(d16,9000,9329) | inrange(d16,8411,8413) | inrange(d16,8421,8423)
replace occ_sector = 9 if inrange(d16,8510 , 8890 ) | d16==8430 
replace occ_sector = 10 if inrange(d16,9601,9609) | inrange(d16,5811,6820) | inrange(d16,9411,9499) | inrange(d16,9700,9900)
replace occ_sector = 11 if mi(occ_sector)

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
label define lsector 11 "Not Known / Missing"	 , modify


label values occ_sector lsector
gen sector =  .
replace sector = 1 if inlist(occ_sector,1)
replace sector = 2 if inlist(occ_sector,2,3)
replace sector = 3 if inlist(occ_sector,5,6,7,8,9,10)
replace sector = 4 if occ_sector==4

lab var sector "Sector of occupation"
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction",  replace
lab val sector sector

svyset clid [pweight = wta_hh]  , strata(strata)
**=====================================*
*1) Household head skill level and education level by occupational sector
**=====================================*
tabout hhskill if occ_sector==1  using "${gsdOutput}/povandjobs1.xls"  ,svy npos(col) c(freq) clab(Freq) replace
tabout hhedu if occ_sector==1 using "${gsdOutput}/povandjobs1.xls"  ,svy npos(col) c(freq) clab(Freq) append
forvalues i = 2/11 {
	tabout hhskill if occ_sector==`i'  using "${gsdOutput}/povandjobs1.xls"  ,svy npos(col) c(freq) clab(Freq) append
	tabout hhedu if occ_sector==`i' using "${gsdOutput}/povandjobs1.xls"  ,svy npos(col) c(freq) clab(Freq) append
} 

*statistics below are to be done for the population instead of households
svyset, clear
svyset clid [pweight = wta_pop]  , strata(strata)
**================================================*
*2) Occupational sector by rural / urban classification
**================================================*
tabout occ_sector if urban==0  using "${gsdOutput}/povandjobs2.xls"  ,svy npos(col) c(freq) clab(Freq) replace
tabout occ_sector if urban==1 using "${gsdOutput}/povandjobs2.xls"  ,svy npos(col) c(freq) clab(Freq) append
**================================================*
*3) Occupational sector by province
**================================================*
tabout occ_sector province using "${gsdOutput}/povandjobs3.xls"  ,svy npos(col) c(freq) clab(Freq) replace

**================================================*
*4) Poverty status by head of household sex
**================================================*
tabout b04 poor using "${gsdOutput}/povandjobs4.xls"  ,svy npos(col) c(freq) clab(Freq) replace
**================================================*
*5) Poverty status by head of household ed. status
**================================================*
tabout hhedu poor  using "${gsdOutput}/povandjobs5.xls"  ,svy npos(col) c(freq) clab(Freq) replace
**================================================*
*6) Poverty status by head of household occupation (private/public)
**================================================*
tabout employer poor using "${gsdOutput}/povandjobs6.xls"  ,svy npos(col) c(freq) clab(Freq) replace
**================================================*
*7) Poverty status by head of household occupation (sector - large)
**================================================*
tabout occ_sector poor using "${gsdOutput}/povandjobs7.xls"  ,svy npos(col) c(freq) clab(Freq) replace
**================================================*
*8) Poverty status by urban/rural
**================================================*
tabout urban poor  using "${gsdOutput}/povandjobs8.xls"  ,svy npos(col) c(freq) clab(Freq) replace
**================================================*
*9) Poverty status by province
**================================================*
tabout province poor  using "${gsdOutput}/povandjobs9.xls"  ,svy npos(col) c(freq) clab(Freq) replace
**================================================*
*10) Poverty status by household head skill level
**================================================*
tabout hhskill poor  using "${gsdOutput}/povandjobs10.xls"  ,svy npos(col) c(freq) clab(Freq) replace


***================================================*
**================================================*
*Requsted by Johan for KEU
*occupational sector by headcount rate / prop. & number of households / prop. & number of individuals
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
svyset clid [pweight = wta_pop]  , strata(strata)
**================================================*
*11) Headcount rate by occupational sector and KIHBS year
**================================================*
replace hhsector = 5 if mi(hhsector)
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction" 5"Unemployed / NILF",  replace
label values hhsector sector

tabout kihbs hhsector  using "${gsdOutput}/povandjobs11.xls"  ,svy c(mean poor se poor) sum clab(Headcount SE) sebnone f(3) replace
tabout kihbs hhsector using "${gsdOutput}/povandjobs11.xls"  ,svy c(freq) clab(Population) f(1) append
svyset , clear
svyset clid [pweight = wta_hh]  , strata(strata)
tabout kihbs hhsector  using "${gsdOutput}/povandjobs11.xls"  ,svy c(freq) clab(Households) f(1) append

tabout poor hhsector  if kihbs==2015 using "${gsdOutput}/povandjobs11.xls"  ,svy npos(col) c(col) clab(Freq_`i') f(3) append

