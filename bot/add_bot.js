const puppeteer = require('puppeteer');
const qrcode = require('qrcode-terminal');

async function adicionarBotWhatsApp() {
    let browser;

    try {
        browser = await puppeteer.launch({
            headless: false,
            args: ['--no-sandbox', '--disable-setuid-sandbox', '--display=:99']
        });
        const page = await browser.newPage();

        console.log('Navegando para o WhatsApp Web...');
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        while (true) {
            await page.waitForSelector('div._1CRbF', { timeout: 60000 }); // Espera pelo elemento após o login

            const isLoggedIn = await page.evaluate(() => {
                return document.querySelector('div._1CRbF') !== null; // Verifica se o elemento após o login está presente
            });

            if (isLoggedIn) {
                console.log('WhatsApp Web conectado após o login.');

                const isBotAdded = await page.evaluate(() => {
                    return document.querySelector('div._2Uw-r') !== null; // Verifica se o bot foi adicionado
                });

                if (isBotAdded) {
                    console.log('Bot adicionado como novo dispositivo!');
                    break;
                } else {
                    console.log('Aguardando o bot ser adicionado...');
                    await page.waitForTimeout(5000); // Aguarda 5 segundos e verifica novamente
                }
            } else {
                throw new Error('Erro ao detectar o login no WhatsApp Web.');
            }
        }
    } catch (error) {
        console.error('Erro ao adicionar o bot como novo dispositivo:', error);
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

adicionarBotWhatsApp();
