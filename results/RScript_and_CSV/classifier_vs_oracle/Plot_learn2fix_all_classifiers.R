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

oracle_quality = data.frame("subject"=character(), "classifier"=character(), "category"=character(),
                            "variable"=character(),  "value" = numeric())
human_effort = data.frame("subject"=character(), "classifier"=character(),
                          "variable"=character(),  "value" = numeric())
human_effort2 = data.frame("subject"=character(), "classifier"=character(),
                          "variable"=character(),  "value" = numeric())
human_effort3 = data.frame("subject"=character(), "classifier"=character(),
                          "variable"=character(),  "value" = numeric())


d = read.table("results_INCAL.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_incal")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_incal.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="INCAL",
                                                      category = "Interpolation based", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="INCAL", 
                                                      category = "Interpolation based", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="INCAL",
                                                     category="Interpolation based",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,classifier="INCAL",
                                                    category="Interpolation based",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="INCAL",
                                                     category="Interpolation based",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="INCAL",
                                                     category="Interpolation based",variable="F-Score_Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="INCAL",
                                                     category="Interpolation based",variable="F-Score_Passing",
                                                     value=f_score_pass))
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="INCAL",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="INCAL",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="INCAL",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="INCAL",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}



d = read.table("results_DCT.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="DT",
                                                      category = "Interpolation based", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="DT", 
                                                      category = "Interpolation based", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="DT",
                                                     category="Interpolation based",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,classifier="DT",
                                                    category="Interpolation based",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="DT",
                                                     category="Interpolation based",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="DT",
                                                     category="Interpolation based",variable="F-Score_Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="DT",
                                                     category="Interpolation based",variable="F-Score_Passing",
                                                     value=f_score_pass))
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="DT",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="DT",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="DT",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="DT",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}

d = read.table("results_ADB.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_adb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_adb.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="ADB",
                                                      category = "Interpolation based", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="ADB", 
                                                      category = "Interpolation based", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="ADB",
                                                     category="Interpolation based",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,classifier="ADB",
                                                    category="Interpolation based",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="ADB",
                                                     category="Interpolation based",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="ADB",
                                                     category="Interpolation based",variable="F-Score_Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="ADB",
                                                     category="Interpolation based",variable="F-Score_Passing",
                                                     value=f_score_pass))
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="ADB",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="ADB",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="ADB",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="ADB",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}


d = read.table("results_SVM.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_svm")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_svm.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="SVM",
                                                      category = "Approximation based", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="SVM", 
                                                      category = "Approximation based", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="SVM",
                                                     category="Approximation based",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,classifier="SVM",
                                                    category="Approximation based",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="SVM",
                                                     category="Approximation based",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="SVM",
                                                     category="Approximation based",variable="F-Score_Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="SVM",
                                                     category="Approximation based",variable="F-Score_Passing",
                                                     value=f_score_pass))
  
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="SVM",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="SVM",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="SVM",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="SVM",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))

  
}


d = read.table("results_NB.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_nb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_nb.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="NB",
                                                      category = "Approximation based", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="NB", 
                                                      category = "Approximation based", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="NB",
                                                     category="Approximation based",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,classifier="NB",
                                                    category="Approximation based",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="NB",
                                                     category="Approximation based",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="NB",
                                                     category="Approximation based",variable="F-Score_Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="NB",
                                                     category="Approximation based",variable="F-Score_Passing",
                                                     value=f_score_pass))
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="NB",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="NB",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="NB",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="NB",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
  
}

d = read.table("results_MLP(20).csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_mlp_20")

