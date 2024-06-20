// add_bot.js
const puppeteer = require('puppeteer');
const qrcode = require('qrcode-terminal');

async function adicionarBotWhatsApp() {
    let browser;
    try {
        browser = await puppeteer.launch({ headless: false });
        const page = await browser.newPage();
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        while (true) {
            await page.waitForSelector('canvas', { timeout: 0 });
            const qrContent = await page.evaluate(() => {
                const canvas = document.querySelector('canvas');
                return canvas ? canvas.toDataURL() : null;
            });

            if (qrContent) {
                qrcode.generate(qrContent, { small: true });
                await page.waitForTimeout(5000);
            }
        }
    } catch (error) {
        console.error('Erro ao adicionar o bot:', error);
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

adicionarBotWhatsApp();
