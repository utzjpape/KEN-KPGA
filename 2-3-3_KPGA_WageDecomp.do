clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* WageDecomposition												*
* -> Oaxaca-Blinder decomposition of gender gap in wages		*
* Isis Gaddis (based on input from Angelo Martelli)             *
*---------------------------------------------------------------*
 
use "$dir_kihbs2015/hhm.dta", clear
merge m:1 clid hhid using "$dir_kihbs2015/hh.dta"
assert _m==3
drop _merge

merge m:1 clid using "$dir_kihbs2015/labweight.dta"
assert _m==3
drop _m

**********Survey Settings***********

svyset clid [pweight=weight], strata(county) 

*************EDUCATION and CERTIFICATE****************

gen education=.
replace education=0 if c02==2
replace education=1 if c10_l==1
replace education=2 if c10_l==2
replace education=3 if c10_l==3
replace education=4 if c10_l==4 
replace education=5 if c10_l==5
replace education=6 if c10_l==6 | c10_l==7
replace education=9 if c10_l==8 | c10_l==96

lab def educ	 	0 "no education" ///
					1 "pre-primary" ///
					2 "primary" ///
					3 "post-primary (vocational)" ///
					4 "secondary" ///
					5 "college (middle-level)" ///
					6 "university graduate or post-graduate" ///
					9 "Madrassa/duksi or other"
					
lab val education educ

gen educationg = education
recode educationg (0=0) (1=0) (2/3=1) (4/5=2) (6=3) (9=4)
					

lab def educg 		0 "none or pre-primary" ///
					1 "primary or post-primary" ///
					2 "secondary or college" ///
					3 "university graduate or post-graduate" ///
					4 "other"
lab val educationg educg
lab var educationg "(own) education"

xi i.educationg, pref(_E)

lab var _Eeducation_1 "primary or post-primary"
lab var _Eeducation_2 "secondary or college"
lab var _Eeducation_3 "university graduate or post-graduate"
lab var _Eeducation_4 "other"

**** wage worker dummy

gen wage=.
replace wage=0 if d10_p!=.
replace wage=1 if (d10_p==1 | d10_p==2)


**********INDUSTRY*********** - only wage workers, there are 38 additional missing from mistake in d16

gen industry = .
replace industry = 1 	if inrange(d16,  111,  322)
replace industry = 2 	if inrange(d16,  510,  990)
replace industry = 3 	if inrange(d16, 1010, 3320)
replace industry = 4 	if inrange(d16, 3510, 3530)
replace industry = 5 	if inrange(d16, 3600, 3900)
replace industry = 6 	if inrange(d16, 4100, 4390)
replace industry = 7 	if inrange(d16, 4510, 4799)
replace industry = 8 	if inrange(d16, 4911, 5320)
replace industry = 9 	if inrange(d16, 5510, 5630)
replace industry = 10 	if inrange(d16, 5811, 6399)
replace industry = 11 	if inrange(d16, 6411, 6630)
replace industry = 12 	if inrange(d16, 6810, 6820)
replace industry = 13 	if inrange(d16, 6910, 7500)
replace industry = 14 	if inrange(d16, 7710, 8299)
replace industry = 15 	if inrange(d16, 8411, 8430)
replace industry = 16 	if inrange(d16, 8510, 8550)
replace industry = 17 	if inrange(d16, 8610, 8890)
replace industry = 18 	if inrange(d16, 9000, 9329)
replace industry = 19 	if inrange(d16, 9411, 9609)
replace industry = 20 	if inrange(d16, 9700, 9820)
replace industry = 21 	if inrange(d16, 9900, 9900)
replace industry=. if wage!=1

lab var industry "ISIC code, Rev. 4 - section-level"

lab define industry  1 "A - Crop and animal production, hunting and related service activities" ///
					 2 "B - Mining and quarrying" ///
					 3 "C - Manufacturing" ///										
					 4 "D - Electricity, gas, steam and air conditioning supply" ///			
					 5 "E - Water supply; sewerage, waste management and remediation activities" ///
					 6 "F - Construction" ///
					 7 "G - Wholesale and retail trade; repair of motor vehicles and motorcycles" ///
					 8 "H - Transportation and storage" ///
					 9 "I - Accomodation and food service activities" ///
					10 "J - Information and communication" ///
					11 "K - Financial and insurance activities" ///
					12 "L - Real estate activities" ///
					13 "M - Professional, scientific and technical activities" ///
					14 "N - Administrative and support service activities" ///
					15 "O - Public administration and defence; compulsory social security" ///
					16 "P - Education" ///
					17 "Q - Human health and social work activities" ///
					18 "R - Arts, entertainment and recreation" ///
					19 "S - Other service activities" ///
					20 "T - Activities of households as employers, undifferentiated" ///	
					21 "U - Activities of extraterritorial organizations and bodies"
