knitr::opts_chunk$set(echo = TRUE)

library(ggplot2)
library(scales)
theme_set(theme_bw())

compute_mean = function(data, filename) {
  filename = paste(filename, ".Rda", sep="")
  
  # compute only once
  if(file.exists(filename)) {
    load(filename)
    return(mean_data)
  }
  
  mean_data = data.frame("subject"=character(), 
                         "totalgen"=numeric(),  "labelgen" = numeric(), 
                         "totalfail"=numeric(), "labelfail"= numeric(),
                         "vTotal"=numeric(),  "vCorrect" = numeric(), 
                         "vTotalfail"=numeric(), "vCorrectfail"= numeric(),"vInCorrectfail"=numeric(),
                         "vTotalPass"=numeric(),"vCorrectpass"=numeric(),"vInCorrectpass"=numeric())
  
  for (Subject in levels(factor(data$V1))){
    Runs = 0
    # Generation
    Totalgen = 0
    Labelgen = 0
    Totalfail = 0
    Labelfail = 0
    
    # Validation
    VTotal = 0
    VCorrect = 0
    VTotalfail = 0
    VTotalpass = 0
    VCorrectfail = 0
    VCorrectpass = 0
    VInCorrectfail = 0
    VInCorrectpass = 0
    
    
    for (Run in levels(factor(subset(data,V1 == Subject)$V2))) {
      run_specific = subset(data, V1 == Subject & V2 == Run)
      if (nrow(run_specific) != 0) {
        Runs = Runs + 1
        Totalgen = Totalgen + run_specific$V3
        Labelgen = Labelgen + run_specific$V4
        Totalfail = Totalfail + run_specific$V5
        Labelfail = Labelfail + run_specific$V6
        VTotal = VTotal + run_specific$V7
        VCorrect = VCorrect + run_specific$V8
        
        VTotalfail = VTotalfail + run_specific$V9
        VTotalpass = VTotalpass + (run_specific$V7-run_specific$V9)
        
        VCorrectfail = VCorrectfail + run_specific$V10
        VCorrectpass = VCorrectpass + (run_specific$V8-run_specific$V10)
        VInCorrectfail = VInCorrectfail + (run_specific$V9-run_specific$V10)
        VInCorrectpass = VInCorrectpass + ((run_specific$V7-run_specific$V9)-(run_specific$V8-run_specific$V10))
      }
    }
    mean_data <- rbind (mean_data,
                        data.frame(subject=Subject,
                                   totalgen = Totalgen / Runs,
                                   labelgen = Labelgen / Runs,
                                   totalfail = Totalfail / Runs,
                                   labelfail = Labelfail / Runs,
                                   vTotal = VTotal / Runs,
                                   vCorrect = VCorrect / Runs,
                                   vTotalfail = VTotalfail / Runs,
                                   vCorrectfail = VCorrectfail / Runs,
                                   vInCorrectfail = VInCorrectfail / Runs,
                                   vTotalpass = VTotalpass / Runs,
                                   vCorrectpass = VCorrectpass / Runs,
                                   vInCorrectpass = VInCorrectpass / Runs
                        ))
  }
  save(mean_data,file=filename)
  return(mean_data)
}

oracle_quality = data.frame("subject"=character(), "max_label"=character(), "category"=character(),
                            "variable"=character(),  "value" = numeric())
human_effort = data.frame("subject"=character(), "max_label"=character(), 
                          "variable"=character(),  "value" = numeric())
human_effort2 = data.frame("subject"=character(),"max_label"=character(),
                          "variable"=character(),  "value" = numeric())
human_effort3 = data.frame("subject"=character(), "max_label"=character(),
                          "variable"=character(),  "value" = numeric())


d = read.table("results_dct_5.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_5")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_5.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="5",
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="5",  
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="5",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="5",
                                                     category="Accuracy",variable="F-Score-Failing",
                                                     value=f_score_fail))
  
  
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,max_label="5",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,max_label="5",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="5",
                                                     category="Accuracy",variable="F-Score-Passing",
                                                     value=f_score_pass))
  
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="5",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="5",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="5",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="5",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}


