******************************************************
***   FY17-18 Kenya Poverty and Gender Assessment  ***
***   Urbanization Chapter                         ***
***   By Shohei Nakamura                           ***
******************************************************
/*
clear all
global path "C:/Users/WB377460/Documents/KPGA/"
global data "${path}data/"
global graph "${path}graph/"
global output "${path}output/"
global GIS "${path}GIS/"
cd "${path}" 
*/

************************************
***        Data preparation      ***
************************************

/////////////
/* KIHBS05 */
/////////////

use "${gsdDataRaw}/KIHBS05/consumption aggregated data", clear

gen clid = id_clust
gen hhid = id_hh

tempfile temp
preserve
	use "${gsdData}/1-CleanOutput/hh", clear
	keep if kihbs==2005
	keep clid hhid province county poor
	save `temp', replace
restore

merge 1:1 clid hhid using `temp'
drop if _merge==2
drop _merge

gen urban = (rururb==2)

gen year = 2005

gen COUNTY3_ID = .
replace COUNTY3_ID = 1 if county==23 // Turkana
replace COUNTY3_ID = 2 if county==10 // Marsabit
replace COUNTY3_ID = 3 if county==9 // Mandera
replace COUNTY3_ID = 4 if county==8 // Waijir
replace COUNTY3_ID = 5 if county==24 // West Pokot
replace COUNTY3_ID = 6 if county==25 // Samburu
replace COUNTY3_ID = 7 if county==11 // Isiolo 
replace COUNTY3_ID = 8 if county==30 // Baringo
replace COUNTY3_ID = 9 if county==28 // Keiyo-Marakwet
replace COUNTY3_ID = 10 if county==26 // Trans Nzoia 
replace COUNTY3_ID = 11 if county==39 // Bungoma
replace COUNTY3_ID = 12 if county==7 // Garissa
replace COUNTY3_ID = 13 if county==27 // Uasin Gishu
replace COUNTY3_ID = 14 if county==37 // Kakamega 
replace COUNTY3_ID = 15 if county==31 // Laikipia
replace COUNTY3_ID = 16 if county==40 // Busia 
replace COUNTY3_ID = 17 if county==12 // Meru
replace COUNTY3_ID = 18 if county==29 // Nandi
replace COUNTY3_ID = 19 if county==41 // Siaya
replace COUNTY3_ID = 20 if county==32 // Nakuru
replace COUNTY3_ID = 21 if county==38 // Vihiga
replace COUNTY3_ID = 22 if county==18 // Nyandarua
replace COUNTY3_ID = 23 if county==13 // Tharaka
replace COUNTY3_ID = 24 if county==35 // Kericho
replace COUNTY3_ID = 25 if county==42 // Kisumu
replace COUNTY3_ID = 26 if county==19 // Nyeri
replace COUNTY3_ID = 27 if county==4 // Tana River
replace COUNTY3_ID = 28 if county==15 // Kitui 
replace COUNTY3_ID = 29 if county==20 // Kirinyaga
replace COUNTY3_ID = 30 if county==14 // Embu
replace COUNTY3_ID = 31 if county==43 // Homa Bay
replace COUNTY3_ID = 32 if county==36 // Bomet
replace COUNTY3_ID = 33 if county==46 // Nyamira
replace COUNTY3_ID = 34 if county==33 // Narok
replace COUNTY3_ID = 35 if county==45 // Kisii
replace COUNTY3_ID = 36 if county==21 // Muranga
replace COUNTY3_ID = 37 if county==44 // Migori
replace COUNTY3_ID = 38 if county==22 // Kiambu
replace COUNTY3_ID = 39 if county==16 // Machakos
replace COUNTY3_ID = 40 if county==34 // Kajiado
replace COUNTY3_ID = 41 if county==47 // Nairobi
replace COUNTY3_ID = 42 if county==17 // Makueni
replace COUNTY3_ID = 43 if county==5 // Lamu
replace COUNTY3_ID = 110 if county==3 // Kilifi
replace COUNTY3_ID = 111 if county==6 // Taita Taveta
replace COUNTY3_ID = 135 if county==2 // Kwale
replace COUNTY3_ID = 141 if county==1 // Mombasa

apoverty y2_i [aw=wta_pop], varpl(z2_i)
mean poor [aw=wta_pop]
tab poor [fw=round(wta_pop)]
tab poor urban [fw=round(wta_pop)], col
apoverty y2_i [aw=wta_pop] if urban==1, varpl(z2_i)
mean poor [aw=wta_pop] if urban==1

