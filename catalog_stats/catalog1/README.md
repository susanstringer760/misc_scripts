# Field Catalog Stats README for catalog1

## About

** Catalog Stats is a perl script that generates information from the catalog database consisting of file counts and sizes by product category.

## Prerequisites

- MySQL database

## To run 


    
    cp config/database.pl.template config/database.pl

update **config/database.pl** to reflect necessary parameters to connect the database


Input:
``` $ USAGE: ./generate_report.pl
  -p: project name
  -o: output filename (full path)
  -b: project begin date (YYYYMMDD)
  -e: project end date (YYYYMMDD)
  -n: data base name

Sample output:
    $ HIPPO5 2011-08-15  to 2011-09-15:
        map: 8410 products = 1.24 GB
        model: 803 products = 0.09 GB
        ops: 26359 products = 8.22 GB
        report: 43 reports (233 images) = 0.04 GB
        research: 595 products = 0.01 GB
      TOTAL: 36210 products = 9.6 GB
