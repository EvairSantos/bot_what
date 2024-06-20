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

                    // Aguarda até que o QR code seja lido no WhatsApp Web
                    await page.waitForFunction(() => {
                        const statusElement = document.querySelector('div._13HPh');
                        return statusElement ? statusElement.textContent.includes('Clique para acessar') : false;
                    }, { timeout: 0 });

                    console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');
                    qrCodeFound = true; // Marca que o QR code foi encontrado e lido
                } else {
                    console.log('Não foi possível capturar o QR code. Tentando novamente...');
                    await page.waitForTimeout(5000); // Aguarda 5 segundos e tenta novamente
                }
            } catch (error) {
                console.error('Erro ao capturar o QR code:', error);
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
