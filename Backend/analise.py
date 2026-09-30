import pandas as pd
from pathlib import Path

def carregar_dados():
    pasta_projeto = Path(__file__).resolve().parent.parent
    caminho_csv = pasta_projeto / "Database" / "dados.csv"

    dados = pd.read_csv(caminho_csv)

    return dados
def calcular_estatisticas(dados, coluna):
    print("Média:", dados[coluna].mean())
    print("Mediana:", dados[coluna].median())
    print("Mínimo:", dados[coluna].min())
    print("Máximo:", dados[coluna].max())
    print("Desvio padrão:", dados[coluna].std())


def agregar_dados(dados, coluna_grupo):
    return dados.groupby(coluna_grupo).size()


def classificar_distancia(valor):
    if valor < 0.48:
        return "curta"
    elif valor < 1.17:
        return "média"
    else:
        return "longa"


def aplicar_classificacao(dados, coluna):
    dados["classificacao_distancia"] = dados[coluna].apply(
        classificar_distancia
    )
    return dados