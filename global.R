theme_custom = function (base_size = 14, base_family = "") 
{
  theme_void(base_size = base_size, base_family = base_family) %+replace% 
    theme(line = element_blank(), rect = element_blank(), 
          text = element_text(family = base_family, face = "plain", 
                              colour = "black", size = base_size, lineheight = 0.9, 
                              hjust = 0.5, vjust = 0.5, angle = 0, margin = margin(), 
                              debug = FALSE), 
          axis.line = element_blank(), 
          axis.line.x = NULL, axis.line.y = NULL, axis.text = element_blank(), 
          axis.text.x = element_blank(), axis.text.x.top = element_blank(), 
          axis.text.y = element_blank(), axis.text.y.right = element_blank(), 
          axis.ticks = element_blank(), axis.ticks.length = unit(0, "pt"), axis.title.x = element_blank(), axis.title.x.top = element_blank(), 
          axis.title.y = element_blank(), axis.title.y.right = element_blank(), 
          legend.background = element_blank(), legend.spacing = unit(0.4, "cm"), legend.spacing.x = NULL, legend.spacing.y = NULL, 
          legend.margin = margin(0.2, 0.2, 0.2, 0.2, "cm"), 
          legend.key = element_blank(), legend.key.size = unit(1.2, "lines"), legend.key.height = NULL, legend.key.width = NULL, 
          legend.text = element_text(size = rel(0.8)), legend.text.align = NULL, 
          legend.title = element_text(hjust = 0), legend.title.align = NULL, 
          legend.position = "none", legend.direction = NULL, 
          legend.justification = "center", legend.box = NULL, 
          legend.box.margin = margin(0, 0, 0, 0, "cm"), legend.box.background = element_blank(), 
          legend.box.spacing = unit(0.4, "cm"), panel.background = element_rect(fill='#4d4d4d'), 
          panel.border = element_blank(), panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(), panel.spacing = unit(0, "pt"), panel.spacing.x = NULL, panel.spacing.y = NULL, 
          panel.ontop = FALSE, strip.background = element_blank(), 
          strip.text = element_blank(), strip.text.x = element_blank(), 
          strip.text.y = element_blank(), strip.placement = "inside", 
          strip.placement.x = NULL, strip.placement.y = NULL, 
          strip.switch.pad.grid = unit(0, "cm"), strip.switch.pad.wrap = unit(0, "cm"), plot.background = element_blank(), plot.title = element_blank(), 
          plot.subtitle = element_blank(), plot.caption = element_blank(), 
          plot.margin = margin(0, 0, 0, 0), complete = TRUE)
}


extract.matrix = function(z) z@.Data[,,1]
