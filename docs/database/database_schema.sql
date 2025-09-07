-- Sistema de Gerenciamento de Projetos
-- Script completo de criação do banco de dados e tabelas
-- Arquivo: database_schema.sql

-- Criar o banco de dados
DROP DATABASE IF EXISTS sistema_gerenciamento_projetos;
CREATE DATABASE sistema_gerenciamento_projetos;
USE sistema_gerenciamento_projetos;

-- Tabela de Usuários
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_completo VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    login VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    perfil ENUM('administrador', 'gerente', 'colaborador') NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    INDEX idx_perfil (perfil),
    INDEX idx_ativo (ativo)
);

-- Tabela de Projetos
CREATE TABLE projetos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    data_inicio DATE NOT NULL,
    data_termino_prevista DATE NOT NULL,
    data_termino_real DATE NULL,
    status ENUM('planejado', 'em_andamento', 'concluido', 'cancelado') DEFAULT 'planejado',
    id_gerente INT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_gerente) REFERENCES usuarios(id) ON DELETE RESTRICT,
    INDEX idx_status (status),
    INDEX idx_gerente (id_gerente),
    INDEX idx_data_inicio (data_inicio)
);

-- Tabela de Equipes
CREATE TABLE equipes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nome (nome)
);

-- Tabela de Relação Usuários-Equipes (Membros das equipes)
CREATE TABLE usuarios_equipes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_equipe INT NOT NULL,
    data_vinculacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_desvinculacao TIMESTAMP NULL,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (id_equipe) REFERENCES equipes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_usuario_equipe (id_usuario, id_equipe),
    INDEX idx_equipe (id_equipe),
    INDEX idx_usuario (id_usuario),
    INDEX idx_ativo (ativo)
);

-- Tabela de Relação Equipes-Projetos (Alocação de equipes a projetos)
CREATE TABLE equipes_projetos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_equipe INT NOT NULL,
    id_projeto INT NOT NULL,
    data_alocacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_desalocacao TIMESTAMP NULL,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_equipe) REFERENCES equipes(id) ON DELETE CASCADE,
    FOREIGN KEY (id_projeto) REFERENCES projetos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_equipe_projeto (id_equipe, id_projeto),
    INDEX idx_projeto (id_projeto),
    INDEX idx_equipe (id_equipe),
    INDEX idx_ativo (ativo)
);

-- Tabela de Tarefas
CREATE TABLE tarefas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    id_projeto INT NOT NULL,
    id_responsavel INT NOT NULL,
    status ENUM('pendente', 'em_execucao', 'concluida') DEFAULT 'pendente',
    data_inicio DATE NULL,
    data_fim_prevista DATE NOT NULL,
    data_fim_real DATE NULL,
    prioridade ENUM('baixa', 'media', 'alta') DEFAULT 'media',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_projeto) REFERENCES projetos(id) ON DELETE CASCADE,
    FOREIGN KEY (id_responsavel) REFERENCES usuarios(id) ON DELETE RESTRICT,
    INDEX idx_status (status),
    INDEX idx_projeto (id_projeto),
    INDEX idx_responsavel (id_responsavel),
    INDEX idx_data_fim_prevista (data_fim_prevista)
);

-- Tabela de Logs de Atividades (Requisito implícito - auditoria)
CREATE TABLE logs_atividades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    acao VARCHAR(100) NOT NULL,
    descricao TEXT,
    tabela_afetada VARCHAR(50),
    id_registro_afetado INT,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (id_usuario),
    INDEX idx_acao (acao),
    INDEX idx_tabela (tabela_afetada),
    INDEX idx_data (data_registro)
);

-- Tabela de Token de Redefinição de Senha (Requisito implícito - segurança)
CREATE TABLE tokens_redefinicao (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    data_expiracao TIMESTAMP NOT NULL,
    utilizado BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_expiracao (data_expiracao)
);

-- Mensagem de conclusão
SELECT 'Banco de dados e tabelas criados com sucesso!' AS Status;