knitr::opts_chunk$set(echo = TRUE)

library(ggplot2)
library(scales)
theme_set(theme_bw())

compute_mean=function(data,filename)
{
  filename=paste(filename,".Rda",sep="")
  
  if(file.exists(filename)){
    load(filename)
    return(mean_data)
  }
  
  mean_data=data.frame("subject"=character(), "test_suite"=character(),"coverage"=numeric())
  
  for(Subject in levels(factor(data$V1))){
    Runs=0
    TotalCoverage=0
    
    for(Run in levels(factor(subset(data,V1==Subject)$V2)))
    {
      run_specific=subset(data,V1==Subject & V2==Run)
      if(nrow(run_specific)!=0){
        Runs=Runs+1
        TotalCoverage=TotalCoverage+run_specific$V3
      }
    }
    
    mean_data <- rbind(mean_data,data.frame(subject=Subject,coverage=TotalCoverage/Runs))
    
  }
  
  save(mean_data,file=filename)
  return(mean_data)
}

cov_info=data.frame("subject"=character(),"type_test"=character(),"value"=numeric())
cov_info_2=data.frame("subject"=character(),"prog"=character(),"category"=character(),"value"=numeric())

d=read.table("manual_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_manual")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_manual.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="Manual",value=specific$coverage))
}

d=read.table("heldout_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_heldout")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_heldout.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info_2 <- rbind(cov_info_2,data.frame(subject=Subject,prog="Buggy",category="Heldout Test Suite",value=specific$coverage))
}



d=read.table("heldout_testsuite_golden_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_golden_heldout")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_golden_heldout.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info_2 <- rbind(cov_info_2,data.frame(subject=Subject,prog="Golden",category="Heldout Test Suite",value=specific$coverage))
}



d=read.table("dct_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_dct")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_dct.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="DT",value=specific$coverage))
}

d=read.table("adb_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_adb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_adb.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="ADB",value=specific$coverage))
}


d=read.table("incal_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_incal")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_incal.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="INCAL",value=specific$coverage))
}

d=read.table("svm_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_svm")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_svm.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="SVM",value=specific$coverage))
}

d=read.table("nb_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_nb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_nb.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="NB",value=specific$coverage))
}


d=read.table("mlp_20_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_mlp_20")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_mlp_20.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="MLP(20)",value=specific$coverage))
}


d=read.table("mlp_20_5_test_suite_cov.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_cov_mlp_20_5")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_cov_mlp_20_5.Rda")
  knit_exit()
}

for (Subject in levels(factor(mean_data$subject))){
  specific=subset(mean_data,subject==Subject)
  cov_info <- rbind(cov_info,data.frame(subject=Subject,type_test="MLP(20,5)",value=specific$coverage))
}


ggplot(cov_info,aes(type_test,value))+
  geom_boxplot(aes(fill=type_test))+
  scale_y_continuous(labels = scales::percent)+ xlab("Test suite") + ylab("Statement Coverage") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=7), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "coverage_compare.pdf", width=8, height=4, scale=0.8)

ggplot(cov_info_2,aes(prog,value))+
  facet_grid(~ category)+
  geom_boxplot(aes(fill=prog))+
  scale_y_continuous(labels = scales::percent)+ xlab("Version") + ylab("Statement Coverage") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=9), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "coverage_codeflaws_test_suites.pdf",width=4,height=5,scale=0.8)

print(wilcox.test(subset(cov_info,type_test=="ADB")$value,subset(cov_info,type_test=="Manual")$value,alternative = "less"))

print(paste("Average/Median coverage manual: ",mean(subset(cov_info,type_test=="Manual")$value),median(subset(cov_info,type_test=="Manual")$value)))
# print(paste("Average/Median coverage buggy-heldout: ",mean(subset(cov_info,type_test=="buggy-heldout")$value),median(subset(cov_info,type_test=="buggy-heldout")$value)))
# print(paste("Average/Median coverage golden-heldout: ",mean(subset(cov_info,type_test=="golden-heldout")$value),median(subset(cov_info,type_test=="golden-heldout")$value)))
print(paste("Average/Median coverage dct: ",mean(subset(cov_info,type_test=="DT")$value),median(subset(cov_info,type_test=="DT")$value)))
print(paste("Average/Median coverage adb: ",mean(subset(cov_info,type_test=="ADB")$value),median(subset(cov_info,type_test=="ADB")$value)))
print(paste("Average/Median coverage incal: ",mean(subset(cov_info,type_test=="INCAL")$value),median(subset(cov_info,type_test=="INCAL")$value)))
print(paste("Average/Median coverage svm: ",mean(subset(cov_info,type_test=="SVM")$value),median(subset(cov_info,type_test=="SVM")$value)))
print(paste("Average/Median coverage nb: ",mean(subset(cov_info,type_test=="NB")$value),median(subset(cov_info,type_test=="NB")$value)))
print(paste("Average/Median coverage MLP(20): ",mean(subset(cov_info,type_test=="MLP(20)")$value),median(subset(cov_info,type_test=="MLP(20)")$value)))
print(paste("Average/Median coverage MLP(20,5): ",mean(subset(cov_info,type_test=="MLP(20,5)")$value),median(subset(cov_info,type_test=="MLP(20,5)")$value)))