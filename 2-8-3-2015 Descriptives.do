/*
KIHBS 2005/2006
Stephan Dietrich 15.1.2017, Arden Finn 8 February 2018
descriptive analysis
*/

clear
set more off
*Carolina*
*global path "C:\Users\wb445085\Box Sync\KPGA\Social Protection data\KIBHS05_06" 
*Stephan*
*global path "C:\Users\s.dietrich\Box Sync\KPGA\Social Protection data\KIBHS05_06" 
*Arden
global path "C:\Users\wb512260\OneDrive - WBG\Kenya\PGA 2018\Do Files\Full Data Do Files\2015"

global in "${gsdData}/2-AnalysisOutput/C8-Vulnerability"
global out "${gsdOutput}/C8-Vulnerability"


use "$in\kibhs15_16.dta" , clear

cd "$out"
**which weights: wta_pop or wta_hh
*Choosing HH weights here because that's the unit of analysis for shocks
global weight [w=wta_hh]
*psu? strata?*
svyset $weight

*Poverty and vulnerability rates
tab poor [aw=wta_pop]
tab vulnerable4 [aw=wta_pop]
tab poor [aw=wta_pop] if urban==1
tab vulnerable4 [aw=wta_pop] if urban==1
tab poor [aw=wta_pop] if urban==0
tab vulnerable4 [aw=wta_pop] if urban==0

*Short profiles
tab hhsector [aw=wta_pop]
tab hhsector [aw=wta_pop] if poor==1
tab hhsector [aw=wta_pop] if vulnerable4==1

tab hhedu [aw=wta_pop]
tab hhedu [aw=wta_pop] if poor==1
tab hhedu [aw=wta_pop] if vulnerable4==1

tab urban [aw=wta_pop]
tab urban [aw=wta_pop] if poor==1
tab urban [aw=wta_pop] if vulnerable4==1

tab malehead [aw=wta_pop]
tab malehead [aw=wta_pop] if poor==1
tab malehead [aw=wta_pop] if vulnerable4==1

*A closer look at vulnerability in agricultural households by arid/semi-arid regions
/*List of the 23 arid and semi-arid counties from this document:
http://www.fao.org/fileadmin/user_upload/drought/docs/Vision2030%20development%20strategy%20for%20northern%20kenya%20and%20other%20dry%20areas%202011%20.pdf
*/
gen aridsa=(county==7|county==9|county==8|county==10|county==11|county==23 ///
|county==25|county==30|county==4|county==15|county==17|county==12|county==13 ///
|county==14|county==19|county==24|county==33|county==34|county==31|county==3 ///
|county==2|county==5|county==6)
tab hhsector [aw=wta_pop] if poor==1 & aridsa==1


*Vulnerability conditional on characteristics
tab hhsector vulnerable4 [aw=wta_pop], r nof
tab urban vulnerable4 [aw=wta_pop], r nof
tab hhedu vulnerable4 [aw=wta_pop], r nof
tab malehead vulnerable4 [aw=wta_pop], r nof

