
#' Compare le risque de ré-identification des individus 
#' pour différents types de scénarios
#'
#' @param data data.frame, jeu de données individuelles
#' @param list_scenarios liste de character vectors, chaque vecteur 
#' désignant les variables quasi-identifiantes du scénario
#'
#' @returns
#'
#' @examples
comparer_risque_reidentification <- function(data, list_scenarios){
  require(dplyr)
  require(purrr)
  require(tidyr)
  
  r_keys <- imap(
    list_scenarios,
    \(vs,sc){
      data |> count(across(all_of(vs))) |> mutate(p = 1/n, scenario = sc)
    }
  ) |>
    list_rbind() |>
    mutate(p_cl = cut(p, 
                      breaks = c(0,0.1,0.25,0.34,0.5,1),
                      ordered_result = TRUE)
    )
  
  r_stats <- r_keys |>
    group_by(scenario) |>
    summarise(
      across(p, list(moy = mean,
                     d1 = ~quantile(., probs = 0.1),
                     med = median,
                     d9 = ~quantile(., probs = 0.9))
      ),
      part_uniques = sum(n == 1)/sum(n) * 100
    )
  
  r_graph_probas <- r_keys |>
    count(scenario, p_cl, wt = n)|>
    pivot_wider(names_from = p_cl, values_from = n, values_fill = 0) |>
    pivot_longer(-scenario, names_to = "p_cl", values_to = "n")
  
  return(list(r_keys = r_keys, r_stats = r_stats, r_graph = r_graph_probas))
}
