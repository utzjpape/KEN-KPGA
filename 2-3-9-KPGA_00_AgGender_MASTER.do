*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Gender Gaps in Agriculture									*
* MASTER														*
* (based on input files/code from Haseeb Ali and Habtamu Fuje   *
*---------------------------------------------------------------*
clear all
set more off

if ("${gsdData}"=="") {
	di as error "Configure work environment in 00-run.do before running the code."
	error 1
}


run "${gsdDo}/2-3-9-KPGA_1_AgGender_DM.do"
run "${gsdDo}/2-3-9-KPGA_2_AgGender_Yields.do"
run "${gsdDo}/2-3-9-KPGA_3_AgGender_DescStats.do"
run "${gsdDo}/2-3-9-KPGA_4_AgGender_YieldReg.do"

