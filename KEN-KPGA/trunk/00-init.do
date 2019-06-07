
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
	local swdLocal = "C:\Users\WB390290\OneDrive - WBG\Home\Countries\Kenya\Projects\FY17-KPGA\SV-KPGA"
	*Box directory where the Data folder can be located
	*Full Dataset
	local swdBox = "C:\Users\WB390290\OneDrive - WBG\Home\Countries\Kenya\Projects\FY17-KPGA\KPGA-DB"
	*Team Dataset
*	local swdBox = "C:\Users\WB390290\WBG\Carolina Mejia-Mantilla - KPGA\DataBox"
}
else if (inlist("${suser}","wb445085","WB445085")) {
	*Carolina
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\wb445085\OneDrive - WBG\KPGA-Code"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\wb445085\OneDrive - WBG\KPGA\DataBox"
                    
}
else if (inlist("${suser}", "wb475840", "WB475840")) {
	*Nduati
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\wb475840\WBG\Utz Johann Pape - Kenya\Projects\FY17-KPGA\KPGA-DB"

}
else if (inlist("${suser}", "wb495217", "WB495217")) {
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
else {
	di as error "Configure work environment in 00-init.do before running the code."
	error 1
}


global gsdData = "`swdLocal'/Data"
global gsdDo = "`swdLocal'/Do"
global gsdTemp = "`swdLocal'/Temp"
global gsdOutput = "`swdLocal'/Output"
global gsdDataRaw = "`swdBox'/0-RawInput"
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
	mkdir "${gsdData}/2-AnalysisInput"
	mkdir "${gsdTemp}"
	mkdir "${gsdOutput}"
	mkdir "${gsdOutput}/C1-Overview"
	mkdir "${gsdOutput}/C2-Trends"
	mkdir "${gsdOutput}/C3-Gender"
	mkdir "${gsdOutput}/C4-Rural"
	mkdir "${gsdOutput}/C5-Urban"
	mkdir "${gsdOutput}/C6-Education"
	mkdir "${gsdOutput}/C7-Health"
	mkdir "${gsdOutput}/C8-Vulnerability"
}	

local commands = " distinct missings labmv povdeco outreg2 vincenty fastgini tabout logout svylorenz shp2dta grmap winsor winsor2 oaxaca strrec apoverty wbopendata apoverty sedecomposition glcurve"
foreach c of local commands {
	capture : which `c'
	if (_rc) {
                display as result in smcl `"Please install package {it:`c'} from SSC in order to run this do-file;"' _newline `"you can do so by clicking this link: {stata "ssc install `c'":auto-install `c'}"'
                exit 199
	}
}

