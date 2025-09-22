*----------------------------------------------
* Project: OBSERVATORIO LA CAIXA
* estructura productiva.do
/*Hacemos match con la CEDEFOP y trabajo la EES
para generar gr�ficos y an�lisis para la presentaci�n
*/
* 24/02/2021, version 1
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


*Ajuste ocupaciones a cedefop

ren cno2 cno

replace cno="E0 y F0" if cno=="E0" | cno=="F0"
destring cestudio, replace
replace edad=2 if edad==1
sort cestudio edad cno act


*Gr�ficos desigualdad (C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\EXCEL\figuras descriptivas.xlsx)

*Figura 1

*Tabla 1


by year, sort: egen rif_var=rifvar(salmes), var
by year, sort: egen rif_50=rifvar(salmes), q(50)
by year, sort: egen rif_std=rifvar(salmes), std
by year, sort: egen rif_iqr=rifvar(salmes), iqr(10 90)
by year, sort: egen rif_gini=rifvar(salmes), gini


sum rif_50 rif_var rif_iqr rif_gini

*Figura destribuciones

*kdensity salmes [aw= factotal] if year==2010 & salmes<9900, generate(var2010_x var2010_d) 
*kdensity salmes [aw= factotal] if year==2018 & salmes<9900, generate(var2018_x var2018_d) at(var2010_x) 

*Between-within wage inequality (in logs) https://dash.harvard.edu/bitstream/handle/1/25586658/aer.103.3.214.pdf

gen lsalmes=log(salmes)


*Cambios en perceltiles 


pctile pct2010=salmes if year==2010 [aw=factotal], nq(50)  
pctile pct2014=salmes if year==2014 [aw=factotal], nq(50)  
pctile pct2018=salmes if year==2018 [aw=factotal], nq(50)  

gen v1014=(pct2014-pct2010)
gen v1418=(pct2018-pct2014)
gen v1018=(pct2018-pct2010)

gen d1014=(pct2014-pct2010)/pct2010*100
gen d1418=(pct2018-pct2014)/pct2014*100
gen d1018=(pct2018-pct2010)/pct2010*100

gen percentiles=_n*2

twoway line d1014 d1418 d1018 percentiles if percentiles<98



*VARIANZA TOTAL POR A�O
************************

*genero rif


drop rif_var

tab year [aw=factotal], sum(lsalmes)


*por grupos para within (gr�fico hoja excel "within por variables" y "between por variables")

by year, sort: egen rif_var=rifvar(lsalmes), var

egen grupo0=group(year)

egen rif_var_s0=rifvar(lsalmes), var by(grupo0)


egen grupo1=group(secc year)

egen rif_var_s1=rifvar(lsalmes), var by(grupo1)



egen grupo2=group(secc cno year)

egen rif_var_s2=rifvar(lsalmes), var by(grupo2)


egen grupo3=group(contrato secc cno year)

egen rif_var_s3=rifvar(lsalmes), var by(grupo3)


tabstat rif_var_s* [aw=factotal], by(year)








*POLARIZACI�N
***********************************************

egen codigo=group(secc cno)

preserve

collapse (mean) lsalmes (sum) factotal [aw=factotal], by(codigo year)

keep if year==2010
ren lsalmes lsalmes10
ren factotal peso10
sort codigo
drop year
save "C:\Users\alejh\Downloads\pola10.dta", replace

restore 
 
preserve

collapse (mean) lsalmes (sum) factotal [aw=factotal], by(codigo year)

keep if year==2014
ren lsalmes lsalmes14
ren factotal peso14
sort codigo
drop year
save "C:\Users\alejh\Downloads\pola14.dta", replace

restore 

preserve

collapse (mean) lsalmes (sum) factotal [aw=factotal], by(codigo year)

keep if year==2018
ren lsalmes lsalmes18
ren factotal peso18
sort codigo
drop year
save "C:\Users\alejh\Downloads\pola18.dta", replace

restore 

preserve
drop _all

