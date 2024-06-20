/**
 * Módulo de formatação de mensagens para o WhatsApp Pre-Atendimento.
 * Este módulo fornece funções auxiliares para formatar mensagens.
 * 
 * @module utils/messageFormatter
 */

/**
 * Formata uma mensagem recebida para exibição.
 * 
 * @function formatReceivedMessage
 * @param {string} message - Mensagem recebida.
 * @param {string} sender - Nome do remetente da mensagem.
 * @returns {string} - Mensagem formatada para exibição.
 */
exports.formatReceivedMessage = (message, sender) => {
    return `[${sender}] ${message}`;
};

/**
 * Formata uma mensagem para envio.
 * 
 * @function formatSendMessage
 * @param {string} message - Mensagem a ser enviada.
 * @returns {string} - Mensagem formatada para envio.
 */
exports.formatSendMessage = (message) => {
    return `Enviando mensagem: ${message}`;
};
