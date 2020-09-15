*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* MASTER 														*
* -> runs all analysis files									*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

clear all
set more off

if ("${gsdData}"=="") {
	di as error "Configure work environment in 00-run.do before running the code."
	error 1
}

*directories 
run "${gsdDo}/2-3-0-KPGA_directories.do"

*graphs -> drawing on stats from 2009 census (MMR)
run "${gsdDo}/2-3-1-KPGA_Census2009_graphs.do"

*core labor analysis 
run "${gsdDo}/2-3-2-KPGA_LaborAnalysis.do"

*oaxaca-blinder decomposition of gender gap in wages 
run "${gsdDo}/2-3-3-KPGA_WageDecomp.do"

* graphs -> drawing on education statistics from Simon Lange 
run "${gsdDo}/2-3-4-KPGA_EducMaps.do"

* poverty analysis 
run "${gsdDo}/2-3-5-KPGA_Poverty.do"

* misc. analysis - time use, literacy, ICT, dropouts 
run "${gsdDo}/2-3-6-KPGA_KIHBSmiscellaneous.do"

* graphs -> drawing on WDI data
run "${gsdDo}/2-3-7-KPGA_WDIgraphs.do"

* graphs -> drawing on DHS StatCompiler data 
run "${gsdDo}/2-3-8-KPGA_DHSStatCompiler.do"

* gender gaps in agric. -> drawing on input files from Haseeb Ali/Habtamu Fuje 
run "${gsdDo}/2-3-9-KPGA_00_AgGender_MASTER.do"

