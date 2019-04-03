*Shared prosperity analysis for the note on Inequality 2005/6 vs. 2015/16

set more off
set seed 23081980 
set sortseed 11041955

*Check if filepaths have been established using init.do
if "${gsdData}"=="" {
	display as error "Please run init.do first."
	error 1
}


*********************************************************
* 1| ORIGINAL MEASURES OF INEQUALITY (PRE-CORRECTIONS)
*********************************************************

//Prepare the dataset 
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
svyset clid [pw=wta_pop] , strat(strat)

//Inequality measures in 2005/6 and 2015/16
*Urban-Rural and by province
qui foreach var in 2005 2015  {
	ineqdeco y2_i if kihbs == `var' [aw = wta_pop]
	matrix total_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)]
		
	ineqdeco y2_i if kihbs == `var' & urban == 0 [aw = wta_pop]
    matrix rural_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)] 
 	
	ineqdeco y2_i if kihbs == `var' & urban == 1 [aw = wta_pop]
	matrix urban_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2) ]
}
qui foreach var in 2005 2015  {
	forvalues i = 1 / 8{
		ineqdeco y2_i if kihbs == `var' & province==`i'  [aw = wta_pop]
		matrix prov_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
qui foreach var in 2005 2015  {
	forvalues i = 0 / 1{
		ineqdeco y2_i if kihbs == `var' & nedi==`i'  [aw = wta_pop]
		matrix nedi_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
matrix nedi_2005 = [nedi_0_2005 \ nedi_1_2005]
matrix nedi_2015 = [nedi_0_2015 \ nedi_1_2015]
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]
matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]
matrix prov = [prov_2005 \ prov_2015]
matrix nedi = [nedi_2005 \ nedi_2015]
putexcel set "${gsdOutput}/Inequality/Raw_1.xls" , replace
putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A22=("Nairobi") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") A34=("2005") A35=("Non-Nedi") A36=("Nedi") A38=("2015") A39=("Non-Nedi") A40=("Nedi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") F1=("Atkinson (e=1)") G1=("Atkinson (e=2)")
putexcel B2=matrix(total)
putexcel B6=matrix(rural)
putexcel B10=matrix(urban)
putexcel B15=matrix(prov_2005)
putexcel B25=matrix(prov_2015)
putexcel B35=matrix(nedi_2005)
putexcel B39=matrix(nedi_2015)



*********************************************************
* 2| RESPONSE RATES AND CONSUMPTION BY ENUMERATION AREA
*********************************************************

//Response rates by county
use "${gsdDataRaw}/KIHBS15/response1.dta",clear
keep if urban == 1

*Generate county weight to incease size of scatter points accordingly
egen double tothh = total(wta_hh)
bys county: egen double countyhh = total(wta_hh)
gen countypw = countyhh/tothh

collapse (mean) response mean_cons=y2_i (median) median_cons=y2_i , by(county countypw)
merge 1:m county using "${gsdData}/1-CleanOutput/hh.dta", nogen keep(match) keepusing(province)
duplicates drop
label var median_cons "Median consumption"
replace response = response*100
gen nonresp=100-response
twoway (scatter median_cons nonresp [pw=countypw]) (lfit median_cons nonresp [pw=countypw])  ///
       ,  legend(off) xtitle("Nonresponse rate (%)", size(small)) ytitle("Median consumption per county" "(Monthly 2016 Kshs per adult equivalent)", size(small)) ///
	    xlabel(, labsize(small)) ylabel(4000 "4,000" 6000 "6,000" 8000 "8,000" 10000 "10,000" 12000 "12,000", angle(0) labsize(small)) ///
		name(response2, replace) graphregion(color(white)) bgcolor(white) 
graph save "${gsdOutput}/Inequality/Response-rate_Consumption_Urban", replace

*Rural areas
use "${gsdDataRaw}/KIHBS15/response1.dta",clear
keep if urban == 0
egen double tothh = total(wta_hh)
bys county: egen double countyhh = total(wta_hh)
gen countypw = countyhh/tothh
collapse (mean) response mean_cons=y2_i (median) median_cons=y2_i , by(county countypw)
label var median_cons "Median consumption"
replace response = response*100
gen nonresp=100-response
twoway (scatter median_cons nonresp [pw=countypw]) (lfit median_cons nonresp [pw=countypw])  ///
       ,  legend(off) xtitle("Nonresponse rate (%)", size(small)) ytitle("Median consumption per county" "(Monthly 2016 Kshs per adult equivalent)", size(small)) ///
	    xlabel(, labsize(small)) ylabel(0 "0" 2000 "2,000" 4000 "4,000" 6000 "6,000" 8000 "8,000", angle(0) labsize(small)) ///
		name(response2, replace) graphregion(color(white)) bgcolor(white) 
graph save "${gsdOutput}/Inequality/Response-rate_Consumption_Rural", replace



*********************************************************
* 3| RE-WEIGHTING CORRECTION FOR URBAN AREAS IN 2015/15
*********************************************************

//Prepare the data to estimate the model at PSU level 

*Keep data for 2015 only 
use "${gsdData}/1-CleanOutput/hh.dta",clear
keep if kihbs==2015 
collapse (mean) province county hhsize agehead malehead urban (median) y2_i, by(clid)
ta province, gen(province_)
save "${gsdTemp}/2015-PSU-Urban.dta", replace

*Use data with non-response
use "${gsdDataRaw}/KIHBS15/response1.dta",clear
gen non_resp=(response==0)
bys clid: egen sum_nresp=sum(non_resp)
bys clid: egen sum_resp=sum(response)
gen tot= sum_nresp+ sum_resp
gen resp_rate=sum_resp/tot
gen non_resp_rate=sum_nresp/tot
*Create month variable
gen month=1 if iday<=td(30sep2015)
replace month=2 if iday<=td(30oct2015) & iday>=td(01oct2015)
replace month=3 if iday<=td(30nov2015) & iday>=td(01nov2015)
replace month=4 if iday<=td(31dec2015) & iday>=td(01dec2015)
replace month=5 if iday<=td(31jan2016) & iday>=td(01jan2016)
replace month=6 if iday<=td(29feb2016) & iday>=td(01feb2016)
replace month=7 if iday<=td(30mar2016) & iday>=td(01mar2016)
replace month=8 if iday<=td(30apr2016) & iday>=td(01apr2016)
replace month=9 if iday<=td(31may2016) & iday>=td(01may2016)
replace month=10 if iday<=td(30jun2016) & iday>=td(01jun2016)
replace month=11 if iday<=td(31jul2016) & iday>=td(01jul2016)
replace month=12 if iday<=td(30aug2016) & iday>=td(01aug2016)
collapse (mean) y2_i cycle (max) non_resp_rate month, by(clid)
label define lmonth 1 "Sep 2015" 2 "Oct 2015" 3 "Nov 2015" 4 "Dec 2015" 5 "Jan 2016" 6 "Feb 2016" 7 "Mar 2016" 8 "Apr 2016" 9 "May 2016" 10 "Jun 2016" 11 "Jul 2016" 12 "Aug 2016"
label values month lmonth

