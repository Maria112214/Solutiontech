-- SCRIPT SEED: INSERÇÃO DE DADOS DE TESTE
-- Projeto Totem Social

-- 1. Inserir Organizações
INSERT INTO organizacoes (nome, tipo, contato) VALUES
('ONG Acolher e Vida', 'ONG', 'contato@acolherevida.org'),
('Prefeitura Municipal - Assistência Social', 'Órgão Público', '156@prefeitura.gov.br'),
('Instituto Papa João XXIII', 'ONG', 'atendimento@joaoxxiii.org');

-- 2. Inserir Pontos de Apoio
INSERT INTO pontos_apoio (nome_local, endereco, id_organizacao) VALUES
('Cozinha Comunitária Central', 'Rua das Flores, 123 - Centro', 1),
('Abrigo Noite Limpa', 'Av. Brasil, 450 - Bairro Alto', 2),
('Centro de Convivência Social', 'Praça da Matriz, 88 - Centro', 3);

-- 3. Inserir Tipos de Serviços
INSERT INTO servicos (tipo_servico) VALUES
('Alimentação'),
('Moradia / Pernoite'),
('Higiene Pessoal / Banho');

-- 4. Inserir Serviços oferecidos nos Pontos
INSERT INTO ponto_servico (id_ponto, id_servico, horario_funcionamento, vagas_disponiveis) VALUES
(1, 1, 'Seg a Dom, das 11h30 às 13h30', 150),
(2, 2, 'Todos os dias, das 19h às 07h', 40),
(2, 3, 'Todos os dias, das 06h às 09h', 25),
(3, 3, 'Seg a Sex, das 08h às 16h', 50);

-- 5. Inserir Totens Cadastrados
INSERT INTO totens (codigo_totem, localizacao, status_operacional) VALUES
('TOTEM-001', 'Praça da Sé - Centro', 'Ativo'),
('TOTEM-002', 'Estação Central de Metrô', 'Ativo'),
('TOTEM-003', 'Parque Municipal - Portão 2', 'Manutenção');
