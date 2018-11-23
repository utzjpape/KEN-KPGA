*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Directories 													*
* -> sets all relevants directories and paths					*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

*** Specify directories

if c(username)=="wb323496" {
	global path "C:\Users\wb323496\OneDrive - WBG\WB_2014 - Gender CCSA\Cross support\FY17 - Kenya KPGA\Analysis_final"
	global pth  "C:\Users\wb323496"
	cd "$path/Do"                             
}


*** Input directories

* Shared KIHBS folder

global dir_kihbs2005 	"${gsdDataRaw}/KIHBS05"    /* KIHBS 2005/6 */
global dir_kihbs2015 	"${gsdDataRaw}/KIHBS15"    /* KIHBS 2015/6 */

* Other folders

global dir_census2009 	"${gsdDataRaw}/3-Gender/Data/Census2009"						/* statics from 2009 census (not raw data)*/
global dir_gisnew 		"${gsdDataRaw}/3-Gender/Shape"  								/* final set of shape files */    
global dir_educstats	"${gsdDataRaw}/3-Gender/Data/Education_Simon"					/* education statistics from Simon */
global dir_agfiles		"${gsdDataRaw}/3-Gender/Data/Agriculture_Haseeb"				/* agriculture files from Haseeb/Habtamu */
global dir_wdi			"${gsdDataRaw}/3-Gender/Data/WDI"								/* World Development Indicators */
global dir_DHSStats		"${gsdDataRaw}/3-Gender/Data/DHSStatCompiler"					/* DHS Stat Compiler */


*** Output directories
capture mkdir "${gsdOutput}/C3-Gender/Graphs"	
capture mkdir "${gsdOutput}/C3-Gender/Tables"	
capture mkdir "${gsdOutput}/C3-Gender/ip"	
capture mkdir "${gsdOutput}/C3-Gender/temp"	


global dir_graphs 		"${gsdOutput}/C3-Gender/Graphs"	   		/* graphs */
global dir_tables		"${gsdOutput}/C3-Gender/Tables"			/* tables */
global ipdir  			"${gsdOutput}/C3-Gender/ip"			   	/* in process */
global tempdir			"${gsdOutput}/C3-Gender/temp"

exit
