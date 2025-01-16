#读取数据
As_3data <- read.table("OC_As3.csv", header = FALSE, sep = ",")
As_5data <- read.table("OC_As5.csv", header = FALSE, sep = ",")

#采样日期
Sampleday <- As_3data[1,2:ncol(As_3data)]

#转换为数值型数据
As_3Data <- As_3data[2:nrow(As_3data),3:ncol(As_3data)]
As_3Data = as.data.frame(lapply(As_3Data,as.numeric)) 
As_5Data <- As_5data[2:nrow(As_5data),3:ncol(As_5data)]
As_5Data = as.data.frame(lapply(As_5Data,as.numeric)) 

#清洗数据，并计算每种处理的单次Eh平均值和标准差
#创建放置数据的数据框
mean_As_3 <- matrix(nrow = 6, ncol = ncol(As_3Data))
sd_As_3 <- matrix(nrow = 6, ncol = ncol(As_3Data))
mean_As_5 <- matrix(nrow = 6, ncol = ncol(As_5Data))
sd_As_5 <- matrix(nrow = 6, ncol = ncol(As_5Data))

#计算过程
for (k in 1:ncol(As_3Data)) { #As3
  for (j in 1:6) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- As_3Data[number:number_end,k]        #cdata表示第k个时期，某一处理的6个数据
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    As_3Data[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_As_3[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)/sqrt(6)
    sd_As_3[j,k] <- sd_cleaned
  }
}
title1 <- data.frame(c("mean_CK", "mean_LN", "mean_MN", "mean_MN-NH4", "mean_MN-NO3", "mean_HN"))
title2 <- data.frame(c("sd_CK", "sd_LN", "sd_MN", "sd_MN-NH4", "sd_MN-NO3", "sd_HN"))
mean_As_3 <-cbind(title1, mean_As_3)
sd_As_3 <-cbind(title2, sd_As_3)

mean_As_3 <- t(mean_As_3)
SampleTime <- data.frame(c("Time", "t0", "t1", "t2", "t3", "t4"))
mean_As_3 <-cbind(SampleTime, mean_As_3)
colnames(mean_As_3) <- as.character(mean_As_3[1, ])
mean_As_3 <- mean_As_3[-1, ]

sd_As_3 <- t(sd_As_3)
sd_As_3 <-cbind(SampleTime, sd_As_3)
colnames(sd_As_3) <- as.character(sd_As_3[1, ])
sd_As_3 <- sd_As_3[-1, ]

for (k in 1:ncol(As_5Data)) { #As5
  for (j in 1:6) {
    number <- 1 + 6*(j-1);
    number_end <- number+5;
    cdata <- As_5Data[number:number_end,k]        #cdata表示第k个时期，某一处理的6个数据
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    As_5Data[number:number_end,k] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    mean_As_5[j,k] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)
    sd_cleaned <- sd_cleaned / sqrt(6)
    sd_As_5[j,k] <- sd_cleaned
  }
}
title1 <- data.frame(c("mean_CK", "mean_LN", "mean_MN", "mean_MN-NH4", "mean_MN-NO3", "mean_HN"))
title2 <- data.frame(c("sd_CK", "sd_LN", "sd_MN", "sd_MN-NH4", "sd_MN-NO3", "sd_HN"))
mean_As_5 <-cbind(title1, mean_As_5)
sd_As_5 <-cbind(title2, sd_As_5)

mean_As_5 <- t(mean_As_5)
SampleTime <- data.frame(c("Time", "t0", "t1", "t2", "t3", "t4"))
mean_As_5 <-cbind(SampleTime, mean_As_5)
colnames(mean_As_5) <- as.character(mean_As_5[1, ])
mean_As_5 <- mean_As_5[-1, ]

sd_As_5 <- t(sd_As_5)
sd_As_5 <-cbind(SampleTime, sd_As_5)
colnames(sd_As_5) <- as.character(sd_As_5[1, ])
sd_As_5 <- sd_As_5[-1, ]






write.csv(mean_As_3, "cd-mean_As3.csv", row.names = FALSE)
write.csv(sd_As_3, "cd-sd_As3.csv", row.names = FALSE)

write.csv(mean_As_5, "cd-mean_As5.csv", row.names = FALSE)
write.csv(sd_As_5, "cd-sd_As5.csv", row.names = FALSE)