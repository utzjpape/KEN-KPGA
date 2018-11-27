*************************************************
*********KENYA Poverty and Rural Livelihood******
*************************************************

/*
Action: Data Cleaning
Author: Habtamu Fuje 
Date: 2017
KIHBS, 2005/6
*/


************************************************
		*SECTION N: AGRICULTURE HOLDING
************************************************
use "${gsdDataRaw}/KIHBS05/Section N Agriculture Holding", clear
egen uhhid= concat(id_clust id_hh)				//Unique HH ID
label var uhhid "Unique HH ID"
rename n01 farmhh
recode farmhh (2=0)
label var farmhh "Did any HH member engage in crop farming, past 12month"
label define YesNo 1 "Yes" 0 "No"


*Decision Maker on Plots
recode n04 (3/11=4)
forvalue p=1/3{									//Decision on Three main parcels
gen dmaker_p`p'=n04 if n_id==`p'
replace dmaker_p`p'=. if dmaker_p`p'==0			//Invalid ID
recode dmaker_p`p' (3/98=3)						//Other HH members (not Head or spouse)
label var dmaker_p`p' "Who/ID makes production (input & cropping) decision on parcel `p'?" 
}
label var dmaker_p3 "Who/ID makes production (input & cropping) decision on parcel 3-11?" 
label define dmakerl 1 "Head" 2 "Spouse" 3 "Others" 
label value dmaker_p* dmakerl
*Plot Size and Value
replace n05=n05*0.404686			//Acre to hectare
egen nparcels=count(n_id), by(uhhid)
label var nparcels  "Number of parcels owned by the HH"
egen cland=sum(n05), by(uhhid)
label var cland "Area of cultivated land, in hectare"
egen oland=sum(n05) if n09==1, by(uhhid)
replace oland=0 if n09!=1
label var oland "Area of cultivated land owned by the HH (hectare)"
egen vland=sum(n13), by(uhhid)
label var vland "Sell/Purchase value of cultivated land"
egen e_rland=sum(n14), by(uhhid)
label var e_rland "Rental expense on rented/leased land, past 12month"
*Irrigation
gen irrigation=(n15>=1 & n15<=12)						//Is the plot irrigated
egen nirrigated=sum(irrigation), by(uhhid)				//Number of irrigated parcels
label var nirrigated "Number of irrigated parcels, count"
egen airrigated=sum(n05) if irrigation==1, by(uhhid)	
replace airrigated=0 if irrigation != 1					
label var airrigated "Area (hectare) of irrigated cultivated land"
drop irrigation
*Inorganic Fertilizer
recode n20 (2=0)

egen nifertilizer=sum(n20), by(uhhid)				//Number of  parcels treated with inorganic fertilizer
label var nifertilizer "Number of parcels treated with inorganic fertilizer"
egen aifertilizer=sum(n05) if n20==1, by(uhhid)		//Area of cultivated land treated with inorganic fertilizer
replace aifertilizer=0 if n20!=1
label var aifertilizer "Area (hectare) of cultivated land treated with inorganic fertilizer"
recode n24 (2=0)
egen nofertilizer=sum(n24), by(uhhid)				//Number of  parcels treated with organic fertilizer
label var nofertilizer "Number of parcels treated with organic fertilizer"
egen aofertilizer=sum(n05) if n24==1, by(uhhid)		//Area of cultivated land treated with organic fertilizer
replace aofertilizer=0 if n24!=1
label var aofertilizer "Area (hectare) of cultivated land treated with organic fertilizer"

*Expenditure on Inputs (other than land)
		*Operating exp:
		
	
