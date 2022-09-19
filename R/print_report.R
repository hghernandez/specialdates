#' Guarda el reporte en un archivo excel
#'
#' La función print_report permite guardar los productos de la función
#' **comparables_days_means** en un archivo excel. Podemos guardarlo en un
#' nuevo archivo o anexarlo a uno existente.

#' @param ls objeto lista generado por la función _comparables_days_means_.
#' @param festividad nombre de la fecha especial analizada.
#' @param name nombre del archivo.
#' @param sheetname nombre de la sheet. Importante cuando decidimos anexar
#' nuestro reporte a un archivo excel existente.
#' @param append FALSE. Si queremos anexarlo a un archivo existente cambiar a TRUE.
#' @return archivo excel en la misma ubicación del proyecto.
#' @export



print_report <- function(ls,festividad,name,sheetname,append= FALSE){

  if(append== FALSE){
  wb <- openxlsx::createWorkbook()

  openxlsx::addWorksheet(wb,sheetName = sheetname,gridLines = NULL)
  openxlsx::writeData(wb,sheet = sheetname, x = paste0("Reporte ",festividad),startCol = 1,startRow = 1)
  openxlsx::writeData(wb,sheet = sheetname,x = ls$cuadro,startCol = 1,startRow = 3, keepNA = TRUE,na.string = "--")
  print(ls$grafico)
  openxlsx::insertPlot(wb = wb,sheet = sheetname,startRow = nrow(ls$cuadro)+6,width = 8, height = 4, fileType = "png", units = "in")


  openxlsx::saveWorkbook(wb,paste0(name,".xlsx"),overwrite = TRUE)
  }else{
    wb <- openxlsx::loadWorkbook(paste0(name,".xlsx"))

    openxlsx::addWorksheet(wb,sheetName = sheetname,gridLines = NULL)
    openxlsx::writeData(wb,sheet = sheetname, x = paste0("Reporte ",festividad),startCol = 1,startRow = 1)
    openxlsx::writeData(wb,sheet = sheetname,x = ls$cuadro,startCol = 1,startRow = 3, keepNA = TRUE,na.string = "--")
    print(ls$grafico)
    openxlsx::insertPlot(wb = wb,sheet = sheetname,startRow = nrow(ls$cuadro)+6,width = 8, height = 4, fileType = "png", units = "in")


    openxlsx::saveWorkbook(wb,paste0(name,".xlsx"),overwrite = TRUE)



  }
}
