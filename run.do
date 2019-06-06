*Run do-file for KPGA chapters. 

*Stage 1 - Data preperation
run "${gsdDo}/1-1-hh.do"
run "${gsdDo}/1-2-hhm.do"
run "${gsdDo}/1-3-finalize.do"
run "${gsdDo}/1-4-1-income05.do"
run "${gsdDo}/1-4-1-income15.do"
run "${gsdDo}/1-4-2-income_merge.do"

*Chapter 1 - Intro
*Download cross country welfare indicators
run "${gsdDo}/2-1-1_Cross-Country_Indicators.do"
*Monetary poverty analysis
run "${gsdDo}/2-1-2_Monetary_Poverty.do"

*Chapter 2 - Trends
*Tabulation of poverty and shared prosperity statistics at provincial / NEDI and rural urban levels.
run "${gsdDo}/2-2-1-spatialprofile.do"
*Ravallion-Huppi (sectoral) decomposition on income source categories
run "${gsdDo}/2-2-2-income_decomp.do"
*Do-file calculates household head poverty profile
run "${gsdDo}/2-2-3-hhdprofile.do"
*Map of poverty headcount rates by NEDI classification.
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
*Clean 2005/06 and 2015/16 data towards creating ag. output aggregates.
run "${gsdDo}/2-4-1-KIHBS Cleaning 2006.do"
run "${gsdDo}/2-4-2-KIHBS Cleaning 2015.do"
*Rural poverty profile
run "${gsdDo}/2-4-3-Poor_05_15.do"
*Generate household income variable and output proportions of income by source
run "${gsdDo}/2-4-4-Income_05_15.do"
*Hours Worked in Agriculture / NonAgriclture within Household 
run "${gsdDo}/2-4-5-Employment_hours_05_15.do"
*Identify primary farm decision maker
run "${gsdDo}/2-4-6-Gender_DM.do"
*Calculate crop yield and it's relationship to poverty by gender and by location
run "${gsdDo}/2-4-7-Yield.do"
*Poverty & yield change between survey years by county, focus on maize and beans. 
run "${gsdDo}/2-4-8-Poverty_yield.do"
*Classify households by primary ISIC code and output salary by code
run "${gsdDo}/2-4-9-ISIC classification.do"
*Output poverty rate abd proportion of population by decile of agricultural hours worked. Fig. 4.5
run "${gsdDo}/2-4-10-CDFs.do"
*Land area cultivated by crop as a proportion of total area cultivated.
run "${gsdDo}/2-4-11-Land Area Crops.do"

*Chapter 5 - Urban
*data preparation
run "${gsdDo}/2-5-1-data.do"
*Run analysis
run "${gsdDo}/2-5-2-analysis.do"
*analysis of internal migration using DHS 2014
run "${gsdDo}/2-5-3-DHS.do"

*Chapter 8 - Vulnerability
*Prepare datasets
run "${gsdDo}/2-8-1-2005 Prepare Dataset.do"
run "${gsdDo}/2-8-1-2015 Prepare Dataset.do"
*Tabulate descriptive statistics
run "${gsdDo}/2-8-2-2005 Descriptives.do"
run "${gsdDo}/2-8-2-2015 Descriptives.do"
*Create 2005/06 poverty & vulnerability profile
run "${gsdDo}/2-8-3-2005 povertyprofile.do"
*Prepare 2005 shocks / coping strategy data
run "${gsdDo}/2-8-4-2005 coping prepare.do"
run "${gsdDo}/2-8-5-2005 coping descriptives.do"
run "${gsdDo}/2-8-6-2005 Shocks.do"

run "${gsdDo}/2-8-7-2015 Shocks.do"
run "${gsdDo}/2-8-8-2015 coping prepare.do"
run "${gsdDo}/2-8-9-2015 coping descriptives.do"
