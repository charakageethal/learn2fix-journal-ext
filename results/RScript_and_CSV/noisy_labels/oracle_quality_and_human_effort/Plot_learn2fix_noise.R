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

oracle_quality = data.frame("subject"=character(), "noise_level"=character(), "category"=character(),
                            "variable"=character(),  "value" = numeric())
human_effort = data.frame("subject"=character(), "noise_level"=character(),
                          "variable"=character(),  "value" = numeric())
human_effort2 = data.frame("subject"=character(), "noise_level"=character(),
                          "variable"=character(),  "value" = numeric())
human_effort3 = data.frame("subject"=character(), "noise_level"=character(),
                          "variable"=character(),  "value" = numeric())





d = read.table("results_DCT.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="0%",
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="0%", 
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="0%",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,noise_level="0%",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="0%",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="0%",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="0%",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))

  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="0%",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="0%",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
}
d = read.table("results_dct_noise_5.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_noise_5")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_noise_5.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="5%",
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="5%", 
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="5%",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,noise_level="5%",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="5%",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="5%",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="5%",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="5%",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="5%",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
}



d = read.table("results_dct_noise_10.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_noise_10")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_noise_10.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="10%",
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="10%", 
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="10%",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,noise_level="10%",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="10%",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="10%",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="10%",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="10%",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="10%",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
}


d = read.table("results_dct_noise_20.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct_noise_20")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct_noise_20.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="20%",
                                                      category = "Accuracy", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, noise_level="20%", 
                                                      category = "Accuracy", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="20%",
                                                     category="Accuracy",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,noise_level="20%",
                                                    category="Accuracy",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,noise_level="20%",
                                                     category="Accuracy",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="20%",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,noise_level="20%",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="20%",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject, noise_level="20%",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
}




ggplot(oracle_quality, aes(noise_level, value)) +
  geom_boxplot(aes(fill= noise_level)) +
  facet_grid(~ variable)+
  scale_y_continuous(labels = scales::percent)+ xlab("Noise level") + ylab("Prediction Accuracy") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=7), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "oracle_quality_with_noise.pdf", width=9, height=4, scale=0.8)


ggplot(human_effort, aes(noise_level, value)) +
 geom_boxplot(aes(fill=noise_level)) + scale_y_continuous(labels =
 scales::percent) + facet_grid(~ variable) + xlab("Noise level")+
 ylab("Probability") + theme(legend.position="none", legend.title=
 element_blank(), axis.text.x = element_text(colour = "black",size=7), axis.text.y =
 element_text(colour = "black")) + scale_fill_grey(start = 0.6, end = .9)
 ggsave(filename = "human_effort_prob_with_noise.pdf",width=11,height=5.2,scale=0.5)


 ggplot(human_effort2, aes(noise_level, value)) +
   geom_boxplot(aes(fill=noise_level)) + scale_y_continuous(labels =
   scales::percent,limits=c(0,1)) + facet_grid(~ variable) + xlab("Noise level")+
   ylab("Proportion") + theme(legend.position="none", legend.title=
   element_blank(), axis.text.x = element_text(colour = "black",size=7), axis.text.y =
  element_text(colour = "black")) + scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "human_effort_prop_with_noise.pdf",width = 11,height=5.2,scale=0.5)

 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality,noise_level=="0%" & variable=="Overall")$value),median(subset(oracle_quality,noise_level=="0%" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality,noise_level=="0%" & variable=="Failing-Recall")$value),median(subset(oracle_quality,noise_level=="0%" & variable=="Failing-Recall")$value)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality,noise_level=="0%" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="0%" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality,noise_level=="0%" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="0%" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality,noise_level=="0%" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="0%" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality,noise_level=="5%" & variable=="Overall")$value),median(subset(oracle_quality,noise_level=="5%" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality,noise_level=="5%" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="5%" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality,noise_level=="5%" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="5%" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality,noise_level=="5%" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="5%" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality,noise_level=="5%" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="5%" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality,noise_level=="10%" & variable=="Overall")$value),median(subset(oracle_quality,noise_level=="10%" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality,noise_level=="10%" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="10%" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality,noise_level=="10%" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="10%" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality,noise_level=="10%" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="10%" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality,noise_level=="10%" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="10%" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy: ",mean(subset(oracle_quality,noise_level=="20%" & variable=="Overall")$value),median(subset(oracle_quality,noise_level=="20%" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall: ",mean(subset(oracle_quality,noise_level=="20%" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="20%" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision: ",mean(subset(oracle_quality,noise_level=="20%" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="20%" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall: ",mean(subset(oracle_quality,noise_level=="20%" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="20%" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision: ",mean(subset(oracle_quality,noise_level=="20%" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,noise_level=="20%" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 