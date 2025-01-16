# 导入库
library(dlm)
library(dplyr)

定义卡尔曼滤波插值函数
kalman_interpolate <- function(df_transposed, sample_name) {
  model <- dlmModPoly(order = 2, dV = 1, dW = 20)
  uniform_time <- seq(min(df_transposed$Time), max(df_transposed$Time), by = 1)
  uniform_data <- data.frame(Time = uniform_time)
  uniform_data <- merge(uniform_data, df_transposed, by = "Time", all.x = TRUE)
  filtered <- dlmFilter(uniform_data[[sample_name]], model)
  interpolated_values <- filtered$m[-1]
  uniform_data[[paste("Interpolated", sample_name, sep = "_")]] <- c(interpolated_values)
  return(uniform_data)
}

# kalman_interpolate <- function(df_transposed, sample_name) {
#   # 创建卡尔曼滤波模型，设置为二阶多项式，dV 和 dW 为 2x2 对角矩阵
#   dV <- matrix(c(1, 0, 0, 1), nrow = 2)  # 观测噪声协方差矩阵
#   dW <- matrix(c(10, 0, 0, 10), nrow = 2)  # 过程噪声协方差矩阵
#   
#   # 创建二阶多项式模型（包括ORP和变化率）
#   model <- dlmModPoly(order = 2, dV = dV, dW = dW)
#   
#   # 使用卡尔曼滤波
#   filtered <- dlmFilter(df_transposed$ORP, model)
#   
#   
#   # 创建均匀时间序列，确保其范围与原始数据的时间列一致
#   uniform_time <- seq(min(df_transposed$Time), max(df_transposed$Time), by = 1)
#   uniform_data <- data.frame(Time = uniform_time)
#   
#   # 合并均匀时间序列和原始数据，确保时间对齐
#   uniform_data <- merge(uniform_data, df_transposed, by = "Time", all.x = TRUE)
#   
#   # 使用卡尔曼滤波进行插值
#   filtered <- dlmFilter(uniform_data[[sample_name]], model)
#   
#   # 获取插值结果，并移除第一个初始化值
#   interpolated_values <- filtered$m[-1]
#   
#   # # 如果插值结果的长度小于时间序列长度，填充 NA 值以匹配长度
#   # if (length(interpolated_values) < nrow(uniform_data)) {
#   #   interpolated_values <- c(interpolated_values, rep(NA, nrow(uniform_data) - length(interpolated_values)))
#   # }
#   # 
#   # 将插值结果添加到数据框
#   uniform_data[[paste("Interpolated", sample_name, sep = "_")]] <- interpolated_values
#   
#   return(uniform_data)
# }

# kalman_interpolate <- function(df_transposed, sample_name) {
#   # 创建卡尔曼滤波模型，设置为二阶多项式，dV 和 dW 为 2x2 对角矩阵
#   dV <- matrix(c(1, 0, 0, 1), nrow = 2)  # 观测噪声协方差矩阵（2x2）
#   dW <- matrix(c(10, 0, 0, 10), nrow = 2)  # 过程噪声协方差矩阵（2x2）
#   
#   # 创建二阶多项式模型（包括ORP和变化率）
#   model <- dlmModPoly(order = 2, dV = dV, dW = dW)
#   
#   # 使用卡尔曼滤波
#   filtered <- dlmFilter(df_transposed[[sample_name]], model)
#   
#   # 创建均匀时间序列，确保其范围与原始数据的时间列一致
#   uniform_time <- seq(min(df_transposed$Time), max(df_transposed$Time), by = 1)
#   uniform_data <- data.frame(Time = uniform_time)
#   
#   # 合并均匀时间序列和原始数据，确保时间对齐
#   uniform_data <- merge(uniform_data, df_transposed, by = "Time", all.x = TRUE)
#   
#   # 获取插值结果，并移除第一个初始化值
#   interpolated_values <- filtered$m[, 1]  # 使用第一列（ORP值的预测）
#   
#   # 确保插值结果的长度与时间序列一致，如果不一致则填充NA
#   if (length(interpolated_values) < nrow(uniform_data)) {
#     interpolated_values <- c(interpolated_values, rep(NA, nrow(uniform_data) - length(interpolated_values)))
#   }
#   
#   # 将插值结果添加到数据框
#   uniform_data[[paste("Interpolated", sample_name, sep = "_")]] <- interpolated_values
#   
#   return(uniform_data)
# }



