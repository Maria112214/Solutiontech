from pathlib import Path
import pandas as pd

CAMINHO_CSV = Path(__file__).resolve().parent / 'database' / 'dados.csv'


def ler_dados():
    # Detecta automaticamente o separador (vírgula ou ponto e vírgula) e remove o BOM UTF-8
    df = pd.read_csv(CAMINHO_CSV, sep=None, engine='python', encoding='utf-8-sig')

    # Remove espaços extras nas extremidades dos nomes das colunas
    df.columns = df.columns.str.strip()

    colunas_obrigatorias = [
        'id_solicitacao', 'data_solicitacao', 'hora_solicitacao', 'id_totem',
        'bairro_totem', 'cidade_totem', 'tipo_solicitacao', 'distancia_solicitacao',
        'status_solicitacao', 'genero_solicitante', 'id_local_atendimento',
        'nome_local_atendimento', 'tempo_ate_atendimento'
    ]

    faltantes = set(colunas_obrigatorias) - set(df.columns)
    if faltantes:
        raise ValueError(f'Colunas ausentes no CSV: {list(faltantes)}')

    if df.empty:
        raise ValueError('O ficheiro CSV está vazio.')

    df['data_solicitacao'] = pd.to_datetime(
        df['data_solicitacao'], format='%Y-%m-%d', errors='raise'
    )
    df['distancia_solicitacao'] = pd.to_numeric(
        df['distancia_solicitacao'], errors='raise'
    )
    df['tempo_ate_atendimento'] = pd.to_numeric(
        df['tempo_ate_atendimento'], errors='coerce'
    )

    if df.duplicated(subset=['id_solicitacao']).any():
        raise ValueError('Existem IDs de solicitação duplicados na fonte.')

    return df


def resumo(df):
    return {
        'total_solicitacoes': int(len(df)),
        'total_totens': int(df['id_totem'].nunique()),
        'total_locais_atendimento': int(df['id_local_atendimento'].nunique()),
        'tipos_solicitacao': int(df['tipo_solicitacao'].nunique()),
        'solicitacoes_atendidas': int((df['status_solicitacao'] == 'atendida').sum()),
        'solicitacoes_encaminhadas': int((df['status_solicitacao'] == 'encaminhada').sum()),
        'solicitacoes_nao_atendidas': int((df['status_solicitacao'] == 'nao_atendida').sum()),
        'solicitacoes_canceladas': int((df['status_solicitacao'] == 'cancelada').sum()),
        'distancia_media_km': round(float(df['distancia_solicitacao'].mean()), 2),
        'tempo_medio_atendimento_min': round(float(df['tempo_ate_atendimento'].mean()), 2),
        'data_inicial': df['data_solicitacao'].min().strftime('%Y-%m-%d'),
        'data_final': df['data_solicitacao'].max().strftime('%Y-%m-%d'),
    }


def por_tipo(df):
    tabela = (
        df.groupby('tipo_solicitacao', as_index=False)
        .agg(
            total_solicitacoes=('id_solicitacao', 'count'),
            atendidas=('status_solicitacao', lambda x: int((x == 'atendida').sum())),
            tempo_medio_min=('tempo_ate_atendimento', lambda x: round(float(x.mean()), 2)),
        )
        .sort_values('total_solicitacoes', ascending=False)
    )
    return tabela.to_dict(orient='records')


def por_status(df):
    tabela = (
        df.groupby('status_solicitacao', as_index=False)
        .agg(total_solicitacoes=('id_solicitacao', 'count'))
        .sort_values('total_solicitacoes', ascending=False)
    )
    return tabela.to_dict(orient='records')


if __name__ == '__main__':
    dados = ler_dados()
    print('Amostra dos dados:')
    print(dados.head(3))
    print('\nResumo estatístico:')
    print(resumo(dados))