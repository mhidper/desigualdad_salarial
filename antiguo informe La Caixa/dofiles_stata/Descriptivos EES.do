*----------------------------------------------
* Project: OBSERVATORIO LA CAIXA
* Descriptivos EES.do
* 15/01/2021, version 1
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

do "C:\Users\alejh\Dropbox\CONSULTORIA\Observatorio La Caixa\STATA\dofiles\EES10_14_18.do"


***********TOTAL***************

preserve


pctile pct2010=lsalhora if year==2010 & sexo==0 [pw=factotal], nq(100) 

pctile pct2014=lsalhora if year==2014 & sexo==0 [pw=factotal], nq(100) 

pctile pct2018=lsalhora if year==2018 & sexo==0 [pw=factotal], nq(100)

pctile pct2010_sp=lsalhora if year==2010 & sexo==1  [pw=factotal], nq(100) 

pctile pct2014_sp=lsalhora if year==2014 & sexo==1 [pw=factotal], nq(100)

pctile pct2018_sp=lsalhora if year==2018 & sexo==1 [pw=factotal], nq(100) 

gen p = _n

gen dpctile1= pct2014- pct2010 
gen dpctile_sp1= pct2014_sp- pct2010_sp 
gen dpctile2= pct2018- pct2014 
gen dpctile_sp2= pct2018_sp- pct2014_sp


label var dpctile1 "Hombres 2010/14"
label var dpctile_sp1 "Mujeres 2010/14"

label var dpctile2 "Hombres 2014/18"
label var dpctile_sp2 "Mujeres 2014/18"

twoway (line dpctile1 p if p<95 & p>5) (line dpctile_sp1 p if p<95 & p>5)
twoway (line dpctile2 p if p<95 & p>5) (line dpctile_sp2 p if p<95 & p>5)
restore


