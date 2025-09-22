# --- Celda con código corregido para usar 'lsalmes' ---
# Puedes copiar este código y pegarlo en una nueva celda de tu notebook.

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

# 1. Funciones para Estadísticos Ponderados
def weighted_quantile(values, quantiles, sample_weight=None):
    values = np.array(values)
    quantiles = np.array(quantiles)
    if sample_weight is None:
        sample_weight = np.ones(len(values))
    sample_weight = np.array(sample_weight)
    sorter = np.argsort(values)
    values = values[sorter]
    sample_weight = sample_weight[sorter]
    weighted_quantiles = np.cumsum(sample_weight) - 0.5 * sample_weight
    weighted_quantiles /= np.sum(sample_weight)
    return np.interp(quantiles, weighted_quantiles, values)

def weighted_std(values, weights):
    average = np.average(values, weights=weights)
    variance = np.average((values - average)**2, weights=weights)
    return np.sqrt(variance)

def weighted_gini(values, weights):
    values = np.array(values)
    weights = np.array(weights)
    sorter = np.argsort(values)
    sorted_values = values[sorter]
    sorted_weights = weights[sorter]
    cum_weights = np.cumsum(sorted_weights)
    total_weight = cum_weights[-1]
    ranks = (cum_weights - 0.5 * sorted_weights) / total_weight
    mean = np.average(sorted_values, weights=sorted_weights)
    if mean == 0:
        return 0
    cov_y_rank = np.average((sorted_values - mean) * (ranks - np.average(ranks, weights=sorted_weights)), weights=sorted_weights)
    return 2 * cov_y_rank / mean

# 2. Cálculo de los Estadísticos por Año
# Asegúrate de que el DataFrame 'df' está cargado y tiene la columna 'lsalmes'
results = {}
years = ['2010', '2014', '2018']
df['salmes'] = pd.to_numeric(df['salmes'], errors='coerce')
df['factotal'] = pd.to_numeric(df['factotal'], errors='coerce')

for year in years:
    year_data = df[df['year'] == year].copy()
    # --- MODIFICACIÓN: Usar 'lsalmes' ---
    values = year_data['lsalmes'].dropna()
    weights = year_data.loc[values.index, 'factotal']
    
    gini = weighted_gini(values, weights)
    std = weighted_std(values, weights)
    p10, p90 = weighted_quantile(values, [0.1, 0.9], sample_weight=weights)
    iqr = p90 - p10
    
    results[year] = {
        'Gini': gini,
        'Std. Dev.': std,
        'IQR (90-10)': iqr
    }

results_df = pd.DataFrame(results).T
print("Estadísticos de Desigualdad Calculados (usando lsalmes):")
print(results_df)

# 3. Generación del Gráfico
labels = results_df.columns
years = results_df.index
x = np.arange(len(labels))
width = 0.25

fig, ax1 = plt.subplots(figsize=(14, 8))

# Agrupar por estadística en el eje X
gini_values = results_df['Gini'].values
std_values = results_df['Std. Dev.'].values
iqr_values = results_df['IQR (90-10)'].values

# Posiciones para cada grupo de barras
pos_gini = np.array([0])
pos_std = np.array([1])
pos_iqr = np.array([2])

# Eje Izquierdo (Gini)
color_gini = 'tab:blue'
ax1.bar(pos_gini - width, gini_values[0], width, label='2010', color='#1f77b4')
ax1.bar(pos_gini, gini_values[1], width, label='2014', color='#ff7f0e')
ax1.bar(pos_gini + width, gini_values[2], width, label='2018', color='#2ca02c')
ax1.set_ylabel('Coeficiente de Gini', color=color_gini, fontsize=12)
ax1.tick_params(axis='y', labelcolor=color_gini)

# Eje Derecho (Std. Dev. y IQR)
ax2 = ax1.twinx()
# --- MODIFICACIÓN: Etiqueta del eje Y ---
ax2.set_ylabel('Log Salario Mensual', fontsize=12)

ax2.bar(pos_std - width, std_values[0], width, color='#1f77b4')
ax2.bar(pos_std, std_values[1], width, color='#ff7f0e')
ax2.bar(pos_std + width, std_values[2], width, color='#2ca02c')

ax2.bar(pos_iqr - width, iqr_values[0], width, color='#1f77b4')
ax2.bar(pos_iqr, iqr_values[1], width, color='#ff7f0e')
ax2.bar(pos_iqr + width, iqr_values[2], width, color='#2ca02c')

# Configuración final del gráfico
ax1.set_xticks(x)
ax1.set_xticklabels(labels)
ax1.set_xlabel('Medida de Desigualdad', fontsize=12)
# --- MODIFICACIÓN: Título del gráfico ---
fig.suptitle('Evolución de Medidas de Desigualdad Salarial (lsalmes)', fontsize=16)

# Crear leyenda manualmente
legend_elements = [Patch(facecolor='#1f77b4', label='2010'),
                   Patch(facecolor='#ff7f0e', label='2014'),
                   Patch(facecolor='#2ca02c', label='2018')]
fig.legend(handles=legend_elements, loc='upper left', bbox_to_anchor=(0.1, 0.9))

fig.tight_layout()
plt.show()