egen e_irrigation=sum(n18), by(uhhid)					//Expenditure on irrigation
label var e_irrigation "Expenditure on irrigation"
egen e_ifertilizer=sum(n22), by(uhhid)					//Exp on inorganic fertilizer					
label var e_ifertilizer "Expenditure on inorganic fertilizer"
egen e_ofertilizer=sum(n25), by(uhhid)					//Exp on inorganic fertilizer					
label var e_ofertilizer "Expenditure on organic fertilizer"
gen e_fertilizer=e_ifertilizer+e_ofertilizer			//Exp on org & inorg fertilizre
label var e_fertilizer "Expenditure on (org & inorg) fertilizer"
egen e_pesticide=sum(n26_a), by(uhhid)					//Exp on Pesticide
egen e_fuel=sum(n26_b), by(uhhid)						//Exp on Fuel
egen e_lubricant=sum(n26_c), by(uhhid)					//Exp on Lubricants
egen e_electric=sum(n26_d), by(uhhid)					//Exp on Electricity
egen e_mrepair=sum(n26_e), by(uhhid)					//Exp on Machine repair
egen e_plough=sum(n26_f), by(uhhid)						//Exp on Tractor/Oxen ploughing cost
egen e_tools=sum(n26_g), by(uhhid)						//Exp on Purchase of small farm implments/tools
egen e_frepair=sum(n26_j), by(uhhid)					//Exp on Repair of farm (?)
egen e_labor=sum(n26_h), by(uhhid)						//Exp on Labor
egen e_others=sum(n26_i), by(uhhid)						//Exp on Other inputs
foreach var in pesticide fuel lubricant electric plough tools labor{
label var e_`var' "Total expenditure on `var', past 12 months"
} 
label var e_mrepair "Total expenditure on ag machine repair, past 12 months"
label var e_frepair "Total expenditure on farm(?) repair, past 12 months"
label var e_others "Total expenditure on other ag inputs, past 12 months"
		*Fixed Costs:
egen e_land_acq=sum(n27_a), by(uhhid)					//Exp on Land Reclamation,clearance etc.
label var e_land_acq "Expenditure on land acquisition (reclamation, clearnce etc.), past 12 months"
egen e_treecrop=sum(n27_b), by(uhhid)					//Exp on Establishment of longterm crops: coffee, cotton etc
label var e_treecrop "Expenditure on establishing longterm/tree crop (coffee, cotton etc.), past 12 months"
egen e_equip=sum(n27_c), by(uhhid)					//Exp on Purchase of mechanical equipment: tractor
label var e_equip "Expenditure on mechanical equipment (like tractor), past 12 months"
 
#delimit ;
local firtsnm farmhh nparcels dmaker_p1 dmaker_p2 dmaker_p3 cland oland 
		nirrigated airrigated nifertilizer aifertilizer nofertilizer 
		aofertilizer e_rland e_irrigation e_ifertilizer e_ofertilizer 
		e_fertilizer e_pesticide e_fuel e_lubricant e_electric 
		e_mrepair e_plough e_tools e_frepair e_labor e_others e_land_acq 
		e_treecrop e_equip;
collapse (firstnm) `firtsnm', by(uhhid);
#delimit cr 
save "${gsdData}/2-AnalysisOutput/C4-Rural/c_Section N", replace
save "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding05.dta", replace


************************************************
		*SECTION O: AGRICULTURE OUTPUT
************************************************
use "${gsdDataRaw}/KIHBS05/Section O Agriculture Output", clear
egen uhhid= concat(id_clust id_hh)				//Unique HH ID
label var uhhid "Unique HH ID"
*merge m:1 uhhid using "${gsdDataRaw}/KIHBS05/c_Section A"
*drop _merge
merge m:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Section N.dta"
drop _merge
ren (id_clust id_hh) (clid hhid)

merge m:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs05_06.dta", keepus(wta_pop poor prov)
ren (clid hhid) (id_clust id_hh)

keep if _merge == 3
drop _merge

*Cost of seed
egen e_seed=rowtotal(o08 o11)
label var e_seed "Expenditure on seed and seedling" 
*Major Crop Categories:
gen crop_category=1 if (o02>=1 & o02<=14) //Maize & Cereals
replace crop_category=2 if (o02>=15 & o02<=19) //Tubers Roots
replace crop_category=3 if (o02>=28 & o02<=43) //Beans, Legumes, Nuts
replace crop_category=4 if (o02>=21 & o02<=27) | (o02>=51 & o02<=59) //Fruits and Vegetables
replace crop_category=5 if (o02==75 | o02==76) //Tea and Coffee
replace crop_category=6 if (o02>=71 & o02<=74) //Other Cash Crops (sugarcane/tobacco/cotton)
replace crop_category=7 if crop_category == . & n01 == 1 & o02 != . //Other Crops

label define c_cropl 1 "Maize & Other Cereals" 2 "Tubers & Roots" 3 "Beans, Legumes & Nuts" 4 "Fruits & Vegetables"	///
					 5 "Tea & Coffee" 6 "Other Cash Crops" 7 "Other Crops"
label value crop_category c_cropl
						
						
*Major crops:
rename o02 crop
gen m_crop=crop
recode m_crop (1=101) (2=102) (3/5=103) (8/11=104) (12=105) (19=106) ///
			  (32=107) (35=108) (75=109) (76=110)
replace m_crop=. if m_crop==999 | m_crop<=80								//Old codes	
label define m_cropl 101 "White Maize" 102 "Hybride Maize" 103 "Other Maize" ///
					104 "Millet" 105 "Sorghum" 106 "Potatoes" 107 "Beans"   ///
					108 "Cow peas" 109 "Tea" 110 "Coffee"
label value m_crop m_cropl	
				
*Land covered by crop category:
replace o04=o04*0.404686			//Acre to hectare
bysort uhhid: egen area_total = sum(o04)
qui forvalues j=1/7{
egen land_crop_ar`j'=sum(o04) if crop_category==`j', by(uhhid)
}


