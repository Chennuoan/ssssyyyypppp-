import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pymc as pm
import arviz as az

# 确保保存图片的文件夹存在
os.makedirs("plots_interaction", exist_ok=True)

# 修正字体设置
plt.rcParams['font.sans-serif'] = ['SimSun', 'Microsoft YaHei', 'SimHei']  # 中文字体
plt.rcParams['font.family'] = ['SimSun']  # 设置为宋体
plt.rcParams['axes.unicode_minus'] = False  # 解决负号显示问题

# 设置随机种子
np.random.seed(42)


# 读取数据
def load_data(file_path):
    try:
        data = pd.read_csv(file_path)
        data['date'] = pd.to_datetime(data['date'])
        data['time'] = (data['date'] - data['date'].min()).dt.days  # 计算天数差
        return data
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        raise
    except Exception as e:
        print(f"读取数据时发生错误: {e}")
        raise


# 数据绘图
def plot_data(data, output_dir="plots_interaction"):
    try:
        plt.figure(figsize=(12, 6))
        titles = ["ozone", "temperature", "relative_humidity", "numdeaths"]
        columns = ["ozone", "temperature", "relative_humidity", "numdeaths"]
        colors = ['blue', 'orange', 'green', 'red']

        for i in range(4):
            plt.subplot(2, 2, i + 1)
            plt.plot(data['time'], data[columns[i]], label=titles[i], color=colors[i])
            plt.title(titles[i])

        plt.tight_layout()
        plt.savefig(f"{output_dir}/data_plots.png", dpi=300, bbox_inches="tight")
        plt.close()
    except Exception as e:
        print(f"绘图时发生错误: {e}")
        raise


# 贝叶斯模型运行
def run_model_with_interactions(data):
    try:
        with pm.Model() as model:
            intercept = pm.Normal('intercept', mu=0, sigma=5)
            beta_ozone = pm.Normal('beta_ozone', mu=0, sigma=10)
            beta_temp = pm.Normal('beta_temp', mu=0, sigma=5)
            beta_humidity = pm.Normal('beta_humidity', mu=0, sigma=5)
            beta_interaction_ozone_temp = pm.Normal('beta_interaction_ozone_temp', mu=0, sigma=5)
            beta_interaction_ozone_humidity = pm.Normal('beta_interaction_ozone_humidity', mu=0, sigma=5)
            beta_interaction_temp_humidity = pm.Normal('beta_interaction_temp_humidity', mu=0, sigma=5)
            sigma = pm.HalfNormal('sigma', sigma=1)

            # 交互项
            interaction_ozone_temp = data['ozone'] * data['temperature']
            interaction_ozone_humidity = data['ozone'] * data['relative_humidity']
            interaction_temp_humidity = data['temperature'] * data['relative_humidity']

            # 线性模型，包括交互项
            mu = intercept + beta_ozone * data['ozone'] + beta_temp * data['temperature'] + beta_humidity * data['relative_humidity'] \
                + beta_interaction_ozone_temp * interaction_ozone_temp \
                + beta_interaction_ozone_humidity * interaction_ozone_humidity \
                + beta_interaction_temp_humidity * interaction_temp_humidity

            Y_obs = pm.Normal('Y_obs', mu=mu, sigma=sigma, observed=data['numdeaths'])
            trace = pm.sample(2000, tune=1000, chains=4, cores=4, return_inferencedata=False)

        # 收敛性诊断
        inference_data = pm.to_inference_data(trace, model=model)

        # 查看参数的 R-hat 和 n_eff
        summary = az.summary(inference_data, hdi_prob=0.95)
        print("Summary Output:")
        print(summary)

        # 绘制后验分布图
        az.plot_posterior(inference_data, var_names=['intercept', 'beta_ozone', 'beta_temp', 'beta_humidity',
                                                     'beta_interaction_ozone_temp', 'beta_interaction_ozone_humidity',
                                                     'beta_interaction_temp_humidity'])
        plt.savefig("plots_interaction/posterior_distribution_interactions.png", dpi=300, bbox_inches="tight")
        plt.close()

        return trace, model, mu

    except Exception as e:
        print(f"模型运行出错: {e}")
        raise


        # 绘制参数的后验分布图
        az.plot_posterior(inference_data, var_names=['intercept', 'beta_ozone', 'beta_temp', 'beta_humidity'])
        plt.savefig("plots_interaction/posterior_distribution.png", dpi=300, bbox_inches="tight")
        plt.close()
        # 设置图形的大小
        plt.figure(figsize=(10, 8))  # 这里修改了高度，宽度保持为 10
        # 绘制链的轨迹图
        az.plot_trace(inference_data, var_names=['intercept', 'beta_ozone', 'beta_temp', 'beta_humidity'])
        # 增加间距，避免标题重叠
        plt.subplots_adjust(hspace=0.4)  # 调整子图之间的垂直间距
        plt.savefig("plots_interaction/trace_plots.png", dpi=300, bbox_inches="tight")
        plt.close()

        return trace, model, mu
    except Exception as e:
        print(f"模型运行出错: {e}")
        raise


