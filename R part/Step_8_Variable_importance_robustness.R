## NO Ile de France ----
### Clear environment ----
rm(list=ls())

### Load packages ----
library(caret)
library(PRROC)
library(randomForest)
library(rpart)
library(hdm)
library(dplyr)
library(tidyverse)
library(rpart.plot)
require(foreign)
library(MASS)

### Load datasets ----
load("/home/francesca.micocci/Export_project/train1.m.RData")
load("/home/francesca.micocci/Export_project/test1.m.RData")

### Remove Ile de France
train=train1.m[which(train1.m$nuts2!="FR10"),]
test=test1.m[which(test1.m$nuts2!="FR10"),]

### Now run all algorithms on such datasets
#### Generate list of predictors -----
pred_ML<-colnames(train)
to_exclude=c("export","bvdidnumber","year","missing")
pred_ML=setdiff(pred_ML,to_exclude)
rm(to_exclude)

#### Generate  formulas ----
formula.logit<-(as.formula(paste("export ~", paste(pred_ML, collapse="+"))))  
formula.ML <- as.formula(paste("as.factor(export) ~", paste(pred_ML, collapse="+")))

#### Run BART machine ----
library(rJava)
options(java.parameters="-Xmx150g")
library("bartMachine")

#vector of ouput
y <- factor(train$export,levels=c("1","0"))
#matrix of predictors
X<-as.data.frame(train)
#remove identifiers
X$export<-NULL
X$bvdidnumber<-NULL
X$year<-NULL
X$missing<-NULL
#run bart machine
bart_machine <- bartMachine(X, y,use_missing_data=TRUE,use_missing_data_dummies_as_covars=TRUE,seed=2021)
#Generate a compatible matrix of predictors for the test set
test1=test
test1$export<-NULL
test1$bvdidnumber<-NULL
test1$year<-NULL
test1$missing<-NULL
# predict output on the test set 
test$bart.prob<-predict(bart_machine, test1,type='prob')
# use probability to classify firms
test$bart.pred<-ifelse(test$bart.prob>0.5,1,0)
# Generate prediction quality statistics
cm=confusionMatrix(data = as.factor(test$bart.pred),
                   reference = as.factor(test$export),positive = "1")
roc<- roc.curve(scores.class0 =as.numeric(test$bart.prob),
                weights.class0 = as.numeric(test$export),
                curve = T)
pr<- pr.curve(scores.class0 =as.numeric(test$bart.prob),
              weights.class0 = as.numeric(test$export),
              curve = T)
#Store all results
performance=data.frame(matrix(NA,1,7))
colnames(performance)=c("Model","Accuracy","Sensitivity","Specificity","BACC","ROC","PR")
performance[1,1]="No Ile de France"
performance[1,2]=cm[["overall"]][["Accuracy"]]
performance[1,3]=cm[["byClass"]][["Sensitivity"]]
performance[1,4]=cm[["byClass"]][["Specificity"]]
performance[1,5]=cm[["byClass"]][["Balanced Accuracy"]]
performance[1,6]=roc[["auc"]]
performance[1,7]=pr[["auc.integral"]]

### compute VIP -----
VIP_no_FR10=investigate_var_importance(bart_machine, num_replicates_for_avg = 5)
save(VIP_no_FR10, file="/home/francesca.micocci/Export_project/VIP_no_FR10.RData")
# Ile de France -----
# Select only  Ile de France
train2=train1.m[which(train1.m$nuts2=="FR10"),]
test2=test1.m[which(test1.m$nuts2=="FR10"),]
# Output vector
y <- factor(train2$export,levels=c("1","0"))
# matrix of predictors
X<-as.data.frame(train2)
X$export<-NULL
X$bvdidnumber<-NULL
X$year<-NULL
X$missing<-NULL
# compute bart-mia
bart_machine2 <- bartMachine(X, y,use_missing_data=TRUE,use_missing_data_dummies_as_covars=TRUE,seed=2021)
# generate compatible matrix for test-set
test12=test2
test12$export<-NULL
test12$bvdidnumber<-NULL
test12$year<-NULL
test12$missing<-NULL
# predict output
test2$bart.prob<-predict(bart_machine, test12,type='prob')
# using predicted probability, classify firms
test2$bart.pred<-ifelse(test2$bart.prob>0.5,1,0)
#Prediction quality statistics
cm=confusionMatrix(data = as.factor(test2$bart.pred),
                   reference = as.factor(test2$export),positive = "1")