*Merge other characteristics for the model 
merge 1:1 clid using "${gsdTemp}/2015-PSU-Urban.dta", nogen assert(match)
gen y2_i_sq=y2_i*y2_i
gen ly2_i_sq=ln(y2_i_sq)
gen ly2_i=ln(y2_i)
ta month, gen(month_)
save "${gsdTemp}/EA-data_response_model.dta", replace


//Produce results with different specifications 
*Model 1
logit non_resp_rate ly2_i, or robust
outreg2 using "${gsdOutput}/Inequality/Logit_Non-response.xls", bdec(3) tdec(3) rdec(3) nolabel eform cti(odds ration) replace 
predict prob_non_resp_1, pr
estat ic
gen prob_resp_1=1-prob_non_resp_1
*Obtain graph of rescaled probability of responding
preserve
sum prob_resp_1
gen max=r(max)
gen x=1- max
replace prob_resp_1=prob_resp_1+x
drop max x
drop if y2_i>40000 
twoway scatter  prob_resp_1 y2_i,  xtitle("Mean consumption per PSU (Monthly 2016 Kshs per AE)", size(small)) ///
			   xlabel(, labsize(small)) ytitle("Probability of responding KIHSB 2015/15", ///
			   size(small)) ylabel(, angle(horizontal) labsize(small)) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Response-Prob_1", replace
restore

*Model 2
logit non_resp_rate y2_i, or robust noconst
outreg2 using "${gsdOutput}/Inequality/Logit_Non-response.xls", bdec(3) tdec(3) rdec(3) nolabel eform cti(odds ration) append
predict prob_non_resp_2, pr
estat ic
gen prob_resp_2=1-prob_non_resp_2
*Obtain graph of rescaled probability of responding
preserve
sum prob_resp_2
gen max=r(max)
gen x=1- max
replace prob_resp_2=prob_resp_2+x
drop max x
drop if y2_i>40000 
twoway scatter  prob_resp_2 y2_i,  xtitle("Mean consumption per PSU (Monthly 2016 Kshs per AE)", size(small)) ///
			   xlabel(, labsize(small)) ytitle("Probability of responding KIHSB 2015/15", ///
			   size(small)) ylabel(, angle(horizontal) labsize(small)) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Response-Prob_2", replace
restore 

*Model 3
logit non_resp_rate ly2_i, or robust noconst
outreg2 using "${gsdOutput}/Inequality/Logit_Non-response.xls", bdec(3) tdec(3) rdec(3) nolabel eform cti(odds ration) append
predict prob_non_resp_3, pr
estat ic
gen prob_resp_3=1-prob_non_resp_3
*Obtain graph of rescaled probability of responding
preserve
sum prob_resp_3
gen max=r(max)
gen x=1- max
replace prob_resp_3=prob_resp_3+x
drop max x
drop if y2_i>40000 
twoway scatter  prob_resp_3 y2_i,  xtitle("Mean consumption per PSU (Monthly 2016 Kshs per AE)", size(small)) ///
			   xlabel(, labsize(small)) ytitle("Probability of responding KIHSB 2015/15", ///
			   size(small)) ylabel(, angle(horizontal) labsize(small)) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Response-Prob_3", replace
restore

*Model 4
logit non_resp_rate ly2_i_sq i.province, or robust noconst
outreg2 using "${gsdOutput}/Inequality/Logit_Non-response.xls", bdec(3) tdec(3) rdec(3) nolabel eform cti(odds ration) append
predict prob_non_resp_4, pr
estat ic
gen prob_resp_4=1-prob_non_resp_4
*Obtain graph of rescaled probability of responding
preserve
sum prob_resp_4
gen max=r(max)
gen x=1- max
replace prob_resp_4=prob_resp_4+x
drop max x
drop if y2_i>40000 
twoway scatter  prob_resp_4 y2_i,  xtitle("Mean consumption per PSU (Monthly 2016 Kshs per AE)", size(small)) ///
			   xlabel(, labsize(small)) ytitle("Probability of responding KIHSB 2015/15", ///
			   size(small)) ylabel(, angle(horizontal) labsize(small)) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Response-Prob_4", replace
restore

*Model 5
logit non_resp_rate ly2_i_sq i.month, or robust noconst
outreg2 using "${gsdOutput}/Inequality/Logit_Non-response.xls", bdec(3) tdec(3) rdec(3) nolabel eform cti(odds ration) append
predict prob_non_resp_5, pr
estat ic
gen prob_resp_5=1-prob_non_resp_5
*Obtain graph of rescaled probability of responding
preserve
sum prob_resp_5
gen max=r(max)
gen x=1- max
replace prob_resp_5=prob_resp_5+x
drop max x
drop if y2_i>40000 
twoway scatter  prob_resp_5 y2_i,  xtitle("Mean consumption per PSU (Monthly 2016 Kshs per AE)", size(small)) ///
			   xlabel(, labsize(small)) ytitle("Probability of responding KIHSB 2015/15", ///
			   size(small)) ylabel(, angle(horizontal) labsize(small)) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Response-Prob_5", replace
restore

*Model 6
logit non_resp_rate malehead y2_i province_1 province_4 province_6 province_7 , or robust noconst
outreg2 using "${gsdOutput}/Inequality/Logit_Non-response.xls", bdec(3) tdec(3) rdec(3) nolabel eform cti(odds ration) append
predict prob_non_resp_6, pr
estat ic
gen prob_resp_6=1-prob_non_resp_6
*Obtain graph of rescaled probability of responding
preserve
sum prob_resp_6
gen max=r(max)
gen x=1- max
replace prob_resp_6=prob_resp_6+x
drop max x
*drop if y2_i>40000 
twoway (scatter  prob_resp_6 y2_i if urban==1) (scatter  prob_resp_6 y2_i if urban==0) ,  xtitle("Mean consumption per EA (Monthly 2016 Kshs per adult equivalent)", size(small)) ///
		xlabel(, labsize(small)) ytitle("Probability of responding KIHBS 2015/16", ///
		size(small)) ylabel(, angle(horizontal) labsize(small)) graphregion(color(white)) bgcolor(white) ///
		legend(label(1 "Urban EAs") label(2 "Rural EAs")) xlabel(20000 "20,000" 40000 "40,000" 60000 "60,000")  
graph save "${gsdOutput}/Inequality/Response-Prob_6", replace
restore


//Prepare the data to adjust sampling weights 
keep clid prob_resp_*
gen kihbs=2015
save "${gsdTemp}/Prob-response_Models.dta", replace

*Open the relevant file 
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
merge m:1 kihbs clid using "${gsdTemp}/Prob-response_Models.dta", nogen keep(master match)

*Obtain totals at different levels of aggregation
bys kihbs urban: egen weight_urban=sum(wta_pop) 
bys kihbs province: egen weight_province=sum(wta_pop) 
bys kihbs urban province: egen weight_province_urban=sum(wta_pop) 
bys kihbs urban county: egen weight_county_urban=sum(wta_pop) 
bys kihbs: egen weight_total=sum(wta_pop)
save "${gsdTemp}/Adjusted-weights.dta", replace


