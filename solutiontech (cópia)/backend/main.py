from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
from analise import ler_dados, resumo, por_tipo, por_status

from controller.dashboard import router as dashboard_router
from controller.chat import router as chat_router

app = FastAPI(title='API de Ciência de Dados - Atendimentos por Totem')

# Configuração de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registra os routers do dashboard e do chat
app.include_router(dashboard_router)
app.include_router(chat_router)


def carregar_dados():
    try:
        return ler_dados()
    except (OSError, UnicodeError) as erro:
        raise HTTPException(
            status_code=503,
            detail='Não foi possível abrir o ficheiro database/dados.csv.',
        ) from erro
    except (ValueError, pd.errors.ParserError) as erro:
        raise HTTPException(
            status_code=422,
            detail='Confira o cabeçalho e os dados do ficheiro CSV.',
        ) from erro


@app.get('/')
def inicio():
    return {'mensagem': 'Backend de análise de solicitações em funcionamento'}


@app.get('/analise/resumo')
def consultar_resumo():
    dados = carregar_dados()
    return resumo(dados)


@app.get('/analise/tipos')
def consultar_tipos():
    dados = carregar_dados()
    return por_tipo(dados)


@app.get('/analise/status')
def consultar_status():
    dados = carregar_dados()
    return por_status(dados)