def posterior_predictive_plot_with_CI(data, model, trace, output_dir="plots_interaction"):
    try:
        # 获取后验预测
        with model:
            # 采样所有变量
            posterior_predictive = pm.sample_posterior_predictive(trace, var_names=['Y_obs'])

        # 确保 posterior_predictive 中包含 'Y_obs'
        if 'Y_obs' not in posterior_predictive['posterior_predictive']:
            print("Error: 后验预测中没有 'Y_obs' 变量")
            return

        # 获取预测值 (形状为 (4, 2000, 1826))
        predicted_values = posterior_predictive['posterior_predictive']['Y_obs']

        # 将 'DataArray' 转换为 numpy 数组
        predicted_values = predicted_values.values  # 转换为 numpy 数组

        # 合并链维度，形状变为 (2000, 1826)
        predicted_values = predicted_values.reshape(-1, predicted_values.shape[-1])

        # 计算 95% 可信区间
        lower_bound = np.percentile(predicted_values, 2.5, axis=0)  # 2.5% 分位数
        upper_bound = np.percentile(predicted_values, 97.5, axis=0)  # 97.5% 分位数

        # 计算均值预测
        avg_prediction = predicted_values.mean(axis=0)  # 对2000次采样的结果进行均值处理，得到(1826,)

        # 确保数据和预测值的维度匹配
        if len(data['time']) != len(avg_prediction):
            print(f"Error: 维度不匹配 - data['time']({len(data['time'])}) 与 avg_prediction({len(avg_prediction)}) 的长度不同")
            return

        # 绘制实际与预测死亡人数对比图，并加上可信区间
        plt.figure(figsize=(10, 6))
        plt.plot(data['time'], data['numdeaths'], label="实际死亡人数", color='blue')
        plt.plot(data['time'], avg_prediction, label="均值预测", color='green')
        plt.fill_between(data['time'], lower_bound, upper_bound, color='gray', alpha=0.3, label="95%可信区间")

        # 设置图例位置
        plt.legend(loc='upper right')

        plt.title("实际与预测死亡人数对比（带有可信区间）")
        plt.xlabel("时间 (天)")
        plt.ylabel("死亡人数")
        plt.savefig(f"{output_dir}/actual_vs_predicted_with_CI.png", dpi=300, bbox_inches="tight")
        plt.close()

    except Exception as e:
        print(f"后验预测绘图时出错: {e}")
        raise


def posterior_predictive_plot(data, model, trace, output_dir="plots_interaction"):
    try:
        # 获取后验预测
        with model:
            # 采样所有变量
            posterior_predictive = pm.sample_posterior_predictive(trace, var_names=['Y_obs'])

        # 确保 posterior_predictive 中包含 'Y_obs'
        if 'Y_obs' not in posterior_predictive['posterior_predictive']:
            print("Error: 后验预测中没有 'Y_obs' 变量")
            return

        # 获取预测值 (形状为 (4, 2000, 1826))
        predicted_values = posterior_predictive['posterior_predictive']['Y_obs']

        # 将 'DataArray' 转换为 numpy 数组
        predicted_values = predicted_values.values  # 转换为 numpy 数组

        # 合并链维度，形状变为 (2000, 1826)
        predicted_values = predicted_values.reshape(-1, predicted_values.shape[-1])

        # 计算不同次数的均值
        avg_500 = predicted_values[:500, :].mean(axis=0)  # 0-500次的均值
        avg_1000 = predicted_values[:1000, :].mean(axis=0)  # 0-1000次的均值
        avg_1500 = predicted_values[:1500, :].mean(axis=0)  # 0-1500次的均值
        avg_2000 = predicted_values[:2000, :].mean(axis=0)  # 0-2000次的均值

        # 计算 95% 可信区间
        lower_bound_95 = np.percentile(predicted_values, 2.5, axis=0)
        upper_bound_95 = np.percentile(predicted_values, 97.5, axis=0)

        # 确保数据和预测值的维度匹配
        if len(data['time']) != len(avg_500):
            print(f"Error: 维度不匹配 - data['time']({len(data['time'])}) 与 avg_500({len(avg_500)}) 的长度不同")
            return

        # 绘制实际与预测死亡人数对比图，显示不同次数的预测均值曲线
        plt.figure(figsize=(10, 6))
        plt.plot(data['time'], data['numdeaths'], label="实际死亡人数", color='blue')
        plt.plot(data['time'], avg_500, label="0-500次均值预测", color='green')
        plt.plot(data['time'], avg_1000, label="0-1000次均值预测", color='orange')
        plt.plot(data['time'], avg_1500, label="0-1500次均值预测", color='red')
        plt.plot(data['time'], avg_2000, label="0-2000次均值预测", color='purple')

        # 填充可信区间
        plt.fill_between(data['time'], lower_bound_95, upper_bound_95, color='gray', alpha=0.3, label="95%可信区间")

        # 设置图例位置
        plt.legend(loc='upper right')  # 你可以根据需要调整位置

        plt.title("实际与不同次数均值预测死亡人数对比")
        plt.xlabel("时间 (天)")
        plt.ylabel("死亡人数")
        plt.savefig(f"{output_dir}/actual_vs_avg_prediction_comparison_with_CI.png", dpi=300, bbox_inches="tight")
        plt.close()

    except Exception as e:
        print(f"后验预测绘图时出错: {e}")
        raise



def main(file_path='londondataset2002_2006.csv', output_dir="plots_interaction"):
    data = load_data(file_path)
    plot_data(data, output_dir)

    try:
        trace, model, mu = run_model_with_interactions(data)
        inference_data = pm.to_inference_data(trace, model=model)

        # 生成参数的摘要表
        summary = az.summary(inference_data, hdi_prob=0.95)
        print(summary)

        # 绘制后验分布图
        az.plot_posterior(inference_data, var_names=['intercept', 'beta_ozone', 'beta_temp', 'beta_humidity'])
        plt.savefig(f"{output_dir}/posterior_distribution.png", dpi=300, bbox_inches="tight")
        plt.close()

        posterior_predictive_plot(data, model, trace, output_dir)

    except Exception as e:
        print(f"模型运行失败: {e}")
        return


# 入口
if __name__ == '__main__':
    main()
