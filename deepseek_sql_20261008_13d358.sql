-- =============================================================
-- SISTEMA DE GESTÃO E INTELIGÊNCIA PARA ATENDIMENTO
-- A PESSOAS EM VULNERABILIDADE SOCIAL
-- Banco: PostgreSQL 14+ (com extensão PostGIS)
-- Chaves primárias: SERIAL (inteiro auto-incremento)
-- =============================================================

-- -------------------------------------------------------------
-- 0. EXTENSÕES NECESSÁRIAS
-- -------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS postgis;

-- -------------------------------------------------------------
-- 1. SCHEMA
-- -------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS atendimento_social;
SET search_path TO atendimento_social, public;

-- =============================================================
-- 2. TIPOS ENUMERADOS
-- =============================================================

CREATE TYPE tipo_servico_enum AS ENUM (
    'ALIMENTACAO',
    'ROUPA',
    'ABRIGO'
);

CREATE TYPE origem_atendimento_enum AS ENUM (
    'TOTEM',
    'ESPONTANEO'
);

CREATE TYPE status_ticket_enum AS ENUM (
    'EMITIDO',
    'UTILIZADO',
    'EXPIRADO',
    'CANCELADO'
);

CREATE TYPE sexo_enum AS ENUM (
    'MASCULINO',
    'FEMININO',
    'OUTRO',
    'NAO_INFORMADO'
);

CREATE TYPE faixa_idade_enum AS ENUM (
    '0-18',
    '19-30',
    '31-50',
    '51-70',
    '71+',
    'NAO_INFORMADO'
);

-- =============================================================
-- 3. TABELAS PRINCIPAIS
-- =============================================================

-- -------------------------------------------------------------
-- 3.1 TOTEM
-- -------------------------------------------------------------
CREATE TABLE totem (
    id_totem            SERIAL PRIMARY KEY,
    nome                VARCHAR(100) NOT NULL,
    descricao           VARCHAR(255),
    endereco            VARCHAR(255) NOT NULL,
    latitude            NUMERIC(10,7) NOT NULL,
    longitude           NUMERIC(10,7) NOT NULL,
    geom                GEOGRAPHY(POINT, 4326),
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    data_instalacao     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_totem_nome UNIQUE (nome),
    CONSTRAINT ck_totem_latitude  CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_totem_longitude CHECK (longitude BETWEEN -180 AND 180)
);

COMMENT ON TABLE  totem IS 'Totens físicos instalados no eixo monumental de Maringá.';
COMMENT ON COLUMN totem.geom IS 'Coluna geográfica preenchida por trigger a partir de latitude/longitude.';

-- -------------------------------------------------------------
-- 3.2 DOADOR (obrigatoriamente Pessoa Jurídica)
-- -------------------------------------------------------------
CREATE TABLE doador (
    id_doador           SERIAL PRIMARY KEY,
    razao_social        VARCHAR(200) NOT NULL,
    nome_fantasia       VARCHAR(200),
    cnpj                VARCHAR(14) NOT NULL,
    responsavel         VARCHAR(150) NOT NULL,
    telefone            VARCHAR(20)  NOT NULL,
    email               VARCHAR(150) NOT NULL,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_doador_cnpj UNIQUE (cnpj),
    CONSTRAINT ck_doador_cnpj_numerico CHECK (cnpj ~ '^[0-9]{14}$'),
    CONSTRAINT ck_doador_email CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);

COMMENT ON TABLE  doador IS 'Doador pessoa jurídica que oferta serviços.';
COMMENT ON COLUMN doador.cnpj IS 'CNPJ sem máscara, apenas 14 dígitos.';

-- -------------------------------------------------------------
-- 3.3 LOCAL DE ATENDIMENTO
-- -------------------------------------------------------------
CREATE TABLE local_atendimento (
    id_local            SERIAL PRIMARY KEY,
    id_doador           INTEGER NOT NULL,
    nome_local          VARCHAR(150) NOT NULL,
    endereco            VARCHAR(255) NOT NULL,
    latitude            NUMERIC(10,7) NOT NULL,
    longitude           NUMERIC(10,7) NOT NULL,
    geom                GEOGRAPHY(POINT, 4326),
    referencia          VARCHAR(255),
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_local_doador FOREIGN KEY (id_doador)
        REFERENCES doador (id_doador) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_local_latitude  CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_local_longitude CHECK (longitude BETWEEN -180 AND 180)
);

