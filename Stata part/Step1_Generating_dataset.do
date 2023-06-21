* Original data are split in 30 .txt files. We start from importing them using a forvalues cycle and we save the outputs as dta files.
forvalues i=1/30 {
import delimited "/Users/francescamicocci/Documents/Export_project/Data/manuf France (`i').txt", encoding(ISO-8859-1)clear
save "/Users/francescamicocci/Documents/Export_project/Data/manuf_France_(`i').dta", replace
}

* Once we converted the txt files into dta we can append them all in a single datasets
use "/Users/francescamicocci/Documents/Export_project/Data/manuf_France_(1).dta"

forvalues i=2/30 { 
append using "/Users/francescamicocci/Documents/Export_project/Data/manuf_France_(`i').dta" 
}

* We drop duplicates
duplicates drop

drop ÿþ
*We save the generated dta file
save "/Users/francescamicocci/Documents/Export_project/Data/Data_from_string.dta", replace