lab val industry industry

gen industrygg = industry
recode industrygg (1=1) (2=2) (3=3) (4/6=4) (7=5) (8=6) (9=7) (10=8) (11/12=9) (13/14=10) (15/17=11) (18/21=12)
lab define industrygg 	1 "A - Agriculture" ///
						2 "B - Mining" ///
						3 "C - Manufacturing" ///
						4 "D/E/F - Utilities, construction" ///
						5 "G - Trade" ///
						6 "H - Transport" ///
						7 "I - Accomodation" ///
						8 "J - ICT" ///
						9 "K/L - Finance, real estate" ///
						10 "M/N - Professional, administrative services" ///
						11 "O/Q - Education, health, social security" ///
						12 "R/T - Other services"
lab val industrygg industrygg

gen industryg = industry
recode industryg (1=1) (2/3=2) (4/5=3) (6=2) (7/21=3)
lab define industryg 	1 "Agriculture" ///
						2 "Industry" ///
						3 "Services"
lab val industryg industryg

xi i.industrygg, pref(_L)

lab var _Lindustryg_2 "B - Mining" 
lab var _Lindustryg_3 "C - Manufacturing" 
lab var _Lindustryg_4 "D/E/F - Utilities, construction"
lab var _Lindustryg_5 "G - Trade" 
lab var _Lindustryg_6 "H - Transport" 
lab var _Lindustryg_7 "I - Accomodation" 
lab var _Lindustryg_8 "J - ICT" 
lab var _Lindustryg_9 "K/L - Finance, real estate" 
lab var _Lindustryg_10 "M/N - Professional, administrative services" 
lab var _Lindustryg_11 "O/Q - Education, health, social security" 
lab var _Lindustryg_12 "R/T - Other services"


**************OCCUPATION******************** - only wage workers, there are 38 additional missing from mistake in d16

generate occupation=d15
recode occupation (110/112 120/122 130/133 140/141 150/151 = 1) ///
				  (210/212 220/223 230/238 240/244 250/254 259 260/262 270/275 279 280/282 289 290/296 =2) ///
				  (310/319 320/329 330/334 340/344 350/355 360/369 370/373 390/399=3) ///
				  (411/417 420/423=4) ///
				  (510/512 520/524 530/533 540/543=5) /// 
				  (610/613 620/621 630/631 640/641 650/651 =6) ///
				  (710/712 720/727 730/733 740/746 750/758 760/762 770/773 780/783 =7) ///
				  (810/813 820/825 830/835 840/849 850/852 860/869 870/876 880/884 890/899=8) /// 
				  (910/916 920/923 930/934=9) ///
				  (010/011=10)
				  
			  
					
lab var occupation "Kenya National Occupational Classification Standard (KNOCS)- Major Groups"

lab define occupation 1 "1 -  LEGISLATORS, ADMINISTRATORS AND MANAGERS" ///
					  2 "2 -  PROFESSIONALS" ///
					  3 "3 - TECHNICIANS AND ASSOCIATE PROFESSIONALS" ///										
					  4 "4 - SECRETARIAL, CLERICAL SERVICES AND RELATED WORKERS" ///			
					  5 "5 - SERVICE WORKERS, SHOP AND MARKET SALES WORKERS" ///
					  6 "6 -  SKILLED FARM, FISHERY, WILDLIFE AND RELATED WORKERS" ///
					  7 "7 -  CRAFT AND RELATED TRADES WORKERS" ///
					  8 "8 - PLANT AND MACHINE OPERATORS AND ASSEMBLERS" ///
					  9 "9 - ELEMENTARY OCCUPATIONS" ///
					 10 "10 - ARMED FORCES"
lab val occupation occupation
replace occupation=. if wage!=1
		
