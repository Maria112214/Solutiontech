from fastapi import FastAPI, HTTPException
import pandas as pd
from analise import ler_dados, resumo, por_solicitacao, por_data

app = FastAPI(
    title="Solution Tech",
    description="API para analisar os dados de solicitação por totens.",
    version="1.0.0",
)

def carregar_dados():
    try:
        return ler_dados()
    except (OSError, UnicodeError) as erro:
        raise HTTPException(
            status_code=503,
            detail='Não foi possível abrir database/compras_20.csv.',
        ) from erro
    except (ValueError, pd.errors.ParserError) as erro:
        raise HTTPException(
            status_code=422,
            detail='Confira o cabeçalho, as datas e os números do CSV.',
        ) from erro


@app.get("/")
def inicio():
    return {
        "mensagem": "API funcionando!",
        "documentacao": "/docs"
    }

@app.get("/analise/resumo")
def obter_resumo():
    dados = ler_dados()
    return resumo(dados)

@app.get("/analise/solicitacao")
def obter_produtos():
    dados = ler_dados()
    return por_solicitacao(dados)

@app.get("/analise/datas")
def obter_datas():
    dados = ler_dados()
    return por_data(dados)

