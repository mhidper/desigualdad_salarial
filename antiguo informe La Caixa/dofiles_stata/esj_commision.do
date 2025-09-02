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



cd "C:\Users\alejh\Dropbox\INVESTIGACIÓN\Ocupacion y Covid\ESJ Data\Cedefop ESJS microdata Dissemination\Cedefop_ESJS_Data\"

use Cedefop_ESJS_microdata.dta


*Elimino quienes no dan salario

drop if q51==97
drop if q51==99


gen country="ES" if qcountry==12
replace country="GER" if qcountry==1
replace country="FRA" if qcountry==2
replace country="IT" if qcountry==5

gen esp=country=="ES"

drop if country==""
 

*Salarios
ren q50_12_1 wageES /*ESP*/
count if wageES!=.
ren q50_2_1 wageGER /*GER*/
count if wageGER!=.
ren q50_3_1 wageFRA /*FRA*/
count if wageFRA!=.
ren q50_5_1 wageIT /*IT*/
count if wageIT!=.

gen wage=wageES
replace wage=wageGER if wageGER!=.
replace wage=wageFRA if wageFRA!=.
replace wage=wageIT if wageIT!=.

replace wage=wage/14 if wage>30000

*Horas

ren q10_2 hourspw

gen lhours=log(4*hourspw)

label var lhours "Log Horas"

*GÉNERO

ren q1b sexo
replace sexo=sexo-1

label var sexo "mujer"

*años

gen age= resp_age
gen age2=age^2

label var age "edad"
label var age2 "edad al cuadrado"

*AÑOS EN TRABAJO

ren q7_2 years
gen years2=years^2

label var years "antiguedad"
label var years2 "antiguedad al cuadrado"

*SECTORES

tab q6a, gen(sectores)

label var sectores1 "Administration"
label var sectores2 "Agriculture"
label var sectores3 "Supply of energy"
label var sectores4 "Supply water"
label var sectores5 "Manufacturing"
label var sectores6 "Construction"
label var sectores7 "Retail"
label var sectores8 "Accomm. or food services"
label var sectores9 "Transportation"
label var sectores10 "ITC services"
label var sectores11 "Financial"
label var sectores12 "Prof. scient.services"
label var sectores13 "Education or health"
label var sectores14 "Culture"
label var sectores15 "Social services"
label var sectores16 "Other"


*Empleados empresas

tab q6c, gen(emp)

rename emp1 pyme
rename emp2 medium
gen medbig_e=emp3+emp4
gen big_e=emp5+emp6
gen flexib_e=emp7+emp8+emp9

drop emp* 


*Contratos

tab q12, gen(contract)
replace contract5=contract5+contract6

ren contract1 indef_c
ren contract2 temporary_c
ren contract3 agency_c
ren contract4 noformal_c
ren contract5 other_c



*Educación

tab q15, gen(edu)

*Estudios

replace q1701=0 if q1701==. 
replace q1702=0 if q1702==. 
replace q1703=0 if q1703==.
replace q1704=0 if q1704==.
replace q1705=0 if q1705==.
replace q1706=0 if q1706==. 
replace q1707=0 if q1707==. 
replace q1708=0 if q1708==.
replace q1709=0 if q1709==.
replace q1710=0 if q1710==.
replace q1711=0 if q1711==. 
replace q1712=0 if q1712==. 
replace q1713=0 if q1713==. 
replace q1714=0 if q1714==. 

replace q1712=q1712+q1713+q1714

ren q1701 pedag
ren q1702 human
ren q1703 econ
ren q1704 othersoc
ren q1705 natural
ren q1706 math
ren q1707 comput
ren q1708 engin
ren q1709 agric
ren q1710 medic
ren q1711 pers_ser
ren q1712 otros_super


gen stem=math+comput+engin
gen humdades=human+othersoc

*ocupación

tab q3a_1_q3, gen(occ)


