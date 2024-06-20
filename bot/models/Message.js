/**
 * Modelo de Mensagem para o WhatsApp Pre-Atendimento.
 * Este modelo define a estrutura e as operações relacionadas às mensagens trocadas no serviço.
 * 
 * @module models/Message
 */

const mongoose = require('mongoose');

/**
 * Esquema da Mensagem.
 * 
 * @constant {object} MessageSchema - Esquema da Mensagem.
 * @property {string} content - Conteúdo da mensagem.
 * @property {string} sender - Remetente da mensagem (cliente).
 * @property {string} receiver - Destinatário da mensagem (operador).
 * @property {Date} timestamp - Data e hora de envio da mensagem.
 */
const MessageSchema = new mongoose.Schema({
    content: {
        type: String,
        required: true
    },
    sender: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Client',
        required: true
    },
    receiver: {
        type: String,
        required: true
    },
    timestamp: {
        type: Date,
        default: Date.now
    }
});

/**
 * Modelo de Mensagem baseado no esquema MessageSchema.
 * 
 * @constant {object} Message - Modelo de Mensagem.
 */
const Message = mongoose.model('Message', MessageSchema);

module.exports = Message;
