#读取数据
Ndata <- read.table("Eh-N_6.23~9.13.csv", header = FALSE, sep = ",")
Pdata <- read.table("Eh-P_6.23~9.13.csv", header = FALSE, sep = ",")
Npredate <- Ndata[1,-c(1:2)];
list1 <- seq(3, ncol(predate1), by = 2);
list2 <- seq(4, ncol(predate1), by = 2);
Ppredate <- Pdata[1,-c(1:2)];
list3 <- seq(3, ncol(predate2), by = 2);
list4 <- seq(4, ncol(predate2), by = 2);
#分别提取表层水和土壤采样数据
#氮添加
sampleNstrategy <- Ndata[3:nrow(Ndata),2];
Nwaterdata <- Ndata[3:nrow(Ndata),list1];
Nwaterdata2 = as.data.frame(lapply(Nwaterdata,as.numeric)) #转换为数值型数据
Nsoildata <- Ndata[3:nrow(Ndata),list2];
Nsoildata2 = as.data.frame(lapply(Nsoildata,as.numeric))

Nwaterdata <- cbind(sampleNstrategy,Nwaterdata2);   #Nwaterdata为氮添加上覆水Eh数据
Nsoildata <- cbind(sampleNstrategy,Nsoildata2);     #Nsoildata为氮添加土壤Eh数据

#磷添加
samplePstrategy <- Ndata[3:nrow(Pdata),2];
Pwaterdata <- Pdata[3:nrow(Pdata),list3];
Pwaterdata2 = as.data.frame(lapply(Pwaterdata,as.numeric))
Psoildata <- Pdata[3:nrow(Pdata),list4];
Psoildata2 = as.data.frame(lapply(Psoildata,as.numeric))

Pwaterdata <- cbind(samplePstrategy,Pwaterdata2);   #Pwaterdata为磷添加上覆水Eh数据
Psoildata <- cbind(samplePstrategy,Psoildata2);     #Psoildata为磷添加土壤Eh数据

#提取采样日期（区分氮和磷），并转换为从第1天开始，直到最后一天
sampledate1 <- Npredate[list1];
sampleday1 <- matrix(nrow = 1, ncol = ncol(sampledate1));      #这里有个做的不好的地方，时间应该作为单独一列数据，否则不便于后面画图
for(i in 1:ncol(sampledate1)){  #将第一次采样设置为第0天，可得一共81天，用日期相减的方法转换每个采样日期
  sampleday1[1,i] <- as.numeric(as.Date(sampledate1[1,i], units = "days"))-as.numeric(as.Date(sampledate1[1,1], units = "days"))
}
xc1 <- "平均值/时间（天）"; #给采样时间前加一列，用于放样品名
Nsampleday1 <- cbind(xc1, sampleday1)
xc2 <- "标准差/时间（天）"; #给采样时间前加一列，用于放样品名
Nsampleday2 <- cbind(xc2, sampleday1) 

sampledate2 <- Ppredate[list3];
sampleday2 <- matrix(nrow = 1, ncol = ncol(sampledate2));
for(i in 1:ncol(sampledate2)){  #将第一次采样设置为第0天，可得一共55天，用日期相减的方法转换每个采样日期
  sampleday2[1,i] <- as.numeric(as.Date(sampledate2[1,i], units = "days"))-as.numeric(as.Date(sampledate2[1,1], units = "days"))
}
xc1 <- "平均值/时间（天）"; #给采样时间前加一列，用于放样品名
Psampleday1 <- cbind(xc1, sampleday2)
xc2 <- "标准差/时间（天）"; #给采样时间前加一列，用于放样品名
Psampleday2 <- cbind(xc2, sampleday2) 


#清洗数据，并计算每种处理的单次Eh平均值和标准差
#创建放置数据的数据框
mean_Nwater <- matrix(nrow = 6, ncol = ncol(Nwaterdata));
mean_Nwater[,1] <- c("CK", "LN", "MN", "MN-NH4", "MN-NO3", "HN");
sd_Nwater <- matrix(nrow = 6, ncol = ncol(Nwaterdata));
sd_Nwater[,1] <- c("CK", "LN", "MN", "MN-NH4", "MN-NO3", "HN");

mean_Nsoil <- matrix(nrow = 6, ncol = ncol(Nsoildata));
mean_Nsoil[,1] <- c("CK", "LN", "MN", "MN-NH4", "MN-NO3", "HN");
sd_Nsoil <- matrix(nrow = 6, ncol = ncol(Nsoildata));
sd_Nsoil[,1] <- c("CK", "LN", "MN", "MN-NH4", "MN-NO3", "HN");

mean_Pwater <- matrix(nrow = 4, ncol = ncol(Pwaterdata));
mean_Pwater[,1] <- c("CK", "LP", "MP", "HP");
sd_Pwater <- matrix(nrow = 4, ncol = ncol(Pwaterdata));
sd_Pwater[,1] <- c("CK", "LP", "MP", "HP");

mean_Psoil <- matrix(nrow = 4, ncol = ncol(Psoildata));
mean_Psoil[,1] <- c("CK", "LP", "MP", "HP");
sd_Psoil <- matrix(nrow = 4, ncol = ncol(Psoildata));
sd_Psoil[,1] <- c("CK", "LP", "MP", "HP");

for (k in 2:ncol(Nwaterdata)) { #N添加上覆水
  for (j in 1:6) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- Nwaterdata[number:number_end,k]        #cdata表示第k天，某一处理的6个数据
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    Nwaterdata[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_Nwater[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)
    sd_Nwater[j,k] <- sd_cleaned
  }
}

for (k in 2:ncol(Nsoildata)) { #N添加土壤
  for (j in 1:6) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- Nsoildata[number:number_end,k]   
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    Nsoildata[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_Nsoil[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)
    sd_Nsoil[j,k] <- sd_cleaned
  }
}

for (k in 2:ncol(Pwaterdata)) { #P添加上覆水
  for (j in 1:4) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- Pwaterdata[number:number_end,k]
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    Pwaterdata[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_Pwater[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)
    sd_Pwater[j,k] <- sd_cleaned
  }
}

for (k in 2:ncol(Psoildata)) { #P添加土壤
  for (j in 1:4) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- Psoildata[number:number_end,k]
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    Psoildata[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_Psoil[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)
    sd_Psoil[j,k] <- sd_cleaned
  }
}

#将计算得到的平均值和标准差加入时间行并合并
mean_Nwater <- rbind(Nsampleday1, mean_Nwater)
sd_Nwater <- rbind(Nsampleday2, sd_Nwater)
cal_Nwater <- rbind(mean_Nwater, sd_Nwater)

mean_Nsoil <- rbind(Nsampleday1, mean_Nsoil)
sd_Nsoil <- rbind(Nsampleday2, sd_Nsoil)
cal_Nsoil <- rbind(mean_Nsoil, sd_Nsoil)

mean_Pwater <- rbind(Psampleday1, mean_Pwater)
sd_Pwater <- rbind(Psampleday2, sd_Pwater)
cal_Pwater <- rbind(mean_Pwater, sd_Pwater)

mean_Psoil <- rbind(Psampleday1, mean_Psoil)
sd_Psoil <- rbind(Psampleday2, sd_Psoil)
cal_Psoil <- rbind(mean_Psoil, sd_Psoil)