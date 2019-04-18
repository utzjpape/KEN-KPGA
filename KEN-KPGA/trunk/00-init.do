
*Initialize work environment

global suser = c(username)

clear all
set more off
set maxvar 10000
set seed 23081980 
set sortseed 11041955

if (inlist("${suser}","wb390290","WB390290")) {
	*Utz
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\WB390290\OneDrive - WBG\Home\Countries\Kenya\Projects\FY17-KPGA\KPGA-SV"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\WB390290\OneDrive - WBG\Home\Countries\Kenya\Projects\FY17-KPGA\KPGA-DB\0-RawInput"
}
else if (inlist("${suser}","wb445085","WB445085")) {
	*Carolina
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\wb445085\OneDrive - WBG\KPGA-Code"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\wb445085\OneDrive - WBG\KPGA\DataBox"
                    
}
else if (inlist("${suser}","nduati", "wb475840", "WB475840")) {
	*Nduati
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\WB475840\Documents\KPGA"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\WB475840\WBG\Utz Johann Pape - KPGA-DB\0-RawInput"

}
else if (inlist("${suser}","nduati", "wb495217", "WB495217")) {
	*Simon
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\WB495217\OneDrive - WBG\SL WBG Files\PA Kenya\KEN-KPGA"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\WB495217\WBG\Utz Johann Pape - DataBoxFull"

}
else if (inlist("${suser}","WB499706", "wb499706")) {
	*Philip
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\WB499706\OneDrive - WBG\WBG Data PW\Code\KEN\KPGA"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\WB499706\WBG\Carolina Mejia-Mantilla - KPGA\DataBox"
	
}
else if (inlist("${suser}","wb484006", "WB484006")) {	
	*Gonzalo
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\WB484006\OneDrive - WBG\Code\KEN\KPGA"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\WB484006\WBG\Utz Johann Pape - KPGA-DB\0-RawInput"
}
else if (inlist("${suser}","wb544731", "WB544731")) {	
	*Alastair
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\wb544731\OneDrive - WBG\Countries\Kenya\KEN-KPGA"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\wb544731\WBG\Utz Johann Pape - KPGA-DB\0-RawInput"
}
else {
	di as error "Configure work environment in 00-init.do before running the code."
	error 1
}


global gsdData = "`swdLocal'/Data"
global gsdDo = "`swdLocal'/Do"
global gsdTemp = "`swdLocal'/Temp"
global gsdOutput = "`swdLocal'/Output"
global gsdDataRaw = "`swdBox'"
global gsdOutput_poverty_profile = "`swdBox_poverty_profile'/Figures"

*If needed, install the directories and packages used in the process 
capture confirm file "`swdLocal'/Data/nul"
scalar define n_data=_rc
capture confirm file "`swdLocal'/Temp/nul"
scalar define n_temp=_rc
capture confirm file "`swdLocal'/Output/nul"
scalar define n_output=_rc
scalar define check=n_data+n_temp+n_output
di check

if ((check!=0) & ("${suser}"!="nduati")) {
	mkdir "${gsdData}"
	mkdir "${gsdData}/1-CleanInput"
	mkdir "${gsdData}/1-CleanTemp"
	mkdir "${gsdData}/1-CleanOutput"
	mkdir "${gsdData}/2-AnalysisOutput"
	mkdir "${gsdData}/2-AnalysisOutput/C4-Rural"
	mkdir "${gsdData}/2-AnalysisTemp"
	mkdir "${gsdTemp}"
	mkdir "${gsdOutput}"
	mkdir "${gsdOutput}/C2-Trends"
	mkdir "${gsdOutput}/C3-Gender"
	mkdir "${gsdOutput}/C4-Rural"
	mkdir "${gsdOutput}/Inequality"

	*install packages used in the process
	ssc install distinct
	ssc install missings
	ssc install labutil2
	ssc install labutil
	ssc install labmv
	ssc install egenmore
	ssc install outreg2
	ssc install vincenty
	ssc install fastgini
	ssc install tabout
	ssc install logout
	ssc install svylorenz
	ssc install shp2dta
    ssc install spmap
	ssc install sdecode
	ssc install fitstat
	ssc install drdecomp
	net install dm79.pkg
	ssc install winsor
	ssc install winsor2
	ssc install oaxaca
	ssc install strrec
	ssc install ineqdeco
}
