library(ggplot2)
library(dplyr)
library(tidyr)
library(ggsci)

# 读取数据
df <- read.csv("cd-Eh(N).csv", header = TRUE)

# 转换为长格式
df_long <- df %>%
  pivot_longer(
    cols = -Time, 
    names_to = c(".value", "Group"), 
    names_sep = "_"
  )

title1 <- c(
  "CK", 
  "LN", 
  "MN", 
  expression(MN~(NH[4]^"+")),   # NH₄⁺
  expression(MN~(NO[3]^"-")),   # NO₃⁻
  "HN"
)
# scale_color_manual(
#   values = c(
#     "CK" = "blue",
#     "LN" = "orange",
#     "MN" = "green",
#     "MN.NH4" = "gray",
#     "MN.NO3" = "gold",
#     "HN" = "forestgreen"
#   ),
#   labels = title1  # 使用 expression 列表作为图例标签
# ) +

ggplot(df_long, aes(x = Time, y = mean, color = Group, group = Group)) +
  geom_line(size = 1) +                                # 绘制折线
  geom_point(size = 2) +                               # 添加数据点
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), 
                width = 0.1, size = 0.2, alpha = 0.7) + # 添加误差棒
  labs(
    title = "Soil Pore Water Eh",
    x = "Time", 
    y = ""
  ) +
  scale_color_jco(labels = title1)+
  theme_minimal() +                                   # 使用简约主题
  theme(
    panel.grid.major = element_blank(),               # 去掉主网格线
    panel.grid.minor = element_blank(),               # 去掉次网格线
    panel.background = element_blank(),               # 去掉背景
    panel.border = element_rect(color = "black", fill = NA, size = 1), # 外部框线
    axis.line = element_line(color = "black"),        # 坐标轴线
    axis.ticks.length = unit(0.25, "cm"),             # 设置纵坐标外凸刻度线长度
    axis.ticks.y = element_line(size = 2, color = "black"),  # 设置纵坐标刻度线的样式
    legend.position = "right",                        # 将图例放在右侧
    legend.title = element_blank(),                   # 去掉图例标题
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5), # 图标题居中
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 20),
    legend.text = element_text(size = 15),
    plot.margin = margin(10, 15, 10, 10)              # 调整图形的边距，压缩空间
  ) +
  coord_cartesian(clip = "off")                       # 压缩图形显示比例
# 保存图形为 PNG 格式，设置较高的分辨率（例如 300 dpi）
ggsave("土壤孔隙水Eh变化.jpg", dpi = 300, width = 8, height = 10)




# 读取数据
df <- read.csv("cd-pH(N).csv", header = TRUE)

# 转换为长格式
df_long <- df %>%
  pivot_longer(
    cols = -Time, 
    names_to = c(".value", "Group"), 
    names_sep = "_"
  )


ggplot(df_long, aes(x = Time, y = mean, color = Group, group = Group)) +
  geom_line(size = 1) +                                # 绘制折线
  geom_point(size = 3) +                               # 添加数据点
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), 
                width = 0.1, size = 0.2, alpha = 0.5) + # 添加误差棒
  labs(
    title = "Soil Pore Water pH",
    x = "Time", 
    y = ""
  ) +
  scale_color_jco(labels = title1)+
  theme_minimal() +                                   # 使用简约主题
  theme(
    panel.grid.major = element_blank(),               # 去掉主网格线
    panel.grid.minor = element_blank(),               # 去掉次网格线
    panel.background = element_blank(),               # 去掉背景
    panel.border = element_rect(color = "black", fill = NA, size = 1), # 外部框线
    axis.line = element_line(color = "black"),        # 坐标轴线
    axis.ticks.length = unit(0.25, "cm"),             # 设置纵坐标外凸刻度线长度
    axis.ticks.y = element_line(size = 1, color = "black"),  # 设置纵坐标刻度线的样式
    legend.position = "right",                        # 将图例放在右侧
    legend.title = element_blank(),                   # 去掉图例标题
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5), # 图标题居中
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 20),
    legend.text = element_text(size = 15),
    plot.margin = margin(10, 15, 10, 10)              # 调整图形的边距，压缩空间
  ) +
  coord_cartesian(clip = "off")                       # 压缩图形显示比例
# 保存图形为 PNG 格式，设置较高的分辨率（例如 300 dpi）
ggsave("土壤孔隙水pH变化.jpg", dpi = 300, width = 8, height = 10)