roc<- roc.curve(scores.class0 =as.numeric(test2$bart.prob),
                weights.class0 = as.numeric(test2$export),
                curve = T)
pr<- pr.curve(scores.class0 =as.numeric(test2$bart.prob),
              weights.class0 = as.numeric(test2$export),
              curve = T)

performance[2,1]="Ile de France"
performance[2,2]=cm[["overall"]][["Accuracy"]]
performance[2,3]=cm[["byClass"]][["Sensitivity"]]
performance[2,4]=cm[["byClass"]][["Specificity"]]
performance[2,5]=cm[["byClass"]][["Balanced Accuracy"]]
performance[2,6]=roc[["auc"]]
performance[2,7]=pr[["auc.integral"]]


###Compute VIP -----
VIP_FR10=investigate_var_importance(bart_machine2, num_replicates_for_avg = 5)
save(VIP_FR10, file="/home/francesca.micocci/Export_project/VIP_FR10.RData")

# Graph Ile de France ----
load("/Users/francescamicocci/Documents/Export_project/Versione_finale/VIP_FR10.RData")

var.imp<-as.data.frame(VIP_FR10)
var.imp<-var.imp[var.imp$avg_var_props>0.01,]
var.imp<-var.imp[order(-var.imp$avg_var_props),] 
var.imp$var=rownames(var.imp)
to_drop=grep("nace_",var.imp$var)
var.imp=var.imp[setdiff(c(1:nrow(var.imp)),to_drop),]
var.imp$predictor<-c('working capital','cost of materials','operating revenue turn.',
                     'size-age','current assets','age','creditors','debtors',
                     'external econ. of scale', 'regional spillovers','financial expenses',
                     "inward FDI:1",'patents:0',"financial revenues",  "current liabilities",
                     "intangible fixed assets", "total assets", "fixed assets" ,
                     "MISS cost of materials","financial sustainability", "current ratio",
                     "solvency ratio asset-based","MISS dep. amort.","taxation","added value",
                     "patents:1","outward FDI:0","loans", "wage","outward_FDI:1","liquidity ratio",
                     "consolidated accounts:0","MISS added value","non-current liabilities" ,    
                     "cash & cash.equivalent","inward FDI:0")    
var.imp$type<-c('accounts','accounts','accounts',
                'financial ratio', 'accounts','demographics','accounts','accounts',
                'internationalization','internationalization', 'accounts',
                'internationalization', 'others','accounts','accounts',
                'accounts','accounts','accounts',
                'accounts','financial ratio','financial ratio',
                'financial ratio','accounts','accounts','accounts',
                'others', 'internationalization', 'accounts','others','internationalization', 'financial ratio',
                'demographics','accounts','accounts','accounts','internationalization')
#Reorder by type of predictor and inclusion proportion
var.imp <-var.imp[order(var.imp$type,-var.imp$avg_var_props),]
var.imp$sort<-c(1:nrow(var.imp))
#remove the row names
rownames(var.imp) <- NULL
#Draw rthe graph
png("/Users/francescamicocci/Desktop/tiff_pic/FigB3_a_variable_inclusion_proportion_FR10.png", width = 1000, height = 600,units="px",res=120)
ggplot(var.imp, aes(x=reorder(predictor,sort), y=avg_var_props,fill=type)) + 
  geom_bar(position="dodge", stat="identity",colour="black")+
  geom_errorbar( aes(x=predictor, ymin=avg_var_props-sd_var_props, ymax=avg_var_props+sd_var_props), width=0.4, colour="#610000", alpha=0.9, size=1)+ theme_classic()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="bottom",legend.background = element_rect(size=0.5, linetype="solid", 
                                                                                                                                                                                                                                                                                                    colour ="black"))+ scale_fill_manual(values = c("gray100","gray75","gray50","gray88","gray25"))+ labs(fill = "Predictor Type")+
  xlab("Predictor") + ylab("Inclusion proportion")

dev.off()