d = read.table("results_dct_10.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_10")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_10.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="10",
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="10", 
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="10",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="10",
                                                     category="Accuracy",variable="F-Score-Failing",
                                                     value=f_score_fail))
  
  
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,max_label="10",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,max_label="10",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="10",
                                                     category="Accuracy",variable="F-Score-Passing",
                                                     value=f_score_pass))
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="10",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="10",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="10", 
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="10", 
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))

}


d = read.table("results_dct_20.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_20")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_20.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="20",
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="20",  
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="20",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="20",
                                                     category="Accuracy",variable="F-Score-Failing",
                                                     value=f_score_fail))
  
  
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,max_label="20",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,max_label="20",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="20",
                                                     category="Accuracy",variable="F-Score-Passing",
                                                     value=f_score_pass))
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="20",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="20",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="20", 
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="20", 
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}


d = read.table("results_dct_30.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_30")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_30.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="30", 
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="30",  
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="30",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,max_label="30",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,max_label="30",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="30",
                                                     category="Accuracy",variable="F-Score-Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="30",
                                                     category="Accuracy",variable="F-Score-Passing",
                                                     value=f_score_pass))
  
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="30",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="30",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="30", 
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="30", 
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))

  
}



d = read.table("results_dct_40.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_40")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_40.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="40", 
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="40",  
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="40",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,max_label="40",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,max_label="40",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="40",
                                                     category="Accuracy",variable="F-Score-Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="40",
                                                     category="Accuracy",variable="F-Score-Passing",
                                                     value=f_score_pass))
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="40",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="40",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="40", 
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="40", 
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}


d = read.table("results_dct_50.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_50")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_50.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="50", 
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, max_label="50",  
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="50",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,max_label="50",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,max_label="50",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="50",
                                                     category="Accuracy",variable="F-Score-Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject, max_label="50",
                                                     category="Accuracy",variable="F-Score-Passing",
                                                     value=f_score_pass))
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="50",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,max_label="50",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="50", 
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,max_label="50", 
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}



# ggplot(subset(oracle_quality,variable=="Overall"), aes(max_label, value)) +
#   geom_boxplot(aes(fill= max_label)) +
#   scale_y_continuous(labels = scales::percent)+ xlab("Max Labelling-Effort") + ylab("Overall Accuracy") +
#   theme(legend.position="none", legend.title= element_blank(),
#         axis.text.x = element_text(colour = "black",size=7), axis.text.y = element_text(colour = "black")) +
#   scale_fill_grey(start = 0.6, end = .9)
# ggsave(filename = "oracle_quality_overall.pdf", width=7, height=4, scale=0.8)
# 
# ggplot(subset(oracle_quality,variable=="Failing-Recall"), aes(max_label, value)) +
#   geom_boxplot(aes(fill= max_label)) +
#   scale_y_continuous(labels = scales::percent)+ xlab("Max Labelling-Effort") + ylab("Recall-Failing") +
#   theme(legend.position="none", legend.title= element_blank(),
#         axis.text.x = element_text(colour = "black",size=7), axis.text.y = element_text(colour = "black")) +
#   scale_fill_grey(start = 0.6, end = .9)
# ggsave(filename = "oracle_quality_failing-recall.pdf", width=7, height=4, scale=0.8)
# 
# ggplot(subset(oracle_quality,variable=="Failing-Precision"), aes(max_label, value)) +
#   geom_boxplot(aes(fill= max_label)) +
#   scale_y_continuous(labels = scales::percent)+ xlab("Max. Labelling-Effort") + ylab("Precision-Failing") +
#   theme(legend.position="none", legend.title= element_blank(),
#         axis.text.x = element_text(colour = "black",size=7), axis.text.y = element_text(colour = "black")) +
#   scale_fill_grey(start = 0.6, end = .9)
# ggsave(filename = "oracle_quality_failing-precision.pdf", width=7, height=4, scale=0.8)


