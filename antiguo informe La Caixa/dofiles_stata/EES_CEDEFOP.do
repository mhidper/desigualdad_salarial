*----------------------------------------------
* Project: OBSERVATORIO LA CAIXA
* tareas y ICT
/*Hacemos match con la CEDEFOP y trabajo la EES
para generar gráficos y análisis para la presentaciín
*/
* 25/02/2021, version 1
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



cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\datos preparados\"

use preparados.dta, replace

keep if qcountry==12

*educación

drop if q15==99

ren q15 cestudio

replace cestudio=4 if cestudio==5


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

*Tareas por variable q13

gen manual=(q13_1_scale==1 | q13_1_scale==2)
replace manual=2 if q13_1_scale==3
replace manual=3 if q13_1_scale==4
replace manual=3 if q13_1_scale==99

gen learning=(q13_2_scale==1 | q13_2_scale==2)
replace learning=2 if q13_2_scale==3
replace learning=3 if q13_2_scale==4
replace learning=3 if q13_2_scale==99


gen flex=(q13_3_scale==1 | q13_3_scale==2)
replace flex=2 if q13_3_scale==3
replace flex=3 if q13_3_scale==4
replace flex=3 if q13_3_scale==99

gen teams=(q13_4_scale==1 | q13_4_scale==2)
replace teams=2 if q13_4_scale==3
replace teams=3 if q13_4_scale==4
replace teams=3 if q13_4_scale==99


tab manual, gen(tmanual)
tab learning, gen(aprend)
tab flex, gen(flexible)
tab teams, gen(equipos)


*Trainning

gen trai_during=(q33_1==1)
gen trai_out=(q33_2==1)
gen trai_whilst=(q33_3==1)
gen trai_non=(q33_4==1 | q33_5==1)


drop manual learning flex teams

collapse tecnical communic team foreign customer prob_solv learn_sk planning ///
cambio_tic lit_basic lit_advanced num_basic num_advanced  ict_basic ict_moderate ///
ict_advanced  cust_low verbal comm_team mis_higher mis_matched mis_lower ///
tmanual* aprend* flexible* equipos* trai*, by(cestudio edad cno act)


sort cestudio edad cno act

save "C:\Users\alejh\Downloads\enlacecedefop.dta", replace

drop _all

do "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\dofiles\EES10_14_18.do"


***********TOTAL***************

cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\logs"

*log using descriptivos_sectores.log, replace


*log off


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
replace edad=2 if edad==1
sort cestudio edad cno act


merge n:1 cestudio edad cno act using "C:\Users\alejh\Downloads\enlacecedefop.dta"

keep if _merge==3


tab sec_ced, gen(sec_cedef)
tab cno, gen(ocup)
tab cestudio, gen(estud)

gen lsalmes=log(salmes)





*tareas y cambio tec por percentiles
*************************************************************************
local i = 5
	while `i'<= 95 {
		egen pct18_`i' = pctile(salmes) if year==2018, p(`i')
		local i = `i' + 5
		}
		
local i = 10	
	while `i' <=95 {
		local j = `i' - 5
		gen p18_`i'=(pct18_`j'<salmes & pct18_`i'>salmes) if year==2018
		local i = `i' + 5
		}
		
gen p18=0

