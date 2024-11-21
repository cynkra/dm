# srppp

<details>

* Version: 1.0.1
* GitHub: https://github.com/agroscope-ch/srppp
* Source code: https://github.com/cran/srppp
* Date/Publication: 2024-11-01 14:40:02 UTC
* Number of recursive dependencies: 86

Run `revdepcheck::cloud_details(, "srppp")` for more info

</details>

## Newly broken

*   checking running R code from vignettes ... ERROR
    ```
    Errors in running code in vignettes:
    when running code in ‘srppp.rmd’
      ...
    > dm_draw(current_register)
    
    > library(knitr)
    
    > kable(head(select(current_register$substances, pk, 
    +     iupac, substance_de, substance_fr, substance_it), n = 4))
    
      When sourcing ‘srppp.R’:
    Error: could not find function "select"
    Execution halted
    
      ‘srppp.rmd’ using ‘UTF-8’... failed
      ‘srppp_products_with_MO.rmd’ using ‘UTF-8’... OK
    ```

*   checking re-building of vignette outputs ... NOTE
    ```
    Error(s) in re-building vignettes:
    --- re-building ‘srppp.rmd’ using rmarkdown
    trying URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
    Content type 'application/x-zip-compressed' length 2468351 bytes (2.4 MB)
    ==================================================
    downloaded 2.4 MB
    
    
    Quitting from lines 75-80 [unnamed-chunk-3] (srppp.rmd)
    Error: processing vignette 'srppp.rmd' failed with diagnostics:
    could not find function "select"
    --- failed re-building ‘srppp.rmd’
    
    --- re-building ‘srppp_products_with_MO.rmd’ using rmarkdown
    trying URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
    Content type 'application/x-zip-compressed' length 2468351 bytes (2.4 MB)
    ==================================================
    downloaded 2.4 MB
    
    --- finished re-building ‘srppp_products_with_MO.rmd’
    
    SUMMARY: processing the following file failed:
      ‘srppp.rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

