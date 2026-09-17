-- SCRIPT DQL: CONSULTAS DE NEGÓCIO
-- Projeto Totem Social

-- 1. Consulta simples: Listar todos os totens ativos e suas localizações
SELECT codigo_totem, localizacao, status_operacional 
FROM totens 
WHERE status_operacional = 'Ativo';

-- 2. Consulta com JOIN: Listar locais, endereço e a organização responsável
SELECT 
    p.nome_local, 
    p.endereco, 
    o.nome AS organizacao_responsavel, 
    o.tipo
FROM pontos_apoio p
INNER JOIN organizacoes o ON p.id_organizacao = o.id;

-- 3. Consulta complexa: Buscar todos os serviços de Alimentação disponíveis com vagas
SELECT 
    p.nome_local,
    p.endereco,
    s.tipo_servico,
    ps.horario_funcionamento,
    ps.vagas_disponiveis
FROM ponto_servico ps
INNER JOIN pontos_apoio p ON ps.id_ponto = p.id
INNER JOIN servicos s ON ps.id_servico = s.id
WHERE s.tipo_servico = 'Alimentação' AND ps.vagas_disponiveis > 0;
