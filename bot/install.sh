#!/bin/bash

# Verifica se o Puppeteer está instalado localmente
if [ ! -d "node_modules/puppeteer" ]; then
    echo "Instalando o Puppeteer localmente..."
    npm install puppeteer
fi

# Verifica se o qrcode-terminal está instalado localmente
if [ ! -d "node_modules/qrcode-terminal" ]; then
    echo "Instalando o qrcode-terminal localmente..."
    npm install qrcode-terminal
fi

# Função para gerar e exibir o QR Code do WhatsApp Web
generate_qr_code() {
    echo ">>> Gerando e exibindo o QR Code do WhatsApp Web..."

    node - <<EOF
const puppeteer = require('puppeteer');
const qrcode = require('qrcode-terminal');

(async () => {
    try {
        const browser = await puppeteer.launch({
            args: ['--no-sandbox', '--disable-setuid-sandbox'],
        });
        const page = await browser.newPage();

        // Acessa o WhatsApp Web
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle' });

        // Verifica se o WhatsApp Web foi carregado corretamente
        const title = await page.title();
        if (!title.includes('WhatsApp')) {
            throw new Error('Não foi possível acessar o WhatsApp Web.');
        }

        // Aguarda até que o QR Code apareça na tela
        await page.waitForSelector('canvas');

        // Captura o QR Code do WhatsApp Web
        const qrCodeData = await page.evaluate(() => {
            const canvas = document.querySelector('canvas');
            return canvas ? canvas.toDataURL() : null;
        });

        if (!qrCodeData) {
            throw new Error('Não foi possível capturar o QR Code do WhatsApp Web.');
        }

        // Exibe o QR Code no terminal
        qrcode.generate(qrCodeData, { small: true });

        console.log('Escaneie o QR Code do WhatsApp Web para continuar.');

        // Aguarda até que o QR Code seja escaneado
        await page.waitForFunction('document.querySelector("canvas").style.display === "none"');

        console.log('QR Code escaneado com sucesso.');

        await browser.close();
    } catch (error) {
        console.error('Ocorreu um erro:', error.message);
        process.exit(1);
    }
})();
EOF
}

# Executa a função para gerar e exibir o QR Code
generate_qr_code

echo ">>> Instalação e configuração concluídas."
