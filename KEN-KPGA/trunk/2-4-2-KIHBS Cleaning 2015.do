clear
set more off 
*cleaning 2015/16 agriculture vairables

************************************************
		*SECTION N: AGRICULTURE HOLDING
************************************************
use "${gsdDataRaw}\KIHBS15\k1", clear
merge m:1 clid hhid using  "${gsdDataRaw}\KIHBS15\hh", keepusing(k01)

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

gen farmhh_m = 0 if _merge == 2					// As mentioned the farm classification seems incorrect. I recalssify based on whether this segment
replace farmhh_m = 1 if _merge == 3					// of the questionaire was answered, which should indicate whether the household is involved in agriculture.
label value farmhh_m YesNo


*Decision Maker on Plots
recode k05 (3/8=3)
forvalue p=1/3{									//Decision on Three main parcels
gen dmaker_p`p'=k05 if parcel_id==`p'
replace dmaker_p`p'=. if dmaker_p`p'==0			//Invalid ID
recode dmaker_p`p' (3/98=3)						//Other HH members (not Head or spouse)
label var dmaker_p`p' "Who/ID makes production (input & cropping) decision on parcel `p'?" 
}
label var dmaker_p3 "Who/ID makes production (input & cropping) decision on parcel 3-11?" 
label define dmakerl 1 "Head" 2 "Spouse" 3 "Others" 
label value dmaker_p* dmakerl

*Plot Size and Value		
gen plot_size = k06*0.404686		//Acre to hectare
label var plot_size "Area (hectare) of land parcel"
egen n_parcels=count(parcel_id), by(uhhid)
label var n_parcels  "Number of parcels owned by the HH"
egen cult_land=sum(plot_size), by(uhhid)
label var cult_land "Area of cultivated land, in hectare"
recode k07 (2=0)
rename k07 OwnLand
replace OwnLand = 99 if OwnLand == . & _merge==3
label value OwnLand YesNoMissing
label var OwnLand "Does HH own this land"
egen OwnLandCult=sum(plot_size) if OwnLand==1, by(uhhid)
replace OwnLandCult = 0 if OwnLand!=1
label var OwnLandCult "Area of cultivated land owned by the HH (hectare)"
egen val_land=sum(k11), by(uhhid)
label var val_land "Sell/Purchase value of cultivated land"
egen rent_lease=sum(k12), by(uhhid)
label var rent_lease "Rental expense on rented/leased land, past 12month"

*Irrigation
gen irrigation=k14						//Is the plot irrigated
recode irrigation (2=0)
label value irrigation YesNo
egen n_irrigated=sum(irrigation), by(uhhid)				//Number of irrigated parcels
label var n_irrigated "Number of irrigated parcels, count"
egen ar_irrigated=sum(plot_size) if irrigation==1, by(uhhid)	//Total area cultivated of irrigated parcels
replace ar_irrigated=0 if irrigation!=1
label var ar_irrigated "Area (hectare) of irrigated cultivated land"
drop irrigation

*Inorganic Fertilizer
gen useIfert = 1 if (k18_1 == 1 | k18_1 == 3) | (k18_2 == 1 | k18_2 == 3)
replace useIfert = 0 if useIfert == .
label value useIfert YesNo
egen n_Ifert=sum(useIfert), by(uhhid)				//Number of  parcels treated with inorganic fertilizer
label var n_Ifert "Number of parcels treated with inorganic fertilizer"
egen ar_Ifert=sum(plot_size) if useIfert == 1, by(uhhid)		//Area of cultivated land treated with inorganic fertilizer
replace ar_Ifert=0 if useIfert!=1
label var ar_Ifert "Area (hectare) of cultivated land treated with inorganic fertilizer"

*Inorganic Fertilizer
gen useOfert = 1 if (k18_1 == 2 | k18_1 == 3) | (k18_2 == 2 | k18_2 == 3)
replace useOfert = 0 if useOfert == .
label value useOfert YesNo
egen n_Ofert=sum(useOfert), by(uhhid)				//Number of  parcels treated with organic fertilizer
label var n_Ofert "Number of parcels treated with organic fertilizer"
egen ar_Ofert=sum(cult_land) if useOfert == 1, by(uhhid)		//Area of cultivated land treated with organic fertilizer
replace ar_Ofert=0 if useOfert!=1
label var ar_Ofert "Area (hectare) of cultivated land treated with organic fertilizer"

