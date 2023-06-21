*Set directory
cd /your/directory/
* Import the dta dataset generated as output of Step1
use "Export_project/Data/Data_from_string.dta", replace

*Extract the year from the date
gen year_status=substr(statusdate, 7, 10)
label var year_status "Status date Year"

*Remove non-french entities
gen state=substr(bvdidnumber, 1, 2)
drop if state!="FR"
drop state

*Generate the price index variables for intermediate and capital goods from EUROSTAT
gen interm_pi2010=97.6
gen interm_pi2011=103.1
gen interm_pi2012=103.8
gen interm_pi2013=103.2
gen interm_pi2014=101.8
gen interm_pi2015=100.00
gen interm_pi2016=97.5
gen interm_pi2017=100.2
gen interm_pi2018=102.8
gen interm_pi2019=102.8

gen capital_pi2010=95.2
gen capital_pi2011=97.3
gen capital_pi2012=98.4
gen capital_pi2013=99.2
gen capital_pi2014=99.6
gen capital_pi2015=100.00
gen capital_pi2016=100.2
gen capital_pi2017=100.7
gen capital_pi2018=101.4
gen capital_pi2019=102.6

gen wage_pi2010=89.8
gen wage_pi2011=93.5
gen wage_pi2012=96.3
gen wage_pi2013=97.7
gen wage_pi2014=98.8
gen wage_pi2015=100.00
gen wage_pi2016=101.6
gen wage_pi2017=102.8
gen wage_pi2018=104.9
gen wage_pi2019=107.5

*Merge the original dataset with new variables on FDI
merge m:m bvdidnumber using "Export_project/Data/new_var.dta"


*Transform the data into a panel
unab mylist : *2011
local mylist : subinstr local mylist "2011" "", all
reshape long `mylist', i(bvdidnumber) j(year) string

*Merge with PPIs dataset
tostring nacerev2primarycodes, replace
drop _merge

merge m:m year nacerev2primarycodes using "Export_project/Data/PPI.dta"
*Perform some data cleaning
rename Value PPI 
drop if bvdidnumber==""
replace PPI = "100.0" if year=="2015"
*NOTE: There are some missing PPI from the original data. I used PPI of nace codes 24 and 30 respectively to fill the missing PPIs.
replace PPI = "97.6" if year=="2010" & nacerev2primarycodes=="2446"
replace PPI = "105.7" if year=="2011" & nacerev2primarycodes=="2446"
replace PPI = "100.4" if year=="2012" & nacerev2primarycodes=="2446"
replace PPI = "95.1" if year=="2013" & nacerev2primarycodes=="2446"
replace PPI = "94.5" if year=="2014" & nacerev2primarycodes=="2446"
replace PPI = "89.2" if year=="2016" & nacerev2primarycodes=="2446"
replace PPI = "98.2" if year=="2017" & nacerev2primarycodes=="2446"
replace PPI = "100.9" if year=="2018" & nacerev2primarycodes=="2446"
replace PPI = "97.0" if year=="2019" & nacerev2primarycodes=="2446"

replace PPI = "96.8" if year=="2010" & nacerev2primarycodes=="3040"
replace PPI = "100.1" if year=="2011" & nacerev2primarycodes=="3040"
replace PPI = "100.3" if year=="2012" & nacerev2primarycodes=="3040"
replace PPI = "99.5" if year=="2013" & nacerev2primarycodes=="3040"
replace PPI = "99.5" if year=="2014" & nacerev2primarycodes=="3040"
replace PPI = "100.1" if year=="2016" & nacerev2primarycodes=="3040"
replace PPI = "100.6" if year=="2017" & nacerev2primarycodes=="3040"
replace PPI = "101.0" if year=="2018" & nacerev2primarycodes=="3040"
replace PPI = "101.5" if year=="2019" & nacerev2primarycodes=="3040"

destring PPI, replace


*Generate real values for Capital, Materials and Sales
drop _merge
gen rCapital=fixedassetseur*100/capital_pi
gen rMaterials=materialcostseur*100/interm_pi
gen rAddVal=addedvalueeur*100/PPI
gen rSales=saleseur*100/PPI
gen wagebill=costsofemployeeseur*100/wage_pi
gen wage=ln(wagebill/numberofemployees)


* Generate the variables to be used for computation of TFP and Markups
gen va=ln(rAddVal)
label var va "log of real Added Values"
gen y=ln(rSales)
label var y "log of real Sales"
gen k=ln(rCapital)
labe var k "log of real fixeed assets"
gen log_emp=ln(numberofemployees)
label var log_emp "log of number of employees"
gen m=ln(rMaterials)
label var m "log of real material costs"
gen l=ln(wagebill)
label var l "log of real cost of labour"

drop rCapital rMaterials rAddVal rSales ÿþ interm_pi capital_pi wage_pi PPI wagebill

save "Export_project/Data/Data_real_val.dta", replace