COMMENT ON TABLE local_atendimento IS 'Locais físicos onde o doador realiza o atendimento.';

-- -------------------------------------------------------------
-- 3.4 OFERTA (tipo + local + horário + vagas)
-- -------------------------------------------------------------
CREATE TABLE oferta (
    id_oferta           SERIAL PRIMARY KEY,
    id_local            INTEGER NOT NULL,
    tipo_servico        tipo_servico_enum NOT NULL,
    dia_semana          SMALLINT NOT NULL,
    hora_inicio         TIME NOT NULL,
    hora_fim            TIME NOT NULL,
    vagas_dia           INTEGER,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_oferta_local FOREIGN KEY (id_local)
        REFERENCES local_atendimento (id_local) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_oferta_dia_semana CHECK (dia_semana BETWEEN 0 AND 6),
    CONSTRAINT ck_oferta_horario    CHECK (hora_fim > hora_inicio),
    CONSTRAINT ck_oferta_vagas      CHECK (vagas_dia IS NULL OR vagas_dia >= 0)
);

COMMENT ON TABLE  oferta IS 'Ofertas de serviço por local, tipo e faixa de horário.';
COMMENT ON COLUMN oferta.dia_semana IS '0=domingo, 1=segunda, ..., 6=sábado.';

-- -------------------------------------------------------------
-- 3.5 TICKET (emitido no totem)
-- -------------------------------------------------------------
CREATE TABLE ticket (
    id_ticket           SERIAL PRIMARY KEY,
    id_totem            INTEGER NOT NULL,
    id_local            INTEGER NOT NULL,
    senha_sequencial    INTEGER NOT NULL,
    codigo_senha        VARCHAR(30) NOT NULL,
    data_hora_emissao   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_hora_expiracao TIMESTAMPTZ,
    status              status_ticket_enum NOT NULL DEFAULT 'EMITIDO',
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_ticket_totem FOREIGN KEY (id_totem)
        REFERENCES totem (id_totem) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ticket_local FOREIGN KEY (id_local)
        REFERENCES local_atendimento (id_local) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_ticket_codigo    UNIQUE (codigo_senha),
    CONSTRAINT ck_ticket_senha     CHECK (senha_sequencial > 0)
);

COMMENT ON TABLE  ticket IS 'Tickets emitidos no totem para apresentação no local escolhido.';
COMMENT ON COLUMN ticket.codigo_senha IS 'Código legível impresso no ticket (ex.: EST-20250510-0001).';

