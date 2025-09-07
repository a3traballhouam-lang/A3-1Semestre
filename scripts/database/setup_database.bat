@echo off
echo ====================================
echo CONFIGURANDO BANCO DE DADOS
echo ====================================

echo Digite o nome de usuário do MySQL: 
set /p username=

echo Digite a senha do MySQL: 
set /p password=

echo Executando script do banco de dados...
mysql -u %username% -p%password% < ..\docs\database\database_schema.sql

echo Importando dados iniciais...
mysql -u %username% -p%password% sistema_gerenciamento_projetos < ..\docs\database\initial_data.sql

echo Banco de dados configurado com sucesso!
pause