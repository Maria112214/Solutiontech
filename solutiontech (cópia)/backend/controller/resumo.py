"""Rotas de consulta. Os cálculos estão no arquivo analise.py."""
from fastapi import APIRouter

from analise import (
    totalizar_solicitacao,
    totalizar_totem,
    totalizar_tipo_atendimento,
    totalizar_tipo_solicitacao,
)

router = APIRouter(prefix="/resumo", tags=["Resumo das vendas"])


@router.get("/solicitacao")
def consultar_total_solicitacao():
    """Quantas compras foram realizadas no período do CSV?"""
    return totalizar_solicitacao()


@router.get("/totem")
def consultar_total_totem():
    """Quantos clientes diferentes compraram no período?"""
    return totalizar_totem()


@router.get("/atendimento")
def consultar_total_atendimento():
    """Quantos produtos diferentes foram vendidos no período?"""
    return totalizar_tipo_atendimento()


@router.get("/tipo")
def consultar_totais_tipo_atendimento():
    """Quantas compras foram realizadas em cada forma de pagamento?"""
    return totalizar_tipo_solicitacao()
