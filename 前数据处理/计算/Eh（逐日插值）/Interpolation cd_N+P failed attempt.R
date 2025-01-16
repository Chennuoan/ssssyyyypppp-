#步骤一：对每个平行样本进行插值

library(dlm)

kalman_interpolate <- function(df_transposed, sample_name) {
  # 定义卡尔曼滤波模型，设置初始值
  model <- dlmModPoly(order = 1, dV = 10, dW = 10)
  
  # 创建均匀时间序列，确保其范围与原始数据的时间列一致
  uniform_time <- seq(min(df_transposed$Time), max(df_transposed$Time), by = 1)
  
  # 创建一个包含均匀时间序列的空数据框
  uniform_data <- data.frame(Time = uniform_time)
  
  # 将均匀时间序列与原始数据合并，确保数据对齐
  uniform_data <- merge(uniform_data, df_transposed, by = "Time", all.x = TRUE)
  
  # 使用卡尔曼滤波进行插值
  filtered <- dlmFilter(uniform_data[[sample_name]], model)
  
  # 获取插值结果
  interpolated_values <- filtered$m
  
  # 删除插值结果中的第一行，即卡尔曼滤波的初始化值
  interpolated_values <- interpolated_values[-1]  # 去除第一行
  
  # 将插值结果添加到数据框
  uniform_data[[paste("Interpolated", sample_name, sep = "_")]] <- c(interpolated_values)  # 保留原始长度
  
  return(uniform_data)
}


df <- read.csv("数据清洗后/cd_NaddinWater.csv", header = FALSE)
# 将数据框转置
df_transposed2 <- as.data.frame(t(df))
df_transposed2[1,1] <- "Time"
# 将第一行作为列名，并删除第一行
colnames(df_transposed2) <- as.character(df_transposed2[1, ])
df_transposed2 <- df_transposed2[-1, ]
# 将数值列转换为数值类型
library(dplyr)
df_transposed2 <- df_transposed2 %>% mutate(across(-Time, as.numeric))  # 除 "Time" 列外，其他列都转换为数值
df_transposed2$Time <- as.numeric(df_transposed2$Time)                 # 转换 "Time" 列为数值

# 假设 df_transposed2 是原始数据框，包含 Time 和一些实验数据列
# df_transposed2 <- data.frame(
#   Time = 1:10,
#   Interpolated_CK_A = rnorm(10, 10),
#   Interpolated_LN_B = rnorm(10, 12),
#   Interpolated_MN_C = rnorm(10, 14),
#   Interpolated_MN_NH4 = rnorm(10, 13),
#   Interpolated_MN_NO3 = rnorm(10, 15),
#   Interpolated_HN_F = rnorm(10, 11)
# )


# names_list 包含了你希望处理的组名
names_list <- c("CK", "LN", "MN", "MN-NH4", "MN-NO3", "HN")

# 创建一个空的数据框，最终将各组数据合并
df_combined <- data.frame(Time = df_transposed2$Time)

# 循环遍历每个组名
for (name in names_list) {
  # 使用列名模式匹配提取包含特定组名的列
  cols <- grep(name, names(df_transposed2), value = TRUE)
  
  # 如果匹配到列
  if (length(cols) > 0) {
    # 提取这些列
    temp_df <- df_transposed2[, c("Time", cols)]
    
    # 修改列名为目标名称，例如：CK_1, CK_2 等
    new_colnames <- paste0(name, "_", seq_along(cols))  # 生成新的列名
    colnames(temp_df)[2:length(cols) + 1] <- new_colnames  # 修改列名
    
    # 将提取的列合并到 df_transposed 数据框
    df_transposed <- cbind(df_transposed, temp_df[, -1])  # 排除 Time 列
  }
  # 为每个样本进行卡尔曼滤波插值并重命名插值列
  
  # 要插值的样本名称从 "CK_1" 到 "CK_6"
  sample_names <- paste0(name,"_", 1:6)
  
  # 创建一个空列表保存每个样本的插值结果
  samples <- list()
  final_data <-list()
  # 循环插值每个样本并保存
  for (name in sample_names) {
    samples[[name]] <- kalman_interpolate(df_transposed, sample_name = name)
  }
  
  # 合并所有插值结果到 final_data
  final_data <- samples[[sample_names[1]]][, c("Time", paste0("Interpolated_", sample_names[1]))]
  
  # 通过循环合并每个样本的插值结果
  for (name in sample_names[-1]) {
    final_data <- merge(final_data, samples[[name]][, c("Time", paste0("Interpolated_", name))], by = "Time", all = TRUE)
  }
  
  # 查看最终的 final_data
  print(final_data)
  
#     # for (i in 1:6) {
#     # sample1 <- kalman_interpolate(df_transposed, sample_name = paste0(name, "_",i))
#     # sample2 <- kalman_interpolate(df_transposed, sample_name = "CK_2")
#     # sample3 <- kalman_interpolate(df_transposed, sample_name = "CK_3")
#     # sample4 <- kalman_interpolate(df_transposed, sample_name = "CK_4")
#     # sample5 <- kalman_interpolate(df_transposed, sample_name = "CK_5")
#     # sample6 <- kalman_interpolate(df_transposed, sample_name = "CK_6")
#     # 
#     # 合并所有样本的插值结果
#     final_data <- merge(final_data, sample2[,c("Time","Interpolated_CK_2")], by = "Time", all = TRUE)
#     final_data <- merge(final_data, sample3[,c("Time","Interpolated_CK_3")], by = "Time", all = TRUE)
#     final_data <- merge(final_data, sample4[,c("Time","Interpolated_CK_4")], by = "Time", all = TRUE)
#     final_data <- merge(final_data, sample5[,c("Time","Interpolated_CK_5")], by = "Time", all = TRUE)
#     final_data <- merge(final_data, sample6[,c("Time","Interpolated_CK_6")], by = "Time", all = TRUE)
#   }
#   
# }


# 查看最终的合并数据框
head(final_data)

# 按时间顺序逐行计算均值和标准误差
# 使用 apply 函数按行计算平均值和标准误差
mean_values <- apply(final_data[, 8:13], 1, mean)  # 计算每行的平均值
stderr_values <- apply(final_data[, 8:13], 1, function(x) sd(x) / sqrt(length(x)))  # 计算每行的标准误差

# 创建一个新的数据框保存结果
result_df <- data.frame(Time = final_data$Time, Mean = mean_values, SE = stderr_values)

# 打印结果
print(result_df)