clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Gender Gaps in Agriculture									*
* MASTER														*
* (based on input files/code from Haseeb Ali and Habtamu Fuje   *
*---------------------------------------------------------------*


do "${gsdDo}/2-3-9_KPGA_1_AgGender_DM.do"
do "${gsdDo}/2-3-9_KPGA_2_AgGender_Yields.do"
do "${gsdDo}/2-3-9_KPGA_3_AgGender_DescStats.do"
do "${gsdDo}/2-3-9_KPGA_4_AgGender_YieldReg.do"

di in red "ALL FILES RUN :) :) :) "

exit
