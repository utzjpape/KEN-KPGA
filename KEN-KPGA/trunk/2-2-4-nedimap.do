
set more off

use "${gsdData}\1-CleanOutput\kihbs15_16.dta" , clear

*Rename so that counties match with the NEW shape files
gen temp=.
replace temp=1 if county==5
replace temp=2 if county==2
replace temp=5 if county==34
replace temp=6 if county==11
replace temp=7 if county==16
replace temp=8 if county==28
replace temp=9 if county==39
replace temp=10 if county==7
replace temp=11 if county==26
replace temp=12	if county==17
replace temp=13	if county==24
replace temp=14	if county==30
replace temp=15	if county==9
replace temp=16	if county==33
replace temp=17	if county==8
replace temp=18	if county==15
replace temp=19	if county==22
replace temp=20	if county==47
replace temp=21	if county==32
replace temp=22	if county==18
replace temp=23	if county==19
replace temp=24	if county==21
replace temp=25	if county==31
replace temp=26	if county==36
replace temp=27	if county==20
replace temp=28	if county==35
replace temp=29	if county==12
replace temp=30	if county==14
replace temp=31	if county==27
replace temp=32	if county==29
replace temp=33	if county==46
replace temp=34	if county==38
replace temp=35	if county==13
replace temp=36	if county==45
replace temp=37	if county==37
replace temp=38	if county==6
replace temp=39	if county==3
replace temp=40	if county==1
replace temp=41	if county==4
replace temp=42	if county==23
replace temp=43	if county==10
replace temp=44	if county==25
replace temp=45	if county==40
replace temp=46	if county==41
replace temp=47	if county==44
replace temp=48	if county==42
replace temp=49	if county==43

rename county ID_OLD
rename temp _ID

gen nedi = inlist(ID_OLD,5,7,9,10,25,4,23,8,24,11)
label define lnedi 0"Non-NEDI County" 1"NEDI County" , replace
label values nedi lnedi
label var nedi "Dummy for NEDI Counties"

collapse (mean)  nedi , by(*ID*)

merge 1:1 _ID using "${gsdData}/1-CleanOutput/County Polys.dta" , keep(match master) nogen 

*Merging in county centroids
gen county = ID_OLD
merge 1:1 county using "${gsdData}/1-CleanOutput/centroids.dta", keepusing(x_c y_c) assert(match) nogen
label define lcounty 28 "Elgeyo-M'kwt" , modify

grmap nedi using "${gsdData}/1-CleanOutput/KenyaCountyPolys_coord.dta", id(_ID) title("NEDI counties, KIHBS 2015/16", size(*1)) ///
 legend(label(3 "NEDI")) legend(label(2 "Non-NEDI")) legstyle(1) fcolor(OrRd) clnumber(2) ///
 label(label( ID_OLD ) xcoord(x_c) ycoord(y_c) size(tiny)) 
graph save "${gsdOutput}/C2-Trends/KEN-NEDI.gph" ,replace

