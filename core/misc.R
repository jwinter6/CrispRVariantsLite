.onAttach <- function(...) {
  
  # Create link to javascript and css files for package
  shiny::addResourcePath("sbs", system.file("www", package="shinyBS"))
  
}

shinyBSDep <- htmltools::htmlDependency("shinyBS", packageVersion("shinyBS"),
                   src = c("href" = "sbs"), script = "shinyBS.js",
                   stylesheet = "shinyBS.css")
typeaheadDep <- htmltools::htmlDependency("shinyBS", packageVersion("shinyBS"),
                   src = c("href" = "sbs"), script = c("bootstrap3-typeahead.js",
                   "typeahead_inputbinding.js"));


# Copy of dropNulls function for shiny to avoid using shiny:::dropNulls
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}


# Takes a tag and removes any classes in the remove argument
removeClass <- function(tag, remove) {
  
  if(length(remove) == 1) remove <- strsplit(remove, " ", fixed = TRUE)[[1]]
  class <- strsplit(tag$attribs$class, " ", fixed = TRUE)[[1]]
  class <- class[!(class %in% remove)]
  tag$attribs$class <- paste(class, collapse = " ")
  
  return(tag)
}


addClass <- function(tag, add) {
  tag$attribs$class <- paste(tag$attribs$class, add)
  return(tag)
}





addAttribs <- function(tag, ...) {
  a <- list(...)
  for(i in seq(length(a))) {
    tag$attribs[names(a)[i]] = a[[i]]
  }
  return(tag)
}






removeAttribs <- function(tag, ...) {
  a <- list(...)
  for(i in seq(length(a))) {
    tags$attribs[a[[i]]] = NULL
  }
  return(tag)
}


getAttribs <- function(tag) {
  tag$attribs
}



##### Modified CRISPRVariants arrange Plots function to accomodate download of high-res images

arrangePlots_highres <- function(top.plot, left.plot, right.plot, fig.height = NULL,
                         col.wdth.ratio  = c(2, 1), row.ht.ratio = c(1,6),
                         left.plot.margin = grid::unit(c(0.1,0,3,0.2), "lines")){
  
  # Set the size ratio of the top and bottom rows
  plot_hts <- if (is.null(fig.height)){ row.ht.ratio
  }else { fig.height/sum(row.ht.ratio)*row.ht.ratio }
  
  # Remove y-axis labels from right plot
  right.plot <- right.plot + theme(axis.text.y = element_blank(),
                                   axis.ticks.y = element_blank())
  
  # Adjust margins of left.plot
  left.plot <- left.plot + theme(plot.margin = left.plot.margin)
  
  # Convert plots to grobs, lock plot heights
  p2 <- ggplot2::ggplotGrob(left.plot)
  p3 <- ggplot2::ggplotGrob(right.plot)
  p3$heights <- p2$heights
  
  # Return arranged plots
  return(gridExtra::arrangeGrob(top.plot,
                                 gridExtra::arrangeGrob(p2, p3, ncol = 2, widths = col.wdth.ratio),
                                 nrow = 2, heights = plot_hts, newpage = FALSE))
}