ggplot(oracle_quality, aes(max_label, value)) +
  geom_boxplot(aes(fill= max_label)) +
  facet_grid(~ variable)+
  scale_y_continuous(labels = scales::percent)+ xlab("Max Labelling-Effort") + ylab("Prediction Accuracy") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=7), axis.text.y = element_text(colour = "black"), strip.text.x = element_text(colour = "black",size=7)) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "oracle_quality_vs_human_effort.pdf", width=9, height=4, scale=0.8)

ggplot(human_effort, aes(max_label, value)) +
 geom_boxplot(aes(fill=max_label)) + scale_y_continuous(labels =
 scales::percent) + facet_grid(~ variable) + xlab("Max Labelling-Effort")+
 ylab("Probability") + theme(legend.position="none", legend.title=
 element_blank(), axis.text.x = element_text(colour = "black",size=7), axis.text.y =
 element_text(colour = "black")) + scale_fill_grey(start = 0.6, end = .9)
 ggsave(filename = "dct_effort1.pdf",width=11,height=5.2,scale=0.5)
 
 ggplot(human_effort2, aes(max_label, value)) +
   geom_boxplot(aes(fill=max_label)) + scale_y_continuous(labels =
  scales::percent,limits = c(0,1)) + facet_grid(~ variable) + xlab("Max Labelling-Effort")+
   ylab("Proportion") + theme(legend.position="none", legend.title=
                                 element_blank(), axis.text.x = element_text(colour = "black",size=7), axis.text.y =
                                 element_text(colour = "black")) + scale_fill_grey(start = 0.6, end = .9)
 ggsave(filename = "dct_effort2.pdf",width=11,height=5.2,scale=0.5)
 

# 
#  ggplot(human_effort2, aes(classifier, value)) +
#    geom_boxplot(aes(fill=classifier)) + scale_y_continuous(labels =
#    scales::percent) + facet_grid(~ variable) + xlab("")+
#    ylab("Proportion") + theme(legend.position="none", legend.title=
#    element_blank(), axis.text.x = element_text(colour = "black",size=7), axis.text.y =
#   element_text(colour = "black")) + scale_fill_grey(start = 0.6, end = .9)
#  ggsave(filename = "dct_effort2.pdf",width = 11,height=5.2,scale=0.5)
# 
#  

 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality,variable=="Overall" & max_label=="5")$value),median(subset(oracle_quality,variable=="Overall" & max_label=="5")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality, variable=="Failing-Recall" & max_label=="5")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Recall" & max_label=="5")$value,na.rm=TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality, variable=="Failing-Precision" & max_label=="5")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Precision" & max_label=="5")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality, variable=="Passing-Recall" & max_label=="5")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Recall" & max_label=="5")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality, variable=="Passing-Precision" & max_label=="5")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Precision" & max_label=="5")$value,na.rm = TRUE))) 
 