*Expenditure on Inputs (other than land)
		*Operating exp:
		
/*		
egen e_irrigation=sum(n18), by(uhhid)					//Expenditure on irrigation
label var e_irrigation "Expenditure on irrigation"
			// Expenditure on irrigation not available, perhaps due to small number of hh from 2005-2006
			// that spent money on irrigation.
*/

/* These items are listed in Section K of the 2015-2016 KIHBS Survey, but can not be found in the data.
Check with Habtamu */

/*
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
 
 
*/
keep uhhid clid hhid farmhh farmhh_m n_parcels dmaker_p1 dmaker_p2 dmaker_p3 cult_land OwnLandCult ///
	n_irrigated ar_irrigated n_Ifert ar_Ifert n_Ofert ar_Ofert
 
 
 foreach v of var * {
	local l`v' : variable label `v'
	if `"`l`v''"' == "" {
	local l`v' "`v'"
 	}
 }	 
 
#delimit ;


collapse (firstnm) farmhh farmhh_m n_parcels dmaker_p1 dmaker_p2 dmaker_p3 cult_land OwnLandCult
	n_irrigated n_Ifert n_Ofert (max) ar_irrigated ar_Ifert ar_Ofert, by(uhhid);
	
#delimit cr 	
	
 foreach v of var * {
 label var `v' "`l`v''"
 }	

label value farmhh YesNo
label value farmhh_m YesNo
label value dmaker_p* dmakerl

/* farmhh and farmhh_m do not match. They identify farming households from two different sources. */
 
save "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding15.dta", replace





************************************************
		*SECTION O: AGRICULTURE OUTPUT
************************************************
use "${gsdDataRaw}\KIHBS15\l", clear
egen uhhid= concat(hhid clid)								//Unique HH ID
label var uhhid "Unique HH ID"
merge m:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding15.dta"
*keep if _merge == 3
gen test = _merge
drop _merge
merge m:1 hhid clid using "${gsdDataRaw}\KIHBS15\hh.dta", keepusing(county)
*keep if _merge == 3
drop _merge
merge m:1 hhid clid using "${gsdData}/1-CleanOutput/kihbs15_16.dta", keepus(wta_pop province poor)
keep if _merge == 3
drop _merge

*Cost of seed
gen e_seed=l07
label var e_seed "Expenditure on seed and seedling" 
*Major Crop Categories:
gen crop = l02_cr
gen crop_category = .

#delimit ;
replace crop_category = 1 if crop == 1 | (crop == 6 | crop == 7 | crop == 8 | crop == 9 | 
crop == 12 | crop == 13 | crop == 14);							/// Maize & Other Cereals		         										         
replace crop_category = 2 if (crop == 15 | crop == 16 | crop == 17 | crop == 18 |    
crop == 19); 													/// Tubers and Roots
replace crop_category = 3 if (crop == 28 | crop == 31 | crop == 32 | crop == 33 |    
crop ==  34 | crop ==  35 | crop == 36 | crop == 37 | crop ==  38 | crop == 40 | 
crop == 41 | crop ==  42 | crop == 43);							/// Beans/Legumes & Nuts

replace crop_category = 4 if (crop == 21 | crop == 22 | crop == 23 | crop == 24 |    
crop == 25 | crop == 26 | crop == 27) | (crop == 51 | crop ==  52 | crop == 53 | 
crop ==  54 | crop == 55 | crop == 56 | crop == 58 | crop ==  59);		/// Fruits & Vegetables	 
replace crop_category = 5 if (crop == 75) | (crop == 76);				/// Tea & Coffee
replace crop_category = 6 if crop >= 71 & crop <= 74;	///Other Cash Crops (sugarcane/tobacco/cotton)

replace crop_category = 7 if (crop == 80 | 	
crop == 57 | crop == 77 | crop == 78 | crop == 79 |     
crop == 20 | crop == 61 | crop ==  62); 				/// Other Crops (Grass, Sugarcane, Trees, Khat, other crops)						 
	
label define c_cropl 1 "Maize & Other Cereals" 2 "Tubers & Roots" 3 "Beans, Legumes & Nuts" 4 "Fruits & Vegetables"	///
						5 "Tea & Coffee" 6 "Other Cash Crops" 7 "Other Crops";
						
#delimit cr 				
					
label value crop_category c_cropl


*Major crops:
gen m_crop=crop
recode m_crop (1=101) (12=102) (18/19=103) (24/25=104) (32=105) (33=106) ///
			  (35=107) (36=108) (53/54=109) (75=110) (76=111)
replace m_crop=. if m_crop<=80								//Old codes	

label define m_cropl 101 "Maize" 102 "Sorghum" 103 "Potatoes" ///
					104 "Cabbage/Kale" 105 "Beans" 106 "Grams green" 107 "Cow peas"   ///
					108 "Pigeon peas" 109 "Bananas" 110 "Tea" 111 "Coffee"
label value m_crop m_cropl				

*Land covered by crop category:
gen l03_ar_1=l03_ar*0.404686 if l03_un == 1		//Acre to hectare
bysort uhhid: egen area_total = sum(l03_ar_1)

/* Area cultivated from Agricultural Holding Section is usually very different from
aggregate area listed in this section. Why? */

qui forvalues j=1/7{
egen land_crop_ar`j'=sum(l03_ar) if crop_category==`j' & l03_un == 1, by(uhhid)
}


