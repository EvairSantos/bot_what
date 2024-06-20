/**
 * Serviço de Respostas Automáticas para o WhatsApp Pre-Atendimento.
 * Este serviço gerencia as respostas automáticas e a lógica de resposta do bot.
 * 
 * @module services/responseService
 */

/**
 * Gera uma resposta automática baseada na mensagem recebida.
 * 
 * @function generateResponse
 * @param {string} message - Mensagem recebida pelo bot.
 * @returns {string} - Resposta automática gerada pelo bot.
 */
exports.generateResponse = (message) => {
    // Lógica para gerar resposta automática baseada na mensagem
    if (message.toLowerCase().includes('olá')) {
        return 'Olá! Em que posso ajudar?';
    } else if (message.toLowerCase().includes('como está o atendimento')) {
        return 'O atendimento está em andamento. Por favor, aguarde um momento.';
    } else {
        return 'Desculpe, não entendi. Poderia repetir?';
    }
};
