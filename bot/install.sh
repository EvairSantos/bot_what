#!/bin/bash

################################################################################
# Script de Instalação do Projeto whatsapp-pre-atendimento                      #
# Este script automatiza a instalação e configuração do projeto whatsapp-pre-  #
# atendimento na VPS.                                                          #
#                                                                              #
# Requisitos:                                                                  #
# - Node.js e npm instalados                                                  #
# - Acesso à internet para clonar o repositório do GitHub                      #
# - Acesso ao WhatsApp Web para escanear o código QR                           #
#                                                                              #
# Uso: ./install.sh                                                            #
################################################################################

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Diretório onde o script está sendo executado
base_dir=$(pwd)

# Pasta onde o repositório foi clonado (assumindo que é bot_what-main)
project_dir="$base_dir/bot_what-main"

# Navegar até o diretório do projeto
cd "$project_dir" || exit

# Instalar as dependências do projeto
print_status "Instalando as dependências..."
npm install

# Configurar o arquivo .env (exemplo: definindo a porta)
print_status "Configurando o arquivo .env..."
echo "PORT=3000" > .env

# Abrir o WhatsApp Web para escanear o código QR
print_status "Abrindo o WhatsApp Web para escanear o código QR..."
npm install puppeteer

# Script para abrir o WhatsApp Web (exemplo com puppeteer)
node <<EOF
const puppeteer = require('puppeteer');

async function abrirWhatsAppWeb() {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('https://web.whatsapp.com');

    console.log('Escaneie o código QR com seu dispositivo móvel para continuar...');
}

abrirWhatsAppWeb();
EOF

print_status "Instalação concluída com sucesso!"
