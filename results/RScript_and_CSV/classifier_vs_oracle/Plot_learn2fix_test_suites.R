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

test_suite= data.frame("subject"=character(),"classifier"=character(),"variable"=character(),value=numeric())
test_suite1= data.frame("subject"=character(),"classifier"=character(),"variable"=character(),value=numeric())


d = read.table("results_INCAL.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_incal")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_incal.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="INCAL",variable="Total Tests",value=specific$labelgen+1))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="INCAL",variable="Passing",value=specific$labelgen-specific$labelfail))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="INCAL",variable="Failing",value=specific$labelfail+1))
  #test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="INCAL",variable="Failing-to-Passing",value=(specific$labelfail+1)/(specific$labelgen-specific$labelfail)))
  
}



d = read.table("results_DCT.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="DT",variable="Total Tests",value=specific$labelgen+1))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="DT",variable="Passing",value=specific$labelgen-specific$labelfail))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="DT",variable="Failing",value=specific$labelfail+1))
  #test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="DT",variable="Failing-to-Passing",value=(specific$labelfail+1)/(specific$labelgen-specific$labelfail)))
  
}

d = read.table("results_ADB.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_adb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_adb.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="ADB",variable="Total Tests",value=specific$labelgen+1))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="ADB",variable="Passing",value=specific$labelgen-specific$labelfail))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="ADB",variable="Failing",value=specific$labelfail+1))
  #test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="ADB",variable="Failing-to-Passing",value=(specific$labelfail+1)/(specific$labelgen-specific$labelfail)))
  
  
}


d = read.table("results_SVM.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_svm")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_svm.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="SVM",variable="Total Tests",value=specific$labelgen+1))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="SVM",variable="Passing",value=specific$labelgen-specific$labelfail))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="SVM",variable="Failing",value=specific$labelfail+1))
  #test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="SVM",variable="Failing-to-Passing",value=(specific$labelfail+1)/(specific$labelgen-specific$labelfail)))
  
}


d = read.table("results_NB.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_nb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_nb.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="NB",variable="Total Tests",value=specific$labelgen+1))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="NB",variable="Passing",value=specific$labelgen-specific$labelfail))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="NB",variable="Failing",value=specific$labelfail+1))
  #test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="NB",variable="Failing-to-Passing",value=(specific$labelfail+1)/(specific$labelgen-specific$labelfail)))
  
  
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
  
  validation <- rbind(validation,data.frame(subject=Subject,category="Manually Constructed Tests",variable="Total Tests",number=specific$vTotal))
  
  validation <- rbind(validation,data.frame(subject=Subject,category="Manually Constructed Tests",variable="Passing Tests",number=specific$vTotal - specific$vTotalfail))
  
  validation <- rbind(validation,data.frame(subject=Subject,category="Manually Constructed Tests",variable="Failing Tests",number=specific$vTotalfail))
  
  validation2 <-rbind(validation2,data.frame(subject = Subject, category = "Fail. Rate", 
                                             variable = "%Failing", 
                                             number = specific$vTotalfail / specific$vTotal))

  
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20)",variable="Total Tests",value=specific$labelgen+1))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20)",variable="Passing",value=specific$labelgen-specific$labelfail))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20)",variable="Failing",value=specific$labelfail+1))
  #test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20)",variable="Failing-to-Passing",value=(specific$labelfail+1)/(specific$labelgen-specific$labelfail)))
  
  
}

d = read.table("results_MLP(20,5).csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_mlp_20_5")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_mlp_20_5.Rda")
  knit_exit()
}
for (Subject in levels(factor(mean_data$subject))){
  specific = subset(mean_data, subject == Subject)
  
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20,5)",variable="Total Tests",value=specific$labelgen+1))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20,5)",variable="Passing",value=specific$labelgen-specific$labelfail))
  test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20,5)",variable="Failing",value=specific$labelfail+1))
  #test_suite <- rbind(test_suite,data.frame(subject=Subject,classifier="MLP(20,5)",variable="Failing-to-Passing",value=(specific$labelfail+1)/(specific$labelgen-specific$labelfail)))
  
}

