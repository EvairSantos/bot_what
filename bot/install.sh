#!/bin/bash

# Instala os módulos necessários localmente
npm install qrcode-terminal puppeteer readline-sync

# Função para gerar e exibir o QR Code do WhatsApp Web
print_qr_code() {
    echo ">>> Gerando e exibindo o QR Code do WhatsApp Web..."

    node - <<EOF
const qrcode = require('qrcode-terminal');
const puppeteer = require('puppeteer');
const readlineSync = require('readline-sync');

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('https://web.whatsapp.com');

    console.log('Aguarde enquanto o QR Code do WhatsApp Web está sendo gerado...');

    // Espera até que o QR Code apareça na tela
    await page.waitForSelector('canvas');

    // Captura o QR Code do WhatsApp Web
    const qrCodeData = await page.evaluate(() => {
        const canvas = document.querySelector('canvas');
        return canvas ? canvas.toDataURL() : null;
    });

    if (!qrCodeData) {
        console.error('Não foi possível capturar o QR Code do WhatsApp Web.');
        await browser.close();
        return;
    }

    // Exibe o QR Code no terminal
    qrcode.generate(qrCodeData, { small: true });

    console.log('Escaneie o QR Code do WhatsApp Web para continuar.');

    // Aguarda até que o QR Code seja escaneado
    await page.waitForFunction('document.querySelector("canvas").style.display === "none"');

    console.log('QR Code escaneado com sucesso. Continuando com a instalação...');

    await browser.close();
})();
EOF
}

# Executa a função para gerar e exibir o QR Code
print_qr_code

echo ">>> Instalação e configuração concluídas."
