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

patch_quality=data.frame("subject"=character(),"metric"=character(),"noise_level"=character(),"value"=numeric())

d=read.table("results_dct_repair.csv",sep=",",comment.char = "#")

for(i in 1:30)
{
  m_repair=0
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if("REPAIR" %in% specific$V12) m_repair=m_repair+1
    if("REPAIR" %in% specific$V18) a_repair=a_repair+1
  }
  
  n_subjects=length(levels(factor(d$V1)))
  patch_quality<-rbind(patch_quality,data.frame(subject=Subject,metric="Repairability",noise_level="Manual",value=m_repair/n_subjects))
  patch_quality<-rbind(patch_quality,data.frame(subject=Subject,metric="Repairability",noise_level="autogen-0%",value=a_repair/n_subjects))
}

d_manual=subset(d,V12=="REPAIR")
d_autogen=subset(d,V18=="REPAIR")

patch_quality2=data.frame(subject=d_manual$V1,
                          metric=rep("Validation Score",nrow(d_manual)),
                          noise_level=rep("Manual",nrow(d_manual)),
                          value=d_manual$V14/d_manual$V15)

patch_quality2=rbind(patch_quality2,
                     data.frame(subject=d_autogen$V1,
                                metric=rep("Validation Score",nrow(d_autogen)),
                                noise_level=rep("autogen-0%",nrow(d_autogen)),
                                value=d_autogen$V20/d_autogen$V21))


d=read.table("results_dct_noise_5.csv",sep=",",comment.char = "#")

for(i in 1:30)
{
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if("REPAIR" %in% specific$V12) a_repair=a_repair+1
  }
  
  n_subjects=length(levels(factor(d$V1)))
  patch_quality<-rbind(patch_quality,data.frame(subject=Subject,metric="Repairability",noise_level="autogen-5%",value=a_repair/n_subjects))
   
}

d_autogen=subset(d,V12=="REPAIR")
patch_quality2=rbind(patch_quality2,
                     data.frame(subject=d_autogen$V1,
                                metric=rep("Validation Score",nrow(d_autogen)),
                                noise_level=rep("autogen-5%",nrow(d_autogen)),
                                value=d_autogen$V14/d_autogen$V15))


d=read.table("results_dct_noise_10.csv",sep=",",comment.char = "#")

for(i in 1:30)
{
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if("REPAIR" %in% specific$V12) a_repair=a_repair+1
  }
  
  n_subjects=length(levels(factor(d$V1)))
  patch_quality<-rbind(patch_quality,data.frame(subject=Subject,metric="Repairability",noise_level="autogen-10%",value=a_repair/n_subjects))
  
}

d_autogen=subset(d,V12=="REPAIR")
patch_quality2=rbind(patch_quality2,
                     data.frame(subject=d_autogen$V1,
                                metric=rep("Validation Score",nrow(d_autogen)),
                                noise_level=rep("autogen-10%",nrow(d_autogen)),
                                value=d_autogen$V14/d_autogen$V15))




d=read.table("results_dct_noise_20.csv",sep=",",comment.char = "#")

for(i in 1:30)
{
  a_repair=0
  
  for(Subject in levels(factor(d$V1)))
  {
    specific=subset(d,V1==Subject & V2==i)
    if("REPAIR" %in% specific$V12) a_repair=a_repair+1
  }
  
  n_subjects=length(levels(factor(d$V1)))
  patch_quality<-rbind(patch_quality,data.frame(subject=Subject,metric="Repairability",noise_level="autogen-20%",value=a_repair/n_subjects))
  
}

d_autogen=subset(d,V12=="REPAIR")
patch_quality2=rbind(patch_quality2,
                     data.frame(subject=d_autogen$V1,
                                metric=rep("Validation Score",nrow(d_autogen)),
                                noise_level=rep("autogen-20%",nrow(d_autogen)),
                                value=d_autogen$V14/d_autogen$V15))

