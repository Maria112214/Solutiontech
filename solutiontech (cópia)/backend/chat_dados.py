from analise import ler_dados, por_status, por_tipo, resumo
from analise_dashboard import compras_por_dia, faturamento_por_dia


def totalizar_solicitacoes():
    df = ler_dados()
    return {"total_solicitacoes": int(len(df))}


def consultar_resumo():
    df = ler_dados()
    return resumo(df)


def consultar_por_tipo():
    df = ler_dados()
    return por_tipo(df)


def consultar_por_status():
    df = ler_dados()
    return por_status(df)


CONSULTAS = {
    "Quantas solicitações foram realizadas?": totalizar_solicitacoes,
    "Qual é o resumo geral dos atendimentos e totens?": consultar_resumo,
    "Quantas solicitações houve por tipo de ajuda?": consultar_por_tipo,
    "Qual é a situação (status) das solicitações?": consultar_por_status,
    "Quantas solicitações houve por dia?": compras_por_dia,
    "Quantos atendimentos foram concluídos por dia?": faturamento_por_dia,
}


def encontrar_pergunta(texto):
    limpo = texto.strip().casefold()

    # 1. Verifica correspondência exata com as perguntas cadastradas
    for pergunta in CONSULTAS:
        if pergunta.casefold() == limpo:
            return pergunta

    # 2. Reconhece intenções parecidas digitadas livremente pelo usuário
    if "resumo" in limpo or "geral" in limpo:
        return "Qual é o resumo geral dos atendimentos e totens?"
    if "tipo" in limpo or "categoria" in limpo or "ajuda" in limpo:
        return "Quantas solicitações houve por tipo de ajuda?"
    if "status" in limpo or "situação" in limpo or "situacao" in limpo:
        return "Qual é a situação (status) das solicitações?"
    if ("concluíd" in limpo or "concluid" in limpo or "atendid" in limpo) and "dia" in limpo:
        return "Quantos atendimentos foram concluídos por dia?"
    if "dia" in limpo:
        return "Quantas solicitações houve por dia?"
    if ("quantas" in limpo or "total" in limpo) and ("solicita" in limpo or "chamado" in limpo):
        return "Quantas solicitações foram realizadas?"

    return None


def consultar(pergunta):
    return CONSULTAS[pergunta]()