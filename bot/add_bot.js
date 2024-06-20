const puppeteer = require('puppeteer');
const qrcode = require('qrcode-terminal');

async function adicionarBotWhatsApp() {
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
            try {
                console.log('Aguardando o QR code...');
                await page.waitForSelector('canvas[data-ref]', { timeout: 120000 });

                const qrContent = await page.evaluate(() => {
                    const qrElement = document.querySelector('canvas[data-ref]');
                    if (qrElement) {
                        return qrElement.getAttribute('data-ref');
                    }
                    return null;
                });

                if (qrContent) {
                    console.log('Conteúdo do QR code capturado:', qrContent);
                    console.log('QR code capturado, exibindo no terminal...');
                    qrcode.generate(qrContent, { small: true });

                    // Espera até que o QR code desapareça, indicando que foi lido
                    await page.waitForFunction(
                        () => document.querySelector('canvas[data-ref]') === null,
                        { timeout: 120000 }
                    );

                    console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');

                    const isConnected = await page.evaluate(() => {
                        return document.querySelector('div[data-testid="chatlist"]') !== null;
                    });

                    if (isConnected) {
                        console.log('Bot adicionado como novo dispositivo!');
                        break;
                    } else {
                        console.log('Aguardando o QR code ser lido...');
                        await page.waitForTimeout(5000); // Aguardar 5 segundos e verificar novamente
                    }
                } else {
                    throw new Error('Não foi possível capturar o QR code.');
                }
            } catch (error) {
                console.error('Erro ao capturar o QR code:', error);
                await page.screenshot({ path: 'erro_qr.png' }); // Salva uma captura de tela para depuração
                console.log('Captura de tela salva como "erro_qr.png"');
                await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] }); // Recarregar a página para tentar novamente
                await page.waitForTimeout(5000); // Aguardar 5 segundos antes de tentar novamente
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
