devtools::document()
devtools::check()


#Creo subcarpeta con sript que arma el data test

usethis::use_data_raw()

#Creo el archivo README

usethis::use_readme_rmd()

#Armo un sticker

load("data/ventas.rda")

devtools::load_all("C:/Users/hernan.hernandez/Documents/specialdates")


s <- heatmap.calendar(df = ventas,
                 fini = '2022-06-01',
                 ffin = '2022-06-30',
                 fields.date = "fechas",
                 agrupador = "country",
                 filtro = "Argentina",
                 valor = "cantidad",
                 titulo = "specialdates",
                 exportar = FALSE)


library(hexSticker)

sticker(s, package="specialdates", p_size=20, s_x=1, s_y=.75, s_width=1.3, s_height=1,
        filename= "inst/figures/ggplot2.png")


imgurl <- "inst/figures/imagen.png"
sticker(imgurl, package="specialdates", p_size=20, s_x=1, s_y=.75, s_width=.5,
        filename="inst/figures/imgfile.png",
        h_color = '#9D00FF',h_fill = 'white',p_color = '#FF8EDD')

openxlsx::writeData()