print(wilcox.test(subset(patch_quality2,noise_level=="Manual")$value,subset(patch_quality2,noise_level=="autogen-0%")$value,alternative="less"))
print(wilcox.test(subset(patch_quality2,noise_level=="autogen-0%")$value,subset(patch_quality2,noise_level=="autogen-5%")$value,alternative="greater"))
print(wilcox.test(subset(patch_quality2,noise_level=="autogen-5%")$value,subset(patch_quality2,noise_level=="autogen-10%")$value,alternative="greater"))
print(wilcox.test(subset(patch_quality2,noise_level=="autogen-10%")$value,subset(patch_quality2,noise_level=="autogen-20%")$value,alternative="greater"))
print(wilcox.test(subset(patch_quality2,noise_level=="autogen-0%")$value,subset(patch_quality2,noise_level=="autogen-10%")$value,alternative="greater"))
print(wilcox.test(subset(patch_quality2,noise_level=="Manual")$value,subset(patch_quality2,noise_level=="autogen-5%")$value,alternative="two.sided"))
print(wilcox.test(subset(patch_quality2,noise_level=="Manual")$value,subset(patch_quality2,noise_level=="autogen-10%")$value,alternative="two.sided"))
print(wilcox.test(subset(patch_quality2,noise_level=="Manual")$value,subset(patch_quality2,noise_level=="autogen-20%")$value,alternative="two.sided"))


print(paste("Average/Median manual repairabliity (Manual) : ", mean(subset(patch_quality,  noise_level == "Manual")$value),median(subset(patch_quality,  noise_level == "Manual")$value)))
print(paste("Average/Median manual repairabliity (Noise-0%) : ", mean(subset(patch_quality,  noise_level == "autogen-0%")$value),median(subset(patch_quality,  noise_level == "autogen-0%")$value)))
print(paste("Average/Median manual repairabliity (Noise-5%) : ", mean(subset(patch_quality,  noise_level == "autogen-5%")$value),median(subset(patch_quality,  noise_level == "autogen-5%")$value)))
print(paste("Average/Median manual repairabliity (Noise-10%) : ", mean(subset(patch_quality,  noise_level == "autogen-10%")$value),median(subset(patch_quality,  noise_level == "autogen-10%")$value)))
print(paste("Average/Median manual repairabliity (Noise-20%) : ", mean(subset(patch_quality,  noise_level == "autogen-20%")$value),median(subset(patch_quality,  noise_level == "autogen-20%")$value)))

print(paste("Average/Median manual Validation Score (Manual) : ", mean(subset(patch_quality2,  noise_level == "Manual")$value),median(subset(patch_quality2,  noise_level == "Manual")$value)))
print(paste("Average/Median manual Validation Score (Noise-0%) : ", mean(subset(patch_quality2,  noise_level == "autogen-0%")$value,na.rm = TRUE),median(subset(patch_quality2,  noise_level == "autogen-0%")$value,na.rm = TRUE)))
print(paste("Average/Median manual Validation Score (Noise-5%) : ", mean(subset(patch_quality2,  noise_level == "autogen-5%")$value,na.rm = TRUE),median(subset(patch_quality2,  noise_level == "autogen-5%")$value,na.rm = TRUE)))
print(paste("Average/Median manual Validation Score (Noise-10%) : ", mean(subset(patch_quality2,  noise_level == "autogen-10%")$value),median(subset(patch_quality2,  noise_level == "autogen-10%")$value)))
print(paste("Average/Median manual Valdiation Score (Noise-20%) : ", mean(subset(patch_quality2,  noise_level == "autogen-20%")$value),median(subset(patch_quality2,  noise_level == "autogen-20%")$value)))

ggplot(patch_quality, aes(noise_level, value)) +
  geom_boxplot(aes(fill=noise_level)) +
  scale_y_continuous(labels = scales::percent,limits=c(0,0.3)) +
  facet_grid(~ metric) +
  xlab("") + ylab("%Subjects Repaired") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=5), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "overall_repairability.pdf", width=7, height=4, scale=0.8)

ggplot(patch_quality2, aes(noise_level, value)) +
  geom_boxplot(aes(fill=noise_level)) +
  scale_y_continuous(labels = scales::percent, limits=c(0,1)) +
  facet_grid(~ metric) +
  xlab("") + ylab("% Heldout Test Cases Passed") +
  theme(legend.position="none", legend.title= element_blank(),
        axis.text.x = element_text(colour = "black",size=5), axis.text.y = element_text(colour = "black")) +
  scale_fill_grey(start = 0.6, end = .9)
ggsave(filename = "overall_patchquality.pdf", width=7, height=4, scale=0.8)