rename land_crop_ar1 land_ar_MaizeCereals
rename land_crop_ar2 land_ar_TubersRoots
rename land_crop_ar3 land_ar_BeansLegumesNuts
rename land_crop_ar4 land_ar_FruitsVegetables
rename land_crop_ar5 land_ar_TeaCoffee
rename land_crop_ar6 land_ar_OtherCash
rename land_crop_ar7 land_ar_OtherCrops

label var land_ar_MaizeCereals "The amount of land allocated to Maize and other Cereals"
label var land_ar_TubersRoots "The amount of land allocated to Tuber and Roots"
label var land_ar_BeansLegumesNuts "The amount of land allocated to Beans/Legumes/Nuts"
label var land_ar_FruitsVegetables "The amount of land allocated to Fruits and Vegetables"
label var land_ar_TeaCoffee "The amount of land allocated to Tea and Coffee"
label var land_ar_OtherCash "The amount of land allocated to Other Cash Crops"
label var land_ar_OtherCrops "The amount of land allocated to Other Crops"


*Land covered by major crops:
qui forvalues j=101/110{
egen land_crop`j'=sum(o04) if m_crop==`j', by(uhhid)
}
egen land_crop101_103=sum(o04) if m_crop>=101 & m_crop<=103, by(uhhid)


*Harvest and Disposal:
qui foreach j in 13 14 15 19 20 21 22 23{	//Convert volume to kg
replace o`j'_1=o`j'_1*50 if o`j'_2==2		//50kg bag to kg
replace o`j'_1=o`j'_1*90 if o`j'_2==3		//90kg bag to kg
replace o`j'_1=o`j'_1*1000 if o`j'_2==4		//tons to kg
replace o`j'_1=. if o`j'_2>=6 & o`j'_2<=10	//Unknown units, replace volume with missing values
}
* 13 = harvested	14 = consumed	15 = sold	19 = payments	20 = stored		21 = seeds	22 = gift	23 = lost/wasted

qui foreach j in 13 14 15 19 20 21 22 23{		//Convert unit code to kg
replace o`j'_2=1 if o`j'_2>=2 & o`j'_2<=4		//Covert unit 50/90kg bags and tons to kg
replace o`j'_2=. if o`j'_2>=6 & o`j'_2<=10		//Unknown unit code	
}


gen harvested = o13_1
gen consumed = o14_1
gen sold = o15_1
gen sale_rev = o16
gen seeds = o21_1
gen payments = o19_1
gen stored = o20_1
gen donations = o22_1
gen lost_wasted = o23_1


gen harvested_2 = o13_2
gen consumed_2 = o14_2
gen sold_2 = o15_2
gen sale_rev_2 = o16
gen seeds_2 = o21_2
gen payments_2 = o19_2
gen stored_2 = o20_2
gen donations_2 = o22_2
gen lost_wasted_2 = o23_2

