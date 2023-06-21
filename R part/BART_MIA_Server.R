
library(rJava)
options(java.parameters="-Xmx150g")
library("bartMachine")

load("/home/francesca.micocci/Export_project/train1.m.RData")
load("/home/francesca.micocci/Export_project/test1.m.RData")

y <- factor(train1.m$export,levels=c("1","0"))
X<-as.data.frame(train1.m)
X$export<-NULL
X$bvdidnumber<-NULL
X$year<-NULL
bart_machine.1<-bartMachine(X, y,use_missing_data=TRUE,use_missing_data_dummies_as_covars=TRUE,seed=2021)
test1.m$export<-NULL
test1.m$bvdidnumber<-NULL
test1.m$year<-NULL
bart_machine.fitted1.m<-predict(bart_machine.1, test1.m,type='prob')
save(bart_machine.fitted1.m,file="/home/francesca.micocci/Export_project/bart.fitted1.m.RData")

var.imp<-investigate_var_importance(bart_machine.1)
save(var.imp,file="/home/francesca.micocci/Export_project/var_imp.RData")


library(rJava)
options(java.parameters="-Xmx150g")
library("bartMachine")

load("/home/francesca.micocci/Export_project/train2.m.RData")
load("/home/francesca.micocci/Export_project/test2.m.RData")

y <- factor(train2.m$export,levels=c("1","0"))
X<-as.data.frame(train2.m)
X$export<-NULL
X$bvdidnumber<-NULL
X$year<-NULL
bart_machine.2<-bartMachine(X, y,use_missing_data=TRUE,use_missing_data_dummies_as_covars=TRUE,seed=2021)
test2.m$export<-NULL
test2.m$bvdidnumber<-NULL
test2.m$year<-NULL
bart_machine.fitted2.m<-predict(bart_machine.2, test2.m,type='prob')
save(bart_machine.fitted2.m,file="/home/francesca.micocci/Export_project/bart.fitted2.m.RData")

investigate_var_importance(bart_machine.2,num_var_plot=12)
var.imp<-investigate_var_importance(bart_machine.2,num_var_plot=12)
save(var.imp,file="/home/francesca.micocci/Export_project/var_imp.RData")
rm(y,X,train2.m,test2.m)

library(rJava)
options(java.parameters="-Xmx150g")
library("bartMachine")

load("/home/francesca.micocci/Export_project/train3.m.RData")
load("/home/francesca.micocci/Export_project/test3.m.RData")

y <- factor(train3.m$export,levels=c("1","0"))
X<-as.data.frame(train3.m)
X$export<-NULL
X$bvdidnumber<-NULL
X$year<-NULL
bart_machine.3<-bartMachine(X, y,use_missing_data=TRUE,use_missing_data_dummies_as_covars=TRUE)
test3.m$export<-NULL
test3.m$bvdidnumber<-NULL
test3.m$year<-NULL
bart_machine.fitted3.m<-predict(bart_machine.3, test3.m,type='prob')
save(bart_machine.fitted3.m,file="/home/francesca.micocci/Export_project/bart.fitted3.m.RData")

library(rJava)
options(java.parameters="-Xmx150g")
library("bartMachine")

load("/home/francesca.micocci/Export_project/train4.m.RData")
load("/home/francesca.micocci/Export_project/test4.m.RData")

y <- factor(train4.m$export,levels=c("1","0"))
X<-as.data.frame(train4.m)
X$export<-NULL
X$bvdidnumber<-NULL
X$year<-NULL
bart_machine.4<-bartMachine(X, y,use_missing_data=TRUE,use_missing_data_dummies_as_covars=TRUE)
test4.m$export<-NULL
test4.m$bvdidnumber<-NULL
test4.m$year<-NULL
bart_machine.fitted4.m<-predict(bart_machine.4, test4.m,type='prob')
save(bart_machine.fitted4.m,file="/home/francesca.micocci/Export_project/bart.fitted4.m.RData")

library(rJava)
options(java.parameters="-Xmx150g")
library("bartMachine")

load("/home/francesca.micocci/Export_project/train5.m.RData")
load("/home/francesca.micocci/Export_project/test5.m.RData")

y <- factor(train5.m$export,levels = c("1","0"))
X<-as.data.frame(train5.m)
X$export<-NULL
X$bvdidnumber<-NULL
X$year<-NULL
bart_machine.5<-bartMachine(X, y,use_missing_data=TRUE,use_missing_data_dummies_as_covars=TRUE)
test5.m$export<-NULL
test5.m$bvdidnumber<-NULL
test5.m$year<-NULL
bart_machine.fitted5.m<-predict(bart_machine.5, test5.m,type='prob')
save(bart_machine.fitted5.m,file="/home/francesca.micocci/Export_project/bart.fitted5.m.RData")


investigate_var_importance(bart_machine.5,num_var_plot=15)
var.imp<-investigate_var_importance(bart_machine.5,num_var_plot=15)
rm(y,X,train5.m,test5.m)