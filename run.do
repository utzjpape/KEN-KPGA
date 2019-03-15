*Do

*Stage 1 - Data preperation
run "${gsdDo}/1-1-hh.do"
run "${gsdDo}/1-2-hhm.do"
run "${gsdDo}/1-3-finalize.do"
run "${gsdDo}/1-4-1-income05.do"
run "${gsdDo}/1-4-1-income15.do"
run "${gsdDo}/1-4-2-income_merge.do"

*Chapter 1 - Intro
*run...


*Chapter 2 - Trends
*run files
run "${gsdDo}/2-2-1-spatialprofile.do"
run "${gsdDo}/2-2-2-income_decomp.do"
run "${gsdDo}/2-2-3-hhdprofile.do"
run "${gsdDo}/2-2-4-nedimap.do"


*Chapter 3 - Gender
*directories
run "${gsdDo}/2-3-0_KPGA_directories.do"	
*graphs -> drawing on stats from 2009 census (MMR)				
run "${gsdDo}/2-3-1_KPGA_Census2009_graphs.do"				
*core labor analysis
run "${gsdDo}/2-3-2_KPGA_LaborAnalysis.do"	
*oaxaca-blinder decomposition of gender gap in wages				
run "${gsdDo}/2-3-3_KPGA_WageDecomp.do"
*graphs -> drawing on education statistics from Simon Lange					
run "${gsdDo}/2-3-4_KPGA_EducMaps.do"	
*poverty analysis
run "${gsdDo}/2-3-5_KPGA_Poverty.do"
*misc. analysis - time use, literacy, ICT, dropouts					
run "${gsdDo}/2-3-6_KPGA_KIHBSmiscellaneous.do"	
*graphs -> drawing on WDI data
run "${gsdDo}/2-3-7_KPGA_WDIgraphs.do"	
*graphs -> drawing on DHS StatCompiler data					
run "${gsdDo}/2-3-8_KPGA_DHSStatCompiler.do"
*gender gaps in agric. -> drawing on input files from Haseeb Ali/Habtamu Fuje *** MASTER					
run "${gsdDo}/2-3-9_KPGA_00_AgGender_MASTER.do"

*Chapter 4 - Rural
*Clean 2005 data
run "${gsdDo}/2-4-1-KIHBS Cleaning 2006.do"
*Clean 2015 data
run "${gsdDo}/2-4-2-KIHBS Cleaning 2015.do"
*Characteristics of the Rural Poor 
run "${gsdDo}/2-4-3-Poor_05_15.do"
*Income by source
run "${gsdDo}/2-4-4-Income_05_15.do"
*Hours Worked in Agriculture/NonAgriclture within Household
run "${gsdDo}/2-4-5-Employment_hours_05_15.do"
*gender of decision maker
run "${gsdDo}/2-4-6-Gender_DM.do"
*Calculating Yield and its relationship with poverty
run "${gsdDo}/2-4-7-Yield.do"
*Poverty & yield change by county, is there a correlation, look at wheat+beans
run "${gsdDo}/2-4-8-Poverty_yield.do"
*ISIC classifications
run "${gsdDo}/2-4-9-ISIC classification.do"
*Hours worked / proportion poor by xtiles
run "${gsdDo}/2-4-10-CDFs.do"
*Proportion of land area devoted to crops
run "${gsdDo}/2-4-11-Land Area Crops.do"