# test_suite$classifier <-factor(test_suite$classifier, levels = c("DT","ADB","INCAL","SVM","NB","MLP(20)","MLP(20,5)") )
# 
# d=read.table("manual_repair_tests.csv",sep=",",comment.char = "#")
# 
# for(subject in levels(factor(d$V1)))
# {
#   specific=subset(d,d$V1==subject)
#   test_suite1 <- rbind(test_suite1,data.frame(subject=specific$V1,classifier="Manual",variable="Total Tests",value=specific$V4))
#   test_suite1 <- rbind(test_suite1,data.frame(subject=specific$V1,classifier="Manual",variable="Passing",value=specific$V3))
#   test_suite1 <- rbind(test_suite1,data.frame(subject=specific$V1,classifier="Manual",variable="Failing",value=specific$V2))
#   #test_suite1 <- rbind(test_suite1,data.frame(subject=Subject,classifier="Manual",variable="Failing-to-Passing",value=specific$V2/specific$V3))
# }


d=read.table("manual_repair_tests.csv",sep=",",comment.char = "#")

for(subject in levels(factor(d$V1)))
{
  specific=subset(d,d$V1==subject)
  test_suite <- rbind(test_suite,data.frame(subject=specific$V1,classifier="Manual",variable="Total Tests",value=specific$V3+specific$V2))
  test_suite <- rbind(test_suite,data.frame(subject=specific$V1,classifier="Manual",variable="Passing",value=specific$V3))
  test_suite <- rbind(test_suite,data.frame(subject=specific$V1,classifier="Manual",variable="Failing",value=specific$V2))
  #test_suite <- rbind(test_suite,data.frame(subject=specific$V1,classifier="Manual",variable="Failing-to-Passing",value=specific$V2/specific$V3))
}

test_suite$classifier <-factor(test_suite$classifier, levels = c("Manual","DT","ADB","INCAL","SVM","NB","MLP(20)","MLP(20,5)") )




ggplot(validation, aes(variable, number)) +
  geom_boxplot(aes(fill=variable)) +
  scale_y_log10(limits=c(1,1000)) +
  facet_grid(~ category) +
  xlab("") + ylab("Number of tests") +
  scale_fill_grey(start = 0.6, end = .9) +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black"), axis.text.y = element_text(colour = "black"))
ggsave(filename = "validation.pdf", width=5,height=4.2,scale=0.77)

print(paste("Average number of passing tests: ", mean(subset(validation, variable=="Passing Tests")$number)))
print(paste("Average number of failing tests: ", mean(subset(validation, variable=="Failing Tests")$number)))

ggplot(validation2, aes(variable, number)) +
  geom_boxplot(aes(fill=variable)) +
  scale_y_continuous(labels = scales::percent) +
  facet_grid(~ category) +
  xlab("") + ylab("Proportion of failing tests") +
  scale_fill_grey(start = 0.6, end = .9) +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black"), axis.text.y = element_text(colour = "black"))
ggsave(filename = "validation2.pdf", width=2.2,height=3.2,scale=0.77)

ggplot(test_suite,aes(variable,value))+
  geom_boxplot(aes(fill=variable))+
   scale_y_continuous(labels=waiver())+coord_cartesian(ylim=c(1,25))+xlab("") + ylab("Number of tests")+
  facet_grid(~ classifier)+
  scale_fill_grey(start = 0.6, end = .9) +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=7,angle=90), axis.text.y = element_text(colour = "black"))
ggsave(filename = "repair_test_suite.pdf", width=8,height=3.2,scale=1)