use "C:\Users\alejh\Downloads\pola10.dta"

merge 1:1 codigo using "C:\Users\alejh\Downloads\pola14.dta"
drop _merge
merge 1:1 codigo using "C:\Users\alejh\Downloads\pola18.dta"

gen dpeso= (peso18- peso10)/peso10

twoway (scatter dpeso lsalmes10 [pweight = peso10], mcolor(blue) msymbol(circle) mfcolor(none)) ///
(qfit dpeso lsalmes10 [pweight = peso10], mcolor(blue) msymbol(circle) mfcolor(none)) ///
if dpeso<5 & lsalmes10>5, ///
ytitle(Crecimiento del peso por grupo entre 2010 y 2018 (%)) xtitle(Salario medio por grupo en 2010 (logs)) legend(off)



restore

preserve
egen rif_var_var=rifvar(lsalmes), var by(year)

collapse (sum) rif_var_var factotal (mean) lsalmes [aw=factotal], by(secc cno year)


twoway (scatter rif_var_var lsalmes [fweight = factotal] if year==2010, sort mcolor(gs8) msymbol(circle) mfcolor(none)) ///
(qfit rif_var_var lsalmes [aw=factotal] if year==2010, lcolor(black)) ///
(scatter rif_var_var lsalmes [fweight = factotal] if year==2014, sort mcolor(gs12) msymbol(circle) mfcolor(none)) ///
(qfit rif_var_var lsalmes [aw=factotal] if year==2014, lcolor(blue)) ///
(scatter rif_var_var lsalmes [fweight = factotal] if year==2018, sort mcolor(gs14) msymbol(circle) mfcolor(none)) ///
(qfit rif_var_var lsalmes [aw=factotal] if year==2018, lcolor(red))

restore

*Figura distribuciones por tipo de contrato
*************************************************************************

kdensity lsalmes [aw=factotal] if year==2018, gen(kd_x kd_n)
kdensity lsalmes [aw=factotal] if year==2018 & contrato==1, at(kd_x) gen(kd_x1 kd_n1)
kdensity lsalmes [aw=factotal] if year==2018 & contrato==2, at(kd_x) gen(kd_x2 kd_n2)
kdensity lsalmes [aw=factotal] if year==2018 & contrato==3, at(kd_x) gen(kd_x3 kd_n3)
kdensity lsalmes [aw=factotal] if year==2018 & contrato==4, at(kd_x) gen(kd_x4 kd_n4)

*Evoluci�n del tipo de contrato por percentiles
*************************************************************************
local i = 5
	while `i'<= 95 {
		egen pct10_`i' = pctile(salmes) if year==2010, p(`i')
		egen pct18_`i' = pctile(salmes) if year==2018, p(`i')
		local i = `i' + 5
		}
		
local i = 10	
	while `i' <=95 {
		local j = `i' - 5
		gen p10_`i'=(pct10_`j'<salmes & pct10_`i'>salmes) if year==2010
		gen p18_`i'=(pct18_`j'<salmes & pct18_`i'>salmes) if year==2018
		local i = `i' + 5
		}
		
gen p10=0
gen p18=0

