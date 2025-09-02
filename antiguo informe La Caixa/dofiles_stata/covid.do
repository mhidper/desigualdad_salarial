
*----------------------------------------------
* Project: OBSERVATORIO LA CAIXA
* Ejercicio de efecto COVID
* 19/02/2021, version 1
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



*EPA
*********************************************



use "C:\Users\alejh\Dropbox\CONSULTORIA\ESADE\FORMACIÓN\DESCRIPTIVO\EPA\EPA_2019T4.dta", clear
append using "C:\Users\alejh\Dropbox\CONSULTORIA\ESADE\FORMACIÓN\DESCRIPTIVO\EPA\EPA_2020T1.dta"
append using "C:\Users\alejh\Dropbox\CONSULTORIA\ESADE\FORMACIÓN\DESCRIPTIVO\EPA\EPA_2020T2.dta"
append using "C:\Users\alejh\Dropbox\CONSULTORIA\ESADE\FORMACIÓN\DESCRIPTIVO\EPA\EPA_2020T3.dta"
destring ciclo, replace
destring sexo1, replace
append using "C:\Users\alejh\Dropbox\CONSULTORIA\ESADE\FORMACIÓN\DESCRIPTIVO\EPA\EPA_2020T4.dta", force
 
*Desempleados

gen desemp=(aoi=="05" | aoi=="06")

*Ocupados

gen ocup=situ!=""

*En ERTE

gen erte1=horase=="0000"
gen erte2=(rznotb=="10" | rznotb=="11")

recast int factorel, force
tab erte1 [fw=factorel]
tab erte2 [fw=factorel]

*Trabajadores en ERTE por nivel de estudios

gen ocupados=situ!=""

gen edu=1 if nforma=="AN" | nforma=="P1"
replace edu=2 if nforma=="P2" 
replace edu=3 if nforma=="S1" | nforma=="SG" | nforma=="SP"
replace edu=4 if nforma=="SU"

*ERTE por nivel de estudios
tab erte2 edu if situ!="" [fw=factorel]
*Desempleados por nivel de estudio
tab desemp edu if desemp==1 | situ!="" [fw=factorel]
*Larga duración por nivel de estudios
gen larga=(itbu=="05" | itbu=="06" | itbu=="07" | itbu=="08")
tab larga edu if larga==1 | situ!="" [fw=factorel]

gen epa=1
gen year=2018

destring ocup1, replace
ren ocup1 cno

keep if situ=="07" | situ=="08"


ren factorel factotal

gen sexo=(sexo1==6)


*No agricultura

destring act1, replace
drop if act1==0

ren act1 sect

gen publico=(situ=="08")


*PESOS PARA AJUSTAR POR DESPIDOS
*******************************************

by edu cno sect sexo ciclo, sort: egen pesosrel=sum(factotal)

