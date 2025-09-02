*----------------------------------------------
* Project: OBSERVATORIO LA CAIXA
* Prueba de KNN algorith
* 12/02/2021, version 1
* Manuel Alejandro Hidalgo (Universidad Pablo de Olavide)
*--------------------------------------------------

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\DOCS\"

version 12              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
*--------------------------------------------------




cd "C:\Users\alejh\Dropbox\INVESTIGACIÓN\Ocupacion y Covid\ESJ Data\Cedefop ESJS microdata Dissemination\Cedefop_ESJS_Data\"

use Cedefop_ESJS_microdata.dta


keep if qcountry==12

*educación

drop if q15==99

ren q15 cestudio


*Sectores

ren q6a sec_ced


gen act="."
replace act="I" if sec_ced==5
replace act="E" if sec_ced==3 | sec_ced==4
replace act="C" if sec_ced==6
replace act="ST" if sec_ced==10 | sec_ced==11
replace act="S" if act=="." & sec_ced!=2

*edad

gen edad=2 if  resp_age<=29
replace edad=3 if resp_age>29 & resp_age<=39
replace edad=4 if resp_age>39 & resp_age<=49
replace edad=5 if resp_age>49 & resp_age<=59
replace edad=6 if resp_age>59 



*enlace ocupaciones

gen cno="."
replace cno="A0" if q3b==1 | q3b==2 | q3b==3 | q3b==4 | q3b==5
replace cno="B0" if q3c==1 | q3c==2 | q3c==3
replace cno="C0" if q3c==4 | q3c==5 | q3c==6 | q3c==7
replace cno="E0 Y F0" if q3d==1 | q3d==2 | q3d==3 | q3d==5
replace cno="D0" if q3d==4
replace cno="H0" if q3e==1 | q3e==3
replace cno="G0" if q3e==2 | q3e==5 | q3e==6
replace cno="I0" if q3e==4
replace cno="J0" if q3f>=1 & q3f<=5
replace cno="K0" if q3g==1 | q3g==2
replace cno="L0" if q3g==3 | q3g==4 | q3g==6 | q3g==7
replace cno="N0" if q3g==5 | (q3h>=1 & q3h<=4)
replace cno="O0" if q3i==1 | (q3i>=4 & q3i<=7)
replace cno="P0" if	q3i==2 | q3i==3

drop if cno=="."


rename q23a_1_scale tecnical
rename q23a_2_scale communic
rename q23a_3_scale team
rename q23a_4_scale foreign
rename q23a_5_scale customer
rename q23a_6_scale prob_solv
rename q23a_7_scale learn_sk
rename q23a_8_scale planning


ren q36_1 cambio_tic

gen id_c=_n

tab cestudio, gen(cestudio)
tab edad, gen(edad)
tab cno, gen(cno)
tab act, gen(act)


keep id_c cestudio* edad* cno* act*


save "C:\Users\alejh\Downloads\knn_cedefop.dta", replace

drop _all

do "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\dofiles\EES10_14_18.do"


***********TOTAL***************

cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\logs"

log using descriptivos_sectores.log, replace


log off


*Sectores CEDEFOP
gen sec_ced=.

replace sec_ced=1  if secc=="N0" | secc=="O0"
replace sec_ced=3  if secc=="D0"
replace sec_ced=4  if secc=="E0"
replace sec_ced=5  if secc=="B0" | secc=="C1" | secc=="C2" | secc=="C3" | secc=="C4" | secc=="C5" | secc=="C6" | secc=="C7" | secc=="C8"
replace sec_ced=6  if secc=="F0"
replace sec_ced=7  if secc=="G1" | secc=="G2"
replace sec_ced=8  if secc=="I0"
replace sec_ced=9  if secc=="H1" | secc=="H2"
replace sec_ced=10 if secc=="J0"
replace sec_ced=11 if secc=="K0" | secc=="L0"
replace sec_ced=12 if secc=="M0"
replace sec_ced=13 if secc=="P0" | secc=="Q0"
replace sec_ced=14 if secc=="R0" 
replace sec_ced=15 if secc=="S0" 

gen act="."
replace act="I" if sec_ced==5
replace act="E" if sec_ced==3 | sec_ced==4
replace act="C" if sec_ced==6
replace act="ST" if sec_ced==10 | sec_ced==11
replace act="S" if act=="." & sec_ced!=2


*Ajuste ocpaciones a cedefop

ren cno2 cno

replace cno="E0 y F0" if cno=="E0" | cno=="F0"
destring cestudio, replace
sort cestudio edad cno act

keep if year==2018

gen id_ess=_n

keep id_ess cestudio edad cno act

ren cestudio cestudio_e
ren edad edad_e
ren cno cno_e
ren act act_e


tab cestudio_e, gen(cestudio_e)
tab edad_e, gen(edad_e)
tab cno_e, gen(cno_e)
tab act_e, gen(act_e)

*KN-medias probando para 1000

keep if id_ess<1000

cross using "C:\Users\alejh\Downloads\knn_cedefop.dta"


local i = 1
	while `i' <= 6 {
	   gen cestudio_s`i'= cond((cestudio`i'+cestudio_e`i') > 1, 1, (cestudio`i'+cestudio_e`i'))
	   local i = `i' +1
        }

egen tcestudio=rowtotal(cestudio_s*)

local i = 1
	while `i' <= 6 {
		replace cestudio_s`i'= cond((cestudio`i'+cestudio_e`i')== 2, 1, 0)
	local i = `i' + 1
	}
egen count_cestudio= rowtotal(cestudio_s*)



local i = 1
	while `i' <= 5 {
	   gen edad_s`i'= cond((edad`i'+edad_e`i') > 1, 1, (edad`i'+edad_e`i'))
	   local i = `i' +1
        }

egen tedad=rowtotal(edad_s*)

local i = 1
	while `i' <= 5 {
		replace edad_s`i'= cond((edad`i'+edad_e`i')== 2, 1, 0)
	local i = `i' + 1
	}
egen count_edad= rowtotal(edad_s*)


local i = 1
	while `i' <= 14 {
	   gen cno_s`i'= cond((cno`i'+cno_e`i') > 1, 1, (cno`i'+cno_e`i'))
	   local i = `i' +1
        }

egen tecno=rowtotal(cno_s*)

local i = 1
	while `i' <= 14 {
		replace cno_s`i'= cond((cno`i'+cno_e`i')== 2, 1, 0)
	local i = `i' + 1
	}
egen count_cno= rowtotal(cno_s*)


local i = 1
	while `i' <= 5 {
	   gen act_s`i'= cond((act`i'+act_e`i') > 1, 1, (act`i'+act_e`i'))
	   local i = `i' +1
        }

egen teact=rowtotal(act_s*)

local i = 1
	while `i' <= 5 {
		replace act_s`i'= cond((act`i'+act_e`i')== 2, 1, 0)
	local i = `i' + 1
	}
egen count_act= rowtotal(act_s*)


gen similarity= ((count_cestudio+count_edad+count_cno+count_act)/(tcestudio+tedad+tecno+teact))*100

*Máximo para cada id_ess

sort id_ess similarity

by id_ess, sort: gen n=_n
by id_ess, sort: gen nn=_N

keep if n==nn

keep id_ess id_c

