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

oaxaca rif_var $X [aw=weight_country_noeducation] if wage<15000, ///
detail(trabajador: sexo years years2 age age2 edu1-edu3 pedag humdades econ natural stem agric medic pers_ser otros_super, ///
contrato: lhours temporary_c agency_c noformal_c other_c, sector:sectores2-sectores16, ocup: occ1-occ8, tareas: tecnical communic team foreign customer prob_solv learn_sk planning, ///
ict: ict_basic ict_moderate ict_advanced cambio_tic, empresa: medium medbig big_e flexib_e) relax swap pooled by(es)

kk
/* estimates store OLS1
coefplot OLS1, levels(90) xline(0) sort(, descending)  xsize(20.000) ysize(10.000) pstyle(p5) ///
 drop(_cons) ylabel(, labsize(tiny))
*/
oaxaca lwage_ph years years2 age age2 comm_team cust_low verbal normalize(emp1-emp8) lhours normalize(contract1-contract5) ///
normalize(sectores1-sectores16) normalize(edu1-edu7) normalize(occ1-occ10) cambio_tic ///
normalize(ict_skills1 ict_skills2 ict_skills3 ict_skills4 ict_skills5) [aw= weight_country_noeducation], ///
detail(edad: age age2, experiencia: years years2, ///
contrato: contract2-contract5, empresa: emp1-emp8,sectores: sectores1-sectores16, ocupacion: occ1-occ10, ///
educacion: edu1-edu7, ict: ict_skills1 ict_skills2 ict_skills3 ict_skills4 ict_skills5, tasks: comm_team cust_low verbal) by(sexo) omega relax

gen educa=0
replace educa=1 if edu1==1 | edu2==1 | edu3==1 | edu4==1

*Ejemplo de rifvar

egen rif_iqr=rifvar(lwage_ph), gini

reg rif_iqr $X [aw= weight_country_noeducation] 

oaxaca_rif lwage_ph $X [aw= weight_country_noeducation], rif(gini) relax by(educa)
kk

oaxaca_rif lwage_ph years years2 age age2 comm_team cust_low verbal normalize(emp1-emp8) lhours normalize(contract1-contract5) ///
normalize(sectores1-sectores16) normalize(edu1-edu7) normalize(occ1-occ10) cambio_tic ///
normalize(ict_skills1 ict_skills2 ict_skills3 ict_skills4 ict_skills5), ///
rif(iqr(10 90)) by(edu1) w(1) relax
