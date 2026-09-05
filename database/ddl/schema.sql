CREATE TABLE tb_usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome_usuario VARCHAR(100) NOT NULL
);

CREATE TABLE tb_local (
    id_local INT AUTO_INCREMENT PRIMARY KEY,
    nome_local VARCHAR(100) NOT NULL,
    localizacao VARCHAR(100) NOT NULL
);

CREATE TABLE tb_atendimento (
    id_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_local INT NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    detalhe_servico VARCHAR(150),
    data_hora DATETIME NOT NULL,
    status VARCHAR(30) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario(id_usuario),
    FOREIGN KEY (id_local) REFERENCES tb_local(id_local)
);