qui forvalues j=1/7{
egen land_crop_num`j'=sum(l03_ar) if crop_category==`j' & l03_un == 2, by(uhhid)
}



rename land_crop_ar1 land_ar_MaizeCereals
rename land_crop_ar2 land_ar_TubersRoots
rename land_crop_ar3 land_ar_BeansLegumesNuts
rename land_crop_ar4 land_ar_FruitsVegetables
rename land_crop_ar5 land_ar_TeaCoffee
rename land_crop_ar6 land_ar_OtherCash
rename land_crop_ar7 land_ar_OtherCrops

rename land_crop_num1 land_num_MaizeCereals
rename land_crop_num2 land_num_TubersRoots
rename land_crop_num3 land_num_BeansLegumesNuts
rename land_crop_num4 land_num_FruitsVegetables
rename land_crop_num5 land_num_TeaCoffee
rename land_crop_num6 land_num_OtherCash
rename land_crop_num7 land_num_OtherCrops

label var land_ar_MaizeCereals "The amount of land allocated to Maize and other Cereals"
label var land_ar_TubersRoots "The amount of land allocated to Tuber and Roots"
label var land_ar_BeansLegumesNuts "The amount of land allocated to Beans/Legumes/Nuts"
label var land_ar_FruitsVegetables "The amount of land allocated to Fruits and Vegetables"
label var land_ar_TeaCoffee "The amount of land allocated to Tea and Coffee"
label var land_ar_OtherCash "The amount of land allocated to Other Cash Crops"
label var land_ar_OtherCrops "The amount of land allocated to Other Crops"

label var land_num_MaizeCereals "The amount of land allocated to Maize and other Cereals"
label var land_num_TubersRoots "The amount of land allocated to Tuber and Roots"
label var land_num_BeansLegumesNuts "The amount of land allocated to Beans/Legumes/Nuts"
label var land_num_FruitsVegetables "The amount of land allocated to Fruits and Vegetables"
label var land_num_TeaCoffee "The amount of land allocated to Tea and Coffee"
label var land_num_OtherCash "The amount of land allocated to Other Cash Crops"
label var land_num_OtherCrops "The amount of land allocated to Other Crops"


*Land (area) covered by major crops:
qui forvalues j=101/111{
egen land_ar_`j'=sum(l03_ar) if m_crop==`j' & l03_un == 1, by(uhhid)
}


*Land (number) covered by major crops:
qui forvalues j=101/111{
egen land_num_`j'=sum(l03_ar) if m_crop==`j' & l03_un == 2, by(uhhid)
}


rename l09 harvested
rename l10 consumed
rename l11 sold
rename l12 sale_rev
rename l13 seeds
rename l14 payments
rename l15 stored
rename l18 donations
rename l16 lost_wasted


* l09 = harvested	l10 = consumed	l11 = sold	l14 = payments	l13 = seeds	l18 = donations	l16 = lost/wasted


*Production and Yield: Major Crops (area = acres)
qui forvalues j=101/111{
egen production_`j'=sum(harvested)if m_crop==`j', by(uhhid)
}


qui forvalues j=101/111{
gen yield_`j'=production_`j'/land_ar_`j' if l03_un == 1
}


qui forvalues j=101/111{
gen yieldn_`j'=production_`j'/land_num_`j' if l03_un == 2
}


