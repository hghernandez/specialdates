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


imgurl <- "inst/figures/specialdates.png"

sticker(imgurl, package="specialdates", p_size=20, s_x=1, s_y=.75, s_width=.5,
        filename="inst/figures/imgfile.png",
        h_color = '#9D00FF',h_fill = 'white',p_color = '#FF8EDD',
        p_family = "Agrandir Tight Black")




library(showtext)

font_add_google("Gochi Hand", "gochi")

imgurl <- "inst/figures/specialdates.png"

sticker(imgurl, package="specialdates", p_size=20, s_x=1, s_y=.75, s_width=.5,
        filename="inst/figures/spacialdates_logo.png",
        h_color = "#EAE164",h_fill = "#EAE164",p_color = '#3C6CA8',
        p_family = "gochi",url = "https://github.com/hghernandez/specialdates.git",
        u_color = '#3C6CA8',u_size = 2.9)


openxlsx::writeData()

usethis::use_logo("inst/figures/specialdates_logo.png", geometry = "240x278", retina = TRUE)

sticker(p_family = )

fontfamily