*ICT skills
tab q21a, gen(lit_skills)
tab q21b, gen(num_skills)
tab q21c, gen(ict_skills)


ren lit_skills1 lit_basic
ren lit_skills2 lit_advanced

drop lit_skills*

ren num_skills1 num_basic
ren num_skills2 num_advanced

drop num_skills*


ren ict_skills1 ict_basic
ren ict_skills2 ict_moderate
ren ict_skills3 ict_advanced

drop ict_skills4 ict_skills5

rename q23a_1_scale tecnical
rename q23a_2_scale communic
rename q23a_3_scale team
rename q23a_4_scale foreign
rename q23a_5_scale customer
rename q23a_6_scale prob_solv
rename q23a_7_scale learn_sk
rename q23a_8_scale planning

tab q24, gen(mism)

rename mism1 mis_higher
rename mism2 mis_matched
rename mism3 mis_lower

drop mism4

ren q36_1 cambio_tic

*Hago factorial para guardarlos y luego ver si es mejor para las estimaciones
factor  tecnical communic team foreign customer prob_solv learn_sk planning

predict f1 f2 f3
ren f1 comm_team
ren f2 cust_low
ren f3 verbal


/*IMPUTACIÓN DE SALARIOS POR PAÍS Y GRUPOS*/
********************************************



global X sexo years years2 age age2 pyme medium medbig big_e flexib_e lhours temporary_c agency_c noformal_c other_c edu4 pedag  ///
human econ othersoc natural math comput engin agric medic pers_ser otros_super ict_basic ict_moderate ict_advanced ///
comm_team cust_low verbal sectores2-sectores16 occ1-occ8 cambio_tic

/* 
1	Germany (DE)
2	France (FR)
5	Italy (IT)
9   Netherland (NL)
14  Belgium (BE)
BENE
*/


*45	Less than €1360
*46	Between €1361 - €1890
*47	Between €1891 - €2915
*48	More than €2915 

gen     imputados =45 if wage>0 & wage<=1360 & country=="ES" & q51==.
replace imputados =46 if wage>1360 & wage<=1890 & country=="ES"  & q51==.
replace imputados =47 if wage>1890 & wage<=2915 & country=="ES"  & q51==.
replace imputados =48 if wage>2915 & country=="ES" & q51==.

replace imputados =5 if wage>0 & wage<=1300 & country=="GER" & q51==.
replace imputados =6 if wage>1300 & wage<=2300 & country=="GER"  & q51==.
replace imputados =7 if wage>2300 & wage<=3200 & country=="GER"  & q51==.
replace imputados =8 if wage>3200 & country=="GER" & q51==.

replace imputados =17 if wage>0 & wage<=850 & country=="IT" & q51==.
replace imputados =18 if wage>850 & wage<=1250 & country=="IT"  & q51==.
replace imputados =19 if wage>1250 & wage<=2500 & country=="IT"  & q51==.
replace imputados =20 if wage>2500 & country=="IT" & q51==.

replace imputados =9 if wage>0 & wage<=1300 & country=="FRA" & q51==.
replace imputados =10 if wage>1300 & wage<=2000 & country=="FRA"  & q51==.
replace imputados =11 if wage>2000 & wage<=2800 & country=="FRA"  & q51==.
replace imputados =12 if wage>2800 & country=="FRA" & q51==.



*de momento imputo salarios desde intervalos a lo bestia

by q51, sort: gen ss=_N 


*ES
local i = 45
	while `i' <=48 {
	qreg wage $X [aw= weight_country_noeducation] if imputados== `i' & country=="ES" & wage<15000, q(50)
	predict wage`i'
	predict r`i' if country=="ES" & imputado==`i' , resid

	sum ss if q51==`i'
	local s=r(mean)
	dis `s'

	preserve
		keep r`i' 
		drop if r`i'==.

		centile r`i', centile(5)
		drop if r`i'<r(c_1)

		centile r`i', centile(95)
		drop if r`i'>r(c_1)

		bsample `s'
		gen n=_n
		gen q51=`i'

		sort n
		save "C:\Users\alejh\Downloads\r`i'.dta", replace
	restore

	drop r`i'
	by q51, sort: gen n=_n 

	merge 1:1 n q51 using "C:\Users\alejh\Downloads\r`i'.dta"
	drop _merge n

	replace wage=wage`i'+r`i' if wage==.
	drop wage`i' r`i'
