from pathlib import Path
import pandas as pd

CAMINHO_CSV = (
    Path(__file__).resolve().parent
    / "database"
    / "dados.csv"
)

COLUNAS = [
    "id_solicitacao",
    "data_solicitacao",
    "hora_solicitacao",
    "id_totem",
    "endereco_totem",
    "bairro_totem",
    "cidade_totem",
    "endereco_solicitacao",
    "bairro_solicitacao",
    "cidade_solicitacao",
    "tipo_solicitacao",
    "distancia_solicitacao",
    "horario_inicio_atendimento",
    "horario_final_atendimento",
    "status_solicitacao",
    "horario_atendimento_solicitacao",
    "data_atendimento_solicitacao",
    "data_nascimento_solicitante",
    "genero_solicitante",
    "id_local_atendimento",
    "nome_local_atendimento",
    "tipo_local_atendimento",
    "tempo_ate_atendimento",
    "motivo_nao_atendimento",
]


def ler_dados():
    df = pd.read_csv(
        CAMINHO_CSV,
        dtype={
            "id_solicitacao": "string",
            "id_totem": "string",
            "id_local_atendimento": "string",
        },
    )

    faltantes = set(COLUNAS) - set(df.columns)
    if faltantes:
        raise ValueError(
            f"Colunas ausentes no CSV: {sorted(faltantes)}"
        )

    df = df[COLUNAS].copy()

    if df.empty:
        raise ValueError("O CSV está vazio.")

    for coluna in df.select_dtypes(
        include=["object", "string"]
    ).columns:
        df[coluna] = df[coluna].str.strip()
        df[coluna] = df[coluna].replace("", pd.NA)

    obrigatorias = [
        "id_solicitacao",
        "data_solicitacao",
        "tipo_solicitacao",
        "status_solicitacao",
    ]

    if df[obrigatorias].isna().any().any():
        raise ValueError(
            "Há solicitações sem identificador, data, tipo ou status."
        )

    df["data_solicitacao"] = pd.to_datetime(
        df["data_solicitacao"],
        format="%Y-%m-%d",
        errors="raise",
    )

    for coluna in [
        "distancia_solicitacao",
        "tempo_ate_atendimento",
    ]:
        df[coluna] = pd.to_numeric(
            df[coluna], errors="raise"
        )

    if (df["distancia_solicitacao"].dropna() < 0).any():
        raise ValueError("A distância não pode ser negativa.")

    if (df["tempo_ate_atendimento"].dropna() < 0).any():
        raise ValueError("O tempo não pode ser negativo.")

    if df["id_solicitacao"].duplicated().any():
        raise ValueError(
            "Existem identificadores de solicitação repetidos."
        )

    return df


def resumo(df):
    distancias = df["distancia_solicitacao"].dropna()
    tempos = df["tempo_ate_atendimento"].dropna()

    return {
        "total_solicitacoes": int(len(df)),
        "total_totens": int(df["id_totem"].nunique()),
        "total_locais_atendimento": int(
            df["id_local_atendimento"].nunique()
        ),
        "solicitacoes_por_status": {
            str(chave): int(valor)
            for chave, valor in
            df["status_solicitacao"].value_counts().items()
        },
        "distancia_media": (
            round(float(distancias.mean()), 2)
            if not distancias.empty else None
        ),
        "tempo_medio_ate_atendimento": (
            round(float(tempos.mean()), 2)
            if not tempos.empty else None
        ),
        "data_inicial": df["data_solicitacao"].min().strftime(
            "%Y-%m-%d"
        ),
        "data_final": df["data_solicitacao"].max().strftime(
            "%Y-%m-%d"
        ),
    }


# Mantém o nome esperado pelo main.py.
# Aqui, "produtos" representa os tipos de solicitação social.
def por_solicitacao(df):
    tabela = (
        df.groupby("tipo_solicitacao")
        .size()
        .reset_index(name="total_solicitacoes")
        .sort_values("total_solicitacoes", ascending=False)
    )

    return tabela.to_dict(orient="records")


def por_data(df):
    tabela = (
        df.groupby("data_solicitacao")
        .size()
        .reset_index(name="total_solicitacoes")
        .sort_values("data_solicitacao")
    )

    tabela["data_solicitacao"] = (
        tabela["data_solicitacao"].dt.strftime("%Y-%m-%d")
    )

    return tabela.to_dict(orient="records")


if __name__ == "__main__":
    dados = ler_dados()
    print("Primeiras cinco solicitações:")
    print(dados.head())
    print("\nResumo:")
    print(resumo(dados))
    print("\nSolicitações por tipo:")
    print(por_produto(dados))
    print("\nSolicitações por data:")
    print(por_data(dados))