xi i.occupation, pref(_O)
gen _Ooccupatio_1 = (occupation==1) if occupation !=.
drop _Ooccupatio_9

lab var _Ooccupatio_1   "1 - Legislators, administrators and managers" 
lab var _Ooccupatio_2   "2 - Professionals"
lab var _Ooccupatio_3   "3 - Technicians and associated professioanls" 								
lab var _Ooccupatio_4   "4 - Secreterial, clerical services and related workers" 	
lab var _Ooccupatio_5   "5 - Service workers, shop and market sales workers" 
lab var _Ooccupatio_6   "6 - Skilled farm, fishery, wildlife and related workers" 
lab var _Ooccupatio_7   "7 - Craft and related trades workers" 
lab var _Ooccupatio_8   "8 - Plant and machine operators and assemblers" 
lab var _Ooccupatio_10 "10 - Armed forces"
		
**************WAGE WORKERS - only wage workers

egen wage_earnings = rowtotal(d26 d27) , m
replace wage_earnings=. if wage!=1

replace wage_earnings = . if wage_earnings == 0  |  wage_earnings == 999998 |  wage_earnings == 999999                       /* zero earnings seem unlikely, plus log not defined */
winsor2 wage_earnings, suffix(_w) cuts(1 99)                                  /* winsorize */
 
lab var wage_earnings              "monthly wage earnings (cash and in kind) from primary job"
lab var wage_earnings_w            "monthly wage earnings (cash and in kind) from primary job (winsorized)"

gen lnwage   = ln(wage_earnings)
gen lnwage_w = ln(wage_earnings_w)

*************HOURS WORKED - only wage workers

rename d18 hours
replace hours=. if wage!=1
lab var hours "usual working hours"

********GENDER***********

rename b04 sex
gen female = (sex==2)

************AGE**********

rename b05_yy age

*********MARRIED 

gen marital = b13
recode marital (1=1) (3=1) (2=2) (4=3) (5=3) (6=4) (7=5) (.=.)
lab def marital 1 "monogamously married or living together" 2 "polygamously married" 3 "separated or divorced" 4 "widow or widower" 5 "never married"
lab val marital marital

xi i.marital, pref(_K)
lab var _Kmarital_2 "polygamously married" 
lab var _Kmarital_3 "separated or divorced" 
lab var _Kmarital_4 "widow or widower" 
lab var _Kmarital_5 "never married"


********URBAN/RURAL

gen urban = (eatype==2)

******************************************************************************OAXACA DECOMPOSITIONS

svy: reg lnwage_w age hours _E* _O* _L* urban if wage==1 &  inrange(age, 15, 64) & female==0
gen sample_m = e(sample)
estimates store wagedecomp_reg_male

svy: reg lnwage_w age hours _E* _O* _L* urban if wage==1 & inrange(age, 15, 64) & female==1
gen sample_f = e(sample)
estimates store wagedecomp_reg_female

gen sample = (sample_f==1 | sample_m==1)

svy: mean lnwage_w age hours _E* _O* _L* urban if wage==1 & inrange(age, 15, 64) & female==0
estimates store wagedecomp_mean_male

svy: mean lnwage_w age hours _E* _O* _L* urban if wage==1 & inrange(age, 15, 64) & female==1
estimates store wagedecomp_mean_female


******** Full model

oaxaca lnwage_w age hours (education: _E*) (industry: _L*) (occupation: _O*) (location: urban) ///
	   if wage==1 & inrange(age, 15, 64) & sample==1, by(female) svy xb noisily 	


outreg2 [wagedecomp_reg_male wagedecomp_reg_female] using "$dir_tables/an_wagedecomp_reg", excel label replace ///
		groupvar(age hours Education _E* Industry _L* Occupation _O* urban) ///
		title("Monthly earnings of employees - regression") ///
		addnote("Dependent variable are log monthly earnings. OLS estimation with survey settings.")

outreg2 [wagedecomp_mean_male wagedecomp_mean_female] using "$dir_tables/an_wagedecomp_mean", excel label replace ///
		groupvar(lnwage_w age hours Education _E* Industry _L* Occupation _O* urban) ///
		title("Monthly earnings of employees - descriptive statistics of dependent and independent variables") ///
		addnote("Estimation with survey settings.")

exit
		  


