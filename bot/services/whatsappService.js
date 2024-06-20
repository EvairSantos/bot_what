/**
 * Serviço do WhatsApp para o WhatsApp Pre-Atendimento.
 * Este serviço encapsula a lógica de integração com o WhatsApp.
 * 
 * @module services/whatsappService
 */

/**
 * Simula o envio de mensagem via WhatsApp.
 * 
 * @function sendMessage
 * @param {string} number - Número de telefone para enviar a mensagem.
 * @param {string} message - Mensagem a ser enviada.
 * @returns {Promise<boolean>} - Retorna uma Promise que resolve para true se a mensagem for enviada com sucesso.
 * @throws {Error} - Lança um erro se houver falha ao enviar a mensagem.
 */
exports.sendMessage = async (number, message) => {
    try {
        // Lógica simulada de envio de mensagem via WhatsApp
        console.log(`Enviando mensagem para ${number}: ${message}`);
        
        // Aqui você pode adicionar lógica real de integração com o WhatsApp

        // Simulando um tempo de espera para envio
        await delay(2000); // Função para simular um tempo de espera

        // Retorna true para simular sucesso no envio
        return true;
    } catch (error) {
        console.error('Erro ao enviar mensagem via WhatsApp:', error);
        throw new Error('Erro ao enviar mensagem via WhatsApp.');
    }
};

/**
 * Função para simular um tempo de espera.
 * 
 * @function delay
 * @param {number} ms - Tempo em milissegundos para aguardar.
 * @returns {Promise<void>} - Retorna uma Promise vazia após o tempo de espera.
 */
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
