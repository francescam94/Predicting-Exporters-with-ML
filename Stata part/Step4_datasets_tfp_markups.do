*Start by cleaning the environment
clear all
*Generate a global of nace codes to be used for TFP and Markups computation
global naces 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 


*Subset the dataset by Nace code and compute in each TFP using ACFEST and Markups following similar approach to Markupest
foreach i in $naces{
use "/Users/francescamicocci/Documents/Export_project/Data/Data_panel_1.dta"
destring nace_2d, replace
*Take the observations belonging to the same sector
keep if (nace_2d==`i')
*Compute the markups by ACF. Now the beta l can be considered to be the one not biased by TFP and
*we can use it as elasticity of labour, for TFP
acfest va, free(log_emp) state(k) proxy(m) i(id) t(year) robust overid va 
predict TFP_acf, omega

*Repeat Using Revenues: useful for markups
acfest y, free(l) state(k) proxy(m) i(id) t(year) robust overid  

*Extract the beta for labour
mat beta=e(b)
gen theta=beta[1,2] if !missing(1) & !missing(2)


*---------------creating variables--------------------------------------------------------------------*
* higher order terms on inputs
local M=3
local N=3
forvalues h=1/`M' {
gen l`h'=l^(`h')
gen m`h'=m^(`h')
gen k`h'=k^(`h')
*interaction terms
forvalues j=1/`N' {
gen l`h'm`j'=l^(`h')*m^(`j')
gen l`h'k`j'=l^(`h')*k^(`j')
gen k`h'm`j'=k^(`h')*m^(`j')
}
}
gen lkm=l*k*m
gen l2k2m2=l2*k2*m2
gen l3k3m3=l3*k3*m3

*------FIRST STAGE ------------------------------------------------------------------------------------*
xi: reg y l* m* k* i.year
predict phi
predict epsilon, res
label var phi "phi_it" 
label var epsilon "measurement error first stage"


*Now we can compute alpha as the ratio between l and y times the exp of the errors coming from 
*First stage 

gen alpha=exp(l)/(exp(y)/exp(epsilon))

*Finally we can compute markups as theta/alpha

gen markups=theta/alpha
replace markups=. if markups<0
replace markups=25 if !missing(markups)&markups>25
drop theta-alpha

save "/Users/francescamicocci/Documents/Export_project/Data/data_`i'.dta", replace
clear all

}

use "/Users/francescamicocci/Documents/Export_project/Data/data_10.dta"

foreach i in $naces { 
append using "/Users/francescamicocci/Documents/Export_project/Data/Data_`i'.dta" 
}

duplicates drop


save "/Users/francescamicocci/Documents/Export_project/Data/Data_panel_TFP.dta",replace
