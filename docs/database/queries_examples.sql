-- Sistema de Gerenciamento de Projetos
-- Exemplos de consultas para relatórios e dashboards
-- Arquivo: queries_examples.sql

USE sistema_gerenciamento_projetos;

-- 1. RESUMO DE ANDAMENTO DOS PROJETOS
SELECT 
    p.nome AS 'Projeto',
    p.status AS 'Status',
    p.data_inicio AS 'Início',
    p.data_termino_prevista AS 'Término Previsto',
    DATEDIFF(p.data_termino_prevista, CURDATE()) AS 'Dias Restantes',
    u.nome_completo AS 'Gerente',
    COUNT(DISTINCT t.id) AS 'Total de Tarefas',
    COUNT(DISTINCT CASE WHEN t.status = 'concluida' THEN t.id END) AS 'Tarefas Concluídas',
    COUNT(DISTINCT ep.id_equipe) AS 'Equipes Envolvidas'
FROM projetos p
LEFT JOIN usuarios u ON p.id_gerente = u.id
LEFT JOIN tarefas t ON p.id = t.id_projeto
LEFT JOIN equipes_projetos ep ON p.id = ep.id_projeto AND ep.ativo = TRUE
GROUP BY p.id
ORDER BY p.status, p.data_termino_prevista;

-- 2. DESEMPENHO DE COLABORADORES
SELECT 
    u.nome_completo AS 'Colaborador',
    u.cargo AS 'Cargo',
    COUNT(t.id) AS 'Total de Tarefas',
    COUNT(CASE WHEN t.status = 'concluida' THEN t.id END) AS 'Tarefas Concluídas',
    COUNT(CASE WHEN t.status = 'em_execucao' THEN t.id END) AS 'Tarefas em Andamento',
    COUNT(CASE WHEN t.status = 'pendente' THEN t.id END) AS 'Tarefas Pendentes',
    COUNT(CASE WHEN t.data_fim_real > t.data_fim_prevista THEN t.id END) AS 'Tarefas Atrasadas',
    COUNT(DISTINCT t.id_projeto) AS 'Projetos Envolvidos'
FROM usuarios u
LEFT JOIN tarefas t ON u.id = t.id_responsavel
WHERE u.perfil = 'colaborador' AND u.ativo = TRUE
GROUP BY u.id
ORDER BY COUNT(CASE WHEN t.status = 'concluida' THEN t.id END) DESC;

-- 3. PROJETOS COM RISCO DE ATRASO
SELECT 
    p.nome AS 'Projeto',
    p.status AS 'Status',
    p.data_termino_prevista AS 'Término Previsto',
    DATEDIFF(p.data_termino_prevista, CURDATE()) AS 'Dias Restantes',
    COUNT(t.id) AS 'Total de Tarefas',
    COUNT(CASE WHEN t.status != 'concluida' THEN t.id END) AS 'Tarefas Incompletas',
    COUNT(CASE WHEN t.data_fim_prevista < CURDATE() AND t.status != 'concluida' THEN t.id END) AS 'Tarefas Atrasadas',
    u.nome_completa AS 'Gerente'
FROM projetos p
LEFT JOIN tarefas t ON p.id = t.id_projeto
LEFT JOIN usuarios u ON p.id_gerente = u.id
WHERE p.status IN ('planejado', 'em_andamento')
    AND p.data_termino_prevista < DATE_ADD(CURDATE(), INTERVAL 30 DAY) -- Projetos que terminam em até 30 dias
GROUP BY p.id
HAVING COUNT(CASE WHEN t.status != 'concluida' THEN t.id END) > 0
ORDER BY DATEDIFF(p.data_termino_prevista, CURDATE()) ASC;

-- 4. DETALHAMENTO DE TAREFAS POR PROJETO
SELECT 
    p.nome AS 'Projeto',
    t.titulo AS 'Tarefa',
    t.status AS 'Status',
    t.prioridade AS 'Prioridade',
    t.data_fim_prevista AS 'Prazo',
    DATEDIFF(t.data_fim_prevista, CURDATE()) AS 'Dias Restantes',
    resp.nome_completo AS 'Responsável',
    CASE 
        WHEN t.data_fim_prevista < CURDATE() AND t.status != 'concluida' THEN 'ATRASADA'
        WHEN DATEDIFF(t.data_fim_prevista, CURDATE()) <= 3 AND t.status != 'concluida' THEN 'URGENTE'
        ELSE 'NORMAL'
    END AS 'Situação'
FROM tarefas t
LEFT JOIN projetos p ON t.id_projeto = p.id
LEFT JOIN usuarios resp ON t.id_responsavel = resp.id
ORDER BY p.nome, 
    CASE 
        WHEN t.data_fim_prevista < CURDATE() AND t.status != 'concluida' THEN 1
        WHEN DATEDIFF(t.data_fim_prevista, CURDATE()) <= 3 AND t.status != 'concluida' THEN 2
        ELSE 3
    END,
    t.prioridade DESC;

-- 5. EQUIPES E SEUS MEMBROS
SELECT 
    e.nome AS 'Equipe',
    e.descricao AS 'Descrição',
    COUNT(ue.id_usuario) AS 'Nº de Membros',
    GROUP_CONCAT(u.nome_completo SEPARATOR ', ') AS 'Membros',
    COUNT(ep.id_projeto) AS 'Projetos Ativos'
FROM equipes e
LEFT JOIN usuarios_equipes ue ON e.id = ue.id_equipe AND ue.ativo = TRUE
LEFT JOIN usuarios u ON ue.id_usuario = u.id
LEFT JOIN equipes_projetos ep ON e.id = ep.id_equipe AND ep.ativo = TRUE
GROUP BY e.id
ORDER BY e.nome;

-- 6. RELATÓRIO DE ATIVIDADES DO SISTEMA (LOGS)
SELECT 
    u.nome_completo AS 'Usuário',
    l.acao AS 'Ação',
    l.descricao AS 'Descrição',
    l.tabela_afetada AS 'Tabela',
    l.id_registro_afetado AS 'ID Registro',
    l.data_registro AS 'Data/Hora'
FROM logs_atividades l
LEFT JOIN usuarios u ON l.id_usuario = u.id
ORDER BY l.data_registro DESC
LIMIT 50;

-- 7. PROJEÇÃO DE ENTREGA POR PROJETO
SELECT 
    p.nome AS 'Projeto',
    p.data_termino_prevista AS 'Prazo Original',
    COUNT(t.id) AS 'Total Tarefas',
    COUNT(CASE WHEN t.status = 'concluida' THEN t.id END) AS 'Tarefas Concluídas',
    ROUND((COUNT(CASE WHEN t.status = 'concluida' THEN t.id END) / COUNT(t.id)) * 100, 2) AS 'Conclusão (%)',
    AVG(DATEDIFF(COALESCE(t.data_fim_real, CURDATE()), t.data_inicio)) AS 'Velocidade Média (dias/tarefa)',
    DATE_ADD(CURDATE(), INTERVAL 
        CEILING(
            (COUNT(CASE WHEN t.status != 'concluida' THEN t.id END) * 
            AVG(DATEDIFF(COALESCE(t.data_fim_real, CURDATE()), t.data_inicio)))
        ) DAY) AS 'Projeção de Término'
FROM projetos p
LEFT JOIN tarefas t ON p.id = t.id_projeto
WHERE p.status IN ('em_andamento', 'planejado')
GROUP BY p.id
HAVING COUNT(t.id) > 0;