print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality, variable=="Overall" & max_label=="10")$value),median(subset(oracle_quality, variable=="Overall" & max_label=="10")$value)))
print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality, variable=="Failing-Recall" & max_label=="10")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Recall" & max_label=="10")$value,na.rm=TRUE)))
print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality, variable=="Failing-Precision" & max_label=="10")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Precision" & max_label=="10")$value,na.rm = TRUE)))
print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality, variable=="Passing-Recall" & max_label=="10")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Recall" & max_label=="10")$value,na.rm = TRUE)))
print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality, variable=="Passing-Precision" & max_label=="10")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Precision" & max_label=="10")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality, variable=="Overall" & max_label=="20")$value),median(subset(oracle_quality, variable=="Overall" & max_label=="20")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality, variable=="Failing-Recall" & max_label=="20")$value,na.rm=TRUE),median(subset(oracle_quality, variable=="Failing-Recall" & max_label=="20")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality, variable=="Failing-Precision" & max_label=="20")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Precision" & max_label=="20")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality, variable=="Passing-Recall" & max_label=="20")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Recall" & max_label=="20")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality, variable=="Passing-Precision" & max_label=="20")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Precision" & max_label=="20")$value,na.rm = TRUE)))
 
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality, variable=="Overall" & max_label=="30")$value),median(subset(oracle_quality, variable=="Overall" & max_label=="30")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality, variable=="Failing-Recall" & max_label=="30")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Recall" & max_label=="30")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality, variable=="Failing-Precision" & max_label=="30")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Precision" & max_label=="30")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality, variable=="Passing-Recall" & max_label=="30")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Recall" & max_label=="30")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality, variable=="Passing-Precision" & max_label=="30")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Precision" & max_label=="30")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality, variable=="Overall" & max_label=="40")$value),median(subset(oracle_quality, variable=="Overall" & max_label=="40")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality, variable=="Failing-Recall" & max_label=="40")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Recall" & max_label=="40")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality, variable=="Failing-Precision" & max_label=="40")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Precision" & max_label=="40")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality, variable=="Passing-Recall" & max_label=="40")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Recall" & max_label=="40")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality, variable=="Passing-Precision" & max_label=="40")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Precision" & max_label=="40")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality, variable=="Overall" & max_label=="50")$value),median(subset(oracle_quality, variable=="Overall" & max_label=="50")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality, variable=="Failing-Recall" & max_label=="50")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Recall" & max_label=="50")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality, variable=="Failing-Precision" & max_label=="50")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Precision" & max_label=="50")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality, variable=="Passing-Recall" & max_label=="50")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Recall" & max_label=="50")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality, variable=="Passing-Precision" & max_label=="50")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Passing-Precision" & max_label=="50")$value,na.rm = TRUE)))
 
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality, variable=="Overall" & max_label=="50")$value),median(subset(oracle_quality, variable=="Overall" & max_label=="50")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality, variable=="Failing-Recall" & max_label=="50")$value,na.rm = TRUE),median(subset(oracle_quality, variable=="Failing-Recall" & max_label=="50")$value,na.rm = TRUE)))
 
 
 print(paste("Average/Median prob(30): ",mean(subset(human_effort, variable=="Prob. to label a failing test" & max_label=="30")$value,na.rm = TRUE),median(subset(human_effort, variable=="Prob. to label a failing test" & max_label=="30")$value,na.rm = TRUE)))
 print(paste("Average/Median prob(40): ",mean(subset(human_effort, variable=="Prob. to label a failing test" & max_label=="40")$value,na.rm = TRUE),median(subset(human_effort, variable=="Prob. to label a failing test" & max_label=="40")$value,na.rm = TRUE)))
 
 print("SIGNIFICANCE TEST (Overall accuracy)")
 
 subjects_5=levels(factor(subset(oracle_quality, variable=="Overall"  & is.na(value)==FALSE & max_label=="5")$subject))
 subjects_10=levels(factor(subset(oracle_quality, variable=="Overall" & is.na(value)==FALSE & max_label=="10")$subject))
 subjects_20=levels(factor(subset(oracle_quality, variable=="Overall" & is.na(value)==FALSE & max_label=="20")$subject))
 subjects_30=levels(factor(subset(oracle_quality, variable=="Overall" & is.na(value)==FALSE & max_label=="30")$subject))
 subjects_40=levels(factor(subset(oracle_quality, variable=="Overall" & is.na(value)==FALSE & max_label=="40")$subject))
 print(nrow(subjects_5))
 
 print(nrow(subset(oracle_quality, variable=="Overall" & max_label=="5" & is.na(value)==FALSE & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))))
 
 
 print("One-sided paired Wilcoxon test (-l 5 vs -l 10)")
 print(wilcox.test(subset(oracle_quality, variable=="Overall" & max_label=="5" & is.na(value)==FALSE & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   subset(oracle_quality, variable=="Overall" & max_label=="10" & is.na(value)==FALSE  & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   paired=FALSE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 10 vs -l 20)")
 print(wilcox.test(subset(oracle_quality, variable=="Overall" & max_label=="10" & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   subset(oracle_quality, variable=="Overall" & max_label=="20" & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 20 vs -l 30)")
 print(wilcox.test(subset(oracle_quality, variable=="Overall" & max_label=="20" & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   subset(oracle_quality, variable=="Overall" & max_label=="30" & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 30 vs -l 40)")
 print(wilcox.test(subset(oracle_quality, variable=="Overall" & max_label=="30" & subject %in% intersect(subjects_30,subjects_40))$value,
                   subset(oracle_quality, variable=="Overall" & max_label=="40" & subject %in% intersect(subjects_30,subjects_40))$value,
                   paired=TRUE,alternative="less"))
 
 
 print("SIGNIFICANCE TEST (Failing-Recall)")
 
 subjects_5=levels(factor(subset(oracle_quality, variable=="Failing-Recall"  & max_label=="5")$subject))
 subjects_10=levels(factor(subset(oracle_quality, variable=="Failing-Recall"  & max_label=="10")$subject))
 subjects_20=levels(factor(subset(oracle_quality, variable=="Failing-Recall"  & max_label=="20")$subject))
 subjects_30=levels(factor(subset(oracle_quality, variable=="Failing-Recall"  & max_label=="30")$subject))
 subjects_40=levels(factor(subset(oracle_quality, variable=="Failing-Recall"  & max_label=="40")$subject))
 subjects_50=levels(factor(subset(oracle_quality, variable=="Failing-Recall" & max_label=="50")$subject))
 
print(nrow(subset(oracle_quality, variable=="Failing-Recall" & max_label=="20" & subject %in% intersect(subjects_10,subjects_20))))


 
 print("One-sided paired Wilcoxon test (-l 5 vs -l 10)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Recall" & max_label=="5" & is.na(value)==FALSE & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   subset(oracle_quality, variable=="Failing-Recall" & max_label=="10" & is.na(value)==FALSE & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   paired=TRUE,alternative="greater"))
 
 print("One-sided paired Wilcoxon test (-l 10 vs -l 20)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Recall" & max_label=="10" & subject %in% intersect(subjects_10,subjects_20))$value,
                   subset(oracle_quality, variable=="Failing-Recall" & max_label=="20" & subject %in% intersect(subjects_10,subjects_20))$value,
                   paired=TRUE,alternative="greater"))
 
 print("One-sided paired Wilcoxon test (-l 20 vs -l 30)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Recall" & max_label=="20" & subject %in% intersect(subjects_20,subjects_30))$value,
                   subset(oracle_quality, variable=="Failing-Recall" & max_label=="30" & subject %in% intersect(subjects_20,subjects_30))$value,
                   paired=TRUE,alternative="two.sided"))
 
 print("One-sided paired Wilcoxon test (-l 30 vs -l 40)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Recall" & max_label=="30" & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   subset(oracle_quality, variable=="Failing-Recall" & max_label=="40" & subject %in% Reduce(intersect,list(subjects_5,subjects_10,subjects_20,subjects_30,subjects_40)))$value,
                   paired=TRUE,alternative="greater"))
 
 print("SIGNIFICANCE TEST (Failing-Precision)")
 
 subjects_5=levels(factor(subset(oracle_quality, variable=="Failing-Precision" & max_label=="5")$subject))
 subjects_10=levels(factor(subset(oracle_quality, variable=="Failing-Precision" & max_label=="10")$subject))
 subjects_20=levels(factor(subset(oracle_quality, variable=="Failing-Precision" & max_label=="20")$subject))
 subjects_30=levels(factor(subset(oracle_quality, variable=="Failing-Precision" & max_label=="30")$subject))
 subjects_40=levels(factor(subset(oracle_quality, variable=="Failing-Precision" & max_label=="40")$subject))
 
 
 print("One-sided paired Wilcoxon test (-l 5 vs -l 10)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Precision" & max_label=="5" & subject %in% intersect(subjects_5,subjects_10))$value,
                   subset(oracle_quality, variable=="Failing-Precision" & max_label=="10" & subject %in% intersect(subjects_5,subjects_10))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 10 vs -l 20)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Precision" & max_label=="10" & subject %in% intersect(subjects_10,subjects_20))$value,
                   subset(oracle_quality, variable=="Failing-Precision" & max_label=="20" & subject %in% intersect(subjects_10,subjects_20))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 20 vs -l 30)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Precision" & max_label=="20" & subject %in% intersect(subjects_20,subjects_30))$value,
                   subset(oracle_quality, variable=="Failing-Precision" & max_label=="30" & subject %in% intersect(subjects_20,subjects_30))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 30 vs -l 40)")
 print(wilcox.test(subset(oracle_quality, variable=="Failing-Precision" & max_label=="30" & subject %in% intersect(subjects_30,subjects_40))$value,
                   subset(oracle_quality, variable=="Failing-Precision" & max_label=="40" & subject %in% intersect(subjects_30,subjects_40))$value,
                   paired=TRUE,alternative="less"))
 
 
 print("SIGNIFICANCE TEST (Passing-Recall)")
 
 subjects_5=levels(factor(subset(oracle_quality, variable=="Passing-Recall" & max_label=="5")$subject))
 subjects_10=levels(factor(subset(oracle_quality, variable=="Passing-Recall" & max_label=="10")$subject))
 subjects_20=levels(factor(subset(oracle_quality, variable=="Passing-Recall" & max_label=="20")$subject))
 subjects_30=levels(factor(subset(oracle_quality, variable=="Passing-Recall" & max_label=="30")$subject))
 subjects_40=levels(factor(subset(oracle_quality, variable=="Passing-Recall" & max_label=="40")$subject))
 
 
 print("One-sided paired Wilcoxon test (-l 5 vs -l 10)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Recall" & max_label=="5" & subject %in% intersect(subjects_5,subjects_10))$value,
                   subset(oracle_quality, variable=="Passing-Recall" & max_label=="10" & subject %in% intersect(subjects_5,subjects_10))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 10 vs -l 20)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Recall" & max_label=="10" & subject %in% intersect(subjects_10,subjects_20))$value,
                   subset(oracle_quality, variable=="Passing-Recall" & max_label=="20" & subject %in% intersect(subjects_10,subjects_20))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 20 vs -l 30)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Recall" & max_label=="20" & subject %in% intersect(subjects_20,subjects_30))$value,
                   subset(oracle_quality, variable=="Passing-Recall" & max_label=="30" & subject %in% intersect(subjects_20,subjects_30))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 30 vs -l 40)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Recall" & max_label=="30" & subject %in% intersect(subjects_30,subjects_40))$value,
                   subset(oracle_quality, variable=="Passing-Recall" & max_label=="40" & subject %in% intersect(subjects_30,subjects_40))$value,
                   paired=TRUE,alternative="less"))
 
 print("SIGNIFICANCE TEST (Passing-Precision)")
 
 subjects_5=levels(factor(subset(oracle_quality, variable=="Passing-Precision" & max_label=="5")$subject))
 subjects_10=levels(factor(subset(oracle_quality, variable=="Passing-Precision" & max_label=="10")$subject))
 subjects_20=levels(factor(subset(oracle_quality, variable=="Passing-Precision" & max_label=="20")$subject))
 subjects_30=levels(factor(subset(oracle_quality, variable=="Passing-Precision" & max_label=="30")$subject))
 subjects_40=levels(factor(subset(oracle_quality, variable=="Passing-Precision" & max_label=="40")$subject))
 
 
 print("One-sided paired Wilcoxon test (-l 5 vs -l 10)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Precision" & max_label=="5" & subject %in% intersect(subjects_5,subjects_10))$value,
                   subset(oracle_quality, variable=="Passing-Precision" & max_label=="10" & subject %in% intersect(subjects_5,subjects_10))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 10 vs -l 20)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Precision" & max_label=="10" & subject %in% intersect(subjects_10,subjects_20))$value,
                   subset(oracle_quality, variable=="Passing-Precision" & max_label=="20" & subject %in% intersect(subjects_10,subjects_20))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 20 vs -l 30)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Precision" & max_label=="20" & subject %in% intersect(subjects_20,subjects_30))$value,
                   subset(oracle_quality, variable=="Passing-Precision" & max_label=="30" & subject %in% intersect(subjects_20,subjects_30))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 30 vs -l 40)")
 print(wilcox.test(subset(oracle_quality, variable=="Passing-Precision" & max_label=="30" & subject %in% intersect(subjects_30,subjects_40))$value,
                   subset(oracle_quality, variable=="Passing-Precision" & max_label=="40" & subject %in% intersect(subjects_30,subjects_40))$value,
                   paired=TRUE,alternative="less"))
 
 print("SIGNIFICANCE TEST Human Effort 2")
 subjects_5=levels(factor(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="5")$subject))
 subjects_10=levels(factor(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="10")$subject))
 subjects_20=levels(factor(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="20")$subject))
 subjects_30=levels(factor(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="30")$subject))
 subjects_40=levels(factor(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="40")$subject))
 subjects_50=levels(factor(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="50")$subject))
 
 
 print("One-sided paired Wilcoxon test (-l 40 vs -l 50)")
 print(wilcox.test(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="40" & subject %in% intersect(subjects_40,subjects_50))$value,
                   subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="50" & subject %in% intersect(subjects_40,subjects_50))$value,
                   paired=TRUE,alternative="less"))
 
 print("One-sided paired Wilcoxon test (-l 30 vs -l 40)")
 print(wilcox.test(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="30" & subject %in% intersect(subjects_30,subjects_40))$value,
                   subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="40" & subject %in% intersect(subjects_30,subjects_40))$value,
                   paired=TRUE,alternative="less"))
 
 
 print("One-sided paired Wilcoxon test (-l 20 vs -l 30)")
 print(wilcox.test(subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="20" & subject %in% intersect(subjects_30,subjects_20))$value,
                   subset(human_effort2, variable=="%Failing tests that are labeled" & max_label=="30" & subject %in% intersect(subjects_30,subjects_20))$value,
                   paired=TRUE,alternative="greater"))
 
 
 
 print("SIGNIFICANCE TEST (F-Score-Failing)")
 
 subjects_5=levels(factor(subset(oracle_quality, variable=="F-Score-Failing" & max_label=="5")$subject))
 subjects_10=levels(factor(subset(oracle_quality, variable=="F-Score-Failing" & max_label=="10")$subject))
 subjects_20=levels(factor(subset(oracle_quality, variable=="F-Score-Failing" & max_label=="20")$subject))
 subjects_30=levels(factor(subset(oracle_quality, variable=="F-Score-Failing" & max_label=="30")$subject))
 subjects_40=levels(factor(subset(oracle_quality, variable=="F-Score-Failing" & max_label=="40")$subject))
 subjects_50=levels(factor(subset(oracle_quality, variable=="F-Score-Failing" & max_label=="50")$subject))
 
 
 print("One-sided paired Wilcoxon test (-l 40 vs -l 50)")
 print(wilcox.test(subset(oracle_quality, variable=="F-Score-Failing" & max_label=="40" & subject %in% intersect(subjects_40,subjects_50))$value,
                   subset(oracle_quality, variable=="F-Score-Failing" & max_label=="50" & subject %in% intersect(subjects_40,subjects_50))$value,
                   paired=TRUE,alternative="less"))
 