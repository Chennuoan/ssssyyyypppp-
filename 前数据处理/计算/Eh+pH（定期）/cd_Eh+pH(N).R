#读取数据
Eh_Ndata <- read.table("Eh(N).csv", header = FALSE, sep = ",")
pH_Ndata <- read.table("pH(N).csv", header = FALSE, sep = ",")

#采样日期
# Sampleday <- As_3data[1,2:ncol(As_3data)]

#转换为数值型数据
Eh_NData <- Eh_Ndata[2:nrow(Eh_Ndata),3:ncol(Eh_Ndata)]
Eh_NData = as.data.frame(lapply(Eh_NData,as.numeric)) 
pH_NData <- pH_Ndata[2:nrow(pH_Ndata),3:ncol(pH_Ndata)]
pH_NData = as.data.frame(lapply(pH_NData,as.numeric)) 

#清洗数据，并计算每种处理的单次Eh平均值和标准差
#创建放置数据的数据框
mean_Eh_N <- matrix(nrow = 6, ncol = ncol(Eh_NData))
sd_Eh_N <- matrix(nrow = 6, ncol = ncol(Eh_NData))
mean_pH_N <- matrix(nrow = 6, ncol = ncol(pH_NData))
sd_pH_N <- matrix(nrow = 6, ncol = ncol(pH_NData))

#计算过程
for (k in 1:ncol(Eh_NData)) { #Eh_N
  for (j in 1:6) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- Eh_NData[number:number_end,k]        #cdata表示第k个时期，某一处理的6个数据
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    Eh_NData[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_Eh_N[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)/sqrt(6)
    sd_Eh_N[j,k] <- sd_cleaned
  }
}
title1 <- data.frame(c("mean_CK", "mean_LN", "mean_MN", "mean_MN-NH4", "mean_MN-NO3", "mean_HN"))
title2 <- data.frame(c("sd_CK", "sd_LN", "sd_MN", "sd_MN-NH4", "sd_MN-NO3", "sd_HN"))
mean_Eh_N <-cbind(title1, mean_Eh_N)
sd_Eh_N <-cbind(title2, sd_Eh_N)

mean_Eh_N <- t(mean_Eh_N)
SampleTime <- data.frame(c("Time", "t0", "t1", "t2", "t3", "t4"))
mean_Eh_N <-cbind(SampleTime, mean_Eh_N)
colnames(mean_Eh_N) <- as.character(mean_Eh_N[1, ])
mean_Eh_N <- mean_Eh_N[-1, ]

sd_Eh_N <- t(sd_Eh_N)
sd_Eh_N <-cbind(SampleTime, sd_Eh_N)
colnames(sd_Eh_N) <- as.character(sd_Eh_N[1, ])
sd_Eh_N <- sd_Eh_N[-1, ]

for (k in 1:ncol(pH_NData)) { #pH_N
  for (j in 1:6) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- pH_NData[number:number_end,k]        #cdata表示第k个时期，某一处理的6个数据
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    pH_NData[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_pH_N[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)
    sd_cleaned <- sd_cleaned / sqrt(6)
    sd_pH_N[j,k] <- sd_cleaned
  }
}
title1 <- data.frame(c("mean_CK", "mean_LN", "mean_MN", "mean_MN-NH4", "mean_MN-NO3", "mean_HN"))
title2 <- data.frame(c("sd_CK", "sd_LN", "sd_MN", "sd_MN-NH4", "sd_MN-NO3", "sd_HN"))
mean_pH_N <-cbind(title1, mean_pH_N)
sd_pH_N <-cbind(title2, sd_pH_N)

mean_pH_N <- t(mean_pH_N)
SampleTime <- data.frame(c("Time", "t0", "t1", "t2", "t3", "t4"))
mean_pH_N <-cbind(SampleTime, mean_pH_N)
colnames(mean_pH_N) <- as.character(mean_pH_N[1, ])
mean_pH_N <- mean_pH_N[-1, ]

sd_pH_N <- t(sd_pH_N)
sd_pH_N <-cbind(SampleTime, sd_pH_N)
colnames(sd_pH_N) <- as.character(sd_pH_N[1, ])
sd_pH_N <- sd_pH_N[-1, ]






write.csv(mean_Eh_N, "cd-mean_Eh(N).csv", row.names = FALSE)
write.csv(sd_Eh_N, "cd-sd_Eh(N).csv", row.names = FALSE)
write.csv(Eh_NData, "cd-OCEh(N).csv", row.names = FALSE)

write.csv(mean_pH_N, "cd-mean_pH(N).csv", row.names = FALSE)
write.csv(sd_pH_N, "cd-sd_pH(N).csv", row.names = FALSE)
write.csv(pH_NData, "cd-OCpH(N).csv", row.names = FALSE)