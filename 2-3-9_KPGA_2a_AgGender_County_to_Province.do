set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Gender Gaps in Agriculture									*
* -> Classify counties into provinces							*
* (based on input files/code from Haseeb Ali and Habtamu Fuje)  *
*---------------------------------------------------------------*

decode county, generate(county_s)

gen province = .

replace province = 3 if county_s == "Mombasa"
replace province = 3 if county_s == "Kwale"
replace province = 3 if county_s == "Kilifi"
replace province = 3 if county_s == "Tana River"
replace province = 3 if county_s == "Lamu"
replace province = 3 if county_s == "Taita Taveta"
replace province = 5 if county_s == "Garissa"
replace province = 5 if county_s == "Wajir"
replace province = 5 if county_s == "Mandera"
replace province = 4 if county_s == "Marsabit"
replace province = 4 if county_s == "Isiolo"
replace province = 4 if county_s == "Meru"
replace province = 4 if county_s == "Tharaka Nithi"
replace province = 4 if county_s == "Embu"
replace province = 4 if county_s == "Kitui"
replace province = 4 if county_s == "Machakos"
replace province = 4 if county_s == "Makueni"
replace province = 2 if county_s == "Nyandarua"
replace province = 2 if county_s == "Nyeri"
replace province = 2 if county_s == "Kirinyaga"
replace province = 2 if county_s == "Muranga"
replace province = 2 if county_s == "Kiambu"
replace province = 7 if county_s == "Turkana"
replace province = 7 if county_s == "West Pokot"
replace province = 7 if county_s == "Samburu"
replace province = 7 if county_s == "Trans Nzoia"
replace province = 7 if county_s == "Uasin Gishu"
replace province = 7 if county_s == "Elgeyo Marakwet"
replace province = 7 if county_s == "Nandi"
replace province = 7 if county_s == "Baringo"
replace province = 7 if county_s == "Laikipia"
replace province = 7 if county_s == "Nakuru"
replace province = 7 if county_s == "Nakuru "
replace province = 7 if county_s == "Narok"
replace province = 7 if county_s == "Kajiado"
replace province = 7 if county_s == "Kericho"
replace province = 7 if county_s == "Bomet"
replace province = 8 if county_s == "Kakamega"
replace province = 8 if county_s == "Vihiga"
replace province = 8 if county_s == "Bungoma"
replace province = 8 if county_s == "Busia"
replace province = 6 if county_s == "Siaya"
replace province = 6 if county_s == "Kisumu"
replace province = 6 if county_s == "Homa Bay"
replace province = 6 if county_s == "Migori"
replace province = 6 if county_s == "Kisii"
replace province = 6 if county_s == "Nyamira"
replace province = 1 if county_s == "Nairobi"

#delimit ;
lab def prov
           1 "Nairobi"
           2 "Central"
           3 "Coast"
           4 "Eastern"
           5 "N Eastern"
           6 "Nyanza"
           7 "Rift Valley"
           8 "Western";

#delimit cr


drop county_s
lab val province prov

exit
