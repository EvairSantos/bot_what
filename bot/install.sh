#!/bin/bash

################################################################################
# Script para Gerar QR Code do WhatsApp Web na VPS                             #
# Este script gera o QR Code na tela da VPS para escanear e adicionar o        #
# dispositivo ao WhatsApp Web.                                                 #
#                                                                              #
# Requisitos:                                                                  #
# - Node.js e npm instalados                                                  #
# - Pacote qrcode-terminal para gerar o QR Code na linha de comando            #
#                                                                              #
# Uso: ./gerar_qr_code.sh                                                      #
################################################################################

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Instalar o pacote qrcode-terminal para gerar o QR Code
print_status "Instalando o pacote qrcode-terminal..."
npm install --quiet qrcode-terminal

# Gerar o QR Code na tela da VPS
print_status "Gerando o código QR para escanear..."
node <<EOF
const qrcode = require('qrcode-terminal');

console.log('Escaneie o código QR com seu dispositivo móvel para continuar...');
qrcode.generate('https://web.whatsapp.com');
EOF

print_status "QR Code gerado com sucesso! Escaneie-o com o seu dispositivo móvel."
