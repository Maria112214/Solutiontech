from analise import (
    carregar_dados,
    calcular_estatisticas,
    agregar_dados,
    aplicar_classificacao
)

import matplotlib.pyplot as plt


dados = carregar_dados()

print("Primeiras linhas:")
print(dados.head())

print("\nInformações dos dados:")
dados.info()

print("\nColunas:")
print(dados.columns)

print("\nValores nulos:")
print(dados.isnull().sum())

print("\nEstatísticas da distância:")
calcular_estatisticas(dados, "distancia_solicitacao")

print("\nSolicitações por tipo:")
resultado = agregar_dados(dados, "tipo_solicitacao")
print(resultado)

print("\nClassificação das distâncias:")
dados = aplicar_classificacao(dados, "distancia_solicitacao")
print(
    dados[
        ["distancia_solicitacao", "classificacao_distancia"]
    ].head(10)
)

print("\nQuantidade por classificação:")
print(dados["classificacao_distancia"].value_counts())

print("\nCriando gráfico...")

resultado.plot(kind="bar")

plt.title("Solicitações por tipo")
plt.xlabel("Tipo de solicitação")
plt.ylabel("Quantidade")
plt.tight_layout()
plt.show()