print(paste("Average/Median Number of total tests in manual total test suites:",mean(subset(test_suite,classifier=="Manual" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="Manual" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in manual test suites:",mean(subset(test_suite,classifier=="Manual" & variable=="Passing")$value),median(subset(test_suite,classifier=="Manual" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in manual test suites:",mean(subset(test_suite,classifier=="Manual" & variable=="Failing")$value),median(subset(test_suite,classifier=="Manual" & variable=="Failing")$value)))
#print(paste("Average/Median Number of failing-to-passing in manual test suites:",mean(subset(test_suite,classifier=="Manual" & variable=="Failing-to-Passing")$value),median(subset(test_suite,classifier=="Manual" & variable=="Failing-to-Passing")$value)))

print(paste("Average/Median Number of total tests in DT:",mean(subset(test_suite,classifier=="DT" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="DT" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in DT:",mean(subset(test_suite,classifier=="DT" & variable=="Passing")$value),median(subset(test_suite,classifier=="DT" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in DT:",mean(subset(test_suite,classifier=="DT" & variable=="Failing")$value),median(subset(test_suite,classifier=="DT" & variable=="Failing")$value)))
print(paste("Average/Median Number of failing-to-passing in DT:",mean(subset(test_suite,classifier=="DT" & variable=="Failing-to-Passing" & value!=Inf)$value,na.rm =TRUE),median(subset(test_suite,classifier=="DT" & variable=="Failing-to-Passing")$value,na.rm = TRUE)))

print(paste("Average/Median Number of total tests in ADB:",mean(subset(test_suite,classifier=="ADB" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="ADB" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in ADB:",mean(subset(test_suite,classifier=="ADB" & variable=="Passing")$value),median(subset(test_suite,classifier=="ADB" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in ADB:",mean(subset(test_suite,classifier=="ADB" & variable=="Failing")$value),median(subset(test_suite,classifier=="ADB" & variable=="Failing")$value)))

print(paste("Average/Median Number of total tests in INCAL:",mean(subset(test_suite,classifier=="INCAL" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="INCAL" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in INCAL:",mean(subset(test_suite,classifier=="INCAL" & variable=="Passing")$value),median(subset(test_suite,classifier=="INCAL" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in INCAL:",mean(subset(test_suite,classifier=="INCAL" & variable=="Failing")$value),median(subset(test_suite,classifier=="INCAL" & variable=="Failing")$value)))

print(paste("Average/Median Number of total tests in SVM:",mean(subset(test_suite,classifier=="SVM" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="SVM" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in SVM:",mean(subset(test_suite,classifier=="SVM" & variable=="Passing")$value),median(subset(test_suite,classifier=="SVM" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in SVM:",mean(subset(test_suite,classifier=="SVM" & variable=="Failing")$value),median(subset(test_suite,classifier=="SVM" & variable=="Failing")$value)))

print(paste("Average/Median Number of total tests in NB:",mean(subset(test_suite,classifier=="NB" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="NB" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in NB:",mean(subset(test_suite,classifier=="NB" & variable=="Passing")$value),median(subset(test_suite,classifier=="NB" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in NB:",mean(subset(test_suite,classifier=="NB" & variable=="Failing")$value),median(subset(test_suite,classifier=="NB" & variable=="Failing")$value)))

print(paste("Average/Median Number of total tests in MLP(20):",mean(subset(test_suite,classifier=="MLP(20)" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="MLP(20)" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in MLP(20):",mean(subset(test_suite,classifier=="MLP(20)" & variable=="Passing")$value),median(subset(test_suite,classifier=="MLP(20)" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in MLP(20):",mean(subset(test_suite,classifier=="MLP(20)" & variable=="Failing")$value),median(subset(test_suite,classifier=="MLP(20)" & variable=="Failing")$value)))

print(paste("Average/Median Number of total tests in MLP(20,5):",mean(subset(test_suite,classifier=="MLP(20,5)" & variable=="Total Tests")$value),median(subset(test_suite,classifier=="MLP(20,5)" & variable=="Total Tests")$value)))
print(paste("Average/Median Number of passing tests in MLP(20,5):",mean(subset(test_suite,classifier=="MLP(20,5)" & variable=="Passing")$value),median(subset(test_suite,classifier=="MLP(20,5)" & variable=="Passing")$value)))
print(paste("Average/Median Number of failing tests in MLP(20,5):",mean(subset(test_suite,classifier=="MLP(20,5)" & variable=="Failing")$value),median(subset(test_suite,classifier=="MLP(20,5)" & variable=="Failing")$value)))



