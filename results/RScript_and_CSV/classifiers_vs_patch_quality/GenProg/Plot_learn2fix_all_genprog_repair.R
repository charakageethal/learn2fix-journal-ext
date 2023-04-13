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
                         "vTotalfail"=numeric(), "vCorrectfail"= numeric())
  
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
    VCorrectfail = 0
    
    
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
        VCorrectfail = VCorrectfail + run_specific$V10
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
                                   vCorrectfail = VCorrectfail / Runs
                        ))
  }
  save(mean_data,file=filename)
  return(mean_data)
}



patch_quality=data.frame("subject"=character(),"max_label"=character(),"variable"=character(),"value"=numeric())

d=read.table("results_SVM.csv",sep=",",comment.char = "#")
mean_data=compute_mean(d,"results_svm")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_svm.Rda")
  knit_exit()
}

for(i in 1:30){
  m_repair=0
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if ("REPAIR" %in% specific$V12) m_repair=m_repair+1
    if ("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }  
  subjects=length(levels(factor(d$V1)))
  
  
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="Manual",value=m_repair/subjects))
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="SVM",value=a_repair/subjects))
  
  
}

d_20_manual=subset(d,V12=="REPAIR")
d_svm_autogen=subset(d,V18=="REPAIR")

patch_quality3=data.frame(subject=d_20_manual$V1,
                          max_label=rep("Validation Score",nrow(d_20_manual)),
                          variable=rep("Manual",nrow(d_20_manual)),
                          value=d_20_manual$V14/d_20_manual$V15)

patch_quality3 = rbind(patch_quality3, 
                       data.frame(subject=d_svm_autogen$V1,
                                  max_label = rep("Validation Score", nrow(d_svm_autogen)),
                                  variable = rep("SVM", nrow(d_svm_autogen)),
                                  value = d_svm_autogen$V20/d_svm_autogen$V21))


d = read.table("results_DCT.csv",sep=",",comment.char = "#")
mean_data = compute_mean(d, "results_dct")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_dct.Rda")
  knit_exit()
}


for(i in 1:30){
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if ("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }  
  subjects=length(levels(factor(d$V1)))
  
  
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="DT",value=a_repair/subjects))
  
  
}

d_dt_autogen=subset(d,V18=="REPAIR")

patch_quality3 = rbind(patch_quality3, 
                       data.frame(subject=d_dt_autogen$V1,
                                  max_label = rep("Validation Score", nrow(d_dt_autogen)),
                                  variable = rep("DT", nrow(d_dt_autogen)),
                                  value = d_dt_autogen$V20/d_dt_autogen$V21))

d=read.table("results_NB.csv",sep = ",",comment.char = "#")
mean_data=compute_mean(d,"results_nb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_nb.Rda")
  knit_exit()
}

for(i in 1:30){
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if ("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }  
  subjects=length(levels(factor(d$V1)))
  
  
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="NB",value=a_repair/subjects))
  
  
}

d_nb_autogen=subset(d,V18=="REPAIR")

patch_quality3 = rbind(patch_quality3, 
                       data.frame(subject=d_nb_autogen$V1,
                                  max_label = rep("Validation Score", nrow(d_nb_autogen)),
                                  variable = rep("NB", nrow(d_nb_autogen)),
                                  value = d_nb_autogen$V20/d_nb_autogen$V21))


d=read.table("results_ADB.csv",sep = ",",comment.char = "#")
mean_data=compute_mean(d,"results_adb")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_adb.Rda")
  knit_exit()
}

for(i in 1:30){
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if ("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }  
  subjects=length(levels(factor(d$V1)))
  
  
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="ADB",value=a_repair/subjects))
  
  
}

d_adb_autogen=subset(d,V18=="REPAIR")

patch_quality3 = rbind(patch_quality3, 
                       data.frame(subject=d_adb_autogen$V1,
                                  max_label = rep("Validation Score", nrow(d_adb_autogen)),
                                  variable = rep("ADB", nrow(d_adb_autogen)),
                                  value = d_adb_autogen$V20/d_adb_autogen$V21))