local i = 10
	while `i' <=95 {
		replace p18 = p18+p18_`i'*`i'
		local i = `i' + 5
		}


preserve

drop if year==2014
collapse cambio_tic tecnical communic team foreign customer prob_solv learn_sk planning [aw=factotal], by(p18)

restore

*¿Importan tareas y cambio tecnológico en el cambio de percentiles?


drop if year==2014


by year, sort: egen rif_var=rifvar(lsalmes), var 
by year, sort: egen rif_gini=rifvar(lsalmes), gini 

global X "sexo estudios1-estudios6 anoanti anoanti2 parcial indefin horascontr control tipopais conv_1-conv_5 market1-market4 age1-age6 sec_cedef* ocup1-ocup13  lit_basic lit_advanced num_basic num_advanced  ict_basic ict_moderate ict_advanced cambio_tic tmanual1-tmanual2 aprend1-aprend2 flexible1-flexible2 equipos1-equipos2 mis_higher mis_matched mis_lower trai_during trai_out trai_whilst trai_non"


foreach y of varlist rif_var rif_gini sexo estudios1 estudios3-estudios6 anoanti anoanti2 parcial indefin horascontr control tipopais conv_2-conv_5 market2-market4 age2-age6 sec_cedef* ocup2-ocup13  lit_basic lit_advanced num_basic num_advanced  ict_basic ict_moderate ict_advanced cambio_tic tmanual1-tmanual2 aprend1-aprend2 flexible1-flexible2 equipos1-equipos2 mis_higher mis_matched mis_lower  trai_during trai_out trai_whilst trai_non{
	sum `y' if year==2010
	scalar mean=r(mean)
	scalar sd=r(sd)
	replace `y' = (`y'-mean)/sd if year==2010
	sum `y' if year==2018
	scalar mean=r(mean)
	scalar sd=r(sd)
	replace `y' = (`y'-mean)/sd if year==2018
	}

replace cambio_tic=0 if year==2010


gen factotal_corr=round(factotal/10)

replace factotal_corr=1 if factotal_corr==0

expand factotal_corr


	bootstrap num_adv=(_b[num_advanced]-_b[num_basic]) ///
			  lit_adv=(_b[lit_advanced]-_b[lit_basic]) ///
			  ict_mod=(_b[ict_moderate]-_b[ict_basic]) ///
			  ict_adv=(_b[ict_advanced]-_b[ict_basic]) ///
			  mismat_high=(_b[mis_higher]-_b[mis_matched]) ///
			  mismat_low =(_b[mis_lower]-_b[mis_matched]) ///
			  manual_alw_us=_b[tmanual1] manual_som=_b[tmanual2] /// 
			  aprend_alw_us=_b[aprend1] aprend_som=_b[aprend2] /// 
			  flexib_alw_us=_b[flexible1] flexib_som=_b[flexible2] ///
			  equipo_alw_us=_b[equipos1] equipo_som=_b[equipos2] ///
			  for_entr=_b[trai_during] for_fuera=_b[trai_out] for_mientr=_b[trai_whilst] no_form=_b[trai_non] ///
			  automat=_b[cambio_tic], ///
			  reps(100) seed(1234): reg rif_var $X if year==2018
kk			  
			  
estimates store OLSvar
reg rif_gini $X [aw=factotal] if year==2018
estimates store OLSgini
coefplot OLSvar, bylabel(Varianza) || OLSgini, bylabel(Gini) //////
keep(lit_basic lit_advanced num_basic num_advanced  ict_basic ict_moderate ict_advanced cambio_tic cust_low verbal comm_team mis_higher mis_matched mis_lower) ///
levels(90) xline(0) sort(, descending)  xsize(20.000) ysize(10.000) pstyle(p5) ///
mlabel(string(@b,"%9.3f")) mlabposition(1)


ll
oaxaca rif_var sexo estudios1 estudios3-estudios6 anoanti anoanti2 parcial indefin horascontr control tipopais conv_2-conv_5 market2-market4 age2-age6 sec_cedef* ///
		ocup2-ocup13 cambio_tic tecnical communic team foreign customer prob_solv learn_sk planning [aw=factotal], detail(sectores: sec_cedef*, contrato: parcial indefin horascontr, ///
		ocupacion: ocup2-ocup13, trabajador: estudios1 estudios3-estudios6 age2-age6 anoanti anoanti2 sexo, ///
		empresa: conv_2-conv_5 market1-market4 tipopais control, tareas:tecnical communic team foreign customer prob_solv learn_sk planning) pooled relax by(year) swap
kk

