*----------------------------------------------
* Project: OBSERVATORIO LA CAIXA
* EES10_14_18.do
* 17/02/2021, version 1
* Manuel Alejandro Hidalgo (Universidad Pablo de Olavide)
*--------------------------------------------------

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
cd "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\"

version 12              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
*--------------------------------------------------



use C:\Users\alejh\Dropbox\DATOS\EES10_14_18\datos_salarial18\EES18.dta 
gen year=2018

*Ajuste nombre y variables a modelo 10_14

ren idenccc ordenccc
ren nuts1	region	
ren cnace	secc	
ren regulacion	convenio
ren cno1 cno2
ren estu cestudio /*similar al de 14*/
gen salbruto=retrinoin+retriin
gen vesp=vespnoin+vespin

destring sexo, replace
destring anos2, replace
destring tipojor, replace
destring control, replace
destring mercado, replace
destring convenio, replace
destring tipopais, replace

ren anos2 edad
compress

append using "C:\Users\alejh\Dropbox\DATOS\EES10_14_18\datos_salarial10\EES10.dta", force

replace cestudio="5" if cestudio=="6" & year==2010
replace cestudio="6" if cestudio=="7" & year==2010
replace cestudio="7" if cestudio=="8" & year==2010




append using "C:\Users\alejh\Dropbox\DATOS\EES10_14_18\datos_salarial14\EES14.dta", force

replace cestudio="4" if cestudio=="5"


gen diasrelaba=drelabam*30.42+drelabad
replace diasrelaba=365 if diasrelaba>365

gen diasano=diasrelaba-dsiespa2-dsiespa4

replace salbase=(365/diasano)*(salbruto+vesp)/12 /*Salario anual total*/
gen salmes=salbase+comsal+phextra+extraorm /*salario mensual total*/
gen salneto=salmes-cotiza-irpfmes /*salario neto*/
gen horas =((jsp1+(jsp2/60))*4.35)+hextra
gen salhora=(salmes/horas)
gen salbasehora=(salbase/((jsp1+(jsp2/60))*4.35)) /*sin horas extras*/
gen restosal=salhora-salbasehora
replace salhora=salhora*96.903/103.732 if year==2014 /*precios constantes de 2010*/
gen lsalhora=log(salhora)
gen lsalbasehora=log(salbasehora)
gen lrestosal=log(restosal)
gen horascontr=log(jsp1)
*drop salanual 

replace sexo=0 if sexo==1
replace sexo=1 if sexo==6

replace control=control-1
replace tipopais=tipopais-1


destring tipojor, replace

replace tipojor=0 if tipojor==1
replace tipojor=1 if tipojor==2
rename tipojor parcial

gen tipoconb=real(tipocon)

drop tipocon
ren tipoconb tipocon
replace tipocon=0 if tipocon==2

rename tipocon indefin

tab edad, gen(age)

tab secc, gen(sect)

label var sect1 "industrias extractivas"
label var sect2 "alimentación y bebidas"
label var sect3 "madera y papel"
label var sect4 "artes graficas"
label var sect5 "química, farmacia y refino"
label var sect6 "otros prod. minerales no met."
label var sect7 "metalurgia"
label var sect8 "prod. informáticos, electrónicos y ópticos"
label var  sect9 "fab. mat. de transporte y muebles"
label var  sect10 "e. eléctrica, gas, vapor"
label var  sect11 "suministro de agua"
label var  sect12 "construcción"
label var  sect13 "comercio al por mayor"
label var  sect14 "comercio al por menor"
label var  sect15 "transporte"
label var  sect16 "almacenamiento"
label var  sect17 "hostelería"
label var  sect18 "información y comunicaciones"
label var  sect19 "act. financieras y de seguros"
label var  sect20 "act. inmobiliarias"
label var  sect21 "act. profesionales, científicas y técnicas"
label var  sect22 "act. administrativas y servicios auxliares"
label var  sect23 "aapp y defensa"
label var  sect24 "educación"
label var  sect25 "act. sanitarias y de servicios sociales"
label var  sect26 "act. artísticas y recreativas"
label var  sect27 "otros servicios"

*ICT (https://ec.europa.eu/jrc/sites/jrcsh/files/jrc111922.pdf)

gen ict=0
replace ict=(sect8==1 | sect18==1 | sect19==1 | sect21==1 | sect26==1)

*High Value added (alta porductividad, https://ec.europa.eu/jrc/en/predict/ict-sector-analysis-2019/data-metadata. Fichero prodhempeur_9518.xls, datos 2016)

gen v_added=0
replace v_added=(sect18==1 | sect5==1 | sect9==1 | sect19==1 | sect8==1)


tab mercado, gen(market)

tab convenio, gen(conv_)

tab cestudio, gen(estudios)

gen anoanti2=anoanti^2


gen contrato=0
replace contrato=1 if indefin==1 & parcial==0
replace contrato=2 if indefin==1 & parcial==1
replace contrato=3 if indefin==0 & parcial==0
replace contrato=4 if indefin==0 & parcial==1




