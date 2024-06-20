/**
 * Controlador das mensagens para o WhatsApp Pre-Atendimento.
 * Este controlador lida com a gestão das mensagens enviadas e recebidas pelo bot.
 * 
 * @module controllers/messageController
 */

const Message = require('../models/Message');

/**
 * Obtém todas as mensagens do banco de dados.
 * 
 * @function getMessages
 * @param {object} req - Objeto de requisição HTTP.
 * @param {object} res - Objeto de resposta HTTP.
 * @returns {json} - Retorna um array JSON com todas as mensagens.
 * @throws {error} - Retorna um erro se não conseguir obter as mensagens.
 */
exports.getMessages = async (req, res) => {
    try {
        // Busca todas as mensagens no banco de dados
        const messages = await Message.find();

        // Verifica se há mensagens encontradas
        if (messages.length === 0) {
            return res.status(404).json({ message: 'Nenhuma mensagem encontrada.' });
        }

        // Retorna as mensagens encontradas
        res.status(200).json(messages);
    } catch (error) {
        // Captura erros e retorna uma resposta de erro
        console.error('Erro ao obter mensagens:', error);
        res.status(500).json({ error: 'Erro ao obter mensagens do banco de dados.' });
    }
};