d=read.table("results_INCAL.csv",sep = ",",comment.char = "#")
mean_data=compute_mean(d,"results_incal")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_incal.Rda")
  knit_exit()
}

for(i in 1:30){
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if ("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }  
  subjects=length(levels(factor(d$V1)))
  
  
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="INCAL",value=a_repair/subjects))
  
  
}

d_incal_autogen=subset(d,V18=="REPAIR")

patch_quality3 = rbind(patch_quality3, 
                       data.frame(subject=d_incal_autogen$V1,
                                  max_label = rep("Validation Score", nrow(d_incal_autogen)),
                                  variable = rep("INCAL", nrow(d_incal_autogen)),
                                  value = d_incal_autogen$V20/d_incal_autogen$V21))


d=read.table("results_MLP(20).csv",sep = ",",comment.char = "#")
mean_data=compute_mean(d,"results_mlp_20")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_mlp_20.Rda")
  knit_exit()
}


for(i in 1:30){
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if ("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }  
  subjects=length(levels(factor(d$V1)))
  
  
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="MLP(20)",value=a_repair/subjects))
  
  
}

d_mlp_20_autogen=subset(d,V18=="REPAIR")

patch_quality3 = rbind(patch_quality3, 
                       data.frame(subject=d_mlp_20_autogen$V1,
                                  max_label = rep("Validation Score", nrow(d_mlp_20_autogen)),
                                  variable = rep("MLP(20)", nrow(d_mlp_20_autogen)),
                                  value = d_mlp_20_autogen$V20/d_mlp_20_autogen$V21))

d=read.table("results_MLP(20,5).csv",sep = ",",comment.char = "#")
mean_data=compute_mean(d,"results_mlp_20_5")

if (length(levels(factor(mean_data$subject))) != length(levels(factor(d$V1)))) {
  print("DELETE results_mlp_20_5.Rda")
  knit_exit()
}


for(i in 1:30){
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if ("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }  
  subjects=length(levels(factor(d$V1)))
  
  
  patch_quality <-rbind(patch_quality,data.frame(subject=Subject,max_label="Repairability",variable="MLP(20,5)",value=a_repair/subjects))
  
  
}

d_mlp_20_5_autogen=subset(d,V18=="REPAIR")

patch_quality3 = rbind(patch_quality3, 
                       data.frame(subject=d_mlp_20_5_autogen$V1,
                                  max_label = rep("Validation Score", nrow(d_mlp_20_5_autogen)),
                                  variable = rep("MLP(20,5)", nrow(d_mlp_20_5_autogen)),
                                  value = d_mlp_20_5_autogen$V20/d_mlp_20_5_autogen$V21))


print(wilcox.test(subset(patch_quality3,variable=="SVM")$value,subset(patch_quality3,variable=="Manual")$value,alternative="less"))
print(wilcox.test(subset(patch_quality3,variable=="NB")$value,subset(patch_quality3,variable=="Manual")$value,alternative="less"))

patch_quality3$variable <-factor(patch_quality3$variable, levels = c("Manual","INCAL","DT","ADB","SVM","NB","MLP(20)","MLP(20,5)") )

patch_quality$variable <-factor(patch_quality$variable, levels = c("Manual","INCAL","DT","ADB","SVM","NB","MLP(20)","MLP(20,5)") )

ggplot(patch_quality, aes(variable, value)) +
  geom_boxplot(aes(fill=variable)) +
  scale_y_continuous(labels = scales::percent,limits=c(0,0.3)) +
  facet_grid(~ max_label) +
  xlab("Classification Algorithm") + ylab("%Subjects Repaired") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=5), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "overall_repairability.pdf", width=7, height=4, scale=0.8)

