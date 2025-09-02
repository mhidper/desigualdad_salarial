# Análisis de la Desigualdad Salarial en España

Este proyecto analiza la Encuesta de Estructura Salarial (EES) de España para los años 2010, 2014 y 2018. El objetivo es procesar y preparar los datos para un análisis econométrico posterior sobre la desigualdad salarial.

## Uso

1.  **Datos:** Colocar el archivo `EES10_14_18.zip` que contiene los microdatos de la encuesta en la carpeta `data/`.
2.  **Ejecución:** Abrir y ejecutar el cuaderno de Jupyter `src/generacion_base_de_datos.ipynb`.

El cuaderno se encargará de:
- Descomprimir los ficheros de datos.
- Cargar los datos de los años 2010, 2014 y 2018.
- Homogeneizar y transformar las variables.
- Eliminar los datos descomprimidos una vez cargados en memoria.

## Requisitos

Es necesario tener un entorno de Python con las siguientes librerías instaladas:

- `pandas`
- `numpy`
- `patoolib`
- `jupyter`

Se recomienda crear un entorno virtual y gestionar las dependencias.
