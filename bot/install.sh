#!/bin/bash

# Instala os módulos qrcode-terminal e readline-sync localmente
npm install qrcode-terminal readline-sync

# Função para gerar e exibir o QR Code do WhatsApp Web
print_qr_code() {
    echo ">>> Gerando o QR Code do WhatsApp Web..."

    node - <<EOF
const qrcode = require('qrcode-terminal');
const readlineSync = require('readline-sync');

console.log('Escaneie o QR Code do WhatsApp Web para continuar.');

// Simula a espera do QR Code ser escaneado
readlineSync.question('Pressione Enter após escanear o QR Code...');

// Gerando o QR Code
const qrCodeText = 'https://web.whatsapp.com';
qrcode.generate(qrCodeText, { small: true });

console.log('QR Code do WhatsApp Web:');
EOF
}

# Executa a função para gerar e exibir o QR Code
print_qr_code

echo ">>> Instalação e configuração concluídas."
