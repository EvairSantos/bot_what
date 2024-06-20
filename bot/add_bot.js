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
        let qrCodeScanned = false;

        while (!qrCodeFound || !qrCodeScanned) {
            try {
                console.log('Aguardando o QR code...');
                // Espera até que o elemento com atributo data-ref seja visível
                await page.waitForSelector('div[data-ref]', { timeout: 60000 });

                // Captura o atributo data-ref do elemento
                const qrContent = await page.evaluate(() => {
                    const qrElement = document.querySelector('div[data-ref]');
                    return qrElement ? qrElement.getAttribute('data-ref') : null;
                });

                if (qrContent) {
                    console.log('QR code capturado, exibindo no terminal...');
                    qrcode.generate(qrContent, { small: true });

                    qrCodeScanned = true; // Marca que o QR code foi escaneado

                    // Aguarda até que o QR code seja lido no WhatsApp Web
                    await page.waitForFunction(() => {
                        const qrReadElement = document.querySelector('div._alyq._alz4._alyp._alyo');
                        return qrReadElement !== null;
                    }, { timeout: 0 });

                    console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');
                } else {
                    console.log('Não foi possível capturar o QR code. Tentando novamente...');
                    await page.waitForTimeout(5000); // Aguarda 5 segundos e tenta novamente
                    await page.reload({ waitUntil: 'networkidle0' });
                }

                if (qrCodeScanned) {
                    // Verifica se o dispositivo foi adicionado com sucesso
                    await page.waitForSelector('div#wa-popovers-bucket', { timeout: 60000 });

                    console.log('Dispositivo adicionado com sucesso!');
                    qrCodeFound = true; // Marca que o dispositivo foi adicionado com sucesso
                }
            } catch (error) {
                console.error('Erro ao capturar o QR code ou verificar o dispositivo:', error);
                // Pode ser necessário atualizar a página aqui, caso o tempo de espera tenha sido excedido
                await page.reload({ waitUntil: 'networkidle0' });
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
