library(ggplot2)
library(dplyr)
# 读取CSV文件
df <- read.csv("interpolated_NaddinWater.csv", header = FALSE)

# 将第一行作为列名，并删除第一行
colnames(df) <- as.character(df[1, ])
df <- df[-1, ]

# 检查处理后的数据框
head(df)

# 将数值列转换为数值类型
df <- df %>% mutate(across(-Time, as.numeric))  # 除 "Time" 列外，其他列都转换为数值
df$Time <- as.numeric(df$Time)                 # 转换 "Time" 列为数值

library(tidyr)

# 转换为长格式,方便ggplot2函数绘图 长格式对应宽格式，方便查看数据但不方便绘图
df_long <- df %>%
  pivot_longer(cols = -Time, 
               names_to = c(".value", "Group"), 
               names_sep = "_")

# 检查转换后的数据框
head(df_long)

library(ggplot2)
library(scales)  # 提供自定义变换函数

# 自定义非线性变换函数
# time_transform <- trans_new(
#   name = "custom",
#   transform = function(x) ifelse(x <= 20, x, 20 + (x - 20) / 3),
#   inverse = function(x) ifelse(x <= 20, x, 20 + (x - 20) * 3)
# )
# 绘制折线图和误差条

ggplot(df_long, aes(x = Time, y = mean, color = Group)) +
  geom_line(size = 1) +                             # 绘制折线
  geom_point(size = 3) +                            # 添加数据点
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), 
                width = 1, size = 0.5, alpha = 0.5) +            # 添加误差条
  labs(title = "上覆水Eh随时间变化图（氮添加）",
       x = "时间（天）",
       y = "氧化还原电位（mV）") +
  # scale_x_continuous(trans = time_transform) +
  theme_minimal() +
  theme(legend.position = "top")