local i = 10
	while `i' <=95 {
		replace p10 = p10+p10_`i'*`i'
		replace p18 = p18+p18_`i'*`i'
		local i = `i' + 5
		}
tab contrato, gen(contrato)

preserve

drop if year==2014
collapse contrato* horas [aw=factotal], by(p10 p18)

restore

/*Gr�fico donde se descuenta de la varianza within por sectores original la causada por ocupaci�n y contratos y gr��afico donde se relaciona
la desigualdad sectorial y tipo de contratos*/

*hoja de "within por variables"

tabstat rif_var_s* [aw=factotal] if year==2010, by(secc)
tabstat rif_var_s* [aw=factotal] if year==2018, by(secc)

tabstat contrato1 contrato2 contrato3 contrato4[aw=factotal] if year==2010, by(secc)
tabstat contrato1 contrato2 contrato3 contrato4[aw=factotal] if year==2018, by(secc)

*POR SECTORES /Analizo qu� variables eliminan mayor parte de within por sectores. Estimado residual wage_inq*/
/*la parte que explica cada variable ser� el resultado de multiplicar cada coeficiente obtenido de la regresi�n
con la rif con el valor medio de cada caracter�stica incluida en le regresi�n

bar(Y)= beta*bar(X)

lo hago sin constante
*/


tab cno, gen(ocup)

global X contrato1-contrato4 ocup1-ocup16

local sec "B0 C1 C2 C3 C4 C5 C6 C7 C8 D0 E0 F0 G1 G2 H1 H2 I0 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0"
	foreach x of local sec {	
		reg rif_var $X [aw=factotal] if year==2018 & secc=="`x'", nocons
		mat b=e(b)
		tabstat contrato1-contrato4 ocup1-ocup16 [aw=factotal] if year==2018 & secc=="`x'", save
		mat A=r(StatTotal)
		mat bcontrato=b[1,1..4]
		mat bocup    =b[1,5..20]
		mat Acontrato=A[1,1..4]
		mat Aocup=A[1,5..20]
		mat contrato`x'=bcontrato*Acontrato'
		mat ocup`x'    =bocup*Aocup'
		mat within`x'=contrato`x',ocup`x'
}

mat within=withinB0

local sec "C1 C2 C3 C4 C5 C6 C7 C8 D0 E0 F0 G1 G2 H1 H2 I0 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0"
	foreach x of local sec {
	mat within=within\within`x'
	}

	
	

*OAXACA POR SECTORES (Figura 3)

global X contrato2-contrato4 ocup2-ocup16


local sec "B0 C1 C2 C3 C4 C5 C6 C7 C8 D0 E0 F0 G1 G2 H1 H2 I0 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0"
	foreach x of local sec {	
		gen s_`x'=(secc=="`x'")
		oaxaca rif_var $X [aw=factotal] if year==2018, detail(contrato: contrato2-contrato4, ///
		ocupacion: ocup2-ocup16) omega relax by(s_`x') swap
		mat A`x'=r(table)'
		local i = rowsof(A`x')
		mat B`x'=A`x'[1..`i', 1]
		}
		
mat decomp=BB0

local sec "C1 C2 C3 C4 C5 C6 C7 C8 D0 E0 F0 G1 G2 H1 H2 I0 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0"
	foreach x of local sec {
	mat decomp=decomp,B`x'
	}


*Figura 4 (porcentaje por sectores de diferentes contratos)

tab secc contrato [aw=factotal] if year==2018, sum(factotal) nomeans nost noobs
tab contrato [aw=factotal] if year==2018, sum(lsalmes)



*Figura 5. Gr�fico coeficienst Oaxaca ampliado

drop if year==2014

global Y sexo sect1-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 conv_2-conv_5 market2-market4 tipopais horas control


foreach var of varlist sexo sect1-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 conv_2-conv_5 market2-market4 tipopais horas control {
                sum `var' if year==2010
				scalar mean=r(mean)
				replace `var' = `var' - mean if year==2010
				sum `var' if year==2018
				scalar mean=r(mean)
				replace `var' = `var' - mean if year==2018
}

reg rif_var sexo sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 ///
conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal]

estimate store reg1

oaxaca rif_var sexo sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 ///
conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal], detail(sectores: sect1-sect27, contrato: contrato1-contrato4 horas, ///
		ocupacion: ocup1-ocup16, trabajador: estudios1-estudios6 anoanti anoanti2 sexo, ///
		empresa: conv_1-conv_5 market1-market4 tipopais control) relax by(year) swap reference(reg1)

mat AA=r(table)'

svmat AA


ren AA1 coef
ren AA2 stand
ren AA3 zval
ren AA4 pvalue
ren AA5 ll
ren AA6 ul
gen x=_n


*Edad (2018)

gen jovenes=(edad<=2)

tab jovenes year [aw=factotal], sum(lsalmes)



oaxaca rif_var sexo sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 ///
conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal] if year==2018, detail(sectores: sect1-sect27, contrato: contrato1-contrato4 horas, ///
		ocupacion: ocup1-ocup16, estudios: estudios1-estudios6, trabajador: anoanti anoanti2 sexo, ///
		empresa: conv_1-conv_5 market1-market4 tipopais control) pooled relax by(jovenes) swap

