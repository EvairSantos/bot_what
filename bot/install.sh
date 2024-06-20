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
# Uso: ./install.sh <link-do-repositorio>                                       #
################################################################################

# Verificar se foi passado o link do repositório como argumento
if [ $# -eq 0 ]; then
    echo "Erro: Link do repositório não especificado."
    echo "Uso: ./install.sh <link-do-repositorio>"
    exit 1
fi

# Link do repositório do GitHub fornecido como argumento
repo_link=$1

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Clonar o repositório do GitHub
print_status "Clonando o repositório..."
git clone $repo_link whatsapp-pre-atendimento
cd whatsapp-pre-atendimento/bot

# Instalar as dependências do projeto
print_status "Instalando as dependências..."
npm install

# Configurar o arquivo .env
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