qui foreach var in land_ar land_num production yield yieldn{
rename `var'_101 `var'_Maize
rename `var'_102 `var'_Sorghum
rename `var'_103 `var'_Potatoes
rename `var'_104 `var'_CabbKale
rename `var'_105 `var'_Beans
rename `var'_106 `var'_GramsGr
rename `var'_107 `var'_CowPea
rename `var'_108 `var'_PigPea
rename `var'_109 `var'_Bananas
rename `var'_110 `var'_Tea
rename `var'_111 `var'_Coffee
}

#delimit ;
foreach crop in Maize Sorghum Potatoes CabbKale Beans GramsGr CowPea PigPea Bananas Tea Coffee{;
label var land_ar_`crop' "The amount of land allocated to `crop'";
label var land_num_`crop' "The number of trees allocated to `crop'";
label var production_`crop' "The total volume (kg) of `crop' production, at HH level";
label var yield_`crop' "The yield (kg/ha) of `crop'";	
label var yieldn_`crop' "The yield (kg/tree) of `crop'";	
};
#delimit cr
*drop yield_potatoes yield_beans yield_cowpeas 	///
*	 yield_tea yield_coffee 					//Drop yield for non-cereals 
	/*Note: Yield for non-cereal items might not 
	be interesting to analyze */

*Output price:
	*Price at HH level
gen price_h=sale_rev/sold											//HH level, Price at which crops were sold
label var price_h "Price of major crops, HH level (from sales data)"
qui foreach c in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 ///
		21 22 23 24 25 26 27 28 30 31 32 33 34 35 36 37 38 40 41 ///
		42 43 50 51 52 53 54 55 56 57 58 59 60 61 62 ///
		70 71 72 73 74 75 76 79 80 { 
sum price_h if crop==`c', det
replace price_h=r(p95) if price_h>r(p95) & price_h!=. ///
			& crop==`c' 								//Trim price at 95th percentile
replace price_h=r(p5) if price_h<r(p5) & price_h!=. ///
			& crop==`c' 								//Trim price at 5th percentile
			}

	*Price at Cluster level
egen price_cl = median(price_h), by(clid crop)	//Cluster level, Price at which crops were sold

	*Price at County level
egen price_ct = median(price_h), by(county crop)	//County level, Price at which crops were sold

	*Price at Province level
egen price_p = median(price_h), by(province crop)	//Province level, Price at which crops were sold
	
	*Price at national level
egen price_n = median(price_h), by(crop)							//National level, Price at which crops were sold




gen price=price_h									//Price, HH/Cluster/County/Province/National level
replace price=price_cl if price==.					//Price, HH/Cluster/County/Province/National level
replace price=price_ct if price==.					//Price, HH/Cluster/County/Province/National level
replace price=price_p  if price==.					//Price, HH/Cluster/County/Province/National level
replace price=price_n  if price==.					//Price, HH/Cluster/County/Province/National level

label var price "Price of major crops, HH level if available, otherwise median at cluster/county/province/national level"

/*Note: Prices varry substantial by HH, cluster
	and natonal levels. tabstat price*, by(m_crop) stat(mean count)  */

*Value of Output:
gen vc_crop=price*harvested 		//Value of each crop harvested
label var vc_crop "Value of harvest, individual crops"

egen i_harv=sum(vc_crop), by(uhhid)			//Total crop income
label var i_harv "Household income from harvest of all crops"

gen sc_crop = price*(sold + consumed)  		//Value of each crop sold or consumed
label var sc_crop "Value of crop sold or consumed, individual crops"

egen i_sc_crop=sum(sc_crop), by(uhhid)			//Total value of crops sold or consumed
label var i_sc_crop "Value of household crop sold or consumed"

gen s_crop = price*(sold)  		//Value of each crop sold
label var s_crop "Value of crop sold"

egen i_s_crop=sum(s_crop), by(uhhid)			//Total value of crops sold
label var i_s_crop "Value of household sale of own crop"

gen vcons_crop = price * (consumed)  		//Value of each crop sold or consumed
label var vcons_crop "Value of crop consumed"

egen consumed_crop=sum(vcons_crop), by(uhhid)			//Total value of crops consumed
label var consumed_crop "Value of household consumption of own crop"


qui forvalues j=1/7{
egen i_harv_c`j'=sum(vc_crop) if crop_cat==`j', by(uhhid)	
}

