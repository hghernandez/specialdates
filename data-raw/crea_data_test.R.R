## code to prepare `DATASET` dataset goes here

#Armo un dataset de test para la funcion comparables_days_means

fechas <- seq(as.Date('2021-06-01'),as.Date('2022-06-30'),"days")
merchant <- c("Merchant A","Merchant B")
country <- c("Argentina","Uruguay")

ventas <- tidyr::crossing(fechas,merchant,country)

ventas$cantidad <- round(runif(1580,min = 1,max = 1410))

#Modifico Uruguay

ventas <- dplyr::mutate(ventas,merchant= dplyr::case_when(merchant== 'Merchant A' &
                                                        country== 'Uruguay' ~ 'Merchant C',
                                                      merchant== 'Merchant B' &
                                                        country== 'Uruguay' ~ 'Merchant D',
                                                      TRUE ~ merchant))
View(ventas)

#Guardo el archivo en formato .rda
usethis::use_data(ventas, overwrite = TRUE)
