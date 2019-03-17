******************************************************
***   FY17-18 Kenya Poverty and Gender Assessment  ***
***   Urbanization Chapter                         ***
***   By Shohei Nakamura                           ***
******************************************************

clear all

**********************************************************
**********                                        ********
**********                DHS 2014                ********
**********                                        ********
**********************************************************

use "${gsdDataRaw}/5-Urban/KEMR70FL", clear // Men data

tab mv024 [fw=mv005] // province
tab smregion mv025 [fw=mv005] // county and urban/rural
table mv022 [fw=mv005], format(%10.0f) // starata (1-92) 
tab mv025 [fw=mv005] // urban

tab mv013 [fw=mv005], missing // age cohort (15-54 yrs)

tab mv103 [fw=mv005] // childhood place of residence
tab mv022 mv103 [fw=mv005]

tab mv104 [fw=mv005], missing // years lived in place of residence
tab mv105 [fw=mv005] // type of place of previous residence 
tab mv022 mv105 [fw=mv005]

gen COUNTY3_ID = .
replace COUNTY3_ID = 1 if smregion==701 // Turkana
replace COUNTY3_ID = 2 if smregion==401 // Marsabit
replace COUNTY3_ID = 3 if smregion==503 // Mandera
replace COUNTY3_ID = 4 if smregion==502 // Waijir
replace COUNTY3_ID = 5 if smregion==702 // West Pokot
replace COUNTY3_ID = 6 if smregion==703 // Samburu
replace COUNTY3_ID = 7 if smregion==402 // Isiolo 
replace COUNTY3_ID = 8 if smregion==705 // Baringo
replace COUNTY3_ID = 9 if smregion==707 // Keiyo-Marakwet
replace COUNTY3_ID = 10 if smregion==704 // Trans Nzoia 
replace COUNTY3_ID = 11 if smregion==803 // Bungoma
replace COUNTY3_ID = 12 if smregion==501 // Garissa
replace COUNTY3_ID = 13 if smregion==706 // Uasin Gishu
replace COUNTY3_ID = 14 if smregion==801 // Kakamega 
replace COUNTY3_ID = 15 if smregion==709 // Laikipia
replace COUNTY3_ID = 16 if smregion==804 // Busia 
replace COUNTY3_ID = 17 if smregion==403 // Meru
replace COUNTY3_ID = 18 if smregion==708 // Nandi
replace COUNTY3_ID = 19 if smregion==601 // Siaya
replace COUNTY3_ID = 20 if smregion==710 // Nakuru
replace COUNTY3_ID = 21 if smregion==802 // Vihiga
replace COUNTY3_ID = 22 if smregion==201 // Nyandarua
replace COUNTY3_ID = 23 if smregion==404 // Tharaka
replace COUNTY3_ID = 24 if smregion==713 // Kericho
replace COUNTY3_ID = 25 if smregion==602 // Kisumu
replace COUNTY3_ID = 26 if smregion==202 // Nyeri
replace COUNTY3_ID = 27 if smregion==304 // Tana River
replace COUNTY3_ID = 28 if smregion==406 // Kitui 
replace COUNTY3_ID = 29 if smregion==203 // Kirinyaga
replace COUNTY3_ID = 30 if smregion==405 // Embu
replace COUNTY3_ID = 31 if smregion==604 // Homa Bay
replace COUNTY3_ID = 32 if smregion==714 // Bomet
replace COUNTY3_ID = 33 if smregion==606 // Nyamira
replace COUNTY3_ID = 34 if smregion==711 // Narok
replace COUNTY3_ID = 35 if smregion==605 // Kisii
replace COUNTY3_ID = 36 if smregion==204 // Muranga
replace COUNTY3_ID = 37 if smregion==603 // Migori
replace COUNTY3_ID = 38 if smregion==205 // Kiambu
replace COUNTY3_ID = 39 if smregion==407 // Machakos
replace COUNTY3_ID = 40 if smregion==712 // Kajiado
replace COUNTY3_ID = 41 if smregion==101 // Nairobi
replace COUNTY3_ID = 42 if smregion==408 // Makueni
replace COUNTY3_ID = 43 if smregion==305 // Lamu
replace COUNTY3_ID = 110 if smregion==303 // Kilifi
replace COUNTY3_ID = 111 if smregion==306 // Taita Taveta
replace COUNTY3_ID = 135 if smregion==302 // Kwale
replace COUNTY3_ID = 141 if smregion==301 // Mombasa



// proportion of recent migrants
gen duration = .
forvalues i = 1/10 {
	replace duration = `i' if mv104==`i'
}
replace duration = 99 if mv104>10 & mv104!=. & mv104!=96
table mv022 duration [fw=mv005], format(%10.0f)

