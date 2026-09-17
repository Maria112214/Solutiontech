# Dicionário de Dados: Totem Social

### Tabela: organizacoes
| Campo | Tipo | Restrição | Descrição |
| :--- | :--- | :--- | :--- |
| `id` | INT / SERIAL | PRIMARY KEY | Identificador único da ONG ou órgão |
| `nome` | VARCHAR(100) | NOT NULL | Nome da entidade (ex: ONG Acolher, Prefeitura) |
| `tipo` | VARCHAR(50) | NOT NULL | Categoria (ex: ONG, Órgão Público, Igreja) |
| `contato` | VARCHAR(50) | | Telefone ou e-mail de contato |

### Tabela: pontos_apoio
| Campo | Tipo | Restrição | Descrição |
| :--- | :--- | :--- | :--- |
| `id` | INT / SERIAL | PRIMARY KEY | Identificador do local de atendimento |
| `nome_local` | VARCHAR(100) | NOT NULL | Nome do local (ex: Cozinha Comunitária Central) |
| `endereco` | VARCHAR(200) | NOT NULL | Endereço completo ou ponto de referência |
| `id_organizacao`| INT | FOREIGN KEY | Integração com a tabela `organizacoes` |

### Tabela: servicos
| Campo | Tipo | Restrição | Descrição |
| :--- | :--- | :--- | :--- |
| `id` | INT / SERIAL | PRIMARY KEY | Identificador do tipo de serviço |
| `tipo_servico` | VARCHAR(50) | NOT NULL | Categorias: Alimentação, Moradia, Higiene |

### Tabela: ponto_servico
| Campo | Tipo | Restrição | Descrição |
| :--- | :--- | :--- | :--- |
| `id_ponto` | INT | FOREIGN KEY, PK | Vínculo com a tabela `pontos_apoio` |
| `id_servico` | INT | FOREIGN KEY, PK | Vínculo com a tabela `servicos` |
| `horario_funcionamento` | VARCHAR(100) | NOT NULL | Ex: "Seg a Sex, das 08h às 17h" |
| `vagas_disponiveis` | INT | DEFAULT 0 | Capacidade ou quantidade disponível no dia |

### Tabela: totens
| Campo | Tipo | Restrição | Descrição |
| :--- | :--- | :--- | :--- |
| `id` | INT / SERIAL | PRIMARY KEY | Identificador do equipamento físico |
| `codigo_totem` | VARCHAR(20) | UNIQUE, NOT NULL| Código de identificação impresso no totem |
| `localizacao` | VARCHAR(100) | NOT NULL | Ponto onde o totem está instalado (ex: Praça da Sé) |
| `status_operacional` | VARCHAR(20) | DEFAULT 'Ativo' | Estado do totem (Ativo, Manutenção, Inativo) |