validation=data.frame("subject"=character(),category=character(),variable=character(),number=integer())
validation2=data.frame("subject"=character(),category=character(),variable=character(),number=integer())

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_mlp_20.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="MLP(20)",
                                                      category = "Approximation based", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="MLP(20)", 
                                                      category = "Approximation based", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20)",
                                                     category="Approximation based",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,classifier="MLP(20)",
                                                    category="Approximation based",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20)",
                                                     category="Approximation based",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  validation <- rbind(validation,data.frame(subject=Subject,category="Manually Constructed Tests",variable="Total Tests",number=specific$vTotal))
  
  validation <- rbind(validation,data.frame(subject=Subject,category="Manually Constructed Tests",variable="Passing Tests",number=specific$vTotal - specific$vTotalfail))
  
  validation <- rbind(validation,data.frame(subject=Subject,category="Manually Constructed Tests",variable="Failing Tests",number=specific$vTotalfail))
  
  validation2 <-rbind(validation2,data.frame(subject = Subject, category = "Fail. Rate", 
                                             variable = "%Failing", 
                                             number = specific$vTotalfail / specific$vTotal))
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20)",
                                                     category="Approximation based",variable="F-Score_Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20)",
                                                     category="Approximation based",variable="F-Score_Passing",
                                                     value=f_score_pass))
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="MLP(20)",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="MLP(20)",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="MLP(20)",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="MLP(20)",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))

  
}

d = read.table("results_MLP(20,5).csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_mlp_20_5")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_mlp_20_5.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="MLP(20,5)",
                                                      category = "Approximation based", variable = "Overall", 
                                                      value = specific$vCorrect / specific$vTotal))
  oracle_quality <- rbind (oracle_quality, data.frame(subject = Subject, classifier="MLP(20,5)", 
                                                      category = "Approximation based", variable = "Failing-Recall", 
                                                      value = specific$vCorrectfail / specific$vTotalfail))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20,5)",
                                                     category="Approximation based",variable="Failing-Precision",
                                                     value=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)))
  oracle_quality <- rbind(oracle_quality,data.frame(subject=Subject,classifier="MLP(20,5)",
                                                    category="Approximation based",variable="Passing-Recall",
                                                    value=specific$vCorrectpass/specific$vTotalpass))
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20,5)",
                                                     category="Approximation based",variable="Passing-Precision",
                                                     value=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)))
  
  recall_fail=specific$vCorrectfail / specific$vTotalfail
  precision_fail=specific$vCorrectfail/(specific$vCorrectfail+specific$vInCorrectpass)
  f_score_fail=(2*recall_fail*precision_fail)/(recall_fail+precision_fail)
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20,5)",
                                                     category="Approximation based",variable="F-Score_Failing",
                                                     value=f_score_fail))
  
  recall_pass=specific$vCorrectpass/specific$vTotalpass
  precision_pass=specific$vCorrectpass/(specific$vCorrectpass+specific$vInCorrectfail)
  f_score_pass=(2*recall_pass*precision_pass)/(recall_pass+precision_pass)
  
  
  oracle_quality <- rbind (oracle_quality,data.frame(subject=Subject,classifier="MLP(20,5)",
                                                     category="Approximation based",variable="F-Score_Passing",
                                                     value=f_score_pass))
  
  
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="MLP(20,5)",variable="Prob. to generate a failing test",
                                                value=specific$totalfail/specific$totalgen))
  human_effort <- rbind(human_effort,data.frame(subject=Subject,classifier="MLP(20,5)",variable="Prob. to label a failing test",
                                                value=specific$labelfail/specific$labelgen))
  
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="MLP(20,5)",
                                                    variable = "%Generated tests that are labeled",
                                                    value = specific$labelgen/specific$totalgen))
  human_effort2 <- rbind (human_effort2, data.frame(subject = Subject,classifier="MLP(20,5)",
                                                    variable = "%Failing tests that are labeled",
                                                    value = specific$labelfail/ specific$totalfail))
 
}


print(wilcox.test(subset(oracle_quality,classifier=="DT" & variable=="Overall")$value,subset(oracle_quality,classifier=="ADB" & variable=="Overall")$value,alternative="two.sided"))
print(wilcox.test(subset(oracle_quality,classifier=="DT" & variable=="Failing-Recall")$value,subset(oracle_quality,classifier=="ADB" & variable=="Failing-Recall")$value,alternative="two.sided"))


print(wilcox.test(subset(oracle_quality,classifier=="DT" & variable=="Failing-Precision")$value,subset(oracle_quality,classifier=="INCAL" & variable=="Failing-Precision")$value,alternative="greater"))