gen migrant4 = (duration<=4)
replace migrant4 = . if duration==.
gen migrant8 = (duration<=8)
replace migrant8 = . if duration==.

gen migrant4u = migrant4 if mv025==1
gen migrant8u = migrant8 if mv025==1
gen migrant4r = migrant4 * -1 if mv025==2
gen migrant8r = migrant8 * -1 if mv025==2

gen prev1 = (mv105==0) // capital, large city
replace prev1 =. if mv105==.
gen prev2 = (mv105==5) // other city/town
replace prev2 =. if mv105==.
gen prev3 = (mv105==3) // countryside
replace prev3 =. if mv105==.
gen prev4 = (mv105==4) // abroad
replace prev4 =. if mv105==.

* share of recent rural-to-urban migrants
gen rtou4 = migrant4u==1 & prev3==1
gen rtou8 = migrant8u==1 & prev3==1
sum rtou4 rtou8
table COUNTY3_ID [aw=mv005], c(mean rtou4 mean rtou8)


** migration pattern at the country level **
gen current = .
replace current = 1 if ((COUNTY3_ID==41|COUNTY3_ID==141|COUNTY3_ID==25)&mv025==1)
replace current = 2 if mv025==1 & current!=1
replace current = 3 if mv025==2

tab mv025 mv105 if migrant4==1 [aw=mv005] // during the last 4 years
tab mv025 mv105 if migrant8==1 [aw=mv005] // during the last 8 years

tab current mv105 if migrant4==1 [aw=mv005] // during the last 4 years
tab current mv105 if migrant8==1 [aw=mv005] // during the last 8 years


** Export to GIS **
preserve
	gen nu = 1 if mv025==1 // urban
	gen nr = 1 if mv025==2 // rural
	replace migrant4r = migrant4r * -1
	replace migrant8r = migrant8r * -1
	gen pop = 1
	
	forvalues i = 1/4 {
		gen prev_u`i' = prev`i'
		replace prev_u`i' = . if mv025!=1 | migrant4!=1
		gen prev_r`i' = prev`i'
		replace prev_r`i' = . if mv025!=2 | migrant4!=1
	}
	collapse (sum) migrant4u migrant8u migrant4r migrant8r nu nr prev_u* prev_r* pop ///
		[fw=mv005], by(smregion COUNTY3_ID)
	
	replace migrant8u = (migrant8u - migrant4u) / nu * 100
	replace migrant4u = migrant4u / nu * 100
	gen migrant4_8u = migrant4u + migrant8u
	replace migrant8r = (migrant8r - migrant4r) / nr * 100
	replace migrant4r = migrant4r / nr * 100
	gen migrant4_8r = migrant4r + migrant8r
	
	gen total_u = prev_u1 + prev_u2 + prev_u3 + prev_u4
	gen total_r = prev_r1 + prev_r2 + prev_r3 + prev_r4
	
	forvalues i = 1/4 {
		qui replace prev_u`i' = prev_u`i' / total_u * 100
		qui replace prev_r`i' = prev_r`i' / total_r * 100
	}
	gen prev_u1_2 = prev_u1 + prev_u2
	
	export excel using "${gsdOutput}/C5-Urban/kenya_DHS_GIS.xls", ///
		first(var) replace 
	
restore

preserve
	keep if migrant8==1
	
	forvalues i = 1/4 {
		gen prev_u`i' = prev`i'
		replace prev_u`i' = . if mv025!=1 
		gen prev_r`i' = prev`i'
		replace prev_r`i' = . if mv025!=2 
	}
	collapse (sum) prev_u* prev_r* ///
		[fw=mv005], by(smregion COUNTY3_ID)
	
	gen total_u = prev_u1 + prev_u2 + prev_u3 + prev_u4
	gen total_r = prev_r1 + prev_r2 + prev_r3 + prev_r4
	
	forvalues i = 1/4 {
		qui replace prev_u`i' = prev_u`i' / total_u * 100
		qui replace prev_r`i' = prev_r`i' / total_r * 100
	}
	gen prev_u1_2 = prev_u1 + prev_u2
	gen prev_r1_2 = prev_r1 + prev_r2
	
	export excel using "${gsdOutput}/C5-Urban/kenya_DHS_GIS2.xls", ///
		first(var) replace 
	
restore

