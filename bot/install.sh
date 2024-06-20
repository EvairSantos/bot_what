#!/bin/bash

################################################################################
# Script de Instalação do Projeto whatsapp-pre-atendimento                      #
# Este script automatiza a instalação e configuração do projeto whatsapp-pre-  #
# atendimento na VPS.                                                          #
#                                                                              #
# Requisitos:                                                                  #
# - Node.js e npm instalados (versão >= 18)                                     #
# - Git instalado                                                              #
# - Acesso à internet para clonar o repositório do GitHub                      #
# - Acesso ao WhatsApp Web para escanear o código QR                           #
#                                                                              #
# Uso: ./install.sh                                                            #
################################################################################

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Verificar se o Node.js e npm estão instalados e na versão correta (>= 18)
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null || [[ $(node -v | cut -d'.' -f1 | awk '{print $1}') -lt 18 ]]; then
    print_status "Instalando Node.js e npm (versão 18.x)..."
    # Instalação do Node.js 18.x com nvm (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.bashrc
    nvm install 18
    nvm use 18
fi

# Verificar se o Git está instalado
if ! command -v git &> /dev/null; then
    print_status "Instalando Git..."
    # Instalação do Git no Ubuntu
    sudo apt update
    sudo apt install -y git
fi

# Diretório onde o script está sendo executado
base_dir=$(pwd)

# Pasta onde o repositório será clonado (assumindo que é bot_what-main)
project_dir="$base_dir/bot_what-main"

# Navegar até o diretório do projeto
cd "$project_dir" || exit

# Instalar as dependências do projeto
print_status "Instalando as dependências do projeto..."
npm install

# Configurar o arquivo .env (exemplo: definindo a porta)
print_status "Configurando o arquivo .env..."
echo "PORT=3000" > .env

# Abrir o WhatsApp Web para escanear o código QR usando Puppeteer
print_status "Abrindo o WhatsApp Web para escanear o código QR..."

# Instalar Puppeteer na versão compatível
print_status "Instalando Puppeteer..."
npm install puppeteer@10

# Script para abrir o WhatsApp Web e adicionar o bot como novo dispositivo
print_status "Executando script para adicionar o bot como novo dispositivo..."

node <<EOF
const puppeteer = require('puppeteer');

async function adicionarBotWhatsApp() {
    const browser = await puppeteer.launch({ headless: false }); // Abre o navegador de forma visível para interação humana
    const page = await browser.newPage();

    try {
        // Navega para o WhatsApp Web
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        // Aguarda o usuário escanear o código QR manualmente
        await page.waitForSelector('canvas[aria-label="Scan me!"]');
        console.log('Por favor, escaneie o código QR com seu dispositivo móvel.');

        // Aguarda até que o código QR seja escaneado e a sessão seja iniciada
        await page.waitForSelector('._2Uw-r'); // Isso é um seletor específico do WhatsApp Web após o login
        console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');

        // Após escanear o QR code, adicionar o bot como novo dispositivo
        // Exemplo: clicar no botão para adicionar novo dispositivo
        await page.waitForSelector('div[title="Menu"]');
        await page.click('div[title="Menu"]');

        await page.waitForTimeout(2000); // Aguarda um curto período para o menu ser exibido
        await page.waitForSelector('div[title="Dispositivos ligados"]');
        await page.click('div[title="Dispositivos ligados"]');

        await page.waitForTimeout(2000); // Aguarda um curto período para a página de dispositivos ser carregada
        await page.waitForSelector('span[title="Adicionar dispositivo"]');
        await page.click('span[title="Adicionar dispositivo"]');

        console.log('Bot adicionado como novo dispositivo com sucesso!');
    } catch (error) {
        console.error('Erro ao adicionar o bot como novo dispositivo:', error);
    } finally {
        // Fecha o navegador
        await browser.close();
    }
}

adicionarBotWhatsApp();
EOF

print_status "Instalação concluída com sucesso!"