*Vulnerability rates by county (then getting the bar shading to match the map shading)
graph bar (mean) vulnerable4 [pweight=wta_pop], over(county, sort(vulnerable4) ///
label(angle(forty_five) labsize(vsmall))) ytitle(Vulnerability rate) ///
yscale(noextend nofextend) yline(0.5167562, lpattern(dash) lcolor(gray) ///
noextend) ylabel(0(0.1)1, angle(forty_five)) ymtick(0(0.05)1) ///
plotregion(margin(zero))
forvalues q=1/9 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(247 251 255)))
}
forvalues q=10/17 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(222 235 247)))
}
forvalues q=18/24 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(198 219 239)))
}
forvalues q=25/31 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(158 202 225)))
}
forvalues q=32/35 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(107 174 214)))
}
forvalues q=36/37 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(66 145 198)))
}
gr_edit .plotregion1.bars[38].EditCustomStyle , j(-1) style(shadestyle(color(33 115 181)))
forvalues q=39/42 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(8 81 156)))
}
forvalues q=43/47 {
gr_edit .plotregion1.bars[`q'].EditCustomStyle , j(-1) style(shadestyle(color(8 48 107)))
}
gr_edit .plotregion1.AddLine added_lines editor .1008990499564145 .5174826425499874 99.69193946083438 .5174826425499874
gr_edit .plotregion1.added_lines_new = 1
gr_edit .plotregion1.added_lines_rec = 1
*gr_edit .plotregion1.added_lines[1].style.editstyle  linestyle( width(medium) color(gray) pattern(dash)) headstyle( symbol(circle) linestyle( width(thin) color(gray) pattern(solid)) fillcolor(gray) size(medium) angle(stdarrow) symangle(zero) backsymbol(none) backline( width(thin) color(black) pattern(solid) ) backcolor(black) backsize(zero) backangle(stdarrow) backsymangle(zero)) headpos(neither) editcopygr_edit .plotregion1._xylines[1].draw_view.setstyle, style(no)
local i=0
local j=0
local k=11
while `i'<1.1 {
while `j'<101 {
while `k'>0 {
gr_edit .scaleaxis.major.num_rule_ticks = `k'
gr_edit .scaleaxis.edit_tick 1 `i' `"`j'%"', tickset(major)
local i=`i'+0.1
local j=`j'+10
local k=`k'-1
}
}
}
gr_edit .scaleaxis.style.editstyle majorstyle(tickstyle(textstyle(size(vsmall)))) editcopy

/*
*Vulnerability rates bar chart with graded colouring
DIDN'T QUITE GET THIS RIGHT
preserve
collapse (mean) vulnerable4 [w=wta_pop], by(county)
recode vulnerable4 (0/0.35=1) (0.3501/0.5=2) (0.5001/0.6=3) (0.6001/0.65=4) ///
(0.6501/0.7=5) (0.7001/0.75=6) (0.7501/0.8=7) (0.8001/0.9=8) (0.9001/1=9), ///
gen(vulngroup)
gen vulncat1=vulnerable4 if vulngroup==1
gen vulncat2=vulnerable4 if vulngroup==2
gen vulncat3=vulnerable4 if vulngroup==3
gen vulncat4=vulnerable4 if vulngroup==4
gen vulncat5=vulnerable4 if vulngroup==5
gen vulncat6=vulnerable4 if vulngroup==6
gen vulncat7=vulnerable4 if vulngroup==7
gen vulncat8=vulnerable4 if vulngroup==8
gen vulncat9=vulnerable4 if vulngroup==9

graph bar (mean) vulncat1 (mean) vulncat2 (mean) vulncat3 (mean) vulncat4 (mean) ///
vulncat5 (mean) vulncat6 (mean) vulncat7 (mean) vulncat8 (mean) vulncat9, ///
over(county, sort(vulnerable4) label(angle(forty_five) labsize(vsmall))) ///
ytitle(Vulnerability rate) ///
yscale(noextend nofextend) yline(0.5167562, lpattern(dash) lcolor(gray) noextend) ///
ylabel(0(0.1)1, angle(forty_five)) ymtick(0(0.05)1) ///
plotregion(margin(zero)) ///
bar(1,color(247	251	255)) ///
bar(2,color(222	235	247)) ///
bar(3,color(198	219	239)) ///
bar(4,color(158	202	225)) ///
bar(5,color(107	174	214)) ///
bar(6,color(66 145 198)) ///
bar(7,color(33 115 181)) ///
bar(8,color(8 81 156)) ///
bar(9,color(8 48 107)) ///
legend(off) 

graph bar (mean) vulncat1 (mean) vulncat2 (mean) vulncat3 ///
(mean) vulncat4 (mean) vulncat5 (mean) vulncat6 ///
(mean) vulncat7 (mean) vulncat8 (mean) vulncat9 [w=weight], ///
over(county, sort(vulnerable4) ///
label(angle(forty_five) labsize(vsmall))) ytitle(Vulnerability rate) ///
yscale(noextend nofextend) yline(0.5167562, lpattern(dash) lcolor(gray) ///
noextend) ylabel(0(0.1)1, angle(forty_five)) ymtick(0(0.05)1) ///
plotregion(margin(zero))

restore*/


*Vulnerable position relative to the poverty line
*GRAPHS OF AEQ CONSUMPTION EXPENDITURE FOR THE VULNERABLE AND THE POOR
gen percpline=100*(y2_i/z2_i)
gen bucket = floor((500-1+1)*runiform() + 1)

*Vulnerable and poor
twoway (scatter percpline bucket, msize(vsmall) msymbol(circle)) ///
(function y=100, range(0 500) lcolor(red) lwidth(medthick)) ///
if vulnerable4==1 & poor==1, ///
ytitle(Consumption as percentage of poverty line) ///
ylabel(, angle(forty_five)) ymtick(20(10)100) xtitle(, size(zero)) ///
xline(510, lwidth(thin) lcolor(black)) xlabel(none) title(Poor households) legend(off)

*Vulnerable
twoway (scatter percpline bucket, msize(vsmall) msymbol(circle)) ///
(function y=100, range(0 500) lcolor(red) lwidth(medthick)) ///
if vulnerable4==1 & percpline<300, ///
ytitle(Consumption as percentage of poverty line) ///
ylabel(, angle(forty_five)) ymtick(50(50)300) xtitle(, size(zero)) ///
xline(510, lwidth(thin) lcolor(black)) xlabel(none) title(Vulnerable households) legend(off)

*Vulnerable with two colours
twoway (scatter percpline bucket if poor==1 & vulnerable4==1, mcolor(navy) ///
msize(vsmall) msymbol(circle)) (scatter percpline bucket if vulnerable4==1 ///
& poor==0, mcolor(maroon) msize(vsmall) msymbol(circle)) (function y=100, ///
range(0 500) lcolor(black) lwidth(medthick)) if vulnerable4==1 & ///
percpline<300, ytitle(Consumption as % of poverty line) ylabel(, ///
angle(forty_five)) ymtick(50(50)300) xtitle(, size(zero)) xline(501, ///
lwidth(thin) lcolor(black)) xlabel(none) /*title(Vulnerable households)*/ ///
legend(on order(1 "Poor and vulnerable" 2 "Non-poor and vulnerable" ///
3 "Poverty line")) plotregion(margin(tiny)) graphregion(fcolor(white))

*Vulnerability rates by poor and non-poor
tab poor vulnerable4 [aw=wta_pop], r nof
gen poor2=1 
replace poor2=2 if poor==0
gen nonvuln=vulnerable4==0
graph bar (mean) vulnerable4 (mean) nonvuln [pweight = wta_pop] if ///
vulnerable4!=., over(poor2) stack legend(on order(1 "Poor" 2 "Non-poor")) blabel(bar)
graph bar (mean) vulnerable4 (mean) nonvuln [pweight = wta_pop] if ///
vulnerable4!=., over(poor2) over(urban) stack legend(on order(1 "Poor" 2 "Non-poor")) blabel(bar)
tab vulnerable4 if poor==1 & urban==0 [aw=wta_pop]
tab vulnerable4 if poor==1 & urban==1 [aw=wta_pop]
tab vulnerable4 if poor==0 & urban==0 [aw=wta_pop]
tab vulnerable4 if poor==0 & urban==1 [aw=wta_pop]

*CDFs of urban and rural

*Set version so the old putexcel commands will work
version 14.0

**SUMMARIZE SHOCK INCIDENCE


*1. table with incidence of shock types by consumption quintile
**only regard shocks in the past year?**
foreach num of numlist 1/5{
sum  economicshock $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") B`num'=(r(mean)) B6=("Economic Shocks")  using descriptives,sheet("consumption") modify
sum  aggrshock $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") C`num'=(r(mean)) C6=("Agricultural Shocks")  using descriptives,sheet("consumption") modify
sum  healthshock $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") D`num'=(r(mean)) D6=("Health Shocks")  using descriptives,sheet("consumption") modify
sum  othershock $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") E`num'=(r(mean)) E6=("Other Shocks")  using descriptives,sheet("consumption") modify

sum  economicshock $weight  
putexcel A7=("mean") B7=(r(mean))  using descriptives,sheet("consumption") modify
sum  aggrshock $weight  
putexcel C7=(r(mean))  using descriptives,sheet("consumption") modify
sum  healthshock $weight  
putexcel  D7=(r(mean))  using descriptives,sheet("consumption") modify
sum  othershock $weight  
putexcel E7=(r(mean))  using descriptives,sheet("consumption") modify
}

*2. Table with incidence of shock severity (loss/consumption) by consumption quintile
*MODIFYING ORIGINAL TO MAKE SURE WE ONLY LOOK AT HOUSEHOLDS EXPERIENCING RELEVANT SHOCK
foreach num of numlist 1/5{
sum  leseverity $weight  if hcquintile==`num' & leseverity>0 & leseverity!=.
putexcel A`num'=("`num'") B`num'=(r(mean)) B6=("Economic Shocks")  using descriptives,sheet("loss severity") modify
sum  laseverity $weight  if hcquintile==`num' & laseverity>0 & laseverity!=.
putexcel A`num'=("`num'") C`num'=(r(mean)) C6=("Agricultural Shocks")  using descriptives,sheet("loss severity") modify
sum  lhseverity $weight  if hcquintile==`num' & lhseverity>0 & lhseverity!=.
putexcel A`num'=("`num'") D`num'=(r(mean)) D6=("Health Shocks")  using descriptives,sheet("loss severity") modify
sum  lseverity $weight  if hcquintile==`num' & lseverity>0 & lseverity!=.
putexcel A`num'=("`num'") E`num'=(r(mean)) E6=("All Shocks")  using descriptives,sheet("loss severity") modify

sum  leseverity $weight if leseverity>0 & leseverity!=.
putexcel A7=("mean") B7=(r(mean))  using descriptives,sheet("loss severity") modify
sum  laseverity $weight  if laseverity>0 & laseverity!=.
putexcel C7=(r(mean))  using descriptives,sheet("loss severity") modify
sum  lhseverity $weight  if lhseverity>0 & lhseverity!=.
putexcel  D7=(r(mean))  using descriptives,sheet("loss severity") modify
sum  lseverity $weight  if lseverity>0 & lseverity!=.
putexcel E7=(r(mean))  using descriptives,sheet("loss severity") modify
}

**shock incidence and severeity urban - rural 
local char economicshock aggrshock healthshock othershock
local row = 1
foreach var in `char' {
svy: mean `var' if urban==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("rural-urban")  modify
putexcel B`row' = matrix(e(b)) B1=("Urban") using descriptives,sheet("rural-urban")  modify
svy: mean `var' if urban==0
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Rural") using descriptives,sheet("rural-urban")  modify

*Confidence intervals
svy: mean `var' if urban==1
matrix temp=r(table)
putexcel E`row' = (temp[5,1]) E1=("Urban LL") using descriptives,sheet("rural-urban") modify
putexcel F`row' = (temp[6,1]) F1=("Urban UL") using descriptives,sheet("rural-urban") modify
svy: mean `var' if urban==0
matrix temp=r(table)
putexcel G`row' = (temp[5,1]) G1=("Rural LL") using descriptives,sheet("rural-urban") modify
putexcel H`row' = (temp[6,1]) H1=("Rural UL") using descriptives,sheet("rural-urban") modify

svy: mean `var', over(urban)
test [`var']0 - [`var']1 = 0
putexcel D`row' = matrix(r(p)) D1=("t-test") using descriptives,sheet("rural-urban")  modify
}



*HAVE TO STAR OUT THE HEALTH LOSSES
local char leseverity laseverity /*lhseverity*/ lseverity
local row = 1
foreach var in `char' {
svy: mean `var' if urban==1 & `var'>0 & `var'!=.
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel I`row'=("`varlabel'") using descriptives,sheet("rural-urban")  modify
putexcel J`row' = matrix(e(b)) J1=("Urban") using descriptives,sheet("rural-urban")  modify
svy: mean `var' if urban==0 & `var'>0 & `var'!=.
matrix list e(b)
putexcel K`row' = matrix(e(b)) K1=("Rural") using descriptives,sheet("rural-urban")  modify

