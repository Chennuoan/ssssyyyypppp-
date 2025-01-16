library(openxlsx)

# 创建 Workbook
wb <- createWorkbook()

# 添加工作表
addWorksheet(wb, "N添加上覆水")
addWorksheet(wb, "N添加土壤")
addWorksheet(wb, "P添加上覆水")
addWorksheet(wb, "P添加土壤")
# 写入数据到工作表，不保存行名
writeData(wb, "N添加上覆水", cal_Nwater, rowNames = FALSE)
writeData(wb, "N添加土壤", cal_Nsoil, rowNames = FALSE)
writeData(wb, "P添加上覆水", cal_Pwater, rowNames = FALSE)
writeData(wb, "P添加土壤", cal_Psoil, rowNames = FALSE)
# 保存到 Excel 文件
saveWorkbook(wb, "Eh(平均值+标准差）.xlsx", overwrite = TRUE)

# 文件 "xxxx.xlsx" 会被保存到当前工作目录

wb <- createWorkbook()
addWorksheet(wb, "N添加上覆水Eh数据")
addWorksheet(wb, "N添加土壤Eh数据")
addWorksheet(wb, "P添加上覆水Eh数据")
addWorksheet(wb, "P添加土壤Eh数据")
# 写入数据到工作表，不保存行名
writeData(wb, "N添加上覆水Eh数据", Nwaterdata, rowNames = FALSE)
writeData(wb, "N添加土壤Eh数据", Nsoildata, rowNames = FALSE)
writeData(wb, "P添加上覆水Eh数据", Pwaterdata, rowNames = FALSE)
writeData(wb, "P添加土壤Eh数据", Psoildata, rowNames = FALSE)
# 保存到 Excel 文件
saveWorkbook(wb, "Eh_6.23~9.13（数据清洗后）.xlsx", overwrite = TRUE)
