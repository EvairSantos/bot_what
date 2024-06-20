/**
 * Modelo de Cliente para o WhatsApp Pre-Atendimento.
 * Este modelo define a estrutura e as operações relacionadas aos clientes do serviço.
 * 
 * @module models/Client
 */

const mongoose = require('mongoose');

/**
 * Esquema do Cliente.
 * 
 * @constant {object} ClientSchema - Esquema do Cliente.
 * @property {string} name - Nome do cliente.
 * @property {string} phone - Número de telefone do cliente.
 * @property {Date} createdAt - Data de criação do cliente.
 */
const ClientSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    phone: {
        type: String,
        required: true,
        unique: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

/**
 * Modelo de Cliente baseado no esquema ClientSchema.
 * 
 * @constant {object} Client - Modelo de Cliente.
 */
const Client = mongoose.model('Client', ClientSchema);

module.exports = Client;