tiff("/Users/francescamicocci/Documents/Export_project/Versione_finale/variable_inclusion_proportion_FR10.tiff", width = 1000, height = 600,units="px",res=120)
ggplot(var.imp, aes(x=reorder(predictor,sort), y=avg_var_props,fill=type)) + 
  geom_bar(position="dodge", stat="identity",colour="black")+
  geom_errorbar( aes(x=predictor, ymin=avg_var_props-sd_var_props, ymax=avg_var_props+sd_var_props), width=0.4, colour="#610000", alpha=0.9, size=1)+ theme_classic()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="bottom",legend.background = element_rect(size=0.5, linetype="solid", 
                                                                                                                                                                                                                                                                                                    colour ="black"))+ scale_fill_manual(values = c("gray100","gray75","gray50","gray88","gray25"))+ labs(fill = "Predictor Type")+
  xlab("Predictor") + ylab("Inclusion proportion")

dev.off()


# Graph NO Ile de France -----
rm(list=ls())
load("/Users/francescamicocci/Documents/Export_project/Versione_finale/VIP_no_FR10.RData")

var.imp<-as.data.frame(VIP_no_FR10)
var.imp<-var.imp[var.imp$avg_var_props>0.01,]
var.imp<-var.imp[order(-var.imp$avg_var_props),] 
var.imp$var=rownames(var.imp)
to_drop=c(grep("nace_",var.imp$var),grep("nuts2_",var.imp$var))
var.imp=var.imp[setdiff(c(1:nrow(var.imp)),to_drop),]

var.imp$predictor<-c("creditors","ext. economies of scale","working capital","current assets",           
                    "material costs","age","intangible fixed-assets","shareholders funds",       
                     "debtors","regional spillovers","operating revenue turn.","added value",           
                     "current liabilities","financial sustainability","size-age","taxation",         
                     "long-term debt","fixed assets","total assets","outward FDI:0",           
                     "cash-flow","EBITDA","inward FDI:1","log(n. employees)",
                    "financial expenses","cash & cash-equivalent","interest paid", "markups")    
var.imp$type<-c('accounts','internationalization','accounts','accounts',
                'accounts','demographics','accounts','accounts',
                'accounts','internationalization','accounts','accounts',
                'accounts','financial ratio','financial ratio','accounts',
                'accounts','accounts','accounts','internationalization',
                'accounts','accounts','internationalization','demographics',
                'accounts','accounts','accounts','others')
#Reorder by type of predictor and inclusion proportion
var.imp <-var.imp[order(var.imp$type,-var.imp$avg_var_props),]
var.imp$sort<-c(1:nrow(var.imp))
#remove the row names
rownames(var.imp) <- NULL
#Draw rthe graph

png("/Users/francescamicocci/Desktop/tiff_pic/FigB3_a_variable_inclusion_proportion_no_FR10.png", width = 1000, height = 600,units="px",res=120)
ggplot(var.imp, aes(x=reorder(predictor,sort), y=avg_var_props,fill=type)) + 
  geom_bar(position="dodge", stat="identity",colour="black")+
  geom_errorbar( aes(x=predictor, ymin=avg_var_props-sd_var_props, ymax=avg_var_props+sd_var_props), width=0.4, colour="#610000", alpha=0.9, size=1)+ theme_classic()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="bottom",legend.background = element_rect(size=0.5, linetype="solid", 
                                                                                                                                                                                                                                                                                                    colour ="black"))+ scale_fill_manual(values = c("gray100","gray75","gray50","gray88","gray25"))+ labs(fill = "Predictor Type")+
  xlab("Predictor") + ylab("Inclusion proportion")

dev.off()
tiff("/Users/francescamicocci/Documents/Export_project/Versione_finale/variable_inclusion_proportion_no_FR10.tiff", width = 1000, height = 600,units="px",res=120)
ggplot(var.imp, aes(x=reorder(predictor,sort), y=avg_var_props,fill=type)) + 
  geom_bar(position="dodge", stat="identity",colour="black")+
  geom_errorbar( aes(x=predictor, ymin=avg_var_props-sd_var_props, ymax=avg_var_props+sd_var_props), width=0.4, colour="#610000", alpha=0.9, size=1)+ theme_classic()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="bottom",legend.background = element_rect(size=0.5, linetype="solid", 
                                                                                                                                                                                                                                                                                                    colour ="black"))+ scale_fill_manual(values = c("gray100","gray75","gray50","gray88","gray25"))+ labs(fill = "Predictor Type")+
  xlab("Predictor") + ylab("Inclusion proportion")

dev.off()
