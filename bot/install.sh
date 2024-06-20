#!/bin/bash

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Verificar se o Node.js e npm estão instalados e na versão correta (>= 18)
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null || [[ $(node -v | cut -d'.' -f1 | awk '{print $1}') -lt 18 ]]; then
    print_status "Instalando Node.js e npm (versão 18.x)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install 18
    nvm use 18
fi

# Verificar se o Git está instalado
if ! command -v git &> /dev/null; then
    print_status "Instalando Git..."
    sudo apt update
    sudo apt install -y git
fi

# Instalar dependências do Chromium para Puppeteer
print_status "Instalando dependências do Chromium..."
sudo apt update
sudo apt install -y \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxkbcommon-x11-0 \
    libgbm1 \
    libasound2 \
    xdg-utils

# Instalar Xvfb para emular um servidor X
print_status "Instalando Xvfb..."
sudo apt install -y xvfb

# Encerrar qualquer instância existente do Xvfb e remover o arquivo de bloqueio
print_status "Finalizando instâncias anteriores do Xvfb..."
pkill Xvfb || true
rm -f /tmp/.X99-lock

# Diretório onde o script está sendo executado
base_dir=$(pwd)

# Pasta onde o repositório será clonado
project_dir="$base_dir/bot_what-main/bot"

# Navegar até o diretório do projeto
cd "$project_dir" || exit

# Instalar as dependências do projeto
print_status "Instalando as dependências do projeto..."
npm install

# Instalar qrcode-terminal localmente para exibir o QR code no terminal
print_status "Instalando qrcode-terminal..."
npm install qrcode-terminal

# Instalar readline-sync para captura de entrada do usuário
print_status "Instalando readline-sync..."
npm install readline-sync

# Configurar o arquivo .env
print_status "Configurando o arquivo .env..."
echo "PORT=3000" > .env

# Abrir o WhatsApp Web para escanear o código QR usando Puppeteer
print_status "Abrindo o WhatsApp Web para escanear o código QR..."

# Instalar Puppeteer na versão compatível
print_status "Instalando Puppeteer..."
npm install puppeteer@10

# Script para abrir o WhatsApp Web e adicionar o bot como novo dispositivo
print_status "Executando script para adicionar o bot como novo dispositivo..."

# Usar Xvfb para rodar Puppeteer em um ambiente sem GUI
Xvfb :99 -screen 0 1024x768x16 &

# Função para adicionar o bot como novo dispositivo no WhatsApp Web
async function adicionarBotWhatsApp() {
    const puppeteer = require('puppeteer');
    const readlineSync = require('readline-sync');
    const qrcode = require('qrcode-terminal');

    let browser;

    try {
        browser = await puppeteer.launch({
            headless: false,
            args: ['--no-sandbox', '--disable-setuid-sandbox', '--display=:99']
        });
        const page = await browser.newPage();

        print_status('Navegando para o WhatsApp Web...');
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        while (true) {
            // Aguardar a presença do QR code e capturar o conteúdo do data-ref
            await page.waitForSelector('div._akau', { timeout: 60000 });
            const qrContent = await page.evaluate(() => {
                const qrElement = document.querySelector('div._akau');
                return qrElement ? qrElement.getAttribute('data-ref') : null;
            });

            if (qrContent) {
                print_status('QR code capturado, exibindo no terminal...');
                qrcode.generate(qrContent, { small: true });

                // Aguardar até que a sessão seja iniciada
                await page.waitForSelector('._2Uw-r', { timeout: 60000 });
                print_status('Código QR escaneado com sucesso! WhatsApp Web conectado.');

                // Verificar se o QR code foi lido
                const isQRCodeRead = await page.evaluate(() => {
                    const statusElement = document.querySelector('._2Uw-r');
                    return statusElement ? statusElement.textContent.includes('Conectado') : false;
                });

                if (isQRCodeRead) {
                    print_status('Bot adicionado como novo dispositivo!');
                    break;
                } else {
                    print_status('Aguardando o QR code ser lido...');
                    await page.waitForTimeout(5000); // Aguardar 5 segundos e verificar novamente
                }
            } else {
                throw new Error('Não foi possível capturar o QR code.');
            }
        }

    } catch (error) {
        console.error('Erro ao adicionar o bot como novo dispositivo:', error);

        if (error.message.includes('waiting for selector')) {
            print_status('Tentando novamente...');
            await adicionarBotWhatsApp(); // Tentar novamente
        }
    } finally {
        // Fecha o navegador
        if (browser) {
            await browser.close();
        }
    }
}

// Iniciar a função para adicionar o bot como novo dispositivo
adicionarBotWhatsApp()
    .then(() => {
        print_status('Instalação concluída com sucesso!');
    })
    .catch((err) => {
        console.error('Erro durante a instalação:', err);
    });
