from fastapi import APIRouter
from analise_dashboard import compras_por_dia, faturamento_por_dia

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/compras-por-dia")
def consultar_compras_por_dia():
    return compras_por_dia()


@router.get("/faturamento-por-dia")
def consultar_faturamento_por_dia():
    return faturamento_por_dia()