local i = 189
	while `i' <= 193 {
	preserve 
	duplicates drop edu cno sect sexo ciclo, force
	keep if ciclo ==`i'
	keep edu cno sect sexo ciclo pesosrel
	ren pesosrel pesos`i'
	sort edu cno sect sexo
	drop ciclo
	save "C:\Users\alejh\Downloads\pesos`i'.dta", replace
	restore
	local i = `i' + 1
}



keep erte1 edu epa ciclo sexo year factotal cno sect  
destring ciclo, replace



save "C:\Users\alejh\Downloads\epa.dta", replace
 
 drop _all



*ENCUESTA DE EES
***********************************************************




do "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\dofiles\EES10_14_18.do"


***********TOTAL***************

cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\logs"

*log using descriptivos_sectores.log, replace


*log off


*Sectores EPA
gen sect=.

replace sect=1  if secc=="C1" | secc=="C2" | secc=="C3"
replace sect=2  if secc=="B0" | secc=="C4" | secc=="D0" | secc=="E0" | secc=="C5" | secc=="C6"
replace sect=3  if secc=="C7" | secc=="C8"
replace sect=4  if secc=="F0"
replace sect=5  if secc=="G1" | secc=="G2" | secc=="I0"
replace sect=6  if secc=="H1" | secc=="H2" | secc=="J0"
replace sect=7  if secc=="K0" | secc=="L0" | secc=="M0" | secc=="N0"
replace sect=8  if secc=="O0" | secc=="P0" | secc=="Q0"
replace sect=9  if secc=="R0" | secc=="S0" 



*Ajuste ocpaciones a EPA


gen cno=0
replace cno=0 if cno2=="Q0"
replace cno=1 if cno2=="A0"
replace cno=2 if cno2=="B0" | cno2=="C0"
replace cno=3 if cno2=="D0"
replace cno=4 if cno2=="E0" | cno2=="F0"
replace cno=5 if cno2=="G0" | cno2=="H0" | cno2=="I0"
replace cno=6 if cno2=="J0"
replace cno=7 if cno2=="K0" | cno2=="L0"
replace cno=8 if cno2=="M0" | cno2=="N0"
replace cno=9 if cno2=="O0" | cno2=="P0"


destring cestudio, replace

gen edu=(cestudio==1)
replace edu=2 if cestudio==2
replace edu=3 if cestudio==3 | cestudio==4 | cestudio==5
replace edu=4 if cestudio==6 | cestudio==7


gen epa=0
gen ciclo=2018


append using "C:\Users\alejh\Downloads\epa.dta"

keep if year==2018

*Metemos pesos de la epa para control de desempleados

sort edu cno sect sexo

local i = 189
	while `i' <= 193 {
	merge n:1 edu cno sect sexo using  "C:\Users\alejh\Downloads\pesos`i'.dta"
	drop _merge
	local i = `i' + 1
}


gen lsalmes=log(salmes)

tab edu, gen(ed)
tab cno, gen(oc)
tab sect, gen(sector)

gen pesos_re90=factotal*(pesos190/pesos189)
gen pesos_re91=factotal*(pesos191/pesos189)
gen pesos_re92=factotal*(pesos192/pesos189)
gen pesos_re93=factotal*(pesos193/pesos189)


probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=factotal] if epa==1 & ciclo==190 

predict prob190, pr

probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=pesos_re90] if epa==1 & ciclo==190 

predict prob190un, pr

probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=factotal] if epa==1 & ciclo==191 

predict prob191, pr

probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=pesos_re91] if epa==1 & ciclo==191 

predict prob191un, pr


probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=factotal] if epa==1 & ciclo==192

predict prob192, pr

probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=pesos_re92] if epa==1 & ciclo==192 

predict prob192un, pr

probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=factotal] if epa==1 & ciclo==193

predict prob193, pr

probit erte1 ed2-ed4 sexo oc2-oc10 sector2-sector9 [pw=pesos_re93] if epa==1 & ciclo==193 

predict prob193un, pr



gen sal_anual=14*salmes

gen factotal_un=(pesos_re90+pesos_re91+pesos_re92+pesos_re93)/4

*Sin ajuste desempleados

gen sal_anual_erte=3.5*(salmes*(1-prob190)+0.7*prob190*salmes)+ ///
3.5*(salmes*(1-prob191)+0.7*prob191*salmes)+ ///
3.5*(salmes*(1-prob192)+0.7*prob192*salmes)+ ///
3.5*(salmes*(1-prob193)+0.7*prob193*salmes)


*Con ajuste desempleados

gen sal_anual_erte_un=3.5*(salmes*(1-prob190un)+0.7*prob190un*salmes)+ ///
3.5*(salmes*(1-prob191un)+0.7*prob191un*salmes)+ ///
3.5*(salmes*(1-prob192un)+0.7*prob192un*salmes)+ ///
3.5*(salmes*(1-prob193un)+0.7*prob193un*salmes)

pctile pct=sal_anual [aw=factotal] if epa==0, nq(50) genp(sin_erte)
pctile pct_erte=sal_anual_erte [aw=factotal] if epa==0, nq(50) genp(con_erte)
pctile pct_erte_un=sal_anual_erte_un [aw=factotal_un] if epa==0, nq(50) genp(con_erte_un)

gen p=_n

gen dpct=(pct_erte-pct)/pct*100
gen dpct_un=(pct_erte_un-pct)/pct*100

twoway line dpct dpct_un p if p<51



