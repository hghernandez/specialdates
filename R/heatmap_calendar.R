#' Crea un mapa de calor sobre un calendario
#'
#' La función heatmap_calendar genera un mapa de calor impreso sobre un calendario.
#' De esa forma obtenemos un objeto gráfico que representa con un color más intenso
#' aquéllos días con valores más altos y un color más débil para los días con valores
#' más bajos.

#' @param df nombre del data.frame a analizar.
#' @param fini fecha de inicio de la secuencia en formato (yyyy-mm-dd).
#' @param ffin fecha de fin de la secuencia en formato (yyyy-mm-dd).
#' @param fields.date nombre del campo de fecha.
#' @param agrupador El nivel de agrupamiento (por ej: Merchant, Pais, Región).
#' @param filtro NULL. Si desea aplicar un filtro al campo agrupador indicar el valor.
#' @param valor nombre del campo con el valor a analizar graficamente.
#' @param titulo string con el titulo que desee para el gráfico.
#' @param exportar FALSE. Si desea exportar el archivo en formato .png cambie a TRUE.

#' @return grafico de mapa de calor sobre un calendario.
#' @export


heatmap.calendar <- function(df,fini,ffin,fields.date,agrupador,filtro=NULL,valor,titulo,exportar=FALSE){

  if(is.null(filtro)==TRUE){
    df <- dplyr::rename(df,valor= valor,fecha=fields.date)
    df <- dplyr::group_by(df, !!rlang::sym(agrupador),fecha)
    df <- dplyr::summarise(df,valor= sum(valor))
    df <- dplyr::mutate(df,fecha= lubridate::ymd(fecha))
  }else{
  df <- dplyr::filter(df,!!rlang::sym(agrupador)==filtro)
  }
  #Armo el df del partner

  df <- dplyr::rename(df,valor= valor,fecha=fields.date)
  df <- dplyr::group_by(df, !!rlang::sym(agrupador),fecha)
  df <- dplyr::summarise(df,valor= sum(valor))
  df <- dplyr::mutate(df,fecha= lubridate::ymd(fecha))

  #Armo una combinación de todas las fechas entre un periodo

  fechas  <- tidyr::tibble(fecha = seq(
    lubridate::ymd(fini),
    lubridate::ymd(ffin),
    "days"
  ))


  #completamos las fechas que no existen

  fechas <- dplyr::left_join(fechas, df, by= "fecha")
  fechas <- dplyr::mutate(fechas,valor= tidyr::replace_na(valor,0))



  data.compl <- dplyr::mutate(fechas,
    weekday = lubridate::wday(fecha, label = T, week_start = 7,abbr = T),
    month = lubridate::month(fecha, label = T),
    date = lubridate::yday(fecha),
    week = lubridate::epiweek(fecha)
  )


  data.compl$week[data.compl$month=="ene" & data.compl$week ==52] = 0

  data.compl = dplyr::group_by(data.compl,month)
  data.compl = dplyr::mutate(data.compl, monthweek = 1 + week - min(week))


  #Fijo la escala de gradientes

  low  <- '#FFCE19'
  high <- '#9D00FF'

  graf <- ggplot2::ggplot(data.compl,
                          ggplot2::aes(weekday,-week, fill= valor)) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::labs(title= paste(filtro,sep = " "))  +
    ggplot2::geom_text(ggplot2::aes(label = lubridate::day(fecha)), size = 2.5, color = "white") +
    ggplot2::scale_fill_gradient(low=low, high=high, na.value = 'white')+
    ggplot2::facet_wrap(~month, nrow = 3, ncol = 3, scales = "free")+
    ggplot2::theme(aspect.ratio = 1,
          legend.position = "none",
          legend.key.width = ggplot2::unit(3, "cm"),
          axis.title.x =  ggplot2::element_blank(),
          axis.title.y =  ggplot2::element_blank(),
          axis.text.y =  ggplot2::element_blank(),
          axis.text.x =  ggplot2::element_text(size=8),
          panel.grid =  ggplot2::element_blank(),
          axis.ticks =  ggplot2::element_blank(),
          panel.background =  ggplot2::element_blank(),
          legend.title.align = 0.5,
          strip.background =  ggplot2::element_blank(),
          strip.text =  ggplot2::element_text(face = "bold", size = 14,colour = "#191C3C"),
          panel.border =  ggplot2::element_rect(colour = "grey", fill=NA, size=1),
          plot.title =  ggplot2::element_text(hjust = 0, size = 14, face = "bold",
                                    margin =  ggplot2::margin(0,0,0.5,0, unit = "cm"))
    )

     if(exportar== TRUE){
       ggplot2::ggsave(graf,filename = paste0("Heatmap",titulo," ",filtro,".png"),width = 10,height = 10,units = "cm", dpi = 200)
     }else{return(graf)}



}
