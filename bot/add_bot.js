async function adicionarBotWhatsApp() {
    const puppeteer = require('puppeteer');
    const qrcode = require('qrcode-terminal');

    let browser;

    try {
        browser = await puppeteer.launch({
            headless: false, // Altere para true para testes finais
            args: ['--no-sandbox', '--disable-setuid-sandbox', '--display=:99']
        });
        const page = await browser.newPage();

        console.log('Navegando para o WhatsApp Web...');
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        // Aguardar até que o QR code esteja disponível
        await page.waitForSelector('div[data-ref]', { timeout: 60000 });
        const qrContent = await page.evaluate(() => {
            const qrElement = document.querySelector('div[data-ref]');
            return qrElement ? qrElement.getAttribute('data-ref') : null;
        });

        if (qrContent) {
            console.log('QR code capturado, exibindo no terminal...');
            qrcode.generate(qrContent, { small: true });

            // Aguardar até que o QR code seja escaneado
            await page.waitForSelector('div._alyq._alz4._alyp._alyo', { timeout: 120000 });
            console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');

            // Aguardar até que o dispositivo seja adicionado
            await page.waitForSelector('div#wa-popovers-bucket', { timeout: 120000 });
            console.log('Bot adicionado como novo dispositivo!');
        } else {
            throw new Error('Não foi possível capturar o QR code.');
        }

    } catch (error) {
        console.error('Erro ao adicionar o bot como novo dispositivo:', error);
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

adicionarBotWhatsApp()
    .then(() => console.log('Instalação concluída com sucesso!'))
    .catch((err) => console.error('Erro durante a instalação:', err));