//For each model-weights obtain final values and inequality measures
forval m=1/6 {
	
	use "${gsdTemp}/Adjusted-weights.dta", clear
	merge m:1 clid using "${gsdTemp}/EA-data_response_model.dta", nogen keep(master match) keepusing(non_resp_rate)
	
	*Obtain new weights for PSUs with non-response only but make sure they summ to the same totals 
	gen wta_pop_`m'=wta_pop*(1/prob_resp_`m') if kihbs==2015 & non_resp_rate>0
	replace wta_pop_`m'=wta_pop if wta_pop_`m'>=.
	
	*Scale uniformly to match totals at urban and county level 
	bys kihbs urban county: egen prelim_ur_county=sum(wta_pop_`m') 
	gen scale_factor=weight_county_urban/prelim_ur_county if kihbs==2015
	replace wta_pop_`m'=wta_pop_`m'*scale_factor if scale_factor<.
	bys kihbs urban county: egen check=sum(wta_pop_`m') 
	assert round(check,10)==round(weight_county_urban,10)

	*Check at the total levels
	bys kihbs: egen check_total=sum(wta_pop_`m')
	assert round(check_total,10)==round(weight_total ,10)
	save "${gsdTemp}/Adjusted-weights_`m'.dta", replace

	*Obtain new measures of inequality 
	svyset clid [pw=wta_pop_`m'] , strat(strat)
	qui foreach var in 2005 2015  {
		ineqdeco y2_i if kihbs == `var' [aw = wta_pop_`m']
		matrix total_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)]
			
		ineqdeco y2_i if kihbs == `var' & urban == 0 [aw = wta_pop_`m']
		matrix rural_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)] 
		
		ineqdeco y2_i if kihbs == `var' & urban == 1 [aw = wta_pop_`m']
		matrix urban_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2) ]
	}
	qui foreach var in 2005 2015  {
		forvalues i = 1 / 8{
			ineqdeco y2_i if kihbs == `var' & province==`i'  [aw = wta_pop_`m']
			matrix prov_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
	}
	}
	qui foreach var in 2005 2015  {
		forvalues i = 0 / 1{
			ineqdeco y2_i if kihbs == `var' & nedi==`i'  [aw = wta_pop_`m']
			matrix nedi_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
	}
	}
	matrix nedi_2005 = [nedi_0_2005 \ nedi_1_2005]
	matrix nedi_2015 = [nedi_0_2015 \ nedi_1_2015]
	matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
	matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]
	matrix total = [total_2005 \ total_2015]
	matrix rural = [rural_2005 \ rural_2015]
	matrix urban = [urban_2005 \ urban_2015]
	matrix prov = [prov_2005 \ prov_2015]
	matrix nedi = [nedi_2005 \ nedi_2015]
	putexcel set "${gsdOutput}/Inequality/Raw_2_`m'.xls" , replace
	putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A22=("Nairobi") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") A34=("2005") A35=("Non-Nedi") A36=("Nedi") A38=("2015") A39=("Non-Nedi") A40=("Nedi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") F1=("Atkinson (e=1)") G1=("Atkinson (e=2)")
	putexcel B2=matrix(total)
	putexcel B6=matrix(rural)
	putexcel B10=matrix(urban)
	putexcel B15=matrix(prov_2005)
	putexcel B25=matrix(prov_2015)
	putexcel B35=matrix(nedi_2005)
	putexcel B39=matrix(nedi_2015)

}


//Obtain lorenz curve before-after corrections (using model 6 - best fit from AIC)
use "${gsdTemp}/Adjusted-weights_6.dta", clear

