#' Compara promedio de dias especiales
#'
#' La función comparables_days_means calcula el promedio del período de
#' la fecha comercial y de la semana, mes y año previo. Ofrece también
#' la posibilidad de analizar el período anterior en caso que la fecha no
#' siempre coincida en la misma altura del año.
#'
#' @param df nombre del data.frame a analizar
#' @param fields.date  el nombre del campo de fecha.
#' @param valor El valor con el cuál calcular los promedios.
#' @param fecha vector con las fechas comerciales, es decir c('fecha1','fecha2').
#' @param agrupador El nivel de agrupamiento (por ej: Merchant, Pais, Región).
#' @param festividad el nombre de la fecha comercial.
#' @param mov.days las fechas en que sucedió el evento anterior como vector, es decir c('fecha1','fecha2')
#' @param graf.label booleano para indicar si queremos que agregue el valor encima de la barra poner TRUE
#' @return cuadro que contiene el promedio de la fecha en estudio y los valores absolutos y porcentuales
#' de la comparación con semana previa (pw), mes previo (pm), año previo (py) y si no es fija (pmov)
#' @return grafico de barras con las comparaciones temporales
#' @export





comparables.days.means <- function(df,fields.date,valor,fecha,agrupador,festividad,mov.days= NULL, graf.label=FALSE){


  df <- dplyr::rename(df,Valor= valor, date=fields.date)
  df <- dplyr::group_by(df, !!rlang::sym(agrupador),date)
  df <- dplyr::summarise(df,Valor= sum(Valor))

  if(length(mov.days) > 0){

    #Armo fechas
    fechas <- data.frame(Fecha= seq(as.Date(fecha[1]),as.Date(fecha[2]),by= "days"))

    #Armo las combinaciones de fecha y agrupador
    comb <- unique(df[,agrupador])

    completo <- tidyr::crossing(fechas,comb)


    #Agrego la columna prior_week

    prior_week <- dplyr::mutate(completo, prior_week= Fecha -lubridate::days(7))

    df$date <- as.Date(df$date)

    #agrego los Valores

    prior_week <- dplyr::left_join(prior_week ,df, by= c("prior_week"="date", agrupador))
    prior_week <- dplyr::left_join(prior_week, df, by= c("Fecha"= "date",agrupador))
    prior_week <- dplyr::group_by(prior_week,!!rlang::sym(agrupador))
    prior_week <- dplyr::summarise(prior_week,n= mean(Valor.y,na.rm=T),
                       pw= mean(Valor.x,na.rm=T))
    prior_week <- dplyr::mutate(prior_week, '%'= (n-pw)*100/pw)



    #Armo prior_month


    prior_month <- dplyr::mutate(completo, prior_month= Fecha - lubridate::days(28))


    prior_month <- dplyr::left_join(prior_month,df, by= c("prior_month"="date", agrupador))
    prior_month <- dplyr::left_join(prior_month, df, by= c("Fecha"= "date",agrupador))
    prior_month <- dplyr::group_by(prior_month,!!rlang::sym(agrupador))
    prior_month <- dplyr::summarise(prior_month, n= mean(Valor.y,na.rm=T),
                       pm= mean(Valor.x,na.rm=T))
    prior_month <- dplyr::mutate(prior_month, '%'= (n-pm)*100/pm)


    #Armo prior_year

    prior_year <- dplyr::mutate(completo, prior_year= Fecha - lubridate::days(365))


    prior_year <- dplyr::left_join(prior_year,df, by= c("prior_year"="date", agrupador))
    prior_year <-dplyr::left_join(prior_year, df, by= c("Fecha"= "date",agrupador))
    prior_year <-dplyr::group_by(prior_year,!!rlang::sym(agrupador))
    prior_year <-dplyr::summarise(prior_year, n= mean(Valor.y),
                       py= mean(Valor.x,na.rm=T))
    prior_year <-dplyr::mutate(prior_year, '%'= (n-py)*100/py)

    #Misma fecha año anterior para fechas movibles
    #por ej: semana santa

    movible <- seq(as.Date(mov.days[1]),as.Date(mov.days[2]),"days")

    movible <- tidyr::crossing(movible,comb)


    prior_movible <- cbind(completo,"prior_movible"= movible$movible)

    prior_movible <- dplyr::left_join(prior_movible,df, by= c("prior_movible"="date", agrupador))
    prior_movible <- dplyr::left_join(prior_movible,df, by= c("Fecha"= "date",agrupador))
    prior_movible <- dplyr::group_by(prior_movible,!!rlang::sym(agrupador))
    prior_movible <- dplyr::summarise(prior_movible, n= mean(Valor.y),
                     pmov= mean(Valor.x,na.rm=T))
    prior_movible <- dplyr::mutate(prior_movible, '%'= (n-pmov)*100/pmov)


    #Armo el archivo para gráfico

    data.graf <- tidyr::pivot_longer(dplyr::select(prior_week, -"%"),-c(!!rlang::sym(agrupador)),names_to = "Temporalidad",values_to = "Promedio")
    data.graf <- dplyr::bind_rows(data.graf,tidyr::pivot_longer(dplyr::select(prior_month, -"%"),-c(!!rlang::sym(agrupador)),names_to = "Temporalidad",values_to = "Promedio"))
    data.graf <- dplyr::bind_rows(data.graf,tidyr::pivot_longer(dplyr::select(prior_year, -"%"),-c(!!rlang::sym(agrupador)),names_to = "Temporalidad",values_to = "Promedio"))
    data.graf <-dplyr::bind_rows(data.graf,tidyr::pivot_longer(dplyr::select(prior_movible, -"%"),-c(!!rlang::sym(agrupador)),names_to = "Temporalidad",values_to = "Promedio"))

    #Agrego el nombre de la festividad

    data.graf <-  dplyr::mutate(data.graf, Temporalidad= dplyr::case_when(Temporalidad == 'n'
                                                                       ~ festividad,
                                                                       TRUE ~ as.character(Temporalidad)))

    #Ordeno la temporalidad

    data.graf$Temporalidad <- factor(data.graf$Temporalidad,
                                     levels = c("pw","pm","py","pmov",festividad),
                                     labels = c("Semana previa","Mes previo","Año previo",paste0(festividad," anterior"),festividad))

    theme_geo <- function(){

      ggplot2::'%+replace%'
      ggplot2::theme_grey()
        ggplot2::theme(
          strip.text.x = ggplot2::element_text(size = 10, color = "#191C3C", face = "bold.italic"),
          axis.title.x=  ggplot2::element_blank(),
          axis.title.y=  ggplot2::element_text(face= "bold", size= 9, colour = "#191C3C",angle = 90),
          axis.text.x =  ggplot2::element_text(face= "bold", size= 9, colour = "#191C3C", angle = 30,vjust = 0.9, hjust = 1),
          plot.title =  ggplot2::element_text(hjust = 0.5,face= "bold", size= 11, colour = "#191C3C")
        )
    }

    if(graf.label==TRUE){

    #Armo el gráfico

    grafico <- ggplot2::ggplot(data.graf,
                               ggplot2::aes_string(x= agrupador, y = "Promedio", fill= "Temporalidad"))+
      ggplot2::geom_bar(stat= "identity", position = "dodge") +
      ggplot2::scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale()))+
      ggplot2::scale_fill_manual(values = c("#B7AEFF","#F452E8","#56D26E","#9D00FF","#FF8EDD"),
                        labels= c("Semana Previa", "Mes Previo","Año Previo",paste0(festividad," anterior"),festividad))+
      ggplot2::geom_text(ggplot2::aes(label=round(Promedio,1)),position= ggplot2::position_dodge(width=0.9), vjust=-0.25, size= 3,colour = "#191C3C", check_overlap = TRUE)+
      ggplot2::guides(fill="none")+
      theme_geo()
    }else{
      grafico <- ggplot2::ggplot(data.graf,
                                 ggplot2::aes_string(x= agrupador, y = "Promedio", fill= "Temporalidad"))+
        ggplot2::geom_bar(stat= "identity", position = "dodge") +
        ggplot2::scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale()))+
        ggplot2::scale_fill_manual(values = c("#B7AEFF","#F452E8","#56D26E","#9D00FF","#FF8EDD"),
                                   labels= c("Semana Previa", "Mes Previo","Año Previo",paste0(festividad," anterior"),festividad))+
        ggplot2::guides(fill="none")+
        theme_geo()
    }
    #Arma la tabla de datos

    #Armo la tabla de datos

    tabla.datos <- dplyr::left_join(prior_week, prior_month, by= c(agrupador,"n"))
    tabla.datos <- dplyr::left_join(tabla.datos,prior_year, by= c(agrupador,"n"))
    tabla.datos <- dplyr::left_join(tabla.datos,prior_movible, by= c(agrupador,"n"))
    tabla.datos <- dplyr::mutate(tabla.datos, dplyr::across(where(is.numeric), round, 2))


    #Cambio los nombres de las columnas

    names(tabla.datos) <- c(agrupador,"n","pw",'%',"pm",'%',"py",'%',"pmov",'%')

    #Convierto todos los valores nulos a NA

    is.na(tabla.datos)<-sapply(tabla.datos, is.infinite)
    is.na(tabla.datos)<-sapply(tabla.datos, is.nan)

    list(cuadro= tabla.datos,grafico= grafico)

  }else{

    #Armo fechas
    fechas <- data.frame(Fecha= seq(as.Date(fecha[1]),as.Date(fecha[2]),by= "days"))

    #Armo las combinaciones de fecha e agrupador
    comb <- unique(df[,agrupador])

    completo <- tidyr::crossing(fechas,comb)


    #Agrego la columna prior_week

    prior_week <- dplyr::mutate(completo, prior_week= Fecha -lubridate::days(7))

    df$date <- as.Date(df$date)

    #agrego los Valores

    prior_week <- dplyr::left_join(prior_week ,df, by= c("prior_week"="date", agrupador))
    prior_week <- dplyr::left_join(prior_week, df, by= c("Fecha"= "date",agrupador))
    prior_week <- dplyr::group_by(prior_week, !!rlang::sym(agrupador))
    prior_week <- dplyr::summarise(prior_week,n= mean(Valor.y,na.rm=T),
                                   pw= mean(Valor.x,na.rm=T))
    prior_week <- dplyr::mutate(prior_week, '%'= (n-pw)*100/pw)



    #Armo prior_month


    prior_month <- dplyr::mutate(completo, prior_month= Fecha - lubridate::days(28))


    prior_month <- dplyr::left_join(prior_month,df, by= c("prior_month"="date", agrupador))
    prior_month <- dplyr::left_join(prior_month, df, by= c("Fecha"= "date",agrupador))
    prior_month <- dplyr::group_by(prior_month,!!rlang::sym(agrupador))
    prior_month <- dplyr::summarise(prior_month, n= mean(Valor.y,na.rm=T),
                                    pm= mean(Valor.x,na.rm=T))
    prior_month <- dplyr::mutate(prior_month, '%'= (n-pm)*100/pm)


    #Armo prior_year

    prior_year <- dplyr::mutate(completo, prior_year= Fecha - lubridate::days(365))


    prior_year <- dplyr::left_join(prior_year,df, by= c("prior_year"="date", agrupador))
    prior_year <-dplyr::left_join(prior_year, df, by= c("Fecha"= "date",agrupador))
    prior_year <-dplyr::group_by(prior_year,!!rlang::sym(agrupador))
    prior_year <-dplyr::summarise(prior_year, n= mean(Valor.y),
                                  py= mean(Valor.x,na.rm=T))
    prior_year <-dplyr::mutate(prior_year, '%'= (n-py)*100/py)

    #Armo el archivo para gráfico

    data.graf <- tidyr::pivot_longer(dplyr::select(prior_week, -"%"),-c(!!rlang::sym(agrupador)),names_to = "Temporalidad",values_to = "Promedio")
    data.graf <- dplyr::bind_rows(data.graf,tidyr::pivot_longer(dplyr::select(prior_month, -"%"),-c(!!rlang::sym(agrupador)),names_to = "Temporalidad",values_to = "Promedio"))
    data.graf <- dplyr::bind_rows(data.graf,tidyr::pivot_longer(dplyr::select(prior_year, -"%"),-c(!!rlang::sym(agrupador)),names_to = "Temporalidad",values_to = "Promedio"))

    #Agrego el nombre de la festividad

    data.graf <-  data.graf  %>% dplyr::mutate(Temporalidad= dplyr::case_when(Temporalidad == 'n'
                                                                       ~ festividad,
                                                                       TRUE ~ as.character(Temporalidad)))

    #Ordeno la temporalidad

    data.graf$Temporalidad <- factor(data.graf$Temporalidad,
                                     levels = c("pw","pm","py",festividad),
                                     labels = c("Semana previa","Mes previo","Año previo",festividad))


    theme_geo <- function(){

      ggplot2::'%+replace%'
      ggplot2::theme_grey()
      ggplot2::theme(
        strip.text.x = ggplot2::element_text(size = 10, color = "#191C3C", face = "bold.italic"),
        axis.title.x=  ggplot2::element_blank(),
        axis.title.y=  ggplot2::element_text(face= "bold", size= 9, colour = "#191C3C",angle = 90),
        axis.text.x =  ggplot2::element_text(face= "bold", size= 9, colour = "#191C3C", angle= 30,vjust = 0.9, hjust = 1),
        plot.title =  ggplot2::element_text(hjust = 0.5,face= "bold", size= 11, colour = "#191C3C")
      )
    }


    #Armo el gráfico
    if(graf.label==TRUE){
    grafico <- ggplot2::ggplot(data.graf,
                               ggplot2::aes_string(x= agrupador, y = "Promedio", fill= "Temporalidad"))+
      ggplot2::geom_bar(stat= "identity", position = "dodge") +
      ggplot2::scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale()))+
      ggplot2::scale_fill_manual(values = c("#B7AEFF","#F452E8","#56D26E","#9D00FF","#FF8EDD"),
                                 labels= c("Semana Previa", "Mes Previo","Año Previo",festividad))+
      ggplot2::geom_text(ggplot2::aes(label=round(Promedio,1)),position=ggplot2::position_dodge(width=0.9), vjust=-0.25, size= 3,colour = "#191C3C",check_overlap = TRUE)+
      ggplot2::guides(fill="none")+
      theme_geo()
    }else{
      grafico <- ggplot2::ggplot(data.graf,
                                 ggplot2::aes_string(x= agrupador, y = "Promedio", fill= "Temporalidad"))+
        ggplot2::geom_bar(stat= "identity", position = "dodge") +
        ggplot2::scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale()))+
        ggplot2::scale_fill_manual(values = c("#B7AEFF","#F452E8","#56D26E","#9D00FF","#FF8EDD"),
                                   labels= c("Semana Previa", "Mes Previo","Año Previo",festividad))+
        ggplot2::guides(fill="none")+
        theme_geo()
    }

    #Armo la tabla de datos

    tabla.datos <- dplyr::left_join(prior_week, prior_month, by= c(agrupador,"n"))
    tabla.datos <- dplyr::left_join(tabla.datos, prior_year, by= c(agrupador,"n"))
    tabla.datos <- dplyr::mutate(tabla.datos,dplyr::across(where(is.numeric), round, 2))

    #Cambio los nombres de las columnas

    names(tabla.datos) <- c(agrupador,"n","pw",'%',"pm",'%',"py",'%')


    #Convierto todos los valores nulos a NA

    is.na(tabla.datos)<-sapply(tabla.datos, is.infinite)
    is.na(tabla.datos)<-sapply(tabla.datos, is.nan)

    list(cuadro= tabla.datos,grafico= grafico)



  }

}
