# graph the mode elevation ~ wooddensity + riskratio
# Clear workspace
rm(list = ls())

# import prediction data frames 
source('./analysis/inundation_predicts_species_distributions/graph_code/prediction_dataframes.R')
load('./analysis/inundation_predicts_species_distributions/models/elevation_Vs_wooddensityN_diff_mortality.R')
load('./analysis/inundation_predicts_species_distributions/models/elevation_Vs_wooddensityN_diff_mortality_GLM.R')

# predict values first for riskratio
preds_wooddensity$elev <- predict(model2, newdata = preds_wooddensity, type = "response")
preds_wooddensity$CI025 <- preds_wooddensity$elev + predict(model2, 
                                                            newdata = preds_wooddensity, 
                                                            type = "response", 
                                                            se.fit = TRUE)$se.fit * -1.96

preds_wooddensity$CI975 <- preds_wooddensity$elev + predict(model2, 
                                                            newdata = preds_wooddensity, 
                                                            type = "response", 
                                                            se.fit = TRUE)$se.fit * 1.96

# calculating the partial residuals 
riskratio$partials_dd <- residuals(model2_glm, type = "partial")[, 1] + mean(riskratio$elev)

# lines to join the partials 
partial_lines_data <- data.frame(x = rep(riskratio$dden, 2), 
                                 y = c(riskratio$elev, riskratio$partials_dd))

# ANOVA type II to compare the variance 
var_res <- car::Anova(model2)[,1]
dd_explaied_variation <- paste('ANOVA:', round(var_res / sum(var_res) * 100, 1)[1], "%")

# jittering the species names 
vj <- rep(2.5, 16)
vj[which(riskratio$sp == 'Spar')] <- -5
vj[which(riskratio$sp == 'Smec')] <- -7
vj[which(riskratio$sp == 'Sfal')] <- 5
vj[which(riskratio$sp == 'Sxan')] <- 22
vj[which(riskratio$sp == 'Swal')] <- -5

#horazontal 
hj <- rep(0.01, 16)
hj[which(riskratio$sp == 'Spar')] <- -0.025
hj[which(riskratio$sp == 'Smec')] <- -0.02
hj[which(riskratio$sp == 'Slep')] <- 0.02
hj[which(riskratio$sp == 'Pmal')] <- -0.02
hj[which(riskratio$sp == 'Sacu')] <- -0.02
hj[which(riskratio$sp == 'Sgib')] <- -0.02
hj[which(riskratio$sp == 'Sbec')] <- 0.02
hj[which(riskratio$sp == 'Spau')] <- 0.02
hj[which(riskratio$sp == 'Sfal')] <- -0.02
hj[which(riskratio$sp == 'Dry')] <- 0.02
hj[which(riskratio$sp == 'Ssem')] <- -0.025
hj[which(riskratio$sp == 'Ptom')] <- -0.025

# plotting the data 
p1_wooddensity <- ggplot(preds_wooddensity, aes(x = dden, y = elev)) + 
  geom_line(data = partial_lines_data, aes(x = x, y = y, group = factor(x)), alpha = 0.3) + 
  geom_line() + 
  geom_ribbon(aes(ymin = CI025, ymax = CI975), alpha = 0.2) + 
  geom_point(data = riskratio, aes(y = partials_dd, x = dden),
             color = 'black', 
             pch = 21, 
             fill = 'grey', size = 3)  +
  theme_bw() +
  geom_point(data = riskratio, aes(y = elev, x = dden), color = 'red', alpha = 0.5) + 
  geom_text(aes(x = 0.4, y = 120, label = dd_explaied_variation), size = 5) + 
  ylab('E(elevation) m asl') + 
  xlab(expression("Wood density"~g~cm^-3)) + 
  ylim(40, 120) + 
  stat_smooth(data = riskratio, aes(x = dden, y = elev), 
              se = F, method = 'lm', color = 'red', 
              linetype = 2, size = 0.5) + 
  theme(text = element_text(size = 20)) + 
  geom_text(data = riskratio, aes(label = sp), 
            size = 5,
            nudge_y = vj, 
            nudge_x = hj, 
            fontface = 'italic')


# save(p1_wooddensity, file = './analysis/inundation_predicts_species_distributions/graph_code/graphs/elevation_VS_wooddensity.R')
# ggsave(p1, 
#        file = './analysis/inundation_predicts_species_distributions/graph_code/graphs/elevation_VS_wooddensity_C_inundation.png', 
#        width = 6, 
#        height = 6)

