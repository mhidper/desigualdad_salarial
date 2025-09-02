*----------------------------------------------
* Project: Desigualdad La Caixa
* Descriptivos y ajuste distribucuion
* con salarios imputaods
* 06/02/2021, version 1
* Manuel Alejandro Hidalgo (Universidad Pablo de Olavide)
*--------------------------------------------------

*--------------------------------------------------
* Program Setup
*--------------------------------------------------

version 12              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
*--------------------------------------------------

cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\datos preparados\"

use preparados.dta, replace

gen lwage=log(wage)

global X sexo years years2 age age2 medium medbig big_e flexib_e lhours temporary_c agency_c noformal_c other_c edu1-edu3 pedag  ///
humdades econ natural stem agric medic pers_ser otros_super ict_basic ict_moderate ict_advanced ///
tecnical communic team foreign customer prob_solv learn_sk planning sectores2-sectores16 occ1-occ8 cambio_tic

/*
reg lwage $X [aw=weight_country_noeducation] if country=="ES" & wage<15000
outreg2 using esp.doc, replace ctitle(esp)
estimates store OLS1

reg lwage $X [aw=weight_country_noeducation] if country=="GER" & wage<15000
outreg2 using esp.doc, append ctitle(ger)
estimates store OLS2

reg lwage $X [aw=weight_country_noeducation] if country=="FRA" & wage<15000
outreg2 using esp.doc, append ctitle(fra)
estimates store OLS3

reg lwage $X [aw=weight_country_noeducation] if country=="IT" & wage<15000
outreg2 using esp.doc, append ctitle(ita)
estimates store OLS4

*/
gen es=(country=="ES")


egen rif_var=rifvar(lwage), var by(es)

 foreach var of varlist rif_var $X {
                quietly summarize `var' 
                qui scalar mean=r(mean)
				qui replace `var'=`var'-mean 
}


oaxaca rif_var $X [aw=  weight_with_education] if wage<15000, ///
detail(trabajador: sexo years years2 age age2 edu1-edu3 pedag humdades econ natural stem agric medic pers_ser otros_super, ///
contrato: lhours temporary_c agency_c noformal_c other_c, sector:sectores2-sectores16, ocup: occ1-occ8, tareas: tecnical communic team foreign customer prob_solv learn_sk planning, ///
ict: ict_basic ict_moderate ict_advanced cambio_tic, empresa: medium medbig big_e flexib_e) relax swap pooled by(es)


mat AA=r(table)'


kk