*replace consumed == . if consumed_2 != sold_2 & consumed_2 != . & sold_2 != .  // Replace Mismatched units Quantity consumed with . (only 32 observations)
*replace consumed_2 == . if consumed_2 != sold_2 & consumed_2 != . & sold_2 != .  // Replace Mismatched units Quantity consumed with . (only 32 observations)

*replace sold == . if sold_2 != harvested_2 & harvested_2 != . & sold_2 != .  // Replace Mismatched units Quantity consumed with . (only 32 observations)
*replace sold_2 == . if sold_2 != sold_2 & harvested_2 != . & sold_2 != .  // Replace Mismatched units Quantity consumed with . (only 32 observations)


*Production and Yield: Major Crops
qui forvalues j=101/110{
egen production_crop`j'=sum(o13_1)if m_crop==`j', by(uhhid)
gen yield_crop`j'=production_crop`j'/land_crop`j'
}
egen production_crop101_103=sum(o13_1) if m_crop>=101 & m_crop<=103, by(uhhid)
gen yield_crop101_103=production_crop101_103/land_crop101_103
qui foreach var in land production yield{
rename `var'_crop101 `var'_whitemaize
rename `var'_crop102 `var'_hybridemaize
rename `var'_crop103 `var'_othermaize
rename `var'_crop104 `var'_millet
rename `var'_crop105 `var'_sorghum
rename `var'_crop106 `var'_potatoes
rename `var'_crop107 `var'_beans
rename `var'_crop108 `var'_cowpeas
rename `var'_crop109 `var'_tea
rename `var'_crop110 `var'_coffee
}
rename production_crop101_103 production_allMaize
rename land_crop101_103 land_allMaize
rename yield_crop101_103 yield_allMaize

#delimit ;
foreach crop in whitemaize hybridemaize othermaize allMaize 
		millet sorghum potatoes beans cowpeas tea coffee{;
label var land_`crop' "The amount of land allocated to `crop'";
label var production_`crop' "The total volume of `crop' production, at HH level";
label var yield_`crop' "The yield (kg/ha) of `crop'";	
};
#delimit cr
drop yield_potatoes yield_beans yield_cowpeas 	///
	 yield_tea yield_coffee 					//Drop yield for non-cereals 
	/*Note: Yield for non-cereal items might not 
	be interesting to analyze */

*Output price:
	*Price at HH level
gen price_h=o16/o15_1											//HH level, Price at which crops were sold
label var price_h "Price of major crops, HH level (from sales data)"
qui foreach c in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 ///
		21 22 23 24 25 26 27 28 30 31 32 33 34 35 36 37 38 40 41 ///
		42 43 50 51 52 53 54 55 56 57 58 59 60 61 62 ///
		70 71 72 73 74 75 76 79 80{
sum price_h if o15_2==1 & crop==`c', det
replace price_h=r(p99) if price_h>r(p99) & price_h!=. ///
			& o15_2==1 & crop==`c' 								//Trim price at 99th percentile
}

	*Price at Cluster level
foreach j in 1 5{												//Unit code
egen price_c`j'=median(price_h) if o15_2==`j',by(id_clust crop)	//Cluster level, Price at which crops were sold
}  //This uses units of sales, but not many HHs/Clusters have sales unit
foreach j in 1 5{												//Unit code
egen price_cp`j'=median(price_c`j'),by(id_clust crop o13_2)		//Cluster level, Price at which crops were sold
}	//This uses units of production, apply sales price to all production (by unit)
gen price_c=price_cp1											//Price in Kg			
replace price_c=price_cp5 if price_cp1==.						//Price per count
label var price_c "Price of major crops, cluster median (by units of production/sales)"
drop price_c1 price_c5
	*Price at Province level
foreach j in 1 5{												//Unit code
egen price_p`j'=median(price_h) if o15_2==`j',by(crop prov)		//Province level, Price at which crops were sold
}  //This uses units of sales, but not many HHs/Clusters have sales unit
foreach j in 1 5{												//Unit code
egen price_pp`j'=median(price_p`j'), by(crop o13_2)				//Province level, Price at which crops were sold
}	//This uses units of production, apply sales price to all production (by unit)
gen price_p=price_pp1											//Price in Kg			
replace price_p=price_pp5 if price_pp1==.						//Price per count
label var price_p "Price of major crops, province median"
drop price_p1 price_p5
	*Price at National level
