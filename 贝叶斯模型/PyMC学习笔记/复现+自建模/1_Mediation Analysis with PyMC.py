import arviz as az
import matplotlib.pyplot as plt
import matplotlib
import numpy as np
import pymc as pm
import seaborn as sns
from pandas import DataFrame

# 设置 Matplotlib 配置
matplotlib.use("TkAgg")  # 或者 "Agg", "Qt5Agg", 根据环境选择
plt.rcParams.update({"font.size": 14})

# 随机数生成器
seed = 42
rng = np.random.default_rng(seed)


# 数据生成函数
def make_data():
    N = 75
    a, b, cprime = 0.5, 0.6, 0.3
    im, iy, σm, σy = 2.0, 0.0, 0.5, 0.5
    x = rng.normal(loc=0, scale=1, size=N)
    m = im + rng.normal(loc=a * x, scale=σm, size=N)
    y = iy + (cprime * x) + rng.normal(loc=b * m, scale=σy, size=N)
    print(f"True direct effect = {cprime}")
    print(f"True indirect effect = {a * b}")
    print(f"True total effect = {cprime + a * b}")
    return x, m, y



# 中介模型函数
def mediation_model(x, m, y):
    with pm.Model() as model:
        # 截距的先验分布
        im = pm.Normal("im", mu=0, sigma=10)
        iy = pm.Normal("iy", mu=0, sigma=10)
        # 斜率的先验分布
        a = pm.Normal("a", mu=0, sigma=10)
        b = pm.Normal("b", mu=0, sigma=10)
        cprime = pm.Normal("cprime", mu=0, sigma=10)
        # 噪声的先验分布
        σm = pm.HalfCauchy("σm", 1)
        σy = pm.HalfCauchy("σy", 1)

        # 似然函数
        pm.Normal("m_likelihood", mu=im + a * x, sigma=σm, observed=m)
        pm.Normal("y_likelihood", mu=iy + b * m + cprime * x, sigma=σy, observed=y)

        # 计算感兴趣的量
        indirect_effect = pm.Deterministic("indirect_effect", a * b)
        total_effect = pm.Deterministic("total_effect", a * b + cprime)

    return model


if __name__ == '__main__':
    # 生成数据
    x, m, y = make_data()

    # 可视化数据对比图
    sns.pairplot(DataFrame({"x": x, "m": m, "y": y}))
    plt.savefig("data_comparison.png")

    # 构建中介模型
    model = mediation_model(x, m, y)

    # 生成并保存模型结构图
    pm.model_to_graphviz(model).render("mediation_model_structure", format="png")  # 保存为文件

    # 进行采样
    with model:
        result = pm.sample(tune=4000, target_accept=0.9, random_seed=42)

    # 生成采样结果的 Trace 图
    az.plot_trace(result)
    plt.tight_layout()
    plt.savefig("trace_plots.png")  # 保存为文件

    # 生成后验分布的 Pair 图
    az.plot_pair(
        result,
        marginals=True,
        point_estimate="median",
        figsize=(12, 12),
        scatter_kwargs={"alpha": 0.05},
        var_names=["a", "b", "cprime", "indirect_effect", "total_effect"],
    )
    plt.savefig("posterior_pair_plot.png")  # 保存为文件

    # 生成效果的后验分布图
    ax = az.plot_posterior(
        result,
        var_names=["cprime", "indirect_effect", "total_effect"],
        ref_val=0,
        hdi_prob=0.95,
        figsize=(14, 4),
    )
    ax[0].set_title("direct effect")
    plt.savefig("posterior_distributions.png")  # 保存为文件
    # plt.show()   #必须关闭才能进行下一步代码


    # 总效果模型
    with pm.Model() as total_effect_model:
        _x = pm.ConstantData("_x", x)
        iy = pm.Normal("iy", mu=0, sigma=1)
        c = pm.Normal("c", mu=0, sigma=1)
        σy = pm.HalfCauchy("σy", 1)
        μy = iy + c * _x
        pm.Normal("yy", mu=μy, sigma=σy, observed=y)

        with total_effect_model:
            total_effect_result = pm.sample(tune=4000, target_accept=0.9, random_seed=42)

            fig, ax = plt.subplots(figsize=(14, 4))
            az.plot_posterior(
                total_effect_result, var_names=["c"], point_estimate=None, hdi_prob=0.95, color="r", lw=4, ax=ax
            )
            # az.plot_posterior(
            #     result, var_names=["total_effect"], point_estimate=None, hdi_prob=0.95, color="k", lw=4, ax=ax
            # )
            plt.tight_layout()
    plt.savefig("total_effect_comparison.png")  # 保存为文件
plt.show()