*National
glcurve y2_i [aw = wta_pop], pvar(x_values) glvar(y_values) lorenz nograph
glcurve y2_i [aw = wta_pop_6], pvar(x_values_adj) glvar(y_values_adj) lorenz nograph
replace x_values=100*x_values 
replace y_values=y_values*100
replace x_values_adj=100*x_values_adj 
replace y_values_adj=y_values_adj*100
sort x_*
graph twoway (line y_values x_values, ylabel(, angle(0) labsize(small)) ) ///
	  (line y_values_adj x_values_adj, yaxis(2) lpattern(-) ) ///
	  (function y = x, range(0 100) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)")  ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ylabel(0 "" 20 "" 40 "" 60 "" 80 "" 100 "")  ///
	   legend(label(1 "Original") label(2 "Adjusted") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_national-2015_adjusted", replace	  


*Urban
use "${gsdTemp}/Adjusted-weights_6.dta", clear
keep if kihbs==2015 & urban==1
glcurve y2_i [aw = wta_pop], pvar(x_values) glvar(y_values) lorenz nograph
glcurve y2_i [aw = wta_pop_6], pvar(x_values_adj) glvar(y_values_adj) lorenz nograph
replace x_values=100*x_values 
replace y_values=y_values*100
replace x_values_adj=100*x_values_adj 
replace y_values_adj=y_values_adj*100
sort x_*
graph twoway (line y_values x_values, ylabel(, angle(0) labsize(small)) ) ///
	  (line y_values_adj x_values_adj, yaxis(2) lpattern(-) ) ///
	  (function y = x, range(0 100) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)")  ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ylabel(0 "" 20 "" 40 "" 60 "" 80 "" 100 "")  ///
	   legend(label(1 "Original") label(2 "Adjusted") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_urban-2015_adjusted", replace	  


//Plot the change in sampling weights 
use "${gsdTemp}/Adjusted-weights_6.dta", clear
collapse (sum) wta_pop_6 wta_pop (max) non_resp_rate, by(clid)
keep if wta_pop_6<103000 & wta_pop<103000
graph twoway (scatter wta_pop wta_pop_6 if non_resp_rate==0) ///
        (scatter wta_pop wta_pop_6 if non_resp_rate!=0) ///
	  (function y = x, range(0 103000) ) ///  
      , xtitle("Sum of adjusted population weight by EA") legend(label(1 "EAs w/100% response rate") label(2 "EAs with nonresponse") label(3 "Same population weight"))   ///
	   ytitle("Sum of original population weight by EA") graphregion(color(white)) bgcolor(white) ///
	  xlabel(20000 "20,000" 40000 "40,000" 60000 "60,000" 80000 "80,000" 100000 "100,000")  ///
      ylabel(20000 "20,000" 40000 "40,000" 60000 "60,000" 80000 "80,000" 100000 "100,000", angle(0)) 
graph save "${gsdOutput}/Inequality/Change_weights_overall", replace	  


*********************************************************
* 4| CONSUMPTION MEASURES WITH ADJUSTED WEIGHTS
*********************************************************

//Prepare new dataset with adjusted weights
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
merge 1:1 kihbs clid hhid using "${gsdTemp}/Adjusted-weights_6.dta", nogen assert(match) keepusing(wta_pop_6)
rename wta_pop_6 wta_pop_adj
la var wta_pop_adj "Adjusted population weighting coefficient"

*Adjusted household weights 
gen scale_factor=wta_pop_adj/wta_pop
gen wta_hh_adj=scale_factor*wta_hh

*Scale uniformly to match totals at urban level 
bys kihbs: egen total_hhweight=sum(wta_hh) 
bys kihbs: egen prelim_tot=sum(wta_hh_adj) 

gen scale_tot=total_hhweight/prelim_tot
replace wta_hh_adj=wta_hh_adj*scale_tot
bys kihbs: egen check_tot=sum(wta_hh_adj) 
assert round(check_tot,1)==round(total_hhweight,1)
drop scale_factor total_hhweight prelim_tot scale_tot check_tot
la var wta_hh_adj "Adjusted household weight"
svyset clid [pw=wta_pop_adj] , strat(strat)
save "${gsdData}/1-CleanOutput/hh_adj_weights.dta", replace


//Consumption (Ksh) by decile 
use "${gsdData}/1-CleanOutput/hh.dta", clear

*National
preserve
*drop if province==8
egen texp_nat_rdec = xtile(rcons), weights(wta_hh) by(kihbs) p(10(10)90)
collapse (mean) mean_cons=rcons , by(kihbs texp_nat_rdec)
ren texp_nat_rdec decile
export excel using "${gsdOutput}/Inequality/Raw_3.xlsx", firstrow(variables) replace
restore

*Rural-Urban
*drop if province==8
egen texp_rurb_rdec = xtile(rcons) , weights(wta_hh) by(kihbs urban) p(10(10)90)
collapse (mean) mean_cons=rcons , by(kihbs urban texp_rurb_rdec)
ren texp_rurb_rdec decile
export excel using "${gsdOutput}/Inequality/Raw_4.xlsx", firstrow(variables) replace



//Growth incidence curves
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_hh] , strat(strat)
global cons = "rcons"

*Generating Percentiles 
foreach var in 2005 2015 {
        xtile pctile_`var'_total = $cons if kihbs == `var' [aw = wta_hh], nq(100)
		xtile pctile_`var'_rural = $cons if kihbs == `var' & urban==0 [aw = wta_hh], nq(100)
		xtile pctile_`var'_urban = $cons if kihbs == `var' & urban==1 [aw = wta_hh], nq(100) 
}
foreach var in 2005 2015 {
	forvalues i = 1 / 8 {
        xtile pctile_`i'_`var' = $cons if kihbs == `var' & province == `i' [aw = wta_hh], nq(100)
}
}
egen pctile_total = rowtotal(pctile_2005_total pctile_2015_total)
egen pctile_rural = rowtotal(pctile_2005_rural pctile_2015_rural)
egen pctile_urban = rowtotal(pctile_2005_urban pctile_2015_urban)
forvalues i = 1 / 8 {
	egen pctile_prov`i' = rowtotal(pctile_`i'_2005 pctile_`i'_2015)
}

*National level
svyset clid [pw=wta_hh] , strat(strat) 
qui tabout kihbs if pctile_total == 1 using "${gsdOutput}/Inequality/Raw_7.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - national percentil 1) replace
qui forval i = 2/100 {
	tabout kihbs if pctile_total == `i' using "${gsdOutput}/Inequality/Raw_7.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - national percentil `i') append
}

*Urban
qui tabout kihbs if urban==1 & pctile_urban == 1 using "${gsdOutput}/Inequality/Raw_8.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - urban percentil 1) replace
qui forval i = 2/100 {
	tabout kihbs if urban==1 &  pctile_urban == `i' using "${gsdOutput}/Inequality/Raw_8.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - urban percentil `i') append
}

*Rural 
qui tabout kihbs if urban==0 & pctile_rural == 1 using "${gsdOutput}/Inequality/Raw_9.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - rural percentil 1) replace
qui forval i = 2/100 {
	tabout kihbs if urban==0 &  pctile_rural == `i' using "${gsdOutput}/Inequality/Raw_9.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - rural percentil `i') append
}


*Between 2005 and 2015: create (100x11) matrix full of zeros. 
*        Each column will populated with the percentile annualized change 
*        in real consumption for a particular region (national, rural, urban 
*         and the 8 provinces).
svyset clid [pw=wta_pop] , strat(strat) 
matrix change = J(100, 11, 0)
forvalues x = 1/100 {
          quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_total == `x'
		  matrix change[`x', 1] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_total == `x'
		matrix change[`x', 1] = (((r(mean) / change[`x', 1])^(1/10)-1)*100)

		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_rural == `x' ///
		   & [urban == 0 ] 
		  matrix change[`x', 2] = r(mean)

  		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_rural == `x' ///
		   & [urban == 0 ]
			matrix change[`x', 2] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)
		   		 
		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_urban == `x' ///
		   & [urban == 1] 
		  matrix change[`x', 3] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_urban == `x' ///
		   & [urban == 1]
		matrix change[`x', 3] = (((r(mean) / change[`x', 3])^(1/10)-1)*100)
		   
		  forvalues i = 1 / 8 {
		  
		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_prov`i' == `x' ///
			& [province == `i'] 
			matrix change[`x', (3+`i')] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_prov`i' == `x' ///
		   & [province == `i']
			matrix change[`x', (3+`i')] = (((r(mean) / change[`x', 3+`i'])^(1/10)-1)*100)		  
}
}
svmat change, names(change)
gen x = _n if _n <= 100
forvalues i = 1/11 {
          lowess change`i' x, gen(schange`i') nograph
}
foreach x in 05 15 {
	sum $cons if kihbs == 20`x' [aw = wta_hh]
	scalar mean20`x'_total = r(mean)

	sum $cons if kihbs == 20`x' & urban == 0 [aw = wta_hh]
	scalar mean20`x'_rural = r(mean)

	sum $cons if kihbs == 20`x' & urban == 1 [aw = wta_hh]
	scalar mean20`x'_urban = r(mean)
	
	forvalues i = 1/8 {
		sum $cons if kihbs == 20`x' & province == `i' [aw = wta_hh]
		scalar mean20`x'_prov`i' = r(mean)
}
}
forvalues i = 1/8 {
	local mean_change_prov`i' = (((mean2015_prov`i' / mean2005_prov`i')^(1/10)-1)*100)
}
local mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
local mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
local mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)

*Graphs: national, rural and urban GICs
local i = 1
foreach s in National Rural Urban  {
        line schange`i' x, lcolor(navy) lpattern(solid) yline(`mean_change`i'') yscale(range(5 0)) ylabel(#5) yline(0	, lstyle(foreground)) xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("Annualized % change in real consumption", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`i', replace) graphregion(color(white)) bgcolor(white)
		local i = `i' + 1
}
graph combine gic1, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_national", replace
graph combine gic2, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_rural", replace
graph combine gic3, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_urban", replace

preserve 
gen mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
gen mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
gen mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)
keep x schange* mean_change*
drop if x>=.
export excel using "${gsdOutput}/Inequality/Raw_11.xlsx", firstrow(variables) replace
restore


*NEDI and Non-Nedi GICs 
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_hh] , strat(strat)
global cons = "rcons"
gen nedi_cat = 1 if nedi==0
replace nedi_cat = 2 if nedi==2
replace nedi_cat = 2 if nedi==1
label define lnedicat 1"Non-NEDI County" 2"NEDI County" , replace
label values nedi_cat lnedicat
label var nedi_cat "1=Non-NEDI County 2=NEDI county - FOR matrix in GIC"

*Generating Percentiles 
foreach var in 2005 2015 {
        xtile pctile_2_`var' = $cons if kihbs == `var' & nedi_cat == 2 [aw = wta_hh], nq(100)
}
egen pctile_nedi2 = rowtotal(pctile_2_2005 pctile_2_2015)

*NEDI
svyset clid [pw=wta_hh] , strat(strat)
qui tabout kihbs if nedi_cat==2 & pctile_nedi2 == 1 using "${gsdOutput}/Inequality/Raw_10.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - NEDI percentil 1) replace
qui forval i = 2/100 {
	tabout kihbs if nedi_cat==2 &  pctile_nedi2 == `i' using "${gsdOutput}/Inequality/Raw_10.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - NEDI percentil `i') append
}
	
*Between 2005 and 2015: create (100x8) matrix full of zeros. Each column will 
*populated with the percentile change in real consumption for the 2 NEDI categories)
svyset clid [pw=wta_pop] , strat(strat)
matrix change = J(100, 2, 0)
forvalues x = 1/100 {
			quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_nedi2 == `x' & nedi_cat == 1
			matrix change[`x', (1)] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_nedi2 == `x'   & nedi_cat == 1
			matrix change[`x', (1)] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)	

		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_nedi2 == `x' & nedi_cat == 2
			matrix change[`x', (2)] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_nedi2 == `x'   & nedi_cat == 2
			matrix change[`x', (2)] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)	
			
}
svmat change, names(change)
gen x = _n if _n <= 100
lowess change2 x, gen(schange2) nograph
lowess change1 x, gen(schange1) nograph
foreach x in 05 15 {
		sum $cons if kihbs == 20`x' & nedi_cat == 2 [aw = wta_hh]
		scalar mean20`x'_nedi2 = r(mean)
		
		sum $cons if kihbs == 20`x' & nedi_cat == 1 [aw = wta_hh]
		scalar mean20`x'_nedi1 = r(mean)
}
local mean_change_nedi2 = (((mean2015_nedi2 / mean2005_nedi2)^(1/10)-1)*100)
local mean_change_nedi1 = (((mean2015_nedi1 / mean2005_nedi1)^(1/10)-1)*100)

*Graphs: Non-NEDI and NEDI GICs
line schange2 x, lcolor(navy) lpattern(solid) yline(`mean_change_nedi2') yscale(range(8 0)) ylabel(#8) yline(0 , lstyle(foreground))  xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("Annualized % change in real consumption", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic2, replace) graphregion(color(white)) bgcolor(white)
graph combine gic2, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_nedi", replace
graph combine gic1, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_non-nedi", replace

preserve 
gen mean_change_nedi2 = (((mean2015_nedi2 / mean2005_nedi2)^(1/10)-1)*100)
gen mean_change_nedi1 = (((mean2015_nedi1 / mean2005_nedi1)^(1/10)-1)*100)
keep x schange* mean_change*
drop if x>=.
export excel using "${gsdOutput}/Inequality/Raw_12.xlsx", firstrow(variables) replace
restore


//Growth incidence curves [Excluding Nairobi]
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_hh] , strat(strat)
global cons = "rcons"

drop if province==8

*Generating Percentiles 
foreach var in 2005 2015 {
        xtile pctile_`var'_total = $cons if kihbs == `var' [aw = wta_hh], nq(100)
		xtile pctile_`var'_rural = $cons if kihbs == `var' & urban==0 [aw = wta_hh], nq(100)
		xtile pctile_`var'_urban = $cons if kihbs == `var' & urban==1 [aw = wta_hh], nq(100) 
}
foreach var in 2005 2015 {
	forvalues i = 1 / 7 {
        xtile pctile_`i'_`var' = $cons if kihbs == `var' & province == `i' [aw = wta_hh], nq(100)
}
}
egen pctile_total = rowtotal(pctile_2005_total pctile_2015_total)
egen pctile_rural = rowtotal(pctile_2005_rural pctile_2015_rural)
egen pctile_urban = rowtotal(pctile_2005_urban pctile_2015_urban)
forvalues i = 1 / 7 {
	egen pctile_prov`i' = rowtotal(pctile_`i'_2005 pctile_`i'_2015)
}

*Between 2005 and 2015: create (100x11) matrix full of zeros. 
*        Each column will populated with the percentile annualized change 
*        in real consumption for a particular region (national, rural, urban 
*         and the 8 provinces).
svyset clid [pw=wta_pop] , strat(strat) 
matrix change = J(100, 11, 0)
forvalues x = 1/100 {
          quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_total == `x'
		  matrix change[`x', 1] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_total == `x'
		matrix change[`x', 1] = (((r(mean) / change[`x', 1])^(1/10)-1)*100)

		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_rural == `x' ///
		   & [urban == 0 ] 
		  matrix change[`x', 2] = r(mean)

  		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_rural == `x' ///
		   & [urban == 0 ]
			matrix change[`x', 2] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)
		   		 
		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_urban == `x' ///
		   & [urban == 1] 
		  matrix change[`x', 3] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_urban == `x' ///
		   & [urban == 1]
		matrix change[`x', 3] = (((r(mean) / change[`x', 3])^(1/10)-1)*100)
		   
		  forvalues i = 1 / 7 {
		  
		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_prov`i' == `x' ///
			& [province == `i'] 
			matrix change[`x', (3+`i')] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_prov`i' == `x' ///
		   & [province == `i']
			matrix change[`x', (3+`i')] = (((r(mean) / change[`x', 3+`i'])^(1/10)-1)*100)		  
}
}
svmat change, names(change)
gen x = _n if _n <= 100
forvalues i = 1/10 {
          lowess change`i' x, gen(schange`i') nograph
}
foreach x in 05 15 {
	sum $cons if kihbs == 20`x' [aw = wta_hh]
	scalar mean20`x'_total = r(mean)

	sum $cons if kihbs == 20`x' & urban == 0 [aw = wta_hh]
	scalar mean20`x'_rural = r(mean)

	sum $cons if kihbs == 20`x' & urban == 1 [aw = wta_hh]
	scalar mean20`x'_urban = r(mean)
	
	forvalues i = 1/7 {
		sum $cons if kihbs == 20`x' & province == `i' [aw = wta_hh]
		scalar mean20`x'_prov`i' = r(mean)
}
}
forvalues i = 1/7 {
	local mean_change_prov`i' = (((mean2015_prov`i' / mean2005_prov`i')^(1/10)-1)*100)
}
local mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
local mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
local mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)

*Graphs: national, rural and urban GICs
local i = 1
foreach s in National Rural Urban  {
        line schange`i' x, lcolor(navy) lpattern(solid) yline(`mean_change`i'') yscale(range(5 0)) ylabel(#5) yline(0	, lstyle(foreground)) xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("Annualized % change in real consumption", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`i', replace) graphregion(color(white)) bgcolor(white)
		local i = `i' + 1
}
graph combine gic1, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_national_exc-Nairobi", replace
graph combine gic2, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_rural", replace
graph combine gic3, iscale(*0.9) graphregion(color(white)) 
graph save "${gsdOutput}/Inequality/GIC_urban_exc-Nairobi", replace

preserve 
gen mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
gen mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
gen mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)
keep x schange* mean_change*
drop if x>=.
export excel using "${gsdOutput}/Inequality/Raw_13.xlsx", firstrow(variables) replace
restore


//Real consumption growth (bottom 40 vs. top 60)
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_hh] , strat(strat)

*Total expenditure quintiles
egen texp_nat_quint = xtile(rcons) , weights(wta_hh) by(kihbs) p(20(20)80)
egen texp_rurb_quint = xtile(rcons) , weights(wta_hh) by(kihbs urban) p(20(20)80)
egen texp_prov_quint = xtile(rcons) , weights(wta_hh) by(kihbs province) p(20(20)80)
label var texp_nat_quint "Total real monthly per adq expenditure quintiles (National)"
label var texp_rurb_quint "Total real monthly per adq expenditure quintiles (Rural / Urban)"
label var texp_prov_quint "Total real monthly per adq expenditure quintiles (Provincial)"

*bottom 40% of total expenditure (equivalent to the bottom 2 quintiles)
gen b40_nat=cond(texp_nat_quint<3,1,0)
gen b40_rurb=cond(texp_rurb_quint<3,1,0)
gen b40_prov=cond(texp_prov_quint<3,1,0)
label var b40_nat "Bottom 40 percent (Nationally)"
label var b40_rurb "Bottom 40 percent (Rural / Urban)"
label var b40_prov "Bottom 40 percent (Provincially)"

*National 
qui tabout kihbs using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - national) replace
qui tabout b40_nat kihbs using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h1(Real consumption - national top/bottom) append

*Urban/Rural
qui tabout kihbs if urban==1 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - urban) append
qui tabout b40_rurb kihbs if urban==1 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h1(Real consumption - urban top/bottom) append
qui tabout kihbs if urban==0 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - rural) append
qui tabout b40_rurb kihbs if urban==0 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h1(Real consumption - rural top/bottom) append

*By province
qui forval i=1/8 {
	tabout kihbs if province==`i' using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - province `i') append
	tabout b40_prov kihbs if province==`i' using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h1(Real consumption - province `i' top/bottom) append
}

// Total expenditure quintiles [Excluding Nairobi]
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_hh] , strat(strat)
drop if province==8
egen texp_nat_quint = xtile(rcons) , weights(wta_hh) by(kihbs) p(20(20)80)
egen texp_rurb_quint = xtile(rcons) , weights(wta_hh) by(kihbs urban) p(20(20)80)
egen texp_prov_quint = xtile(rcons) , weights(wta_hh) by(kihbs province) p(20(20)80)
label var texp_nat_quint "Total real monthly per adq expenditure quintiles (National)"
label var texp_rurb_quint "Total real monthly per adq expenditure quintiles (Rural / Urban)"
label var texp_prov_quint "Total real monthly per adq expenditure quintiles (Provincial)"

*bottom 40% of total expenditure (equivalent to the bottom 2 quintiles)
gen b40_nat=cond(texp_nat_quint<3,1,0)
gen b40_rurb=cond(texp_rurb_quint<3,1,0)
gen b40_prov=cond(texp_prov_quint<3,1,0)
label var b40_nat "Bottom 40 percent (Nationally)"
label var b40_rurb "Bottom 40 percent (Rural / Urban)"
label var b40_prov "Bottom 40 percent (Provincially)"

*National [Excluding Nairobi]
qui tabout kihbs using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - national) append
qui tabout b40_nat kihbs using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h1(Real consumption - national top/bottom) append

*Urban/Rural [Excluding Nairobi]
qui tabout kihbs if urban==1 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - urban) append
qui tabout b40_rurb kihbs if urban==1 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h1(Real consumption - urban top/bottom) append
qui tabout kihbs if urban==0 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h2(Real consumption - rural) append
qui tabout b40_rurb kihbs if urban==0 using "${gsdOutput}/Inequality/Raw_5.csv", svy sum c(mean rcons se) sebnone f(3) npos(col) h1(Real consumption - rural top/bottom) append


*********************************************************
* 5| INEQUALITY MEASURES AFTER CORRECTIONS IN 2015/16
*********************************************************

//Prepare the dataset 
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_pop] , strat(strat)