preserve
	gen nu = 1 if mv025==1 // urban
	gen nr = 1 if mv025==2 // rural
	
	collapse (sum) migrant4u migrant8u migrant4r migrant8r nu nr ///
		[fw=mv005], by(smregion)
	
	replace migrant8u = (migrant8u - migrant4u) / nu * 100
	replace migrant4u = migrant4u / nu * 100
	replace migrant8r = (migrant8r - migrant4r) / nr * 100
	replace migrant4r = migrant4r / nr * 100
	gen sort = (migrant4u + migrant8u) * -1
	
	graph hbar migrant4u migrant8u migrant4r migrant8r, ///
		stack over(smregion, sort(sort)) ///
		title("Duration of residence", size(medium)) ///
		ytitle("% of men in the county") ///
		legend(order(1 "Rural to urban: <4 years" ///
		2 "Rural to urban: 4-8 years" 3 "Urban to rural: <4 years" ///
		4 "Urban to rural: 4-8 years") ///
		size(small) col(1) position(3)) ///
	name(a1, replace) nodraw
restore
graph combine a1, ysize(6) iscale(0.6)
graph export "${gsdOutput}/C5-Urban/duration2014.png", replace 


// previous residence

tempfile temp
preserve
	keep if mv025==1
	keep if migrant8==1 // recent migrants
	collapse (sum) prev* [fw=mv005], by(smregion)
	gen total = prev1 + prev2 + prev3 + prev4
	forvalues i = 1/4 {
		qui replace prev`i' = prev`i' / total * 100
	}
	gen sort = prev3 * -1
	keep smregion sort
	save `temp', replace
restore

preserve
	keep if mv025==1 // urban
	keep if migrant8==1 // recent migrants
	gen n = 1
	collapse (sum) prev* [fw=mv005], by(smregion)
	gen total = prev1 + prev2 + prev3 + prev4
	forvalues i = 1/4 {
		qui replace prev`i' = prev`i' / total * 100
	}
	gen sort = prev3 * -1
	graph hbar prev1 prev2 prev4 prev3, stack over(smregion, sort(sort)) ///
		title("(a) Current urban residents", size(medsmall)) ///
		ytitle("% of men arrived during the last 8 years", size(small)) ///
		legend(order(1 "Nairobi/Mombasa/Kisumu" 2 "Other towns" ///
		4 "Countryside" 3 "Abroad") ///
		size(small) col(1)) ///
		name(a1, replace) nodraw
restore
preserve
	keep if mv025==2 // rural
	keep if migrant8==1 // recent migrants
	gen n = 1
	collapse (sum) prev* [fw=mv005], by(smregion)
	gen total = prev1 + prev2 + prev3 + prev4
	forvalues i = 1/4 {
		qui replace prev`i' = prev`i' / total * 100
	}
	//merge 1:1 smregion using `temp'
	//keep if _merge==3
	gen sort = prev3 * -1
	graph hbar prev1 prev2 prev4 prev3, stack over(smregion, sort(sort)) ///
		title("(b) Current rural residents", size(medsmall)) ///
		ytitle("% of men arrived during the last 8 years", size(small)) ///
		legend(order(1 "Nairobi/Mombasa/Kisumu" 2 "Other towns" ///
		4 "Countryside" 3 "Abroad") ///
		size(small) col(1)) ///
		name(a2, replace) nodraw
restore
graph combine a1 a2, ysize(5) iscale(0.6)
graph export "${gsdOutput}/C5-Urban/prev2014.png", replace 


** Wealth index **
tab mv190, gen(ai_)
gen migrant = .
replace migrant = 1 if duration>=0 & duration<4
replace migrant = 2 if duration>=4 & duration<8
replace migrant = 3 if duration>=8 
gen RtoU = prev3
replace RtoU = 0 if mv105==.

preserve
	keep if mv025==1 // currently in urban
	collapse (mean) ai_* [aw=mv005], by(migrant RtoU)
	export excel using "${gsdOutput}/C5-Urban/kenya_DHS.xlsx", ///
		sheet("urban") sheetreplace first(var)
restore
preserve
	keep if COUNTY3_ID == 41 // currently in Nairobi
	collapse (mean) ai_* [aw=mv005], by(migrant RtoU)
	export excel using "${gsdOutput}/C5-Urban/kenya_DHS.xlsx", ///
		sheet("nairobi") sheetreplace first(var)
restore
preserve
	keep if COUNTY3_ID == 141 // currently in Mombasa
	collapse (mean) ai_* [aw=mv005], by(migrant RtoU)
	export excel using "${gsdOutput}/C5-Urban/kenya_DHS.xlsx", ///
		sheet("mombasa") sheetreplace first(var)
restore
preserve
	drop if COUNTY3_ID == 41 | COUNTY3_ID == 141 // currently in other urban
	collapse (mean) ai_* [aw=mv005], by(migrant RtoU)
	export excel using "${gsdOutput}/C5-Urban/kenya_DHS.xlsx", ///
		sheet("other") sheetreplace first(var)
restore
preserve
	keep if mv025==2 // currently in rural
	collapse (mean) ai_* [aw=mv005]
	export excel using "${gsdOutput}/C5-Urban/kenya_DHS.xlsx", ///
		sheet("rural") sheetreplace first(var)
restore








