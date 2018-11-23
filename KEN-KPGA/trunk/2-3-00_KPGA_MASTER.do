*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* MASTER 														*
* -> runs all analysis files									*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

do "$path/Do/0_KPGA_directories.do"						/* directories */
do "$path/Do/1_KPGA_Census2009_graphs.do"				/* graphs -> drawing on stats from 2009 census (MMR) */
do "$path/Do/2_KPGA_LaborAnalysis.do"					/* core labor analysis */
do "$path/Do/3_KPGA_WageDecomp.do"						/* oaxaca-blinder decomposition of gender gap in wages */
do "$path/Do/4_KPGA_EducMaps.do"						/* graphs -> drawing on education statistics from Simon Lange */
do "$path/Do/5_KPGA_Poverty.do"							/* poverty analysis */
do "$path/Do/6_KPGA_KIHBSmiscellaneous.do"				/* misc. analysis - time use, literacy, ICT, dropouts */
do "$path/Do/7_KPGA_WDIgraphs.do"						/* graphs -> drawing on WDI data */
do "$path/Do/8_KPGA_DHSStatCompiler.do"					/* graphs -> drawing on DHS StatCompiler data */
do "$path/Do/9_KPGA_00_AgGender_MASTER.do"				/* gender gaps in agric. -> drawing on input files from Haseeb Ali/Habtamu Fuje *** MASTER */

exit