//Inequality measures in 2005/6 and 2015/16
*Urban-Rural and by province
qui foreach var in 2005 2015  {
	ineqdeco y2_i if kihbs == `var' [aw = wta_pop]
	matrix total_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)]
		
	ineqdeco y2_i if kihbs == `var' & urban == 0 [aw = wta_pop]
    matrix rural_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)] 
 	
	ineqdeco y2_i if kihbs == `var' & urban == 1 [aw = wta_pop]
	matrix urban_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2) ]
}
qui foreach var in 2005 2015  {
	forvalues i = 1 / 8{
		ineqdeco y2_i if kihbs == `var' & province==`i'  [aw = wta_pop]
		matrix prov_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
qui foreach var in 2005 2015  {
	forvalues i = 0 / 1{
		ineqdeco y2_i if kihbs == `var' & nedi==`i'  [aw = wta_pop]
		matrix nedi_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
matrix nedi_2005 = [nedi_0_2005 \ nedi_1_2005]
matrix nedi_2015 = [nedi_0_2015 \ nedi_1_2015]
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]
matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]
matrix prov = [prov_2005 \ prov_2015]
matrix nedi = [nedi_2005 \ nedi_2015]
putexcel set "${gsdOutput}/Inequality/Raw_6.xlsx" , replace
putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A22=("Nairobi") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") A34=("2005") A35=("Non-Nedi") A36=("Nedi") A38=("2015") A39=("Non-Nedi") A40=("Nedi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") F1=("Atkinson (e=1)") G1=("Atkinson (e=2)")
putexcel B2=matrix(total)
putexcel B6=matrix(rural)
putexcel B10=matrix(urban)
putexcel B15=matrix(prov_2005)
putexcel B25=matrix(prov_2015)
putexcel B35=matrix(nedi_2005)
putexcel B39=matrix(nedi_2015)



