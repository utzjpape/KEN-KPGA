*-------------------------------------------------------------------
*
*     KENYA GENDER AND POVERTY ASSESSMENT
*     
*     
*     This file contains the sequence of do-files
*     written to carry out the analysis 
*                         
*-------------------------------------------------------------------

clear all
set more off
set maxvar 10000


*Check if filepaths have been established using init.do
if "${gsdData}"=="" {
	display as error "Please run init.do first."
	error 1
}

*supress all graphs
set graphics off

*Stage 1 - Data preparation
run "${gsdDo}/1-1-homogonise.do"
run "${gsdDo}/1-2-hh.do"
run "${gsdDo}/1-3-hhm.do"
run "${gsdDo}/1-4-finalize.do"
run "${gsdDo}/1-5-1-income05.do"
run "${gsdDo}/1-5-2-income15.do"
run "${gsdDo}/1-5-3-income_merge.do"

*Chapter 1 - Intro
*Download cross country welfare indicators
run "${gsdDo}/2-1-1-Cross_Country_Indicators.do"
*Monetary poverty analysis
run "${gsdDo}/2-1-2-Monetary_Poverty.do"

*Chapter 2 - Trends
*run "${gsdDo}/2-1-2-Monetary_Poverty.do"
*run "${gsdDo}/2-2-1-nonresponse.do"
*run "${gsdDo}/2-2-1-periurban.do"
*Tabulation of poverty and shared prosperity statistics at provincial / NEDI and rural urban levels.
run "${gsdDo}/2-2-1-spatialprofile.do"
*Ravallion-Huppi (sectoral) decomposition on income source categories
run "${gsdDo}/2-2-2-income_decomp.do"
*Poverty profile based on household head characteristics
run "${gsdDo}/2-2-3-hhdprofile.do" 
*Map of poverty headcount rates by NEDI classification.
run "${gsdDo}/2-2-4-nedimap.do"

*Chapter 3 - Gender
run "${gsdDo}/2-3-00-KPGA_MASTER.do"

*Chapter 4 - Rural
*Clean 2005/06 and 2015/16 data towards creating ag. output aggregates.
run "${gsdDo}/2-4-1-KIHBS_Cleaning_2006.do"
run "${gsdDo}/2-4-2-KIHBS_Cleaning_2015.do"
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
run "${gsdDo}/2-4-9-ISIC_classification.do"
*Output poverty rate abd proportion of population by decile of agricultural hours worked. Fig. 4.5
run "${gsdDo}/2-4-10-CDFs.do"
*Land area cultivated by crop as a proportion of total area cultivated.
run "${gsdDo}/2-4-11-Land Area_Crops.do"
*Other rural indicators
*run "${gsdDo}/2-4-12-Additional_rural.do"

*Chapter 5 - Urban
*data preparation
run "${gsdDo}/2-5-1-data.do"
*Run analysis
run "${gsdDo}/2-5-2-analysis.do" 
*analysis of internal migration using DHS 2014
run "${gsdDo}/2-5-3-DHS.do"

*Chapter 8 - Vulnerability
*Prepare datasets
run "${gsdDo}/2-8-1-2005_Prepare_Dataset.do"
run "${gsdDo}/2-8-1-2015_Prepare_Dataset.do"
*Tabulate descriptive statistics
run "${gsdDo}/2-8-2-2005_Descriptives.do"
run "${gsdDo}/2-8-2-2015_Descriptives.do"
*Create 2005/06 poverty & vulnerability profile
run "${gsdDo}/2-8-3-2005_povertyprofile.do"
*Prepare 2005 shocks & coping strategy 
run "${gsdDo}/2-8-4-2005_coping_prepare.do"
*Tabulate shock incidence and severity and coping strategy (by poor/non-poor & rural/urban)
run "${gsdDo}/2-8-5-2005_coping_descriptives.do"
run "${gsdDo}/2-8-6-2005_Shocks.do"
run "${gsdDo}/2-8-7-2015_Shocks.do"
run "${gsdDo}/2-8-8-2015_coping_prepare.do"
run "${gsdDo}/2-8-9-2015_coping_descriptives.do"


*Other analysis: Inequality note trends between 2005/06 and 2015/16
run "${gsdDo}/2-9-Shared_Prosperity.do"


*Other analysis: DFID poverty analysis estimating the effect of programs
run "${gsdDo}/3-1-DfID_introduction.do"
run "${gsdDo}/3-2-DfID_poverty_dynamics.do"
run "${gsdDo}/3-3-DfID_regional_disparities.do"
run "${gsdDo}/3-4-0-DfID_Master_Program_Simulations.do"

