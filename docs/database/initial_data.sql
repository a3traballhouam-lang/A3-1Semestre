-- Sistema de Gerenciamento de Projetos
-- Dados iniciais para o sistema
-- Arquivo: initial_data.sql

USE sistema_gerenciamento_projetos;

-- Inserir usuários iniciais
INSERT INTO usuarios (nome_completo, cpf, email, cargo, login, senha, perfil) VALUES 
('Administrador do Sistema', '123.456.789-00', 'admin@sistema.com', 'Administrador', 'admin', SHA2('admin123', 256), 'administrador'),
('João Silva', '111.222.333-44', 'joao.silva@empresa.com', 'Gerente de Projetos', 'joao.silva', SHA2('senha123', 256), 'gerente'),
('Maria Santos', '222.333.444-55', 'maria.santos@empresa.com', 'Desenvolvedora Senior', 'maria.santos', SHA2('senha123', 256), 'colaborador'),
('Pedro Oliveira', '333.444.555-66', 'pedro.oliveira@empresa.com', 'Designer UX/UI', 'pedro.oliveira', SHA2('senha123', 256), 'colaborador'),
('Ana Costa', '444.555.666-77', 'ana.costa@empresa.com', 'Gerente de TI', 'ana.costa', SHA2('senha123', 256), 'gerente'),
('Carlos Souza', '555.666.777-88', 'carlos.souza@empresa.com', 'Desenvolvedor Fullstack', 'carlos.souza', SHA2('senha123', 256), 'colaborador');

-- Inserir projetos iniciais
INSERT INTO projetos (nome, descricao, data_inicio, data_termino_prevista, id_gerente, status) VALUES 
('Sistema de Gestão Interna', 'Desenvolvimento de sistema interno para gestão de processos da empresa', '2024-01-15', '2024-06-15', 2, 'em_andamento'),
('Site Corporativo', 'Redesign do site institucional da empresa', '2024-02-01', '2024-03-30', 2, 'planejado'),
('App Mobile', 'Desenvolvimento de aplicativo mobile para clientes', '2024-03-01', '2024-09-01', 5, 'planejado'),
('Migração para Cloud', 'Migração da infraestrutura local para nuvem', '2024-01-10', '2024-05-31', 5, 'em_andamento');

-- Inserir equipes iniciais
INSERT INTO equipes (nome, descricao) VALUES 
('Equipe Desenvolvimento Backend', 'Equipe responsável pelo desenvolvimento do backend'),
('Equipe Desenvolvimento Frontend', 'Equipe responsável pelo desenvolvimento do frontend'),
('Equipe Design', 'Equipe responsável pelo design e UX/UI'),
('Equipe Infraestrutura', 'Equipe responsável pela infraestrutura e cloud');

-- Vincular usuários às equipes
INSERT INTO usuarios_equipes (id_usuario, id_equipe) VALUES 
(3, 1), -- Maria na equipe de backend
(4, 3), -- Pedro na equipe de design
(6, 1), -- Carlos na equipe de backend
(6, 2), -- Carlos também na equipe de frontend
(3, 2); -- Maria também na equipe de frontend

-- Alocar equipes aos projetos
INSERT INTO equipes_projetos (id_equipe, id_projeto) VALUES 
(1, 1), -- Equipe backend no Sistema de Gestão
(2, 1), -- Equipe frontend no Sistema de Gestão
(3, 1), -- Equipe design no Sistema de Gestão
(3, 2), -- Equipe design no Site Corporativo
(2, 2), -- Equipe frontend no Site Corporativo
(4, 4), -- Equipe infraestrutura na Migração para Cloud
(1, 3), -- Equipe backend no App Mobile
(2, 3), -- Equipe frontend no App Mobile
(3, 3); -- Equipe design no App Mobile

-- Inserir tarefas iniciais
INSERT INTO tarefas (titulo, descricao, id_projeto, id_responsavel, status, data_inicio, data_fim_prevista, data_fim_real, prioridade) VALUES 
('Criar modelo de dados', 'Desenvolver o modelo entidade-relacionamento do sistema', 1, 3, 'concluida', '2024-01-20', '2024-02-10', '2024-02-05', 'alta'),
('Design da interface', 'Criar protótipo das telas do sistema', 1, 4, 'em_execucao', '2024-02-12', '2024-03-15', NULL, 'alta'),
('Desenvolver API REST', 'Implementar endpoints da API para o sistema', 1, 3, 'em_execucao', '2024-02-15', '2024-04-20', NULL, 'alta'),
('Homepage responsiva', 'Desenvolver homepage responsiva para o site', 2, 6, 'pendente', NULL, '2024-03-15', NULL, 'alta'),
('Configurar servidores cloud', 'Configurar infraestrutura na AWS para migração', 4, 5, 'em_execucao', '2024-01-20', '2024-03-31', NULL, 'alta'),
('Criar identidade visual', 'Desenvolter identidade visual para o aplicativo', 3, 4, 'pendente', NULL, '2024-04-15', NULL, 'media');

-- Inserir alguns logs de exemplo
INSERT INTO logs_atividades (id_usuario, acao, descricao, tabela_afetada, id_registro_afetado) VALUES 
(1, 'LOGIN', 'Usuário admin fez login no sistema', NULL, NULL),
(1, 'INSERT', 'Cadastrou novo usuário: João Silva', 'usuarios', 2),
(2, 'INSERT', 'Criou novo projeto: Sistema de Gestão Interna', 'projetos', 1);

-- Mensagem de conclusão
SELECT 'Dados iniciais importados com sucesso!' AS Status;
SELECT COUNT(*) AS 'Total de Usuários' FROM usuarios;
SELECT COUNT(*) AS 'Total de Projetos' FROM projetos;
SELECT COUNT(*) AS 'Total de Tarefas' FROM tarefas;