# 读取并转置数据
df <- read.csv("数据清洗后/cd_NaddinWater.csv", header = FALSE)
df_transposed <- as.data.frame(t(df))
df_transposed[1,1] <- "Time"
colnames(df_transposed) <- as.character(df_transposed[1, ])
df_transposed <- df_transposed[-1, ]
df_transposed <- df_transposed %>% mutate(across(-Time, as.numeric))
df_transposed$Time <- as.numeric(df_transposed$Time)

# 定义处理组
names_list <- c("CK", "LN", "MN", "MN-NH4", "MN-NO3", "HN")
final_data <- data.frame(Time = df_transposed$Time)

# 对每个处理组执行卡尔曼滤波插值
for (name in names_list) {
  cols <- grep(name, names(df_transposed), value = TRUE)
  if (length(cols) > 0) {
    for (i in seq_along(cols)) {
      sample_name <- cols[i]
      interpolated_data <- kalman_interpolate(df_transposed, sample_name)
      final_data <- merge(final_data, interpolated_data[, c("Time", paste("Interpolated", sample_name, sep = "_"))], by = "Time", all = TRUE)
    }
  }
}


library(openxlsx)
# 创建 Workbook
wb <- createWorkbook()

# 添加工作表
addWorksheet(wb, "N添加上覆水")
writeData(wb, "N添加上覆水", final_data, rowNames = FALSE)
saveWorkbook(wb, "Eh(插值后）.xlsx", overwrite = TRUE)

# mean_Nwater <- matrix(nrow = nrow(final_data), ncol = 6)
# sd_Nwater <- matrix(nrow = nrow(final_data), ncol = 6)

cal_Nwater <- matrix(nrow = nrow(final_data), ncol = 12)
cd_final_data <-matrix(nrow = nrow(final_data), ncol = ncol(final_data))
cd_final_data[,1] <- final_data[,1]
Nsampleday <- final_data[,1]
Nsampleday <- as.data.frame(Nsampleday)
colnames(Nsampleday) <- "Time"
for (j in 1:nrow(final_data)) { #N添加上覆水
  for (k in 1:6) {
    number <- 2 + 6*(k-1);
    number_end <- number+5;
    cdata <- as.numeric(final_data[j,number:number_end])        #cdata表示第j天，某一处理的6个数据
    outliers <- boxplot.stats(cdata)$out
    data_cleaned <- ifelse(cdata %in% outliers, NA, cdata)
    cd_final_data[j,number:number_end] <- data_cleaned #替换原数据中的异常值为缺省值
    
    mean_cleaned <- mean(data_cleaned, na.rm = TRUE)
    cal_Nwater[j,2*k-1] <- mean_cleaned
    sd_cleaned <- sd(data_cleaned, na.rm = TRUE)
    cal_Nwater[j,2*k] <- sd_cleaned
  }
}
#将计算得到的平均值和标准差加入时间行并合并
cal_Nwater <- cbind(Nsampleday, cal_Nwater)
# mean_Nwater <- cbind(Nsampleday, mean_Nwater)
# sd_Nwater <- cbind(Nsampleday, sd_Nwater)
# cal_Nwater <- cbind(mean_Nwater, sd_Nwater)
colnames(cd_final_data) <- as.character(colnames(final_data))
write.csv(cd_final_data, "Eh_6.23~9.13（插值+数据清洗后）.csv")
colnames(cal_Nwater) <- c("Time", "mean_CK", "sd_CK", "mean_LN", "sd_LN", "mean_MN", "sd_MN", "mean_MN-NH4", "sd_MN-NH4", "mean_MN-NO3", "sd_MN-NO3", "mean_HN", "sd_HN")
write.csv(cal_Nwater, "Interpolated_NaddinWater.csv", row.names = FALSE)
