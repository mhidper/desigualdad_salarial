*----------------------------------------------
* Project: Desigualdad La Caixa
* Descriptivos y ajuste distribucuion
* con salarios imputaods
* 12/02/2021, version 1
* Manuel Alejandro Hidalgo (Universidad Pablo de Olavide)
*UBICACIÓN FICHEROS RESULTADOS:
*C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\EXCEL\figuras descriptivas.xlsx
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


*figura 1
/*
kdensity wage if country=="ES" & wage<10000 & wage>0, generate(esp_x esp_d)

kdensity wage if country=="GER" & wage<10000 & wage>0, generate(ger_x ger_d) at(esp_x)
kdensity wage if country=="FRA" & wage<10000 & wage>0, generate(fra_x fra_d) at(esp_x)
kdensity wage if country=="IT" & wage<10000 & wage>0, generate(it_x it_d) at(esp_x)
*/
gen lwage=log(wage)

egen gcountry=group(country)

egen rif_var=rifvar(lwage), iqr(10 90) by(gcountry)

replace resp_gender=resp_gender-1

global X resp_gender sectores2-sectores16  indef_c temporary_c agency_c noformal_c other_c contract6 edu2-edu8



foreach var of varlist $X {
                sum `var' if country=="ES"
				scalar mean=r(mean)
				replace `var' = `var' - mean if country=="ES"
				sum `var' if country=="GER"
				scalar mean=r(mean)
				replace `var' = `var' - mean if country=="GER"
				sum `var' if country=="FRA"
				scalar mean=r(mean)
				replace `var' = `var' - mean if country=="FRA"
				sum `var' if country=="IT"
				scalar mean=r(mean)
				replace `var' = `var' - mean if country=="IT"
				}


oaxaca rif_var $X normalize(sectores1-sectores16) [aw= weight_country_with_education], ///
detail(sector: sectores2-sectores16, contrato:  indef_c temporary_c agency_c noformal_c other_c contract6, ///
educ: edu2-edu8) ///
pooled relax by(esp) swap


oaxaca rif_var $X [aw= weight_country_with_education] if country=="ES" | country=="GER", ///
detail(sector: sectores2-sectores16, contrato:  indef_c temporary_c agency_c noformal_c other_c contract6, ///
educ: edu2-edu8) ///
pooled relax by(esp) swap
kk
oaxaca rif_var sexo sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios7 anoanti anoanti2 ///
conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal] if year==2010, detail(sectores: sect1-sect27, contrato: contrato1-contrato4 horas, ///
		ocupacion: ocup1-ocup16, trabajador: estudios1-estudios7 anoanti anoanti2 sexo, ///
		empresa: conv_1-conv_5 market1-market4 tipopais control) pooled relax by(jovenes) swap