svy: mean `var' if `var'>0 & `var'!=., over(urban)
test [`var']0 - [`var']1 = 0
putexcel L`row' = matrix(r(p)) L1=("t-test") using descriptives,sheet("rural-urban")  modify
}


**shock incidence and severeity by poor and non-poor
local char economicshock aggrshock healthshock othershock
local row = 1
foreach var in `char' {
svy: mean `var' if poor==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("poor-nonpoor")  modify
putexcel B`row' = matrix(e(b)) B1=("Poor") using descriptives,sheet("poor-nonpoor")  modify

svy: mean `var' if poor==0
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Non_Poor") using descriptives,sheet("poor-nonpoor")  modify

*Confidence intervals
svy: mean `var' if poor==1
matrix temp=r(table)
putexcel E`row' = (temp[5,1]) E1=("Poor LL") using descriptives,sheet("poor-nonpoor") modify
putexcel F`row' = (temp[6,1]) F1=("Poor UL") using descriptives,sheet("poor-nonpoor") modify
svy: mean `var' if poor==0
matrix temp=r(table)
putexcel G`row' = (temp[5,1]) G1=("Non-poor LL") using descriptives,sheet("poor-nonpoor") modify
putexcel H`row' = (temp[6,1]) H1=("Non-poor UL") using descriptives,sheet("poor-nonpoor") modify

svy: mean `var', over(poor)
test [`var']0 - [`var']1 = 0
putexcel D`row' = matrix(r(p)) D1=("t-test") using descriptives,sheet("poor-nonpoor")  modify

}

  
local char leseverity laseverity /*lhseverity*/ lseverity
local row = 1
foreach var in `char' {
svy: mean `var' if poor==1 & `var'>0 & `var'!=.
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel I`row'=("`varlabel'") using descriptives,sheet("poor-nonpoor")  modify
putexcel J`row' = matrix(e(b)) J1=("Poor") using descriptives,sheet("poor-nonpoor")  modify
svy: mean `var' if poor==0 & `var'>0 & `var'!=.
matrix list e(b)
putexcel K`row' = matrix(e(b)) K1=("Non-Poor") using descriptives,sheet("poor-nonpoor")  modify

svy: mean `var' if `var'>0 & `var'!=., over(poor)
test [`var']0 - [`var']1 = 0
putexcel L`row' = matrix(r(p)) L1=("t-test") using descriptives,sheet("poor-nonpoor")  modify
}


**shock incidence by province
local char province1 province2 province3 province4 province5 province6 province7 province8 
local row = 1
foreach var in `char' {
svy: mean economicshock if `var'==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("province")  modify
putexcel B`row' = matrix(e(b)) B1=("economic shock") using descriptives,sheet("province")  modify

svy: mean aggrshock if `var'==1
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("weather shock") using descriptives,sheet("province")  modify

svy: mean healthshock if `var'==1
matrix list e(b)
putexcel D`row' = matrix(e(b)) D1=("health shock") using descriptives,sheet("province")  modify

svy: mean othershock if `var'==1
matrix list e(b)
putexcel E`row' = matrix(e(b)) E1=("other shock") using descriptives,sheet("province")  modify
}
*loss severity by province
local char province1 province2 province3 province4 province5 province6 province7 province8 
local row = 1
foreach var in `char' {
svy: mean leseverity if `var'==1 & leseverity>0 & leseverity!=.
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel G`row'=("`varlabel'") using descriptives,sheet("province")  modify
putexcel H`row' = matrix(e(b)) H1=("economic severity") using descriptives,sheet("province")  modify

svy: mean laseverity if `var'==1 & laseverity>0 & laseverity!=.
matrix list e(b)
putexcel I`row' = matrix(e(b)) I1=("weather severity") using descriptives,sheet("province")  modify

/*svy: mean lhseverity if `var'==1 & lhseverity>0 & lhseverity!=.
matrix list e(b)
putexcel J`row' = matrix(e(b)) J1=("health severity") using descriptives,sheet("province")  modify*/

svy: mean lseverity if `var'==1 & lseverity>0 & lseverity!=.
matrix list e(b)
putexcel K`row' = matrix(e(b)) K1=("total severity") using descriptives,sheet("province")  modify
}
        


		
**SUMMARIZE COPING STRATEGIES

*Inserting restriction here for those who actually experience a shock.

preserve
keep if shock>0 & shock!=.

*1.Coping Strategies per quintile
foreach num of numlist 1/5{
sum  assetsales $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") B`num'=(r(mean)) B6=("Sold assets")  using descriptives,sheet("coping rel") modify
sum  morework $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") C`num'=(r(mean)) C6=("Worked more")  using descriptives,sheet("coping rel") modify
sum  borrowed $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") D`num'=(r(mean)) D6=("Borrowed")  using descriptives,sheet("coping rel") modify
sum  helpinstitution $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") E`num'=(r(mean)) E6=("Help institution")  using descriptives,sheet("coping rel") modify
sum  family $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") F`num'=(r(mean)) F6=("Help Family")  using descriptives,sheet("coping rel") modify
sum  reducedcons $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") G`num'=(r(mean)) G6=("Reduced consumption")  using descriptives,sheet("coping rel") modify
sum  savings $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") H`num'=(r(mean)) H6=("Used savings")  using descriptives,sheet("coping rel") modify
sum  spiritual $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") I`num'=(r(mean)) I6=("Spiritual help")  using descriptives,sheet("coping rel") modify
sum  othercoping $weight  if hcquintile==`num' 
putexcel A`num'=("`num'") J`num'=(r(mean)) J6=("Other coping")  using descriptives,sheet("coping rel") modify
}

*rural - urban

local char assetsales morework borrowed helpinstitution family reducedcons savings spiritual othercoping manystrategies
local row = 1
foreach var in `char' {
svy: mean `var' if urban==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("coping rural-urban")  modify
putexcel B`row' = matrix(e(b)) B1=("Urban") using descriptives,sheet("coping rural-urban")  modify
svy: mean `var' if urban==0
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Rural") using descriptives,sheet("coping rural-urban")  modify

*Confidence intervals
svy: mean `var' if urban==1
matrix temp=r(table)
putexcel E`row' = (temp[5,1]) E1=("Urban LL") using descriptives,sheet("coping rural-urban") modify
putexcel F`row' = (temp[6,1]) F1=("Urban UL") using descriptives,sheet("coping rural-urban") modify
svy: mean `var' if urban==0
matrix temp=r(table)
putexcel G`row' = (temp[5,1]) G1=("Rural LL") using descriptives,sheet("coping rural-urban") modify
putexcel H`row' = (temp[6,1]) H1=("Rural UL") using descriptives,sheet("coping rural-urban") modify


svy: mean `var', over(urban)
test [`var']0 - [`var']1 = 0
putexcel D`row' = matrix(r(p)) D1=("t-test") using descriptives,sheet("coping rural-urban")  modify
}




*poor - non-poor

local char assetsales morework borrowed helpinstitution family reducedcons savings spiritual othercoping manystrategies
local row = 1
foreach var in `char' {
svy: mean `var' if poor==1 & shock==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("coping poor-non-poor")  modify
putexcel B`row' = matrix(e(b)) B1=("Poor") using descriptives,sheet("coping poor-non-poor")  modify
svy: mean `var' if poor==0  & shock==1
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Non-Poor") using descriptives,sheet("coping poor-non-poor")  modify

*Confidence intervals
svy: mean `var' if poor==1 & shock==1
matrix temp=r(table)
putexcel E`row' = (temp[5,1]) E1=("Poor LL") using descriptives,sheet("coping poor-non-poor") modify
putexcel F`row' = (temp[6,1]) F1=("Poor UL") using descriptives,sheet("coping poor-non-poor") modify
svy: mean `var' if poor==0 & shock==1
matrix temp=r(table)
putexcel G`row' = (temp[5,1]) G1=("Non-poor LL") using descriptives,sheet("coping poor-non-poor") modify
putexcel H`row' = (temp[6,1]) H1=("Non-poor UL") using descriptives,sheet("coping poor-non-poor") modify

svy: mean `var', over(poor)
test [`var']0 - [`var']1 = 0
putexcel D`row' = matrix(r(p)) D1=("t-test") using descriptives,sheet("coping poor-non-poor")  modify
}


*poor - non poor rural - urban 

local char assetsales morework borrowed helpinstitution family reducedcons savings spiritual othercoping manystrategies
local row = 1
foreach var in `char' {
svy: mean `var' if poor==1 & urban==0
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("coping rural-urban -poor")  modify
putexcel B`row' = matrix(e(b)) B1=("Poor") using descriptives,sheet("coping rural-urban -poor")  modify
svy: mean `var' if poor==0 & urban==0
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Non-Poor") using descriptives,sheet("coping rural-urban -poor")  modify

svy: mean `var' if urban==0, over(poor) 
test [`var']0 - [`var']1 = 0 
putexcel D`row' = matrix(r(p)) D1=("t-test") using descriptives,sheet("coping rural-urban -poor")  modify

}

local char assetsales morework borrowed helpinstitution family reducedcons savings spiritual othercoping manystrategies
local row = 1
foreach var in `char' {
svy: mean `var' if poor==1 & urban==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel G`row'=("`varlabel'") using descriptives,sheet("coping rural-urban -poor")  modify
putexcel H`row' = matrix(e(b)) H1=("Poor") using descriptives,sheet("coping rural-urban -poor")  modify
svy: mean `var' if poor==0 & urban==1
matrix list e(b)
putexcel I`row' = matrix(e(b)) I1=("Non-Poor") using descriptives,sheet("coping rural-urban -poor")  modify

svy: mean `var' if urban==1, over(poor) 
test [`var']0 - [`var']1 = 0 
putexcel J`row' = matrix(r(p)) J1=("t-test") using descriptives,sheet("coping rural-urban -poor")  modify

}


*Help received - Own Actions

local char ownaction help
local row = 1
foreach var in `char' {
svy: mean `var' if poor==1
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("coping help-own")  modify
putexcel B`row' = matrix(e(b)) B1=("Poor") using descriptives,sheet("coping help-own")  modify
svy: mean `var' if poor==0
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Non-Poor") using descriptives,sheet("coping help-own")  modify

svy: mean `var', over(poor)
test [`var']0 - [`var']1 = 0
putexcel D`row' = matrix(r(p)) D1=("t-test") using descriptives,sheet("coping help-own")  modify

}

*total - weather shock CS RURAL HOUSEHOLDS
version 14.0
gen shock2=economicshock==1|healthshock==1|othershock==1

local char assetsales morework borrowed helpinstitution family reducedcons savings spiritual othercoping manystrategies

local row = 1
foreach var in `char' {
svy: mean `var' if shock2==1 & urban==0
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("all vs weather shock")  modify
putexcel B`row' = matrix(e(b)) B1=("All Shocks") using descriptives,sheet("all vs weather shock")  modify
}
local char aassetsales amorework aborrowed ahelpinstitution afamily areducedcons asavings aspiritual aothercoping amanystrategies
local row = 1
foreach var in `char' {
svy: mean `var' if aggrshock==1 & urban==0
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("all vs weather shock")  modify
putexcel C`row' = matrix(e(b)) C1=("Aggricultural Shocks") using descriptives,sheet("all vs weather shock")  modify
}

restore

**SHOCKS AND COPING BY VULNERABILITY CLASSIFICATION



**incidence of shocks for vulnerable - non-vulnerable
local char economicshock aggrshock healthshock othershock
local row = 1
foreach var in `char' {
svy: mean `var' 
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("vuln. shocks")  modify
putexcel B`row' = matrix(e(b)) B1=("Total") using descriptives,sheet("vuln. shocks")  modify
svy: mean `var' if poor==0
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Non-poor") using descriptives,sheet("vuln. shocks")  modify
svy: mean `var' if poor==1
matrix list e(b)
putexcel D`row' = matrix(e(b)) D1=("Poor") using descriptives,sheet("vuln. shocks")  modify
svy: mean `var' if vulnerable1==1
matrix list e(b)
putexcel E`row' = matrix(e(b)) E1=("vulnerable (Prob.>46%)") using descriptives,sheet("vuln. shocks")  modify
svy: mean `var' if vulnerable4==1
matrix list e(b)
putexcel F`row' = matrix(e(b)) F1=("vulnerable (Prob.>29%)") using descriptives,sheet("vuln. shocks")  modify
}

**severity of shocks for vulnerable - non-vulnerable
local char leseverity laseverity lhseverity lseverity
local row = 1
foreach var in `char' {
svy: mean `var' 
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("vuln. severity")  modify
putexcel B`row' = matrix(e(b)) B1=("Total") using descriptives,sheet("vuln. severity")  modify
svy: mean `var' if poor==1
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Poor") using descriptives,sheet("vuln. severity")  modify
svy: mean `var' if vulnerable1==1
matrix list e(b)
putexcel D`row' = matrix(e(b)) D1=("vulnerable (Prob.>46%)") using descriptives,sheet("vuln. severity")  modify
svy: mean `var' if vulnerable4==1
matrix list e(b)
putexcel E`row' = matrix(e(b)) E1=("vulnerable (Prob.>29%)") using descriptives,sheet("vuln. severity")  modify
}

preserve
keep if shock>0 & shock!=.


**coping strategies of vulnerable - non-vulnerable
local char assetsales morework borrowed helpinstitution family reducedcons savings spiritual othercoping manystrategies
local row = 1
foreach var in `char' {
svy: mean `var' 
matrix list e(b)
local varlabel: var label `var'
local ++row
putexcel A`row'=("`varlabel'") using descriptives,sheet("vuln. coping")  modify
putexcel B`row' = matrix(e(b)) B1=("Total") using descriptives,sheet("vuln. coping")  modify
svy: mean `var' if poor==0
matrix list e(b)
putexcel C`row' = matrix(e(b)) C1=("Non-poor") using descriptives,sheet("vuln. coping")  modify
svy: mean `var' if poor==1
matrix list e(b)
putexcel D`row' = matrix(e(b)) D1=("Poor") using descriptives,sheet("vuln. coping")  modify
svy: mean `var' if vulnerable1==1
matrix list e(b)
putexcel E`row' = matrix(e(b)) E1=("vulnerable (Prob.>46%)") using descriptives,sheet("vuln. coping")  modify
svy: mean `var' if vulnerable4==1
matrix list e(b)
putexcel F`row' = matrix(e(b)) F1=("vulnerable (Prob.>29%)") using descriptives,sheet("vuln. coping")  modify
}


*list all coping strategies*
sum  savings $weight  
putexcel A2=("Savings") B2=(r(mean)) B1=("All") C1=("Poor")  D1=("Non-Poor") E1=("t-test")  using descriptives,sheet("coping strategy") modify
sum  savings $weight  if poor==1
putexcel C2=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  savings $weight  if poor==0
putexcel D2=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean savings, over(poor)
test [savings]0 - [savings]1=0
putexcel E2=(r(p))  using descriptives,sheet("coping strategy") modify

sum  sentchildren $weight  
putexcel A3=("sent children to relatives") B3=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  sentchildren $weight  if poor==1
putexcel C3=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  sentchildren $weight  if poor==0
putexcel D3=(r(mean))  using descriptives,sheet("coping strategy") modify
ttest sentchildren, by(poor)
svy: mean sentchildren, over(poor)
test [sentchildren]0 - [sentchildren]1=0
putexcel E3=(r(p))  using descriptives,sheet("coping strategy") modify

sum  sellassets $weight  
putexcel A4=("sell assets") B4=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  sellassets $weight  if poor==1
putexcel C4=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  sellassets $weight  if poor==0
putexcel D4=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean sellassets, over(poor)
test [sellassets]0 - [sellassets]1=0
putexcel E4=(r(p))  using descriptives,sheet("coping strategy") modify

sum  sellfarmland $weight  
putexcel A5=("sell farmland") B5=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  sellfarmland $weight  if poor==1
putexcel C5=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  sellfarmland $weight  if poor==0
putexcel D5=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean sellfarmland, over(poor)
test [sellfarmland]0 - [sellfarmland]1=0
putexcel E5=(r(p))  using descriptives,sheet("coping strategy") modify

sum  rentfarmland $weight  
putexcel A6=("rent farmland") B6=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  rentfarmland $weight  if poor==1
putexcel C6=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  rentfarmland $weight  if poor==0
putexcel D6=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean rentfarmland, over(poor)
test [rentfarmland]0 - [rentfarmland]1=0
putexcel E6=(r(p))  using descriptives,sheet("coping strategy") modify

sum  sellanimals $weight  
putexcel A7=("sell animals") B7=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  sellanimals $weight  if poor==1
putexcel C7=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  sellanimals $weight  if poor==0
putexcel D7=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean sellanimals, over(poor)
test [sellanimals]0 - [sellanimals]1=0
putexcel E7=(r(p))  using descriptives,sheet("coping strategy") modify

sum  sellcrops $weight  
putexcel A8=("sell crops") B8=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  sellcrops $weight  if poor==1
putexcel C8=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  sellcrops $weight  if poor==0
putexcel D8=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean sellcrops, over(poor)
test [sellcrops]0 - [sellcrops]1=0
putexcel E8=(r(p))  using descriptives,sheet("coping strategy") modify
 
sum  workedmore $weight  
putexcel A9=("worked more") B9=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  workedmore $weight  if poor==1
putexcel C9=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  workedmore $weight  if poor==0
putexcel D9=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean workedmore, over(poor)
test [workedmore]0 - [workedmore]1=0
putexcel E9=(r(p))  using descriptives,sheet("coping strategy") modify
  
sum  hhmemberswork $weight  
putexcel A10=("hh member started work") B10=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  hhmemberswork $weight  if poor==1
putexcel C10=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  hhmemberswork $weight  if poor==0
putexcel D10=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean hhmemberswork, over(poor)
test [hhmemberswork]0 - [hhmemberswork]1=0
putexcel E10=(r(p))  using descriptives,sheet("coping strategy") modify
   
sum  startbusiness $weight  
putexcel A11=("started business") B11=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  startbusiness $weight  if poor==1
putexcel C11=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  startbusiness $weight  if poor==0
putexcel D11=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean startbusiness, over(poor)
test [startbusiness]0 - [startbusiness]1=0
putexcel E11=(r(p))  using descriptives,sheet("coping strategy") modify
     
sum  childrenwork $weight  
putexcel A12=("children worked") B12=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  childrenwork $weight  if poor==1
putexcel C12=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  childrenwork $weight  if poor==0
putexcel D12=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean childrenwork, over(poor)
test [childrenwork]0 - [childrenwork]1=0
putexcel E12=(r(p))  using descriptives,sheet("coping strategy") modify
      
sum  migratework $weight  
putexcel A13=("migrated to work") B13=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  migratework $weight  if poor==1
putexcel C13=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  migratework $weight  if poor==0
putexcel D13=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean migratework, over(poor)
test [migratework]0 - [migratework]1=0
putexcel E13=(r(p))  using descriptives,sheet("coping strategy") modify
   
sum  borrowedrelative $weight  
putexcel A14=("borrowed from relative") B14=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  borrowedrelative $weight  if poor==1
putexcel C14=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  borrowedrelative $weight  if poor==0
putexcel D14=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean borrowedrelative, over(poor)
test [borrowedrelative]0 - [borrowedrelative]1=0
putexcel E14=(r(p))  using descriptives,sheet("coping strategy") modify
  
sum  borrowedmoneylender $weight  
putexcel A15=("borrowed from moneylender") B15=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  borrowedmoneylender $weight  if poor==1
putexcel C15=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  borrowedmoneylender $weight  if poor==0
putexcel D15=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean borrowedmoneylender, over(poor)
test [borrowedmoneylender]0 - [borrowedmoneylender]1=0
putexcel E15=(r(p))  using descriptives,sheet("coping strategy") modify
      
sum  borrowedformal $weight  
putexcel A16=("borrowed from formal institution ") B16=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  borrowedformal $weight  if poor==1
putexcel C16=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  borrowedformal $weight  if poor==0
putexcel D16=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean borrowedformal, over(poor)
test [borrowedformal]0 - [borrowedformal]1=0
putexcel E16=(r(p))  using descriptives,sheet("coping strategy") modify
       
sum  helpreligion $weight  
putexcel A17=("help church") B17=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  helpreligion $weight  if poor==1
putexcel C17=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  helpreligion $weight  if poor==0
putexcel D17=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean helpreligion, over(poor)
test [helpreligion]0 - [helpreligion]1=0
putexcel E17=(r(p))  using descriptives,sheet("coping strategy") modify
     
sum  helplocalngo $weight  
putexcel A18=("help local ngo") B18=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  helplocalngo $weight  if poor==1
putexcel C18=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  helplocalngo $weight  if poor==0
putexcel D18=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean helplocalngo, over(poor)
test [helplocalngo]0 - [helplocalngo]1=0
putexcel E18=(r(p))  using descriptives,sheet("coping strategy") modify
      
sum  helpinternationalngo $weight  
putexcel A19=("help international ngo") B19=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  helpinternationalngo $weight  if poor==1
putexcel C19=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  helpinternationalngo $weight  if poor==0
putexcel D19=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean helpinternationalngo, over(poor)
test [helpinternationalngo]0 - [helpinternationalngo]1=0
putexcel E19=(r(p))  using descriptives,sheet("coping strategy") modify
       
sum  helpgovernment $weight  
putexcel A20=("help government") B20=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  helpgovernment $weight  if poor==1
putexcel C20=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  helpgovernment $weight  if poor==0
putexcel D20=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean helpgovernment, over(poor)
test [helpgovernment]0 - [helpgovernment]1=0
putexcel E20=(r(p))  using descriptives,sheet("coping strategy") modify
   
sum  helpfamily $weight  
putexcel A21=("help family member") B21=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  helpfamily $weight  if poor==1
putexcel C21=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  helpfamily $weight  if poor==0
putexcel D21=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean helpfamily, over(poor)
test [helpfamily]0 - [helpfamily]1=0
putexcel E21=(r(p))  using descriptives,sheet("coping strategy") modify
  
sum  reducedfood $weight  
putexcel A22=("reduced food") B22=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  reducedfood $weight  if poor==1
putexcel C22=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  reducedfood $weight  if poor==0
putexcel D22=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean reducedfood, over(poor)
test [reducedfood]0 - [reducedfood]1=0
putexcel E22=(r(p))  using descriptives,sheet("coping strategy") modify
      
sum  consumedless $weight  
putexcel A23=("consumed less") B23=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  consumedless $weight  if poor==1
putexcel C23=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  consumedless $weight  if poor==0
putexcel D23=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean consumedless, over(poor)
test [consumedless]0 - [consumedless]1=0
putexcel E23=(r(p))  using descriptives,sheet("coping strategy") modify
   
sum  reducednonfood $weight  
putexcel A24=("reduced non food") B24=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  reducednonfood $weight  if poor==1
putexcel C24=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  reducednonfood $weight  if poor==0
putexcel D24=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean reducednonfood, over(poor)
test [reducednonfood]0 - [reducednonfood]1=0
putexcel E24=(r(p))  using descriptives,sheet("coping strategy") modify
     
sum  spiritual $weight  
putexcel A25=("spiritual help") B25=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  spiritual $weight  if poor==1
putexcel C25=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  spiritual $weight  if poor==0
putexcel D25=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean spiritual, over(poor)
test [spiritual]0 - [spiritual]1=0
putexcel E25=(r(p))  using descriptives,sheet("coping strategy") modify
    
sum  othercoping $weight  
putexcel A26=("other coping strategy") B26=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  othercoping $weight  if poor==1
putexcel C26=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  othercoping $weight  if poor==0
putexcel D26=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean othercoping, over(poor)
test [othercoping]0 - [othercoping]1=0
putexcel E26=(r(p))  using descriptives,sheet("coping strategy") modify
    
sum  manystrategies $weight  
putexcel A28=("hh used multiple coping strategies") B28=(r(mean))   using descriptives,sheet("coping strategy") modify
sum  manystrategies $weight  if poor==1
putexcel C28=(r(mean))  using descriptives,sheet("coping strategy") modify
sum  manystrategies $weight  if poor==0
putexcel D28=(r(mean))  using descriptives,sheet("coping strategy") modify
svy: mean manystrategies, over(poor)
test [manystrategies]0 - [manystrategies]1=0
putexcel E28=(r(p))  using descriptives,sheet("coping strategy") modify


restore

preserve
keep if shock>0 & shock!=.

*total - weather shock CS RURAL HOUSEHOLDS
version 14.0


*Now a comparison of poor-non-poor for coping with agricultural shocks
*list all coping strategies*
sum  asavings $weight  
putexcel A2=("asavings") B2=(r(mean)) B1=("All") C1=("Poor")  D1=("Non-Poor") E1=("t-test")  using descriptives,sheet("coping strategy ag") modify
sum  asavings $weight  if poor==1
putexcel C2=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  asavings $weight  if poor==0
putexcel D2=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean asavings, over(poor)
test [asavings]0 - [asavings]1=0
putexcel E2=(r(p))  using descriptives,sheet("coping strategy ag") modify

sum  asentchildren $weight  
putexcel A3=("sent children to relatives") B3=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  asentchildren $weight  if poor==1
putexcel C3=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  asentchildren $weight  if poor==0
putexcel D3=(r(mean))  using descriptives,sheet("coping strategy ag") modify
ttest asentchildren, by(poor)
svy: mean asentchildren, over(poor)
test [asentchildren]0 - [asentchildren]1=0
putexcel E3=(r(p))  using descriptives,sheet("coping strategy ag") modify

sum  asellassets $weight  
putexcel A4=("sell assets") B4=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  asellassets $weight  if poor==1
putexcel C4=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  asellassets $weight  if poor==0
putexcel D4=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean asellassets, over(poor)
test [asellassets]0 - [asellassets]1=0
putexcel E4=(r(p))  using descriptives,sheet("coping strategy ag") modify

sum  asellfarmland $weight  
putexcel A5=("sell farmland") B5=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  asellfarmland $weight  if poor==1
putexcel C5=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  asellfarmland $weight  if poor==0
putexcel D5=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean asellfarmland, over(poor)
test [asellfarmland]0 - [asellfarmland]1=0
putexcel E5=(r(p))  using descriptives,sheet("coping strategy ag") modify

sum  arentfarmland $weight  
putexcel A6=("rent farmland") B6=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  arentfarmland $weight  if poor==1
putexcel C6=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  arentfarmland $weight  if poor==0
putexcel D6=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean arentfarmland, over(poor)
test [arentfarmland]0 - [arentfarmland]1=0
putexcel E6=(r(p))  using descriptives,sheet("coping strategy ag") modify

sum  asellanimals $weight  
putexcel A7=("sell animals") B7=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  asellanimals $weight  if poor==1
putexcel C7=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  asellanimals $weight  if poor==0
putexcel D7=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean asellanimals, over(poor)
test [asellanimals]0 - [asellanimals]1=0
putexcel E7=(r(p))  using descriptives,sheet("coping strategy ag") modify

sum  asellcrops $weight  
putexcel A8=("sell crops") B8=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  asellcrops $weight  if poor==1
putexcel C8=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  asellcrops $weight  if poor==0
putexcel D8=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean asellcrops, over(poor)
test [asellcrops]0 - [asellcrops]1=0
putexcel E8=(r(p))  using descriptives,sheet("coping strategy ag") modify
 
sum  aworkedmore $weight  
putexcel A9=("worked more") B9=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  aworkedmore $weight  if poor==1
putexcel C9=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  aworkedmore $weight  if poor==0
putexcel D9=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean aworkedmore, over(poor)
test [aworkedmore]0 - [aworkedmore]1=0
putexcel E9=(r(p))  using descriptives,sheet("coping strategy ag") modify
  
sum  ahhmemberswork $weight  
putexcel A10=("hh member started work") B10=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  ahhmemberswork $weight  if poor==1
putexcel C10=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  ahhmemberswork $weight  if poor==0
putexcel D10=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean ahhmemberswork, over(poor)
test [ahhmemberswork]0 - [ahhmemberswork]1=0
putexcel E10=(r(p))  using descriptives,sheet("coping strategy ag") modify
   
sum  astartbusiness $weight  
putexcel A11=("started business") B11=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  astartbusiness $weight  if poor==1
putexcel C11=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  astartbusiness $weight  if poor==0
putexcel D11=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean astartbusiness, over(poor)
test [astartbusiness]0 - [astartbusiness]1=0
putexcel E11=(r(p))  using descriptives,sheet("coping strategy ag") modify
     
sum  achildrenwork $weight  
putexcel A12=("children worked") B12=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  achildrenwork $weight  if poor==1
putexcel C12=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  achildrenwork $weight  if poor==0
putexcel D12=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean achildrenwork, over(poor)
test [achildrenwork]0 - [achildrenwork]1=0
putexcel E12=(r(p))  using descriptives,sheet("coping strategy ag") modify
      
sum  amigratework $weight  
putexcel A13=("migrated to work") B13=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  amigratework $weight  if poor==1
putexcel C13=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  amigratework $weight  if poor==0
putexcel D13=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean amigratework, over(poor)
test [amigratework]0 - [amigratework]1=0
putexcel E13=(r(p))  using descriptives,sheet("coping strategy ag") modify
   
sum  aborrowedrelative $weight  
putexcel A14=("borrowed from relative") B14=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  aborrowedrelative $weight  if poor==1
putexcel C14=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  aborrowedrelative $weight  if poor==0
putexcel D14=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean aborrowedrelative, over(poor)
test [aborrowedrelative]0 - [aborrowedrelative]1=0
putexcel E14=(r(p))  using descriptives,sheet("coping strategy ag") modify
  
sum  aborrowedmoneylender $weight  
putexcel A15=("borrowed from moneylender") B15=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  aborrowedmoneylender $weight  if poor==1
putexcel C15=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  aborrowedmoneylender $weight  if poor==0
putexcel D15=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean aborrowedmoneylender, over(poor)
test [aborrowedmoneylender]0 - [aborrowedmoneylender]1=0
putexcel E15=(r(p))  using descriptives,sheet("coping strategy ag") modify
      
sum  aborrowedformal $weight  
putexcel A16=("borrowed from formal institution ") B16=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  aborrowedformal $weight  if poor==1
putexcel C16=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  aborrowedformal $weight  if poor==0
putexcel D16=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean aborrowedformal, over(poor)
test [aborrowedformal]0 - [aborrowedformal]1=0
putexcel E16=(r(p))  using descriptives,sheet("coping strategy ag") modify
       
sum  ahelpreligion $weight  
putexcel A17=("help church") B17=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  ahelpreligion $weight  if poor==1
putexcel C17=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  ahelpreligion $weight  if poor==0
putexcel D17=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean ahelpreligion, over(poor)
test [ahelpreligion]0 - [ahelpreligion]1=0
putexcel E17=(r(p))  using descriptives,sheet("coping strategy ag") modify
     
sum  ahelplocalngo $weight  
putexcel A18=("help local ngo") B18=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  ahelplocalngo $weight  if poor==1
putexcel C18=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  ahelplocalngo $weight  if poor==0
putexcel D18=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean ahelplocalngo, over(poor)
test [ahelplocalngo]0 - [ahelplocalngo]1=0
putexcel E18=(r(p))  using descriptives,sheet("coping strategy ag") modify
      
sum  ahelpinternationalngo $weight  
putexcel A19=("help international ngo") B19=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  ahelpinternationalngo $weight  if poor==1
putexcel C19=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  ahelpinternationalngo $weight  if poor==0
putexcel D19=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean ahelpinternationalngo, over(poor)
test [ahelpinternationalngo]0 - [ahelpinternationalngo]1=0
putexcel E19=(r(p))  using descriptives,sheet("coping strategy ag") modify
       
sum  ahelpgovernment $weight  
putexcel A20=("help government") B20=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  ahelpgovernment $weight  if poor==1
putexcel C20=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  ahelpgovernment $weight  if poor==0
putexcel D20=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean ahelpgovernment, over(poor)
test [ahelpgovernment]0 - [ahelpgovernment]1=0
putexcel E20=(r(p))  using descriptives,sheet("coping strategy ag") modify
   
sum  ahelpfamily $weight  
putexcel A21=("help family member") B21=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  ahelpfamily $weight  if poor==1
putexcel C21=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  ahelpfamily $weight  if poor==0
putexcel D21=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean ahelpfamily, over(poor)
test [ahelpfamily]0 - [ahelpfamily]1=0
putexcel E21=(r(p))  using descriptives,sheet("coping strategy ag") modify
  
sum  areducedfood $weight  
putexcel A22=("reduced food") B22=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  areducedfood $weight  if poor==1
putexcel C22=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  areducedfood $weight  if poor==0
putexcel D22=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean areducedfood, over(poor)
test [areducedfood]0 - [areducedfood]1=0
putexcel E22=(r(p))  using descriptives,sheet("coping strategy ag") modify
      
sum  aconsumedless $weight  
putexcel A23=("consumed less") B23=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  aconsumedless $weight  if poor==1
putexcel C23=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  aconsumedless $weight  if poor==0
putexcel D23=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean aconsumedless, over(poor)
test [aconsumedless]0 - [aconsumedless]1=0
putexcel E23=(r(p))  using descriptives,sheet("coping strategy ag") modify
   
sum  areducednonfood $weight  
putexcel A24=("reduced non food") B24=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  areducednonfood $weight  if poor==1
putexcel C24=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  areducednonfood $weight  if poor==0
putexcel D24=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean areducednonfood, over(poor)
test [areducednonfood]0 - [areducednonfood]1=0
putexcel E24=(r(p))  using descriptives,sheet("coping strategy ag") modify
     
sum  aspiritual $weight  
putexcel A25=("aspiritual help") B25=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  aspiritual $weight  if poor==1
putexcel C25=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  aspiritual $weight  if poor==0
putexcel D25=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean aspiritual, over(poor)
test [aspiritual]0 - [aspiritual]1=0
putexcel E25=(r(p))  using descriptives,sheet("coping strategy ag") modify
    
sum  aothercoping $weight  
putexcel A26=("other coping strategy") B26=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  aothercoping $weight  if poor==1
putexcel C26=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  aothercoping $weight  if poor==0
putexcel D26=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean aothercoping, over(poor)
test [aothercoping]0 - [aothercoping]1=0
putexcel E26=(r(p))  using descriptives,sheet("coping strategy ag") modify
    
sum  amanystrategies $weight  
putexcel A28=("hh used multiple coping strategies") B28=(r(mean))   using descriptives,sheet("coping strategy ag") modify
sum  amanystrategies $weight  if poor==1
putexcel C28=(r(mean))  using descriptives,sheet("coping strategy ag") modify
sum  amanystrategies $weight  if poor==0
putexcel D28=(r(mean))  using descriptives,sheet("coping strategy ag") modify
svy: mean amanystrategies, over(poor)
test [amanystrategies]0 - [amanystrategies]1=0
putexcel E28=(r(p))  using descriptives,sheet("coping strategy ag") modify

restore


/**use admin data to plot program evolution over time (codes seem to be wrong!)**
cd "C:\Users\s.dietrich\Desktop\Kenya 0506 data\admin data"
use adminpooled, clear
collapse (sum) ovc opct hsnp pwsd all, by(year)
foreach var of varlist ovc opct hsnp pwsd all{
replace `var'=`var'/1000
}
twoway (line ovc year) (line opct year) (line hsnp year) (line pwsd year) (line all year)


log close
*/



