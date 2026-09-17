-- SCRIPT DDL: CRIAÇÃO DE TABELAS
-- Projeto Totem Social

CREATE TABLE IF NOT EXISTS organizacoes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    contato VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS pontos_apoio (
    id SERIAL PRIMARY KEY,
    nome_local VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    id_organizacao INT REFERENCES organizacoes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS servicos (
    id SERIAL PRIMARY KEY,
    tipo_servico VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS ponto_servico (
    id_ponto INT REFERENCES pontos_apoio(id) ON DELETE CASCADE,
    id_servico INT REFERENCES servicos(id) ON DELETE CASCADE,
    horario_funcionamento VARCHAR(100) NOT NULL,
    vagas_disponiveis INT DEFAULT 0,
    PRIMARY KEY (id_ponto, id_servico)
);

CREATE TABLE IF NOT EXISTS totens (
    id SERIAL PRIMARY KEY,
    codigo_totem VARCHAR(20) UNIQUE NOT NULL,
    localizacao VARCHAR(100) NOT NULL,
    status_operacional VARCHAR(20) DEFAULT 'Ativo'
);