ggplot(patch_quality3, aes(variable, value)) +
  geom_boxplot(aes(fill=variable)) +
  scale_y_continuous(labels = scales::percent, limits=c(0,1)) +
  facet_grid(~ max_label) +
  xlab("Classification Algorithm") + ylab("% Heldout Test Cases Passed") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=5), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "overall_patchquality.pdf", width=7, height=4, scale=0.8)


print(paste("Average/Median manual repairabliity : ", mean(subset(patch_quality,  variable == "Manual")$value),median(subset(patch_quality,  variable == "Manual")$value)))
print(paste("Average/Median autogen repairability (SVM): ", mean(subset(patch_quality,  variable == "SVM")$value),median(subset(patch_quality,variable == "SVM")$value)))
print(paste("Average/Median autogen repairability (DT): ", mean(subset(patch_quality,  variable == "DT")$value),median(subset(patch_quality,variable == "DT")$value)))
print(paste("Average/Median autogen repairability (NB): ", mean(subset(patch_quality,  variable == "NB")$value),median(subset(patch_quality,variable == "NB")$value)))
print(paste("Average/Median autogen repairability (ADB): ", mean(subset(patch_quality,  variable == "ADB")$value),median(subset(patch_quality,variable == "ADB")$value)))
print(paste("Average/Median autogen repairability (INCAL): ", mean(subset(patch_quality,  variable == "INCAL")$value),median(subset(patch_quality,variable == "INCAL")$value)))
print(paste("Average/Median autogen repairability (MLP(20)): ", mean(subset(patch_quality,  variable == "MLP(20)")$value),median(subset(patch_quality,variable == "MLP(20)")$value)))
print(paste("Average/Median autogen repairability (MLP(20,5)): ", mean(subset(patch_quality,  variable == "MLP(20,5)")$value),median(subset(patch_quality,variable == "MLP(20,5)")$value)))

print(paste("Average/Median patch quality manual : ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "Manual" & value!=Inf)$value),median(subset(patch_quality3, max_label=="Validation Score" & variable == "Manual" & value!=Inf)$value)))
print(paste("Average/Median patch quality autogen (SVM): ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "SVM" & value!=Inf)$value,na.rm = TRUE),median(subset(patch_quality3, max_label=="Validation Score" & variable == "SVM" & value!=Inf)$value,na.rm = TRUE)))
print(paste("Average/Median patch quality autogen (DT): ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "DT" & value!=Inf)$value,na.rm = TRUE),median(subset(patch_quality3, max_label=="Validation Score" & variable == "DT" & value!=Inf)$value,na.rm = TRUE)))
print(paste("Average/Median patch quality autogen (NB): ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "NB" & value!=Inf)$value,na.rm = TRUE),median(subset(patch_quality3, max_label=="Validation Score" & variable == "NB" & value!=Inf)$value,na.rm = TRUE)))
print(paste("Average/Median patch quality autogen (ADB): ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "ADB" & value!=Inf)$value,na.rm = TRUE),median(subset(patch_quality3, max_label=="Validation Score" & variable == "ADB" & value!=Inf)$value,na.rm = TRUE)))
print(paste("Average/Median patch quality autogen (INCAL): ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "INCAL" & value!=Inf)$value,na.rm = TRUE),median(subset(patch_quality3, max_label=="Validation Score" & variable == "INCAL" & value!=Inf)$value,na.rm = TRUE)))
print(paste("Average/Median patch quality autogen (MLP(20)): ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "MLP(20)" & value!=Inf)$value,na.rm = TRUE),median(subset(patch_quality3, max_label=="Validation Score" & variable == "MLP(20)" & value!=Inf)$value,na.rm = TRUE)))
print(paste("Average/Median patch quality autogen (MLP(20,5)): ", mean(subset(patch_quality3, max_label=="Validation Score" & variable == "MLP(20,5)" & value!=Inf)$value,na.rm = TRUE),median(subset(patch_quality3, max_label=="Validation Score" & variable == "MLP(20,5)" & value!=Inf)$value,na.rm = TRUE)))