//Inequality between and within groups 
putexcel D44=("Within") 
putexcel E44=("Between") 

*Overall by urban/rural
putexcel A43=("Between/Within inequality: Overall by urban/rural") 
putexcel A45=("2005/6") 
putexcel A46=("2015/16") 
ineqdeco y2_i if kihbs==2005 [aw = wta_pop], bygroup(urban)
putexcel D45=`r(within_ge1)'
putexcel E45=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 [aw = wta_pop], bygroup(urban)
putexcel D46=`r(within_ge1)'
putexcel E46=`r(between_ge1)'

*Overall by province
putexcel A48=("Between/Within inequality: Overall by province") 
putexcel A49=("2005/6") 
putexcel A50=("2015/16") 
ineqdeco y2_i if kihbs==2005 [aw = wta_pop], bygroup(province)
putexcel D49=`r(within_ge1)'
putexcel E49=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 [aw = wta_pop], bygroup(province)
putexcel D50=`r(within_ge1)'
putexcel E50=`r(between_ge1)'

*By urban counties
putexcel A52=("Between/Within inequality: By urban counties") 
putexcel A53=("2005/6") 
putexcel A54=("2015/16") 
ineqdeco y2_i if kihbs==2005 & urban==1 [aw = wta_pop], bygroup(county)
putexcel D53=`r(within_ge1)'
putexcel E53=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 & urban==1 [aw = wta_pop], bygroup(county)
putexcel D54=`r(within_ge1)'
putexcel E54=`r(between_ge1)'

*By rural counties
putexcel A56=("Between/Within inequality: By rural counties") 
putexcel A57=("2005/6") 
putexcel A58=("2015/16") 
ineqdeco y2_i if kihbs==2005 & urban==0 [aw = wta_pop], bygroup(county)
putexcel D57=`r(within_ge1)'
putexcel E57=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 & urban==0 [aw = wta_pop], bygroup(county)
putexcel D58=`r(within_ge1)'
putexcel E58=`r(between_ge1)'



