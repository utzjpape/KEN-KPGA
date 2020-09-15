*Master do file for the simulation of programs

set more off
set seed 23081980 
set sortseed 11041955


*Estimate poverty and population projections into the future
run "${gsdDo}/3-4-1-DfID_Poverty-Population_Projections.do"

*Simulations for each program
run "${gsdDo}/3-4-2-DfID_program_market_assistance.do"
run "${gsdDo}/3-4-3-DfID_program_hunger_safety_net.do"
run "${gsdDo}/3-4-4-DfID_program_nutrition.do"
run "${gsdDo}/3-4-5-DfID_program_social_protection.do"
run "${gsdDo}/3-4-6-DfID_program_mini_grids.do"
run "${gsdDo}/3-4-7-DfID_program_family_plannig.do"
run "${gsdDo}/3-4-8-DfID_program_adolescent_girls.do"
run "${gsdDo}/3-4-9-DfID_program_refugee_host_support.do"
run "${gsdDo}/3-4-10-DfID_program_regional_investment_trade.do"

*Integrate the results for all programs
run "${gsdDo}/3-4-11-DfID_program_all.do"
