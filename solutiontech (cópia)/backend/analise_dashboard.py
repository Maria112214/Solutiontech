import pandas as pd
from analise import ler_dados


def carregar_dados_dashboard():
    dados = ler_dados()
    
    # Verifica se as colunas essenciais do CSV de totens existem
    colunas_necessarias = {"data_solicitacao", "id_solicitacao"}
    if not colunas_necessarias.issubset(dados.columns):
        raise ValueError(f"O CSV precisa ter as colunas: {colunas_necessarias}")

    if dados.empty:
        return dados

    # Trata e formata a data da solicitação (AAAA-MM-DD)
    datas = dados["data_solicitacao"].astype("string").str.strip()
    dados["data_solicitacao"] = pd.to_datetime(
        datas, format="%Y-%m-%d", errors="coerce"
    ).dt.strftime("%Y-%m-%d")

    return dados


def compras_por_dia():
    """Conta quantas solicitações distintas ocorreram por dia."""
    dados = carregar_dados_dashboard()
    if dados.empty:
        return []
    
    totais = dados.groupby("data_solicitacao")["id_solicitacao"].nunique()
    return [
        {"data": data, "total_compras": int(total)}
        for data, total in totais.sort_index().items()
        if pd.notna(data)
    ]


def faturamento_por_dia():
    """Conta quantas solicitações foram efetivamente atendidas por dia."""
    dados = carregar_dados_dashboard()
    if dados.empty:
        return []
    
    # Filtra apenas o status 'atendida' (se a coluna existir)
    if "status_solicitacao" in dados.columns:
        dados = dados[dados["status_solicitacao"] == "atendida"]
        
    totais = dados.groupby("data_solicitacao")["id_solicitacao"].nunique()
    return [
        {"data": data, "faturamento": int(total)}
        for data, total in totais.sort_index().items()
        if pd.notna(data)
    ]