qui forvalues j=1/7{
egen i_sc_c`j'=sum(sc_crop) if crop_cat==`j', by(uhhid)	
replace i_sc_c`j' = 0 if i_sc_c`j' ==.
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

forvalues j=101/111{
gen price_i`j'=price if m_crop==`j' 
}
rename price_i101 price_Maize
rename price_i102 price_Sorghum
rename price_i103 price_Potatoes
rename price_i104 price_CabbKale
rename price_i105 price_Beans
rename price_i106 price_GramsGr
rename price_i107 price_CowPea
rename price_i108 price_PigPea
rename price_i109 price_Bananas
rename price_i110 price_Tea
rename price_i111 price_Coffee

foreach var in  ///
Maize Sorghum Potatoes CabbKale Beans GramsGr CowPea PigPea Bananas Tea Coffee {
label var price_`var' "Price of `var' per kg"
}

#delimit ;



/* Collapse Land + Production + Yield */
local firstnm land_ar_MaizeCereals land_ar_TubersRoots land_ar_BeansLegumesNuts 
land_ar_FruitsVegetables land_ar_TeaCoffee land_ar_OtherCash  land_ar_OtherCrops 
land_num_MaizeCereals land_num_TubersRoots land_num_BeansLegumesNuts 
land_num_FruitsVegetables land_num_TeaCoffee land_num_OtherCash land_num_OtherCrops 
land_ar_Maize land_ar_Sorghum land_ar_Potatoes land_ar_CabbKale land_ar_Beans 
land_ar_GramsGr land_ar_CowPea land_ar_PigPea land_ar_Bananas land_ar_Tea land_ar_Coffee 
land_num_Maize land_num_Sorghum land_num_Potatoes land_num_CabbKale 
land_num_Beans land_num_GramsGr land_num_CowPea land_num_PigPea 
land_num_Bananas land_num_Tea land_num_Coffee 
production_Maize production_Sorghum production_Potatoes production_CabbKale 
production_Beans production_GramsGr production_CowPea production_PigPea 
production_Bananas production_Tea production_Coffee 
yield_Maize yield_Sorghum yield_Potatoes yield_CabbKale yield_Beans yield_GramsGr 
yield_CowPea yield_PigPea yield_Bananas yield_Tea yield_Coffee yieldn_Maize 
yieldn_Sorghum yieldn_Potatoes yieldn_CabbKale yieldn_Beans yieldn_GramsGr 
yieldn_CowPea yieldn_PigPea yieldn_Bananas yieldn_Tea yieldn_Coffee
i_harv i_MaizeCereals i_TubersRoots i_BeansLegumesNuts i_FruitsVegetables 
i_TeaCoffee i_OtherCash i_OtherCrops i_sc_crop i_sc_MaizeCereals i_sc_TubersRoots 
i_sc_BeansLegumesNuts i_sc_FruitsVegetables i_sc_TeaCoffee i_sc_OtherCash i_sc_OtherCrops i_s_crop consumed_crop wta_pop area_total poor
cons_MaizeCereals cons_TubersRoots cons_BeansLegumesNuts cons_FruitsVegetables cons_TeaCoffee cons_OtherCash cons_OtherCrops test;

collapse (firstnm) `firstnm' , by(uhhid);

#delimit cr

label var land_ar_MaizeCereals "The amount of land allocated to Maize and other Cereals"
label var land_ar_TubersRoots "The amount of land allocated to Tuber and Roots"
label var land_ar_BeansLegumesNuts "The amount of land allocated to Beans/Legumes/Nuts"
label var land_ar_FruitsVegetables "The amount of land allocated to Fruits and Vegetables"
label var land_ar_TeaCoffee "The amount of land allocated to Tea and Coffee"
label var land_ar_OtherCash "The amount of land allocated to Other Cash Crops"
label var land_ar_OtherCrops "The amount of land allocated to Other Crops"

label var land_num_MaizeCereals "The amount of land allocated to Maize and other Cereals"
label var land_num_TubersRoots "The amount of land allocated to Tuber and Roots"
label var land_num_BeansLegumesNuts "The amount of land allocated to Beans/Legumes/Nuts"
label var land_num_FruitsVegetables "The amount of land allocated to Fruits and Vegetables"
label var land_num_TeaCoffee "The amount of land allocated to Tea and Coffee"
label var land_num_OtherCash "The amount of land allocated to Other Cash Crops"
label var land_num_OtherCrops "The amount of land allocated to Other Crops"


foreach crop in Maize Sorghum Potatoes CabbKale Beans GramsGr CowPea PigPea Bananas Tea Coffee{
label var land_ar_`crop' "The amount of land allocated to `crop'"
label var land_num_`crop' "The number of trees allocated to `crop'"
label var production_`crop' "The total volume (kg) of `crop' production, at HH level"
label var yield_`crop' "The yield (kg/ha) of `crop'"	
label var yieldn_`crop' "The yield (kg/tree) of `crop'"	
}

