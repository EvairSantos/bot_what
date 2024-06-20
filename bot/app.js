/**
 * Ponto de entrada da aplicação WhatsApp Pre-Atendimento.
 * Este arquivo configura e inicia a aplicação.
 * 
 * @module app
 */

const express = require('express');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware para parsear JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rota de exemplo
app.get('/', (req, res) => {
    res.send('Servidor do WhatsApp Pre-Atendimento está funcionando!');
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Servidor está rodando na porta ${PORT}`);
});
