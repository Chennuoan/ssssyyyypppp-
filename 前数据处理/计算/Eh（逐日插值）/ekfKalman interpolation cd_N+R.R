library(dlm)
library(dplyr)
library(openxlsx)

# 读取并转置数据
df <- read.csv("数据清洗后/cd_NaddinWater.csv", header = FALSE)
df_transposed <- as.data.frame(t(df))
df_transposed[1,1] <- "Time"
colnames(df_transposed) <- as.character(df_transposed[1, ])
df_transposed <- df_transposed[-1, ]
df_transposed <- df_transposed %>% mutate(across(-Time, as.numeric))
df_transposed$Time <- as.numeric(df_transposed$Time)

# 扩展卡尔曼滤波函数（趋势+噪声模型）
ekf_interpolate_trend <- function(df_transposed, sample_name, lambda = 0.01) {
  
  # 状态转移函数（lambda 被传递给 f 函数）
  f <- function(x, lambda) { 
    return(c(x[1] * exp(-lambda * 0.1) + x[2], x[2]))  # 增加时间因子，提升变化速率
  }  # 位置的衰减 + 速度（趋势变化率）
  
  # 观测函数（假设观测值就是状态的第一个分量，即位置）
  g <- function(x) { 
    return(x[1])  # 观测的是位置（数据本身）
  }
  
  # 初始状态（假设初始位置为第一天的测量值，初始速度基于前10天的变化计算）
  x0 <- c(df_transposed[1, sample_name], 
          (df_transposed[10, sample_name] - df_transposed[1, sample_name]) / (df_transposed$Time[10] - df_transposed$Time[1]))
  P0 <- diag(2)   # 初始协方差矩阵（可以调整）
  
  # 初始化状态估计和协方差矩阵
  x <- x0
  P <- P0
  
  # 创建均匀时间序列
  uniform_time <- seq(min(df_transposed$Time), max(df_transposed$Time), by = 1)
  uniform_data <- data.frame(Time = uniform_time)
  uniform_data <- merge(uniform_data, df_transposed, by = "Time", all.x = TRUE)
  
  # 定义存储滤波结果的向量
  filtered_values <- numeric(length(uniform_time))
  kalman_gains <- matrix(0, nrow = length(uniform_time), ncol = 2)  # 用于存储每个时间点的卡尔曼增益
  covariance_matrices <- list()  # 用于存储协方差矩阵
  
  # 动态调整噪声矩阵的策略
  dV_dynamic <- 10  # 观测噪声（可以根据情况动态调整）
  dW_dynamic <- 10  # 过程噪声（可以根据情况动态调整）
  
  # 扩展卡尔曼滤波步骤
  for (t in 1:length(uniform_time)) {
    # 获取当前时间点的观测值
    y <- uniform_data[t, sample_name]
    
    # 预测步骤
    x_pred <- f(x, lambda)  # lambda 会被传递给 f 函数
    P_pred <- P + diag(c(dW_dynamic, dW_dynamic))  # 过程协方差更新
    
    # 更新步骤
    if (!is.na(y)) {
      # 计算雅可比矩阵
      H <- matrix(c(1, 0), nrow = 1, ncol = 2)  # 雅可比矩阵（针对观测方程）
      
      # 卡尔曼增益计算
      K <- P_pred %*% t(H) %*% solve(H %*% P_pred %*% t(H) + dV_dynamic)
      
      # 更新状态估计
      x <- x_pred + K %*% (y - g(x_pred))
      P <- (diag(2) - K %*% H) %*% P_pred
    }
    
    # 保存当前的状态估计（这里只保存位置）
    filtered_values[t] <- x[1]
    
    # 保存当前的卡尔曼增益和协方差矩阵
    kalman_gains[t, ] <- K
    covariance_matrices[[t]] <- P
  }
  
  # 将插值结果和卡尔曼增益、协方差矩阵添加到数据框
  uniform_data[[paste("Interpolated", sample_name, sep = "_")]] <- filtered_values
  uniform_data$Kalman_Gain_1 <- kalman_gains[, 1]  # 保存卡尔曼增益的第一列（对应状态的第一个变量）
  uniform_data$Kalman_Gain_2 <- kalman_gains[, 2]  # 保存卡尔曼增益的第二列（对应状态的第二个变量）
  uniform_data$Covariance_1_1 <- sapply(covariance_matrices, function(P) P[1, 1])  # 协方差矩阵的第一行第一列
  uniform_data$Covariance_2_2 <- sapply(covariance_matrices, function(P) P[2, 2])  # 协方差矩阵的第二行第二列
  
  return(uniform_data)
}

# 定义处理组
names_list <- c("CK", "LN", "MN", "MN-NH4", "MN-NO3", "HN")
final_data <- data.frame(Time = df_transposed$Time)

# 对每个处理组执行扩展卡尔曼滤波插值
for (name in names_list) {
  cols <- grep(name, names(df_transposed), value = TRUE)
  if (length(cols) > 0) {
    for (i in seq_along(cols)) {
      sample_name <- cols[i]
      interpolated_data <- ekf_interpolate_trend(df_transposed, sample_name)
      final_data <- merge(final_data, interpolated_data[, c("Time", paste("Interpolated", sample_name, sep = "_"))], by = "Time", all = TRUE)
    }
  }
}

# 保存为 Excel 文件
wb <- createWorkbook()
addWorksheet(wb, "N添加上覆水")
writeData(wb, "N添加上覆水", final_data, rowNames = FALSE)
saveWorkbook(wb, "Eh(插值后）.xlsx", overwrite = TRUE)
