/**
 * Arquivo de configuração do banco de dados para o projeto WhatsApp Pre-Atendimento.
 * Este arquivo configura a conexão com o banco de dados MySQL.
 * 
 * Banco de Dados: WEB_DB
 * Usuário: web_user
 * Senha: (sem senha)
 * 
 * @module config/database
 */

const mysql = require('mysql');

/**
 * Configuração de conexão com o banco de dados MySQL.
 * 
 * @constant {object} dbConfig - Configurações de conexão.
 * @property {string} host - Endereço do servidor MySQL.
 * @property {string} user - Usuário do banco de dados.
 * @property {string} database - Nome do banco de dados.
 * @property {number} port - Porta do servidor MySQL.
 */
const dbConfig = {
    host: 'localhost',
    user: 'web_user',
    password: '', // Senha não especificada aqui por motivos de segurança.
    database: 'WEB_DB',
    port: 3306
};

/**
 * Cria uma nova conexão com o banco de dados MySQL usando as configurações fornecidas.
 * 
 * @function connectDB
 * @returns {object} - Objeto de conexão com o banco de dados MySQL.
 * @throws {error} - Lança um erro se não conseguir conectar ao banco de dados.
 */
const connectDB = () => {
    const connection = mysql.createConnection(dbConfig);

    connection.connect((err) => {
        if (err) {
            console.error('Erro ao conectar ao banco de dados:', err);
            throw err;
        }
        console.log('Conectado ao banco de dados MySQL!');
    });

    return connection;
};

module.exports = connectDB;