local i = 5
	while `i' <= 95 {
		egen rif_var`i'=rifvar(lsalhora), q(`i') by(year)
		oaxaca rif_var`i' sexo estudios1 estudios3-estudios7 anoanti anoanti2 parcial indefin horascontr control tipopais conv_2-conv_5 market2-market4 age2-age6 sec_cedef* ///
		ocup2-ocup13 cambio_tic tecnical communic team foreign customer prob_solv learn_sk planning [aw=factotal], detail(sectores: sec_cedef*, contrato: parcial indefin horascontr, ///
		ocupacion: ocup2-ocup13, trabajador: estudios1 estudios3-estudios7 age2-age6 anoanti anoanti2 sexo, ///
		empresa: conv_2-conv_5 market1-market4 tipopais control, tareas:tecnical communic team foreign customer prob_solv learn_sk planning) pooled relax by(year) swap
		
		mat b`i'=e(b)
		
		local i = `i' + 5
		}
		
mat b_perc=b5
local i = 10
	while `i' <=95 {
	mat b_perc=b_perc\b`i'
	local i = `i' + 5
	}



	
	

reg rif_50 $X [aw=factotal]
outreg2 using resultados1.doc, replace ctitle(mediana) lab 
reg rif_var $X [aw=factotal]
outreg2 using resultados1.doc, append ctitle(varianza) lab
reg rif_iqr $X [aw=factotal]
outreg2 using resultados1.doc, append ctitle(q1090) lab

kk