*Edad (2010)


oaxaca rif_var sexo sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 ///
conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal] if year==2010, detail(sectores: sect1-sect27, contrato: contrato1-contrato4 horas, ///
		ocupacion: ocup1-ocup16, estudios: estudios1-estudios6, trabajador: anoanti anoanti2 sexo, ///
		empresa: conv_1-conv_5 market1-market4 tipopais control) pooled relax by(jovenes) swap

*G�nero

*2018

oaxaca rif_var  sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 ///
conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal] if year==2018, detail(sectores: sect1-sect27, contrato: contrato1-contrato4 horas, ///
		ocupacion: ocup1-ocup16, trabajador: estudios1-estudios6 anoanti anoanti2 sexo, ///
		empresa: conv_1-conv_5 market1-market4 tipopais control) pooled relax by(sexo) swap

* (2010)


oaxaca rif_var sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios6 anoanti anoanti2 ///
conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal] if year==2010, detail(sectores: sect1-sect27, contrato: contrato1-contrato4 horas, ///
		ocupacion: ocup1-ocup16, trabajador: estudios1-estudios6 anoanti anoanti2 sexo, ///
		empresa: conv_1-conv_5 market1-market4 tipopais control) pooled relax by(sexo) swap

		
kk
		
*CCAA
tab region if year==2018 [aw=factotal], sum(rif_var)

gen temporal=contrato3+contrato4
tab region if year==2018 [aw=factotal], sum(temporal)		
		

*Diferencias por percentiles (para explicar figura tercera informe ppt)


local i = 5
	while `i' <= 95 {
		egen rif_var`i'=rifvar(lsalmes), q(`i') by(year)
		oaxaca rif_var`i' sexo sect2-sect27 contrato2-contrato4 ocup2-ocup16 estudios2-estudios7 anoanti anoanti2 ///
		conv_2-conv_5 market2-market4 tipopais horas control [aw=factotal], detail(sectores: sect1-sect27, contrato: contrato1-contrato4 horas, ///
		ocupacion: ocup1-ocup16, trabajador: estudios1-estudios7 anoanti anoanti2 sexo, ///
		empresa: conv_1-conv_5 market1-market4 tipopais control) pooled relax by(year) swap
		
		mat b`i'=e(b)
		
		local i = `i' + 5
		}
		
mat b_perc=b5
local i = 10
	while `i' <=95 {
	mat b_perc=b_perc\b`i'
	local i = `i' + 5
	}




		
merge n:1 cestudio edad cno act using "C:\Users\alejh\Downloads\enlacecedefop.dta"

keep if _merge==3





egen rif_var=rifvar(lsalmes), var by(year)
egen grupo=group(secc year)

egen rif_var_s18=rifvar(lsalmes), var by(grupo)

kk



*Figura 2. Aportaci�n desigualdad 2010 - 2018 por sectores

preserve

collapse (mean) rif_50 rif_std rif_iqr rif_gini (sum) factotal, by(year secc)
mkmat  rif_50 rif_std rif_iqr rif_gini factotal if year==2010, mat(sectores2010)
mkmat  rif_50 rif_std rif_iqr rif_gini factotal if year==2018, mat(sectores2018)

restore


preserve

collapse (mean) rif_50 rif_std rif_iqr rif_gini (sum) factotal, by(year contrato)
mkmat  rif_50 rif_std rif_iqr rif_gini factotal if year==2010, mat(contrato2010)
mkmat  rif_50 rif_std rif_iqr rif_gini factotal if year==2018, mat(contrato2018)
