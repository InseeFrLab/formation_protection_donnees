get_confint_OR <- function(model, nom){
  
  ci <- exp(confint(model, level = 0.95))
  
  ci <- ci %>% 
    as_tibble() %>%
    mutate(vars = rownames(ci), modele = nom) %>% 
    slice(-1) %>% 
    select(4:3,1:2)
  
  names(ci) <- c("modele", "vars","low","up")
  
  return(ci)
}

cio_function <- function(lo, uo, ls, us){
  min_u <- pmin(uo, us)
  max_l <- pmax(lo,ls)
  1/2*((min_u - max_l)/(uo-lo) + (min_u - max_l)/(us-ls))
}

#' Récupère les intervalles de confiance pour une liste de modèles
#'
#' @param all_modeles liste de modèles 
#'
#' @returns
#' @export
#'
#' @examples
get_all_confints <- function(all_modeles){
  
  nb_modeles <- length(all_modeles)
  all_confints <- purrr::imap( all_modeles, get_confint_OR)
  
  all_cios <- all_confints[1:4] |>
    purrr::list_rbind() |>
    full_join(all_confints[[1]] %>%  select(-1) %>% rename(low_orig = low, up_orig = up)) |>
    mutate(cio = cio_function(low_orig, up_orig, low, up)) |>
    arrange(vars, modele) %>% 
    filter(!is.na(low_orig) & !is.na(up_orig)) %>% 
    group_by(modele) %>% 
    mutate(num = 1:n()) %>% 
    group_by(vars) %>% 
    mutate(num = num + seq(-0.05*(nb_modeles-1),0.05*(nb_modeles-1), 0.1)) %>%
    ungroup()
}

#' Construit un graphique permettant de superposer les intervalles
#' de confiance des coefficients de régression d'un même modèle 
#' tourné sur des données différentes (par exemple originales vs swappées)
#'
#' @param all_cios résultat retourné par get_all_confints
#' @param titre titre du graphique
#' @param sous_titre sous-titre du graphique
#'
#' @returns graphique ggplot2
#' @export
#'
#' @examples
#' m1 <- glm(IS_CHOM ~ SEXE + AGE6 + DIP7, data = lfs_2023)
#' m2 <- glm(IS_CHOM ~ SEXE + AGE6 + DIP7, data = lfs_2023)
#' 
#' all_cios <- get_all_confints(list("original" = m1, "swapped" = m2))
#' head(all_cios)
#' 
#' graph_cios(all_cios) +
#'   theme(axis.text.y =  element_text(size = 8)) 
graph_cios <- function(all_cios, titre = "", sous_titre = ""){
  require(ggplot2)
  lab_vars <- sort(unique(all_cios$vars))
  min_lb <- round(min(all_cios$low),2)
  max_ub <- round(max(all_cios$up),2)
  breaks_y = seq(max(0,min_lb-0.05), max_ub+0.05,length.out=5)
  
  all_cios %>% 
    ggplot() +
    geom_segment( aes(x=num, xend=num, y=low, yend=up, color = modele)) +
    geom_point( aes(x=num, y=low, color = modele), size=1.5 ) +
    geom_point( aes(x=num, y=up, color = modele), size=1.5 ) +
    coord_flip()+
    geom_hline(yintercept = 1, linetype = "dashed", color = "grey25") +
    scale_color_brewer(type = "qual", palette = 2) +
    scale_x_continuous(breaks = seq_along(lab_vars), labels = lab_vars) +
    scale_y_continuous(breaks = breaks_y, 
                       limits = c(max(0,min_lb-0.05),max_ub+0.05), 
                       expand = c(0,0)) +
    theme_minimal(base_size = 14) +
    guides(color = guide_legend("Données")) +
    theme(
      axis.line = element_line(linewidth = 0.45, colour = "grey5"),
      legend.position = "bottom",
      # legend.position.inside = c(0.85,0.2),
      legend.background = element_rect(fill = "white"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(linewidth = 0.5)
    ) +
    xlab("") +
    ylab("Odds Ratio") +
    ggtitle(label = titre, subtitle = sous_titre)
  
}
