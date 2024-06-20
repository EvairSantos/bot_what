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

        while (true) {
            await page.waitForSelector('canvas[aria-label="Scan me!"]', { timeout: 60000 });
            const qrContent = await page.evaluate(() => {
                const qrElement = document.querySelector('canvas[aria-label="Scan me!"]');
                return qrElement ? qrElement.toDataURL() : null;
            });

            if (qrContent) {
                console.log('QR code capturado, exibindo no terminal...');
                qrcode.generate(qrContent, { small: true });

                try {
                    await page.waitForSelector('div[role="button"] > span[data-testid="menu"]', { timeout: 60000 });
                    console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');
                    break;
                } catch (error) {
                    console.log('Aguardando o QR code ser lido...');
                    await page.waitForTimeout(5000); // Aguardar 5 segundos e verificar novamente
                }
            } else {
                console.log('Não foi possível capturar o QR code. Tentando novamente...');
                await page.waitForTimeout(5000); // Aguardar 5 segundos e tentar capturar novamente
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

adicionarBotWhatsApp()
    .then(() => console.log('Instalação concluída com sucesso!'))
    .catch((err) => console.error('Erro durante a instalação:', err));