-- -------------------------------------------------------------
-- 3.6 TICKET_TIPO (N:N — ticket pode ter vários serviços)
-- -------------------------------------------------------------
CREATE TABLE ticket_tipo (
    id_ticket           INTEGER NOT NULL,
    tipo_servico        tipo_servico_enum NOT NULL,
    PRIMARY KEY (id_ticket, tipo_servico),
    CONSTRAINT fk_ticket_tipo_ticket FOREIGN KEY (id_ticket)
        REFERENCES ticket (id_ticket) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE ticket_tipo IS 'Tipos de serviço solicitados em cada ticket.';

-- -------------------------------------------------------------
-- 3.7 ATENDIMENTO (ficha no local)
-- -------------------------------------------------------------
CREATE TABLE atendimento (
    id_atendimento      SERIAL PRIMARY KEY,
    id_local            INTEGER NOT NULL,
    id_ticket           INTEGER,
    origem              origem_atendimento_enum NOT NULL,
    data_hora_atendimento TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sexo                sexo_enum NOT NULL DEFAULT 'NAO_INFORMADO',
    faixa_idade         faixa_idade_enum NOT NULL DEFAULT 'NAO_INFORMADO',
    observacoes         TEXT,
    data_cadastro       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_atendimento_local FOREIGN KEY (id_local)
        REFERENCES local_atendimento (id_local) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_atendimento_ticket FOREIGN KEY (id_ticket)
        REFERENCES ticket (id_ticket) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_atendimento_origem_ticket
        CHECK (
            (origem = 'TOTEM'      AND id_ticket IS NOT NULL) OR
            (origem = 'ESPONTANEO' AND id_ticket IS NULL)
        )
);

COMMENT ON TABLE  atendimento IS 'Ficha de atendimento registrada no local do doador.';
COMMENT ON COLUMN atendimento.id_ticket IS 'Nulo quando o atendimento é espontâneo.';

-- -------------------------------------------------------------
-- 3.8 ATENDIMENTO_TIPO (N:N)
-- -------------------------------------------------------------
CREATE TABLE atendimento_tipo (
    id_atendimento      INTEGER NOT NULL,
    tipo_servico        tipo_servico_enum NOT NULL,
    PRIMARY KEY (id_atendimento, tipo_servico),
    CONSTRAINT fk_atendimento_tipo FOREIGN KEY (id_atendimento)
        REFERENCES atendimento (id_atendimento) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE atendimento_tipo IS 'Tipos de serviço efetivamente entregues em cada atendimento.';

-- =============================================================
-- 4. ÍNDICES
-- =============================================================

CREATE INDEX idx_totem_geom     ON totem             USING GIST (geom);
CREATE INDEX idx_local_geom     ON local_atendimento USING GIST (geom);

CREATE INDEX idx_oferta_local_ativo    ON oferta      (id_local, ativo);
CREATE INDEX idx_oferta_tipo_ativo     ON oferta      (tipo_servico, ativo);
CREATE INDEX idx_ticket_totem_data     ON ticket      (id_totem, data_hora_emissao);
CREATE INDEX idx_ticket_local          ON ticket      (id_local);
CREATE INDEX idx_ticket_status         ON ticket      (status);
CREATE INDEX idx_atendimento_local     ON atendimento (id_local, data_hora_atendimento);
CREATE INDEX idx_atendimento_origem    ON atendimento (origem);
CREATE INDEX idx_atendimento_data      ON atendimento (data_hora_atendimento);

-- =============================================================
-- 5. TRIGGERS
-- =============================================================

-- 5.1 Preenchimento automático da coluna geom (totem)
CREATE OR REPLACE FUNCTION fn_totem_preenche_geom()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geom := ST_SetSRID(
                    ST_MakePoint(NEW.longitude, NEW.latitude),
                    4326
               )::geography;
    NEW.data_atualizacao := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_totem_geom
BEFORE INSERT OR UPDATE OF latitude, longitude ON totem
FOR EACH ROW EXECUTE FUNCTION fn_totem_preenche_geom();

-- 5.2 Preenchimento automático da coluna geom (local_atendimento)
CREATE OR REPLACE FUNCTION fn_local_preenche_geom()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geom := ST_SetSRID(
                    ST_MakePoint(NEW.longitude, NEW.latitude),
                    4326
               )::geography;
    NEW.data_atualizacao := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_local_geom
BEFORE INSERT OR UPDATE OF latitude, longitude ON local_atendimento
FOR EACH ROW EXECUTE FUNCTION fn_local_preenche_geom();

-- 5.3 Geração de senha sequencial por totem/dia
CREATE OR REPLACE FUNCTION fn_ticket_gerar_senha()
RETURNS TRIGGER AS $$
DECLARE
    v_prefixo        VARCHAR(10);
    v_data           DATE;
    v_proxima_senha  INTEGER;
BEGIN
    SELECT UPPER(SUBSTRING(REPLACE(nome, ' ', ''), 1, 3))
      INTO v_prefixo
      FROM totem
     WHERE id_totem = NEW.id_totem;

    v_data := (NEW.data_hora_emissao AT TIME ZONE 'America/Sao_Paulo')::DATE;

    SELECT COALESCE(MAX(senha_sequencial), 0) + 1
      INTO v_proxima_senha
      FROM ticket
     WHERE id_totem = NEW.id_totem
       AND (data_hora_emissao AT TIME ZONE 'America/Sao_Paulo')::DATE = v_data;

    NEW.senha_sequencial := v_proxima_senha;
    NEW.codigo_senha :=
        v_prefixo || '-' || TO_CHAR(v_data, 'YYYYMMDD') || '-' ||
        LPAD(v_proxima_senha::TEXT, 4, '0');

    IF NEW.data_hora_expiracao IS NULL THEN
        NEW.data_hora_expiracao := NEW.data_hora_emissao + INTERVAL '24 hours';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_gerar_senha
BEFORE INSERT ON ticket
FOR EACH ROW EXECUTE FUNCTION fn_ticket_gerar_senha();

-- 5.4 Atualização automática do campo data_atualizacao
CREATE OR REPLACE FUNCTION fn_atualiza_data()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_doador_data
BEFORE UPDATE ON doador
FOR EACH ROW EXECUTE FUNCTION fn_atualiza_data();

CREATE TRIGGER trg_oferta_data
BEFORE UPDATE ON oferta
FOR EACH ROW EXECUTE FUNCTION fn_atualiza_data();

CREATE TRIGGER trg_ticket_data
BEFORE UPDATE ON ticket
FOR EACH ROW EXECUTE FUNCTION fn_atualiza_data();

-- 5.5 Marca ticket como UTILIZADO ao registrar atendimento com origem TOTEM
CREATE OR REPLACE FUNCTION fn_atendimento_marca_ticket()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.origem = 'TOTEM' AND NEW.id_ticket IS NOT NULL THEN
        UPDATE ticket
           SET status = 'UTILIZADO',
               data_atualizacao = NOW()
         WHERE id_ticket = NEW.id_ticket
           AND status = 'EMITIDO';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atendimento_marca_ticket
AFTER INSERT ON atendimento
FOR EACH ROW EXECUTE FUNCTION fn_atendimento_marca_ticket();

-- =============================================================
-- 6. VIEWS DE APOIO
-- =============================================================

CREATE OR REPLACE VIEW vw_locais_disponiveis AS
SELECT
    la.id_local,
    la.nome_local,
    la.endereco,
    la.latitude,
    la.longitude,
    d.razao_social,
    d.nome_fantasia,
    d.telefone,
    d.email,
    o.tipo_servico,
    o.dia_semana,
    o.hora_inicio,
    o.hora_fim,
    o.vagas_dia
FROM local_atendimento la
JOIN doador d ON d.id_doador = la.id_doador
JOIN oferta o ON o.id_local  = la.id_local
WHERE la.ativo = TRUE
  AND d.ativo  = TRUE
  AND o.ativo  = TRUE;

COMMENT ON VIEW vw_locais_disponiveis IS 'Locais ativos com ofertas ativas e seus horários.';

CREATE OR REPLACE VIEW vw_indicadores_atendimento AS
SELECT
    a.data_hora_atendimento::DATE AS data,
    la.nome_local,
    d.razao_social,
    a.origem,
    a.sexo,
    a.faixa_idade,
    at.tipo_servico,
    COUNT(*) AS total_atendimentos
FROM atendimento a
JOIN local_atendimento la ON la.id_local = a.id_local
JOIN doador d             ON d.id_doador = la.id_doador
JOIN atendimento_tipo at  ON at.id_atendimento = a.id_atendimento
GROUP BY
    a.data_hora_atendimento::DATE,
    la.nome_local,
    d.razao_social,
    a.origem,
    a.sexo,
    a.faixa_idade,
    at.tipo_servico;

COMMENT ON VIEW vw_indicadores_atendimento IS 'Agregação anônima para dashboards de gestão.';

CREATE OR REPLACE VIEW vw_locais_por_totem AS
SELECT
    t.id_totem,
    t.nome AS nome_totem,
    la.id_local,
    la.nome_local,
    la.endereco,
    o.tipo_servico,
    o.dia_semana,
    o.hora_inicio,
    o.hora_fim,
    ROUND(ST_Distance(t.geom, la.geom)::NUMERIC, 2) AS distancia_metros
FROM totem t
CROSS JOIN local_atendimento la
JOIN oferta o ON o.id_local = la.id_local
WHERE t.ativo  = TRUE
  AND la.ativo = TRUE
  AND o.ativo  = TRUE;

COMMENT ON VIEW vw_locais_por_totem IS 'Locais ativos ordenáveis por distância em relação a cada totem.';

-- =============================================================
-- 7. DADOS INICIAIS (SEED)
-- =============================================================

INSERT INTO totem (nome, descricao, endereco, latitude, longitude)
VALUES
    ('Estádio Willie Davis',
     'Totem instalado no Estádio Willie Davis',
     'Estádio Willie Davis - Maringá/PR',
     -23.4205000, -51.9331000),
    ('Terminal Urbano',
     'Totem instalado no Terminal Urbano de Maringá',
     'Terminal Urbano - Maringá/PR',
     -23.4253000, -51.9387000),
    ('Catedral',
     'Totem instalado próximo à Catedral de Maringá',
     'Catedral Basílica Menor - Maringá/PR',
     -23.4247000, -51.9383000);

-- =============================================================
-- FIM DO SCRIPT
-- =============================================================