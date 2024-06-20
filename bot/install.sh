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

# Configurar o arquivo .env
print_status "Configurando o arquivo .env..."
echo "PORT=3000" > .env

# Abrir o WhatsApp Web para escanear o código QR usando Puppeteer
print_status "Abrindo o WhatsApp Web para escanear o código QR..."

# Instalar Puppeteer na versão compatível
print_status "Instalando Puppeteer..."
npm install puppeteer@10

# Função para iniciar o processo de adicionar o bot no WhatsApp Web
adicionarBotWhatsApp() {
    # Usar Xvfb para rodar Puppeteer em um ambiente sem GUI
    Xvfb :99 -screen 0 1024x768x16 &

    node <<EOF
const puppeteer = require('puppeteer');
const qrcode = require('qrcode-terminal');

async function adicionarBotWhatsApp() {
    const browser = await puppeteer.launch({
        headless: false,
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--display=:99']
    });
    const page = await browser.newPage();

    try {
        console.log('Navegando para o WhatsApp Web...');
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        // Função para verificar se o código QR foi escaneado
        async function waitForQRScan() {
            try {
                await page.waitForFunction(() => {
                    const qrElement = document.querySelector('div._akau');
                    return qrElement && qrElement.getAttribute('data-ref');
                }, { timeout: 0 });
                return true;
            } catch (error) {
                return false;
            }
        }

        // Aguardar até que o QR code seja escaneado
        const qrScanned = await waitForQRScan();
        if (qrScanned) {
            console.log('QR code capturado, exibindo no terminal...');
            const qrContent = await page.evaluate(() => {
                const qrElement = document.querySelector('div._akau');
                return qrElement.getAttribute('data-ref');
            });
            qrcode.generate(qrContent, { small: true });

            // Aguardar a entrada do usuário para gerar um novo QR code ou confirmar o sucesso
            const readline = require('readline');
            const rl = readline.createInterface({
                input: process.stdin,
                output: process.stdout
            });

            rl.question('❌ Gerar um novo QR code [BACKSPACE]\n🤖 Bot adicionado [ENTER]\n', async (answer) => {
                if (answer.trim() === '') {
                    console.log('Gerando um novo QR code...');
                    await page.reload();
                    await adicionarBotWhatsApp(); // Tentar novamente
                } else {
                    console.log('Bot adicionado com sucesso!');
                }
                rl.close();
                await browser.close();
                adicionarBotWhatsApp(); // Continuar aguardando comandos
            });

        } else {
            throw new Error('Não foi possível capturar o QR code.');
        }

    } catch (error) {
        console.error('Erro ao adicionar o bot como novo dispositivo:', error);

        if (error.message.includes('waiting for selector')) {
            console.log('Tentando novamente...');
            await page.reload();
            adicionarBotWhatsApp(); // Tentar novamente
        } else {
            console.log('Aguardando comandos...');
            adicionarBotWhatsApp(); // Continuar aguardando comandos
        }
    } finally {
        // Fecha o navegador
        await browser.close();
    }
}

adicionarBotWhatsApp();
EOF
}

# Iniciar o processo de adicionar o bot no WhatsApp Web
adicionarBotWhatsApp &

print_status "Instalação concluída com sucesso!"