*Creación grupos de sectores (https://ec.europa.eu/eurostat/cache/metadata/Annexes/htec_esms_an3.pdf)

gen ict_hig_ind=(secc=="C4" | secc=="C7")
gen ict_med_ind=(secc=="C8" | secc=="C5" | secc=="C6" | secc=="C3")	
gen ict_low_ind=(secc=="C1" | secc=="C2")

*knowledge intensive services

gen kis_ser=(secc=="D0" | secc=="E0" | secc=="J0" | secc=="K0" | secc=="M0" | secc=="O0")

gen kis_ser_wofinance=(secc=="D0" | secc=="E0" | secc=="J0"| secc=="M0" | secc=="O0")
gen lkis_ser=(secc=="G1" | secc=="G2" | secc=="H1" | secc=="H2" | secc=="I0" | secc=="L0" | secc=="N0" | secc=="R0" | secc=="S0") 

gen san_edu=(secc=="Q0" | secc=="P0") 

gen construcc=secc=="F0"

gen extract=secc=="B0"

gen sectores=0
replace sectores=1 if extract==1
replace sectores=2 if ict_hig_ind==1
replace sectores=3 if ict_med_ind==1
replace sectores=4 if ict_low_ind==1
replace sectores=5 if construcc==1
replace sectores=6 if kis_ser==1
replace sectores=7 if lkis_ser==1
replace sectores=8 if san_edu==1

gen salhora2=salhora

collapse (firstnm) sectores (mean) salhora (iqr) salhora2 [aw=factotal], by(secc year)


egen secc_n=group(secc)

xtset secc_n year

sort secc_n year

gen crec_mean=((salhora-salhora[_n-1])/salhora[_n-1])*100 if secc_n==secc_[_n-1]
gen crec_iqr=((salhora2-salhora2[_n-1])/salhora2[_n-1])*100 if secc_n==secc_[_n-1]


twoway (scatter  crec_mean crec_iqr if sectores==1) ///
(scatter crec_mean crec_iqr if sectores==2, msymbol(square)) ///
(scatter crec_mean crec_iqr if sectores==3, msymbol(triangle)) ///
(scatter crec_mean crec_iqr if sectores==4, msymbol(diamond)) ///
(scatter crec_mean crec_iqr if sectores==5, msymbol(lgx)) ///
(scatter crec_mean crec_iqr if sectores==6) ///
(scatter crec_mean crec_iqr if sectores==7) ///
(scatter crec_mean crec_iqr if sectores==8), ///
 ytitle(percentiles) xtitle(media) ///
 legend(on order(1 "Extractivas" 2 "Ind. Alta Tec" 3 "Ind. Media Tec." 4 "Ind. Baja Tec." 5 "Construcción" 6 "Servicios Alto Con." 7 "Servicios Bajo Con." 8 "Sanidad y Educación"))

 
 twoway (scatter crec_mean crec_iqr if sectores==4, msymbol(square)) ||  (scatt
> er crec_mean crec_iqr if sectores==5, msymbol(square)), ytitle(percentiles) xt
> itle(media) legend(on order(1 "ejemplo" 2 "Eje")) clegend(on)



kk
*Tabla por sectores antes de agrupar

tabstat salhora [aw=factotal] if year==2010, by(secc) statistics(mean iqr) save
tabstatmat seccstat2010

tabstat salhora [aw=factotal] if year==2018, by(secc) statistics(mean iqr) save
tabstatmat seccstat2018

*preserve 
drop _all
svmat seccstat2010
svmat seccstat2018

gen crec_mean=((seccstat20181-seccstat20101)/seccstat20101)*100
gen crec_iqr=((seccstat20182-seccstat20102)/seccstat20102)*100


# delimit ;
label define msectores 
1 "Extractivas" 
2 "Ind ICT High" 
3 "Ind ICT Med"
4 "Ind ICT Low"
5 "Construccion"
6 "Serv. High Knowledge"
7 "Serv. Low Knowledge"
8 "Sanidad y Educación";
#delimit cr


label value sectores msectores	


log on

tabstat salhora [aw=factotal] if year==2010, by(sectores) statistics(mean iqr) save
mat s2010=r(Stat1)'\r(Stat2)'\r(Stat3)'\r(Stat4)'\r(Stat5)'\r(Stat6)'\r(Stat7)'\r(Stat8)'

tabstat salhora [aw=factotal] if year==2018, by(sectores) statistics(mean iqr) save
mat s2018=r(Stat1)'\r(Stat2)'\r(Stat3)'\r(Stat4)'\r(Stat5)'\r(Stat6)'\r(Stat7)'\r(Stat8)'




tabstat salbasehora [aw=factotal]  if year==2010, by(sectores) statistics(mean iqr) save
tabstat salbasehora [aw=factotal]  if year==2018, by(sectores) statistics(mean iqr) save


tabstat restosal [aw=factotal]  if year==2010, by(sectores) statistics(mean iqr) save
tabstat restosal [aw=factotal]  if year==2018, by(sectores) statistics(mean iqr) save

log close



keep if year==2018


oaxaca rif_iqr $Y [aw=factotal], detail(contrato: parcial indefin horascontr, ///
educacion: estudios1-estudios7, edad: age1-age6, convenios: conv_2-conv_5, ///
anitguedad: anoanti anoanti2, mercado: market2-market4) omega relax by(ict) swap

oaxaca rif_iqr $Y [aw=factotal], detail(contrato: parcial indefin horascontr, ///
educacion: estudios1-estudios7, edad: age1-age6, convenios: conv_2-conv_5, ///
anitguedad: anoanti anoanti2, mercado: market2-market4) omega relax by(v_added) swap

kk
rifhdreg lsalhora $X [aw=factotal], rif(q(50)) 
outreg2 using resultados2.doc, replace ctitle(mediana) lab
rifhdreg lsalhora $X [aw=factotal], rif(var) 
outreg2 using resultados2.doc, append ctitle(varianza) lab
rifhdreg lsalhora $X [aw=factotal], rif(iqr(10 90)) 
outreg2 using resultados2.doc, append ctitle(q1090) lab

oaxaca_rif lsalhora $Y [aw=factotal], detail(contrato: parcial indefin horascontr) rif(iqr(10 90)) relax by(ict)
kk

oaxaca_rif lwage_ph years years2 age age2 comm_team cust_low verbal normalize(emp1-emp8) lhours normalize(contract1-contract5) ///
normalize(sectores1-sectores16) normalize(edu1-edu7) normalize(occ1-occ10) cambio_tic ///
normalize(ict_skills1 ict_skills2 ict_skills3 ict_skills4 ict_skills5), ///
rif(iqr(10 90)) by(edu1) w(1) relax