label var i_harv "Household income from harvest of all crops"

label var i_MaizeCereals "HH income from Maize & other Cereals"
label var i_TubersRoots "HH income from Tubers/Roots" 
label var i_BeansLegumesNuts "HH income from Beans, Legumes & Nuts" 
label var i_FruitsVegetables "HH income from Fruits & Vegetables" 
label var i_TeaCoffee "HH income from cash Tea & Coffee" 
label var i_OtherCash "HH income from other Cash Crops" 
label var i_OtherCrops "HH income from all other Crops" 

label var i_sc_crop "Household income defined as value of crop sold or consumed"

label var i_sc_MaizeCereals "Value of Sale or consumed from Maize & other Cereals"
label var i_sc_TubersRoots "Value of Sale or consumed from Tubers/Roots" 
label var i_sc_BeansLegumesNuts "Value of Sale or consumed from Beans, Legumes & Nuts" 
label var i_sc_FruitsVegetables "Value of Sale or consumed from Fruits & Vegetables" 
label var i_sc_TeaCoffee "Value of Sale or consumed from Tea & Coffee" 
label var i_sc_OtherCash "HH income from other Cash Crops" 
label var i_sc_OtherCrops "Value of Sale or consumed from all other Crops" 

label var i_harv "Household income from harvest of all crops"
label var i_sc_crop "Value of household crop sold or consumed"
label var i_s_crop "Value of household sale of own crop"
label var consumed_crop "Value of household consumption of own crop"

label var area_total "Total land area cultivated"

#delimit ;
foreach var in area_total land_ar_MaizeCereals land_ar_TubersRoots land_ar_BeansLegumesNuts 
land_ar_FruitsVegetables land_ar_TeaCoffee land_ar_OtherCash land_ar_OtherCrops land_num_MaizeCereals 
land_num_TubersRoots land_num_BeansLegumesNuts land_num_FruitsVegetables 
land_num_TeaCoffee land_num_OtherCrops land_ar_Maize land_ar_Sorghum land_ar_Potatoes 
land_ar_CabbKale land_ar_Beans land_ar_GramsGr land_ar_CowPea land_ar_PigPea 
land_ar_Bananas land_ar_Tea land_ar_Coffee land_num_Maize land_num_Sorghum 
land_num_Potatoes land_num_CabbKale land_num_Beans land_num_GramsGr land_num_CowPea 
land_num_PigPea land_num_Bananas land_num_Tea land_num_Coffee production_Maize 
production_Sorghum production_Potatoes production_CabbKale production_Beans 
production_GramsGr production_CowPea production_PigPea production_Bananas 
production_Tea production_Coffee i_harv i_MaizeCereals i_TubersRoots 
i_BeansLegumesNuts i_FruitsVegetables i_TeaCoffee i_OtherCash i_OtherCrops i_sc_crop 
i_sc_MaizeCereals i_sc_TubersRoots i_sc_BeansLegumesNuts i_sc_FruitsVegetables 
i_sc_TeaCoffee i_sc_OtherCrops
cons_MaizeCereals cons_TubersRoots cons_BeansLegumesNuts cons_FruitsVegetables cons_TeaCoffee cons_OtherCash cons_OtherCrops{;
replace `var'=0 if `var'==.;
};	

#delimit cr

preserve 

use "${gsdDataRaw}\KIHBS15\poverty", clear
egen uhhid= concat(hhid clid)				//Unique HH ID
keep uhhid fdtexp
tempfile poverty_uhhid
save "`poverty_uhhid'", replace
restore

merge 1:1 uhhid using "`poverty_uhhid'"
drop if _m == 2
drop _m


save "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output15.dta", replace


keep uhhid land_a* i* wta_pop area_total poor
gen year = 2
save "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta", replace
