#' Web front end
#' 
#' Web application to interact to query The Plant List database.
#' 
#' @export
web.tpl<- function() {
  message("Press escape at any time to stop the application.\n")
  runApp(system.file("plantminer", package = "tpl"))
}