//Map of changes in Gini coefficient by county 
qui forval i=1/47 {
	fastgini y2_i if kihbs==2005 & county==`i' [pw = wta_pop]
	gen gini_05_`i'=r(gini)
	fastgini y2_i if kihbs==2015 & county==`i' [pw = wta_pop]
	gen gini_15_`i'=r(gini)
}
gen gini_05_county=.
gen gini_15_county=.
qui forval i=1/47 {
	replace gini_05_county=gini_05_`i' if county==`i' & kihbs==2005
	replace gini_15_county=gini_15_`i' if county==`i' & kihbs==2015
}
*Obtain Gini per county for both surveys
gen gini_county=gini_05_county if kihbs==2005
replace gini_county=gini_15_county if kihbs==2015
drop gini_05_* gini_15_*
collapse (max) gini_county, by(county kihbs)
reshape wide gini_county, i(county) j(kihbs)
gen diff_gini=gini_county2005-gini_county2015
gen per_diff_gini=(gini_county2015/gini_county2005-1)*100

*File to produce maps on ArcGIS 
sdecode county, gen(county_string)
replace county_string="Elgeyo-Marakwet" if county_string=="Elgeyo Marakwet"
replace county_string="Murang'a" if county_string=="Muranga"
replace county_string="Tharaka-Nithi" if county_string=="Tharaka Nithi"
preserve
gen x="KE0"
gen z=0
egen prelim=concat(x z county)
egen ADM1_PCODE=concat(x county)
replace ADM1_PCODE=prelim if county<10
drop county x z prelim
export excel using "${gsdOutput}/Inequality/Data_Change_Gini.xlsx", firstrow(variables) replace
restore

*Maps on Stata
rename county county_code_KIHBS
merge 1:1 county_code_KIHBS using "${gsdDataRaw}/3-Gender/Shape/counties_3.dta", nogen assert(match)
spmap per_diff_gini using "${gsdDataRaw}/3-Gender/Shape/KenyaCountyPolys_coord.dta", id(_ID) clmethod(custom) fcolor(YlOrRd) clnumber(6) clbreaks(-40 -30 -20 -10 0 10 20) ///
       title(% change in Gini inequality index) subtitle(2005/6 - 2015/16) legend(position(8)) legstyle(2) legjunction(" to ") graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Change_Gini_Counties", replace	  



//Lorenz curves
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_pop] , strat(strat)