ggplot(subset(oracle_quality,variable=="Overall"), aes(classifier, value)) +
  geom_boxplot(aes(fill= variable)) +
  scale_y_continuous(labels = scales::percent)+ xlab("Classification Algorithm") + ylab("Overall Accuracy") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=5), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "oracle_quality_overall.pdf", width=7, height=4, scale=0.8)

print(paste("Average/Median Accuracy (INCAL): ",mean(subset(oracle_quality,classifier=="INCAL" & variable=="Overall")$value),median(subset(oracle_quality,classifier=="INCAL" & variable=="Overall")$value)))
print(paste("Average/Median Failing-Recall (INCAL): ",mean(subset(oracle_quality,classifier=="INCAL" & variable=="Failing-Recall")$value),median(subset(oracle_quality,classifier=="INCAL" & variable=="Failing-Recall")$value)))
print(paste("Average/Median Failing-Precision (INCAL): ",mean(subset(oracle_quality,classifier=="INCAL" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="INCAL" & variable=="Failing-Precision")$value,na.rm = TRUE)))
print(paste("Average/Median Passing-Recall (INCAL): ",mean(subset(oracle_quality,classifier=="INCAL" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="INCAL" & variable=="Passing-Recall")$value,na.rm = TRUE)))
print(paste("Average/Median Passing-Precision (INCAL): ",mean(subset(oracle_quality,classifier=="INCAL" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="INCAL" & variable=="Passing-Precision")$value,na.rm = TRUE)))

 print(paste("Average/Median Accuracy (DT): ",mean(subset(oracle_quality,classifier=="DT" & variable=="Overall")$value),median(subset(oracle_quality,classifier=="DT" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall (DT): ",mean(subset(oracle_quality,classifier=="DT" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="DT" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision (DT): ",mean(subset(oracle_quality,classifier=="DT" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="DT" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall (DT): ",mean(subset(oracle_quality,classifier=="DT" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="DT" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision (DT): ",mean(subset(oracle_quality,classifier=="DT" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="DT" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy (ADB): ",mean(subset(oracle_quality,classifier=="ADB" & variable=="Overall")$value),median(subset(oracle_quality,classifier=="ADB" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall (ADB): ",mean(subset(oracle_quality,classifier=="ADB" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="ADB" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision (ADB): ",mean(subset(oracle_quality,classifier=="ADB" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="ADB" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall (ADB): ",mean(subset(oracle_quality,classifier=="ADB" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="ADB" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision (ADB): ",mean(subset(oracle_quality,classifier=="ADB" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="ADB" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy (SVM): ",mean(subset(oracle_quality,classifier=="SVM" & variable=="Overall")$value),median(subset(oracle_quality,classifier=="SVM" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall (SVM): ",mean(subset(oracle_quality,classifier=="SVM" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="SVM" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision (SVM): ",mean(subset(oracle_quality,classifier=="SVM" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="SVM" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall (SVM): ",mean(subset(oracle_quality,classifier=="SVM" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="SVM" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision (SVM): ",mean(subset(oracle_quality,classifier=="SVM" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="SVM" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy (NB): ",mean(subset(oracle_quality,classifier=="NB" & variable=="Overall")$value),median(subset(oracle_quality,classifier=="NB" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall (NB): ",mean(subset(oracle_quality,classifier=="NB" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="NB" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision (NB): ",mean(subset(oracle_quality,classifier=="NB" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="NB" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall (NB): ",mean(subset(oracle_quality,classifier=="NB" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="NB" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision (NB): ",mean(subset(oracle_quality,classifier=="NB" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="NB" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy (MLP(20)): ",mean(subset(oracle_quality,classifier=="MLP(20)" & variable=="Overall")$value),median(subset(oracle_quality,classifier=="MLP(20)" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall (MLP(20)): ",mean(subset(oracle_quality,classifier=="MLP(20)" & variable=="Failing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20)" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision (MLP(20)): ",mean(subset(oracle_quality,classifier=="MLP(20)" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20)" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall (MLP(20)): ",mean(subset(oracle_quality,classifier=="MLP(20)" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20)" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision (MLP(20)): ",mean(subset(oracle_quality,classifier=="MLP(20)" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20)" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 
 print(paste("Average/Median Accuracy (MLP(20,5)): ",mean(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Overall")$value),median(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Overall")$value)))
 print(paste("Average/Median Failing-Recall (MLP(20,5)): ",mean(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Failing-Recall",n)$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Failing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Failing-Precision (MLP(20,5)): ",mean(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Failing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Failing-Precision")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Recall (MLP(20,5)): ",mean(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Passing-Recall")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Passing-Recall")$value,na.rm = TRUE)))
 print(paste("Average/Median Passing-Precision (MLP(20,5)): ",mean(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Passing-Precision")$value,na.rm = TRUE),median(subset(oracle_quality,classifier=="MLP(20,5)" & variable=="Passing-Precision")$value,na.rm = TRUE)))
 

print(paste("Average/Median %Generated tests that are labeled (INCAL): ", mean(subset(human_effort2, classifier=="INCAL" & variable == "%Generated tests that are labeled")$value),median(subset(human_effort2, classifier=="INCAL" & variable == "%Generated tests that are labeled")$value)))
print(paste("Average/Median %Failing tests that are labeled (INCAL): ", mean(subset(human_effort2, classifier=="INCAL" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE),median(subset(human_effort2, classifier=="INCAL" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE)))
print(paste("Average/Median Prob. to generate a failing test (INCAL): ", mean(subset(human_effort, classifier=="INCAL" & variable == "Prob. to generate a failing test")$value),median(subset(human_effort, classifier=="INCAL" & variable == "Prob. to generate a failing test")$value)))
print(paste("Average/Median Prob. to label a failing test (INCAL): ", mean(subset(human_effort, classifier=="INCAL" & variable == "Prob. to label a failing test")$value),median(subset(human_effort, classifier=="INCAL" & variable == "Prob. to label a failing test")$value)))

print(paste("Average/Median %Generated tests that are labeled (DT): ", mean(subset(human_effort2, classifier=="DT" & variable == "%Generated tests that are labeled")$value),median(subset(human_effort2, classifier=="DT" & variable == "%Generated tests that are labeled")$value)))
print(paste("Average/Median %Failing tests that are labeled (DT): ", mean(subset(human_effort2, classifier=="DT" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE),median(subset(human_effort2, classifier=="DT" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE)))
print(paste("Average/Median Prob. to generate a failing test (DT): ", mean(subset(human_effort, classifier=="DT" & variable == "Prob. to generate a failing test")$value),median(subset(human_effort, classifier=="DT" & variable == "Prob. to generate a failing test")$value)))
print(paste("Average/Median Prob. to label a failing test (DT): ", mean(subset(human_effort, classifier=="DT" & variable == "Prob. to label a failing test")$value),median(subset(human_effort, classifier=="DT" & variable == "Prob. to label a failing test")$value)))

print(paste("Average/Median %Generated tests that are labeled (ADB): ", mean(subset(human_effort2, classifier=="ADB" & variable == "%Generated tests that are labeled")$value),median(subset(human_effort2, classifier=="ADB" & variable == "%Generated tests that are labeled")$value)))
print(paste("Average/Median %Failing tests that are labeled (ADB): ", mean(subset(human_effort2, classifier=="ADB" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE),median(subset(human_effort2, classifier=="ADB" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE)))
print(paste("Average/Median Prob. to generate a failing test (ADB): ", mean(subset(human_effort, classifier=="ADB" & variable == "Prob. to generate a failing test")$value),median(subset(human_effort, classifier=="ADB" & variable == "Prob. to generate a failing test")$value)))
print(paste("Average/Median Prob. to label a failing test (ADB): ", mean(subset(human_effort, classifier=="ADB" & variable == "Prob. to label a failing test")$value),median(subset(human_effort, classifier=="ADB" & variable == "Prob. to label a failing test")$value)))

print(paste("Average/Median %Generated tests that are labeled (SVM): ", mean(subset(human_effort2, classifier=="SVM" & variable == "%Generated tests that are labeled")$value),median(subset(human_effort2, classifier=="SVM" & variable == "%Generated tests that are labeled")$value)))
print(paste("Average/Median %Failing tests that are labeled (SVM): ", mean(subset(human_effort2, classifier=="SVM" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE),median(subset(human_effort2, classifier=="SVM" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE)))
print(paste("Average/Median Prob. to generate a failing test (SVM): ", mean(subset(human_effort, classifier=="SVM" & variable == "Prob. to generate a failing test")$value),median(subset(human_effort, classifier=="SVM" & variable == "Prob. to generate a failing test")$value)))
print(paste("Average/Median Prob. to label a failing test (SVM): ", mean(subset(human_effort, classifier=="SVM" & variable == "Prob. to label a failing test")$value),median(subset(human_effort, classifier=="SVM" & variable == "Prob. to label a failing test")$value)))

print(paste("Average/Median %Generated tests that are labeled (NB): ", mean(subset(human_effort2, classifier=="NB" & variable == "%Generated tests that are labeled")$value),median(subset(human_effort2, classifier=="NB" & variable == "%Generated tests that are labeled")$value)))
print(paste("Average/Median %Failing tests that are labeled (NB): ", mean(subset(human_effort2, classifier=="NB" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE),median(subset(human_effort2, classifier=="NB" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE)))
print(paste("Average/Median Prob. to generate a failing test (NB): ", mean(subset(human_effort, classifier=="NB" & variable == "Prob. to generate a failing test")$value),median(subset(human_effort, classifier=="NB" & variable == "Prob. to generate a failing test")$value)))
print(paste("Average/Median Prob. to label a failing test (NB): ", mean(subset(human_effort, classifier=="NB" & variable == "Prob. to label a failing test")$value),median(subset(human_effort, classifier=="NB" & variable == "Prob. to label a failing test")$value)))

print(paste("Average/Median %Generated tests that are labeled (MLP(20)): ", mean(subset(human_effort2, classifier=="MLP(20)" & variable == "%Generated tests that are labeled")$value),median(subset(human_effort2, classifier=="MLP(20)" & variable == "%Generated tests that are labeled")$value)))
print(paste("Average/Median %Failing tests that are labeled (MLP(20)): ", mean(subset(human_effort2, classifier=="MLP(20)" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE),median(subset(human_effort2, classifier=="MLP(20)" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE)))
print(paste("Average/Median Prob. to generate a failing test (MLP(20)): ", mean(subset(human_effort, classifier=="MLP(20)" & variable == "Prob. to generate a failing test")$value),median(subset(human_effort, classifier=="MLP(20)" & variable == "Prob. to generate a failing test")$value)))
print(paste("Average/Median Prob. to label a failing test (MLP(20)): ", mean(subset(human_effort, classifier=="MLP(20)" & variable == "Prob. to label a failing test")$value),median(subset(human_effort, classifier=="MLP(20)" & variable == "Prob. to label a failing test")$value)))

print(paste("Average/Median %Generated tests that are labeled (MLP(20,5)): ", mean(subset(human_effort2, classifier=="MLP(20,5)" & variable == "%Generated tests that are labeled")$value),median(subset(human_effort2, classifier=="MLP(20,5)" & variable == "%Generated tests that are labeled")$value)))
print(paste("Average/Median %Failing tests that are labeled (MLP(20,5)): ", mean(subset(human_effort2, classifier=="MLP(20,5)" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE),median(subset(human_effort2, classifier=="MLP(20,5)" & variable == "%Failing tests that are labeled")$value, na.rm=TRUE)))
print(paste("Average/Median Prob. to generate a failing test (MLP(20,5)): ", mean(subset(human_effort, classifier=="MLP(20,5)" & variable == "Prob. to generate a failing test")$value),median(subset(human_effort, classifier=="MLP(20,5)" & variable == "Prob. to generate a failing test")$value)))
print(paste("Average/Median Prob. to label a failing test (MLP(20,5)): ", mean(subset(human_effort, classifier=="MLP(20,5)" & variable == "Prob. to label a failing test")$value),median(subset(human_effort, classifier=="MLP(20,5)" & variable == "Prob. to label a failing test")$value)))




