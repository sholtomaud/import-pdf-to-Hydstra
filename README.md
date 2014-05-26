# import-pdf-to-Hydstra

BETA - This script is template for importing pdf from a website into the Hydstra document tree.
For this script the "Bore ID" is equivalent to SITE:STATION in the Hydstra Site table. 

![import-pdf-to-Hydstra](/img/psc.png?raw=true "Import Screenshot")

## Input
In the "BoreID/STATION" field you specify which STATION ID you want to import a pdf for. 
The script will then fetch the pdf from the website 

## TODO
Since this script is currently in beta mode, much of the configuration is 'hard-coded' to fetch PDFs from the DERM GroundWater service. 
A configuration INI file will make this a more generic template.
In the meantime you can use this as a template.