local i = `i' + 1
}

*GER
*****
local i = 5
	while `i' <=8 {
	qreg wage $X [aw= weight_country_noeducation] if imputados== `i' & country=="GER" & wage<15000, q(50)
	predict wage`i'
	predict r`i' if country=="GER" & imputado==`i' , resid

	sum ss if q51==`i'
	local s=r(mean)
	dis `s'

	preserve
		keep r`i' 
		drop if r`i'==.

		centile r`i', centile(5)
		drop if r`i'<r(c_1)

		centile r`i', centile(95)
		drop if r`i'>r(c_1)

		bsample `s'
		gen n=_n
		gen q51=`i'

		sort n
		save "C:\Users\alejh\Downloads\r`i'.dta", replace
	restore

	drop r`i'
	by q51, sort: gen n=_n 

	merge 1:1 n q51 using "C:\Users\alejh\Downloads\r`i'.dta"
	drop _merge n

	replace wage=wage`i'+r`i' if wage==.
	drop wage`i' r`i'
local i = `i' + 1
}

*FRA
*****

local i = 9
	while `i' <=12 {
	qreg wage $X [aw= weight_country_noeducation] if imputados== `i' & country=="FRA" & wage<15000, q(50)
	predict wage`i'
	predict r`i' if country=="FRA" & imputado==`i' , resid

	sum ss if q51==`i'
	local s=r(mean)
	dis `s'

	preserve
		keep r`i' 
		drop if r`i'==.

		centile r`i', centile(5)
		drop if r`i'<r(c_1)

		centile r`i', centile(95)
		drop if r`i'>r(c_1)

		bsample `s'
		gen n=_n
		gen q51=`i'

		sort n
		save "C:\Users\alejh\Downloads\r`i'.dta", replace
	restore

	drop r`i'
	by q51, sort: gen n=_n 

	merge 1:1 n q51 using "C:\Users\alejh\Downloads\r`i'.dta"
	drop _merge n

	replace wage=wage`i'+r`i' if wage==.
	drop wage`i' r`i'
local i = `i' + 1
}


*IT
***

local i = 17
	while `i' <=20 {
	qreg wage $X [aw= weight_country_noeducation] if imputados== `i' & country=="IT" & wage<15000, q(50)
	predict wage`i'
	predict r`i' if country=="IT" & imputado==`i' , resid

	sum ss if q51==`i'
	local s=r(mean)
	dis `s'

	preserve
		keep r`i' 
		drop if r`i'==.

		centile r`i', centile(5)
		drop if r`i'<r(c_1)

		centile r`i', centile(95)
		drop if r`i'>r(c_1)

		bsample `s'
		gen n=_n
		gen q51=`i'

		sort n
		save "C:\Users\alejh\Downloads\r`i'.dta", replace
	restore

	drop r`i'
	by q51, sort: gen n=_n 

	merge 1:1 n q51 using "C:\Users\alejh\Downloads\r`i'.dta"
	drop _merge n

	replace wage=wage`i'+r`i' if wage==.
	drop wage`i' r`i'
local i = `i' + 1
}



gen wage_ph=wage/(hourspw*4) /*Faltaría imputar datos por intervalos*/

gen lwage_ph=log(wage_ph)

label var wage_ph "Salario/hora"
label var lwage_ph "Log salario/hora"



*replace wage_ph=wage/(hourspw*4) if wage_ph==.
*replace lwage_ph=log(wage_ph) if lwage_ph==.

cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\datos preparados\"

save preparados.dta, replace

