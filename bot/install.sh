#!/bin/bash

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Verifica se o Node.js está instalado
if ! command -v node &> /dev/null; then
    print_status "Node.js não encontrado. Instalando Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Verifica se o npm está instalado
if ! command -v npm &> /dev/null; then
    print_status "npm não encontrado. Instalando npm..."
    sudo apt-get install -y npm
fi

# Instala o módulo qrcode-terminal localmente se ainda não estiver instalado
install_qrcode_terminal() {
    if [ ! -d "./node_modules/qrcode-terminal" ]; then
        print_status "Instalando o módulo qrcode-terminal localmente..."
        npm install qrcode-terminal
    else
        print_status "Módulo qrcode-terminal já está instalado."
    fi
}

# Instala os pacotes necessários localmente
print_status "Instalando os pacotes necessários localmente..."
npm install axios puppeteer

# Instala ou verifica se o qrcode-terminal está instalado
install_qrcode_terminal

# Função para abrir o WhatsApp Web e capturar o QR Code
capture_whatsapp_qr() {
    print_status "Abrindo WhatsApp Web e capturando o QR Code..."

    # Script para abrir o WhatsApp Web e gerar o QR Code
    node - <<EOF
const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

    // Esperar até que o QR Code esteja disponível
    await page.waitForSelector('canvas', { timeout: 0 });

    // Capturar o QR Code
    const qrCodeElement = await page.$('canvas');
    const qrCodeImage = await qrCodeElement.screenshot({ path: 'qr_code.png' });
    console.log('QR Code gerado com sucesso!');

    await browser.close();
})();
EOF
}

# Função para exibir o QR Code na VPS
display_qr_code() {
    print_status "Exibindo o QR Code na tela..."
    # Exibir o QR Code na tela utilizando o módulo qrcode-terminal
    node -e "const qrcode = require('qrcode-terminal'); const fs = require('fs'); const qrCodeData = fs.readFileSync('qr_code.png'); qrcode.generate(qrCodeData, { small: true });"
}

# Capturar e exibir o QR Code do WhatsApp Web
capture_whatsapp_qr
display_qr_code

# Aguardar até que o QR Code seja escaneado
print_status "Aguardando escaneamento do QR Code..."
while true; do
    # Verificar se o arquivo .qr.png existe (assumindo que o nome do arquivo seja qr_code.png)
    if [ -f "qr_code.png" ]; then
        print_status "QR Code escaneado com sucesso!"
        break
    fi
    sleep 5  # Esperar 5 segundos antes de verificar novamente
done

print_status "Instalação e configuração concluídas."