*National
glcurve y2_i [aw = wta_pop], by(kihbs) split pvar(x_values) glvar(y_values) lorenz nograph
replace x_values=100*x_values 
replace y_values_2005=y_values_2005*100 
replace y_values_2015=y_values_2015*100
sort x_values
graph twoway (line y_values_2005 x_values, yaxis(1 2) ) ///
	  (line y_values_2015 x_values, yaxis(1 2) ) ///
	  (function y = x, range(0 100) yaxis(1 2) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)") ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ///
	   legend(label(1 "2005/6") label(2 "2015/16") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_national", replace	  

*Urban
glcurve y2_i [aw = wta_pop] if urban==1, by(kihbs) split pvar(x_values_urb) glvar(y_values_urb) lorenz nograph
replace x_values_urb=100*x_values_urb 
replace y_values_urb_2005=y_values_urb_2005*100 
replace y_values_urb_2015=y_values_urb_2015*100
sort x_values_urb
graph twoway (line y_values_urb_2005 x_values_urb, yaxis(1 2) ) ///
	  (line y_values_urb_2015 x_values_urb, yaxis(1 2) ) ///
	  (function y = x, range(0 100) yaxis(1 2) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)") ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ///
	   legend(label(1 "2005/6") label(2 "2015/16") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_urban", replace	  

*Rural
glcurve y2_i [aw = wta_pop] if urban==0, by(kihbs) split pvar(x_values_rur) glvar(y_values_rur) lorenz nograph
replace x_values_rur=100*x_values_rur 
replace y_values_rur_2005=y_values_rur_2005*100 
replace y_values_rur_2015=y_values_rur_2015*100
sort x_values_rur
graph twoway (line y_values_rur_2005 x_values_rur, yaxis(1 2) ) ///
	  (line y_values_rur_2015 x_values_rur, yaxis(1 2) ) ///
	  (function y = x, range(0 100) yaxis(1 2) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)") ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ///
	   legend(label(1 "2005/6") label(2 "2015/16") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_rural", replace	  



//Same resuts but excluding Nairobi
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
drop if province==8

//Inequality measures in 2005/6 and 2015/16
*Urban-Rural and by province
qui foreach var in 2005 2015  {
	ineqdeco y2_i if kihbs == `var' [aw = wta_pop]
	matrix total_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)]
		
	ineqdeco y2_i if kihbs == `var' & urban == 0 [aw = wta_pop]
    matrix rural_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)] 
 	
	ineqdeco y2_i if kihbs == `var' & urban == 1 [aw = wta_pop]
	matrix urban_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2) ]
}
qui foreach var in 2005 2015  {
	forvalues i = 1 / 7 {
		ineqdeco y2_i if kihbs == `var' & province==`i'  [aw = wta_pop]
		matrix prov_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
qui foreach var in 2005 2015  {
	forvalues i = 0 / 1{
		ineqdeco y2_i if kihbs == `var' & nedi==`i'  [aw = wta_pop]
		matrix nedi_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
matrix nedi_2005 = [nedi_0_2005 \ nedi_1_2005]
matrix nedi_2015 = [nedi_0_2015 \ nedi_1_2015]
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 ]
matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]
matrix prov = [prov_2005 \ prov_2015]
matrix nedi = [nedi_2005 \ nedi_2015]
putexcel set "${gsdOutput}/Inequality/Raw_6_B.xlsx" , replace
putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") A34=("2005") A35=("Non-Nedi") A36=("Nedi") A38=("2015") A39=("Non-Nedi") A40=("Nedi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") F1=("Atkinson (e=1)") G1=("Atkinson (e=2)")
putexcel B2=matrix(total)
putexcel B6=matrix(rural)
putexcel B10=matrix(urban)
putexcel B15=matrix(prov_2005)
putexcel B25=matrix(prov_2015)
putexcel B35=matrix(nedi_2005)
putexcel B39=matrix(nedi_2015)


//Inequality between and within groups 
putexcel D44=("Within") 
putexcel E44=("Between") 

*Overall by urban/rural
putexcel A43=("Between/Within inequality: Overall by urban/rural") 
putexcel A45=("2005/6") 
putexcel A46=("2015/16") 
ineqdeco y2_i if kihbs==2005 [aw = wta_pop], bygroup(urban)
putexcel D45=`r(within_ge1)'
putexcel E45=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 [aw = wta_pop], bygroup(urban)
putexcel D46=`r(within_ge1)'
putexcel E46=`r(between_ge1)'

*Overall by province
putexcel A48=("Between/Within inequality: Overall by province") 
putexcel A49=("2005/6") 
putexcel A50=("2015/16") 
ineqdeco y2_i if kihbs==2005 [aw = wta_pop], bygroup(province)
putexcel D49=`r(within_ge1)'
putexcel E49=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 [aw = wta_pop], bygroup(province)
putexcel D50=`r(within_ge1)'
putexcel E50=`r(between_ge1)'

*By urban counties
putexcel A52=("Between/Within inequality: By urban counties") 
putexcel A53=("2005/6") 
putexcel A54=("2015/16") 
ineqdeco y2_i if kihbs==2005 & urban==1 [aw = wta_pop], bygroup(county)
putexcel D53=`r(within_ge1)'
putexcel E53=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 & urban==1 [aw = wta_pop], bygroup(county)
putexcel D54=`r(within_ge1)'
putexcel E54=`r(between_ge1)'

*By rural counties
putexcel A56=("Between/Within inequality: By rural counties") 
putexcel A57=("2005/6") 
putexcel A58=("2015/16") 
ineqdeco y2_i if kihbs==2005 & urban==0 [aw = wta_pop], bygroup(county)
putexcel D57=`r(within_ge1)'
putexcel E57=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 & urban==0 [aw = wta_pop], bygroup(county)
putexcel D58=`r(within_ge1)'
putexcel E58=`r(between_ge1)'

//Lorenz curves [Excluding Nairobi]
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
drop if province==8

*National
glcurve y2_i [aw = wta_pop], by(kihbs) split pvar(x_values) glvar(y_values) lorenz nograph
replace x_values=100*x_values 
replace y_values_2005=y_values_2005*100 
replace y_values_2015=y_values_2015*100
sort x_values
graph twoway (line y_values_2005 x_values, yaxis(1 2) ) ///
	  (line y_values_2015 x_values, yaxis(1 2) ) ///
	  (function y = x, range(0 100) yaxis(1 2) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)") ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ///
	   legend(label(1 "2005/6") label(2 "2015/16") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_national_Exc-Nairobi", replace	  

*Urban
glcurve y2_i [aw = wta_pop] if urban==1, by(kihbs) split pvar(x_values_urb) glvar(y_values_urb) lorenz nograph
replace x_values_urb=100*x_values_urb 
replace y_values_urb_2005=y_values_urb_2005*100 
replace y_values_urb_2015=y_values_urb_2015*100
sort x_values_urb
graph twoway (line y_values_urb_2005 x_values_urb, yaxis(1 2) ) ///
	  (line y_values_urb_2015 x_values_urb, yaxis(1 2) ) ///
	  (function y = x, range(0 100) yaxis(1 2) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)") ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ///
	   legend(label(1 "2005/6") label(2 "2015/16") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_urban_Exc-Nairobi", replace	  

*Rural
glcurve y2_i [aw = wta_pop] if urban==0, by(kihbs) split pvar(x_values_rur) glvar(y_values_rur) lorenz nograph
replace x_values_rur=100*x_values_rur 
replace y_values_rur_2005=y_values_rur_2005*100 
replace y_values_rur_2015=y_values_rur_2015*100
sort x_values_rur
graph twoway (line y_values_rur_2005 x_values_rur, yaxis(1 2) ) ///
	  (line y_values_rur_2015 x_values_rur, yaxis(1 2) ) ///
	  (function y = x, range(0 100) yaxis(1 2) )   ///
       , aspect(1) xtitle("Cumulative share of population (%)") ///
	   ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2)) ///
	   ytitle("Share of total consumption expenditure (%)", axis(1)) ytitle(" ", axis(2)) ///
	   legend(label(1 "2005/6") label(2 "2015/16") label(3 "Equality")) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/Inequality/Lorenz_rural_Exc-Nairobi", replace	  




*********************************************************
* 6| INTEGRATE ALL SHEETS INTO ONE FILE
*********************************************************

*Figures before corrections
import excel "${gsdOutput}/Inequality/Raw_1.xls", sheet("Sheet1") case(lower) allstring clear
export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheet("Raw_1") sheetreplace
erase "${gsdOutput}/Inequality/Raw_1.xls"

*Logit estimates
import delimited "${gsdOutput}/Inequality/Logit_Non-response.txt", clear 
export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheetreplace sheet("Logit")
erase "${gsdOutput}/Inequality/Logit_Non-response.txt"
erase "${gsdOutput}/Inequality/Logit_Non-response.xls"

*Results from each logit model
forval i=1/6 { 
	import excel "${gsdOutput}/Inequality/Raw_2_`i'.xls", clear 
	export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheetreplace sheet("Logit_`i'")
	erase "${gsdOutput}/Inequality/Raw_2_`i'.xls"
}

*All the results after adjusting the sampling weights
forval i=3/4 {
	import excel "${gsdOutput}/Inequality/Raw_`i'.xlsx", sheet("Sheet1") case(lower) firstrow allstring clear
	export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheet("Raw_`i'") sheetreplace
	erase "${gsdOutput}/Inequality/Raw_`i'.xlsx"
}

import delimited "${gsdOutput}/Inequality/Raw_5.csv", delimiter(tab) clear 
export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheet("Raw_5") sheetreplace
erase "${gsdOutput}/Inequality/Raw_5.csv"

import excel "${gsdOutput}/Inequality/Raw_6.xlsx", sheet("Sheet1") case(lower) allstring clear
export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheet("Raw_6") sheetreplace
erase "${gsdOutput}/Inequality/Raw_6.xlsx"

import excel "${gsdOutput}/Inequality/Raw_6_B.xlsx", sheet("Sheet1") case(lower) allstring clear
export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheet("Raw_6_B") sheetreplace
erase "${gsdOutput}/Inequality/Raw_6_B.xlsx"

*Data for GICs
forval i=7/10 {
	import delimited "${gsdOutput}/Inequality/Raw_`i'.csv", delimiter(tab) clear 
	export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheet("Raw_`i'") sheetreplace
	erase "${gsdOutput}/Inequality/Raw_`i'.csv"
}
forval i=11/13 {
	import excel "${gsdOutput}/Inequality/Raw_`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	export excel using "${gsdOutput}/Inequality/figures_v4.xlsx", sheet("Raw_`i'") sheetreplace
	erase "${gsdOutput}/Inequality/Raw_`i'.xlsx"
}