tab urban [fw=round(wta_pop)]

save "${gsdData}/2-AnalysisOutput/KIHBS_master_2005", replace


////////////////
/* KIHBS 2015 */
////////////////

use "${gsdDataRaw}/KIHBS15/poverty", clear

tempfile temp
preserve
	use "${gsdData}/1-CleanOutput/hh", clear
	keep province county
	duplicates drop province county, force
	save `temp', replace
restore

merge m:1 county using `temp', keepusing(province)
drop if _merge==2
drop _merge


gen year = 2015

gen COUNTY3_ID = .
replace COUNTY3_ID = 1 if county==23 // Turkana
replace COUNTY3_ID = 2 if county==10 // Marsabit
replace COUNTY3_ID = 3 if county==9 // Mandera 
replace COUNTY3_ID = 4 if county==8 // Waijir 
replace COUNTY3_ID = 5 if county==24 // West Pokot
replace COUNTY3_ID = 6 if county==25 // Samburu
replace COUNTY3_ID = 7 if county==11 // Isiolo
replace COUNTY3_ID = 8 if county==30 // Baringo
replace COUNTY3_ID = 9 if county==28 // Keiyo-Marakwet
replace COUNTY3_ID = 10 if county==26 // Trans Nzoia
replace COUNTY3_ID = 11 if county==39 // Bungoma
replace COUNTY3_ID = 12 if county==7 // Garissa
replace COUNTY3_ID = 13 if county==27 // Uasin Gishu
replace COUNTY3_ID = 14 if county==37 // Kakamega
replace COUNTY3_ID = 15 if county==31 // Laikipia
replace COUNTY3_ID = 16 if county==40 // Busia
replace COUNTY3_ID = 17 if county==12 // Meru
replace COUNTY3_ID = 18 if county==29 // Nandi
replace COUNTY3_ID = 19 if county==41 // Siaya
replace COUNTY3_ID = 20 if county==32 // Nakuru
replace COUNTY3_ID = 21 if county==38 // Vihiga
replace COUNTY3_ID = 22 if county==18 // Nyandarua
replace COUNTY3_ID = 23 if county==13 // Tharaka
replace COUNTY3_ID = 24 if county==35 // Kericho
replace COUNTY3_ID = 25 if county==42 // Kisumu
replace COUNTY3_ID = 26 if county==19 // Nyeri
replace COUNTY3_ID = 27 if county==4 // Tana River
replace COUNTY3_ID = 28 if county==15 // Kitui
replace COUNTY3_ID = 29 if county==20 // Kirinyaga
replace COUNTY3_ID = 30 if county==14 // Embu
replace COUNTY3_ID = 31 if county==43 // Homa Bay
replace COUNTY3_ID = 32 if county==36 // Bomet
replace COUNTY3_ID = 33 if county==46 // Nyamira
replace COUNTY3_ID = 34 if county==33 // Narok
replace COUNTY3_ID = 35 if county==45 // Kishii
replace COUNTY3_ID = 36 if county==21 // Muranga
replace COUNTY3_ID = 37 if county==44 // Migori
replace COUNTY3_ID = 38 if county==22 // Kiambu
replace COUNTY3_ID = 39 if county==16 // Machakos
replace COUNTY3_ID = 40 if county==34 // Kaijiado
replace COUNTY3_ID = 41 if county==47 // Nairobi
replace COUNTY3_ID = 42 if county==17 // Makueni
replace COUNTY3_ID = 43 if county==5 // Lamu
replace COUNTY3_ID = 110 if county==3 // Kilfi
replace COUNTY3_ID = 111 if county==6 // Taita Taveta 
replace COUNTY3_ID = 135 if county==2 // Kwale
replace COUNTY3_ID = 141 if county==1 // Mombasa

tab urban [fw=round(wta_pop)]

* check poverty
apoverty y2_i [aw=wta_pop], varpl(z2_i)
mean poor [aw=wta_pop]
tab poor [fw=round(wta_pop)]
tab poor urban [fw=round(wta_pop)], col
apoverty y2_i [aw=wta_pop] if urban==1, varpl(z2_i)
mean poor [aw=wta_pop] if urban==1

save "${gsdData}/2-AnalysisOutput/KIHBS_master_2015", replace