foreach j in 1 5{												//Unit code
egen price_n`j'=median(price_h) if o15_2==`j',by(crop)			//National level, Price at which crops were sold
}  //This uses units of sales, but not many HHs/Clusters have sales unit
foreach j in 1 5{												//Unit code
egen price_np`j'=median(price_n`j'), by(crop o13_2)				//National level, Price at which crops were sold
}	//This uses units of production, apply sales price to all production (by unit)
gen price_n=price_np1											//Price in Kg
replace price_n=price_np5 if price_np1==.						//Price per count
label var price_n "Price of major crops, national median"
drop price_n1 price_n5
gen price=price_h									//Price, HH/Cluster/Province/National level
replace price=price_c if price==.					//Price, HH/Cluster/Province/National level
replace price=price_p if price==.					//Price, HH/Cluster/Province/National level
replace price=price_n if price==.					//Price, HH/Cluster/Province/National level
label var price "Price of major crops, HH leve if available, otherwise median at cluster/national level"

bysort id_clust crop: egen price_cp1_r = max(price_cp1)
bysort id_clust crop: egen price_cp5_r = max(price_cp5)

bysort prov crop: egen price_pp1_r = max(price_pp1)
bysort prov crop: egen price_pp5_r = max(price_pp5)

bysort crop: egen price_np1_r = max(price_np1)
bysort crop: egen price_np5_r = max(price_np5)






/*Note: Prices varry substantial by HH, cluster
	and natonal levels. tabstat price*, by(m_crop) stat(mean count)  */

*Value of Output:
gen vc_crop=price*o13_1						//Value of each crop harvested
label var vc_crop "Value of harvest, individual crops"
egen i_harv=sum(vc_crop), by(uhhid)			//Total crop income
label var i_harv "Househodl income from harvest of all crops"

gen vs_crop = price*sold
replace vs_crop = 0 if vs_crop == .

gen vcons_crop = price*consumed if consumed_2 == sold_2

gen price_r = price if consumed_2 == sold_2

replace price_r = price_cp1_r if price_r == . & consumed_2 == 1
replace price_r = price_cp5_r if price_r == . & consumed_2 == 5

replace price_r = price_pp1_r if price_r == . & consumed_2 == 1
replace price_r = price_pp5_r if price_r == . & consumed_2 == 5


replace price_r = price_np1_r if price_r == . & consumed_2 == 1
replace price_r = price_np5_r if price_r == . & consumed_2 == 5

replace vcons_crop = price_r*consumed if consumed_2 != sold_2 & vcons_crop == .
replace vcons_crop = 0 if vcons_crop == .


gen sc_crop = vs_crop + vcons_crop 		//Value of each crop sold or consumed
label var sc_crop "Value of crop sold or consumed, individual crops"

egen i_sc_crop=sum(sc_crop), by(uhhid)			//Total value of crops sold or consumed
label var i_sc_crop "Value of household crop sold or consumed"

egen i_s_crop=sum(vs_crop), by(uhhid)			//Total value of crops sold 
label var i_s_crop "Value of household sale of own crop"

egen consumed_crop=sum(vcons_crop), by(uhhid)			//Total value of own crop consumed
label var consumed_crop "Value of household consumption of own crop"

qui forvalues j=1/7{
egen i_harv_c`j'=sum(vc_crop) if crop_category==`j', by(uhhid)	
}

qui forvalues j=1/7{
egen i_sc_c`j'=sum(sc_crop) if crop_cat==`j', by(uhhid)	
}

qui forvalues j=1/7{
egen cons_c`j'=sum(vcons_crop) if crop_cat==`j', by(uhhid)	
}

rename i_harv_c1 i_MaizeCereals
rename i_harv_c2 i_TubersRoots
rename i_harv_c3 i_BeansLegumesNuts
rename i_harv_c4 i_FruitsVegetables
rename i_harv_c5 i_TeaCoffee
rename i_harv_c6 i_OtherCash
rename i_harv_c7 i_OtherCrops


