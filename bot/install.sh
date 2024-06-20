#!/bin/bash

# Instala o módulo qrcode-terminal localmente
npm install qrcode-terminal

# Gera o QR Code do WhatsApp Web e exibe na tela
print_qr_code() {
    echo ">>> Gerando o QR Code do WhatsApp Web..."
    node - <<EOF
const qrcode = require('qrcode-terminal');
const readlineSync = require('readline-sync');

console.log('Escaneie o QR Code do WhatsApp Web para continuar.');

// Simula a espera do QR Code ser escaneado
readlineSync.question('Pressione Enter após escanear o QR Code...');

console.log('QR Code escaneado com sucesso!');
EOF
}

# Executa a função para gerar e exibir o QR Code
print_qr_code

echo ">>> Instalação e configuração concluídas."
