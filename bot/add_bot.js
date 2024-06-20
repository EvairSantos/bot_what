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

        let qrCodeFound = false;

        while (!qrCodeFound) {
            try {
                console.log('Aguardando o QR code...');
                // Espera até que o elemento <canvas> com atributo data-ref seja visível
                await page.waitForFunction(() => {
                    const qrElement = document.querySelector('canvas[data-ref]');
                    return qrElement && qrElement.getAttribute('data-ref');
                }, { timeout: 60000 });

                const qrContent = await page.evaluate(() => {
                    const qrElement = document.querySelector('canvas[data-ref]');
                    return qrElement ? qrElement.getAttribute('data-ref') : null;
                });

                if (qrContent) {
                    console.log('QR code capturado, exibindo no terminal...');
                    qrcode.generate(qrContent, { small: true });

                    // Espera até que o QR code desapareça, indicando que foi lido
                    await page.waitForFunction(
                        () => !document.querySelector('canvas[data-ref]'),
                        { timeout: 60000 }
                    );

                    console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');

                    // Verifica se está conectado após escanear o QR code
                    const isConnected = await page.evaluate(() => {
                        return document.querySelector('div[data-testid="chatlist"]') !== null;
                    });

                    if (isConnected) {
                        console.log('Bot adicionado como novo dispositivo!');
                        qrCodeFound = true; // Seta como true para sair do loop
                    } else {
                        console.log('Aguardando confirmação de conexão...');
                        await page.waitForTimeout(5000); // Aguarda 5 segundos e verifica novamente
                    }
                } else {
                    throw new Error('Não foi possível capturar o QR code.');
                }
            } catch (error) {
                console.error('Erro ao capturar o QR code:', error);
                await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] }); // Recarrega a página para tentar novamente
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