rename i_sc_c1 i_sc_MaizeCereals
rename i_sc_c2 i_sc_TubersRoots
rename i_sc_c3 i_sc_BeansLegumesNuts
rename i_sc_c4 i_sc_FruitsVegetables
rename i_sc_c5 i_sc_TeaCoffee
rename i_sc_c6 i_sc_OtherCash
rename i_sc_c7 i_sc_OtherCrops

rename cons_c1 cons_MaizeCereals
rename cons_c2 cons_TubersRoots
rename cons_c3 cons_BeansLegumesNuts
rename cons_c4 cons_FruitsVegetables
rename cons_c5 cons_TeaCoffee
rename cons_c6 cons_OtherCash
rename cons_c7 cons_OtherCrops


forvalues j=101/110{
gen price_i`j'=price if m_crop==`j' 
}
rename price_i101 price_whitemaize
rename price_i102 price_hybridemaize
rename price_i103 price_othermaize
rename price_i104 price_millet
rename price_i105 price_sorghum
rename price_i106 price_potatoes
rename price_i107 price_beans
rename price_i108 price_cowpea
rename price_i109 price_tea
rename price_i110 price_coffee
foreach var in whitemaize hybridemaize othermaize ///
	millet sorghum potatoes beans cowpea tea coffee {
label var price_`var' "Price of `var' per kg"
}
keep if n01 == 1
#delimit ;

local firstnm e_seed land_ar_MaizeCereals land_ar_TubersRoots
land_ar_BeansLegumesNuts land_ar_FruitsVegetables land_ar_TeaCoffee
land_ar_OtherCash land_ar_OtherCrops land_whitemaize land_hybridemaize land_othermaize
land_allMaize land_millet land_sorghum land_potatoes 
land_beans land_cowpeas 
land_tea land_coffee yield_whitemaize yield_hybridemaize 
yield_othermaize yield_allMaize yield_millet yield_sorghum 
price_whitemaize price_hybridemaize price_othermaize price_millet 
price_sorghum 
price_potatoes price_beans price_cowpea price_tea price_coffee i_harv
i_MaizeCereals i_TubersRoots i_BeansLegumesNuts i_FruitsVegetables i_TeaCoffee 
i_OtherCash i_OtherCrops i_sc_MaizeCereals i_sc_TubersRoots i_sc_BeansLegumesNuts 
i_sc_FruitsVegetables i_sc_TeaCoffee i_sc_OtherCash i_sc_OtherCrops i_sc_crop i_s_crop consumed_crop wta_pop area_total poor
cons_MaizeCereals cons_TubersRoots cons_BeansLegumesNuts cons_FruitsVegetables cons_TeaCoffee cons_OtherCash cons_OtherCrops;

		
keep (uhhid `firstnm');

collapse (firstnm) `firstnm', by(uhhid);
foreach var in i_MaizeCereals i_TubersRoots i_BeansLegumesNuts i_FruitsVegetables ///
i_TeaCoffee i_OtherCash i_OtherCrops i_sc_MaizeCereals i_sc_TubersRoots ///
i_sc_BeansLegumesNuts i_sc_FruitsVegetables i_sc_TeaCoffee i_sc_OtherCash i_sc_OtherCrops ///
land_ar_MaizeCereals land_ar_TubersRoots land_ar_BeansLegumesNuts land_ar_FruitsVegetables ///
land_ar_TeaCoffee land_ar_OtherCash land_ar_OtherCrops land_whitemaize land_hybridemaize ///
land_othermaize land_millet land_sorghum land_potatoes land_beans land_cowpeas ///
land_tea land_coffee land_allMaize area_total ///
cons_MaizeCereals cons_TubersRoots cons_BeansLegumesNuts cons_FruitsVegetables cons_TeaCoffee cons_OtherCash cons_OtherCrops{;
replace `var'=0 if `var'==.;
};

#delimit cr	

preserve 

use "${gsdDataRaw}/KIHBS05/consumption aggregated data", clear
egen uhhid = concat(id_clust id_hh)				//Unique HH ID
keep uhhid fdtotby fdtotpr
tempfile poverty_uhhid
save `"poverty_uhhid"', replace
restore

merge 1:1 uhhid using `"poverty_uhhid"'
drop if _m == 2
drop _m


save "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output05.dta", replace


keep uhhid land* i* wta_pop area_total poor
gen year = 1
save "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li05.dta", replace


