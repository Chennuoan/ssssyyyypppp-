#1.箱型图法检验异常值并替换为NA
cdata <- Nsoildata[1:6,4]
# 使用 boxplot.stats 来提取异常值
outliers <- boxplot.stats(cdata)$out

# 将异常值替换为 NA
data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)

# 输出结果
data_cleaned

# 计算去除异常值后的平均值和标准差
mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
sd_cleaned <- sd(data_cleaned, na.rm = TRUE)

# 输出结果检测结果
mean_cleaned
sd_cleaned
