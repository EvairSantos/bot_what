const puppeteer = require('puppeteer');
const readlineSync = require('readline-sync');
const qrcode = require('qrcode-terminal');

async function adicionarBotWhatsApp() {
    let browser;

    try {
        browser = await puppeteer.launch({
            headless: false, // Modo headless desabilitado para visualização
            args: ['--no-sandbox', '--disable-setuid-sandbox'] // Argumentos para evitar problemas de sandbox
        });
        const page = await browser.newPage();

        console.log('Navegando para o WhatsApp Web...');
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        while (true) {
            // Aguardar a presença do QR code e capturar o conteúdo do data-ref
            await page.waitForSelector('div._akau', { timeout: 60000 });
            const qrContent = await page.evaluate(() => {
                const qrElement = document.querySelector('div._akau');
                return qrElement ? qrElement.getAttribute('data-ref') : null;
            });

            if (qrContent) {
                console.log('QR code capturado, exibindo no terminal...');
                qrcode.generate(qrContent, { small: true });

                // Aguardar até que a sessão seja iniciada
                await page.waitForSelector('._2Uw-r', { timeout: 60000 });
                console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');

                // Verificar se o QR code foi lido
                const isQRCodeRead = await page.evaluate(() => {
                    const statusElement = document.querySelector('._2Uw-r');
                    return statusElement ? statusElement.textContent.includes('Conectado') : false;
                });

                if (isQRCodeRead) {
                    console.log('Bot adicionado como novo dispositivo!');
                    break;
                } else {
                    console.log('Aguardando o QR code ser lido...');
                    await page.waitForTimeout(5000); // Aguardar 5 segundos e verificar novamente
                }
            } else {
                throw new Error('Não foi possível capturar o QR code.');
            }
        }

    } catch (error) {
        console.error('Erro ao adicionar o bot como novo dispositivo:', error);

        if (error.message.includes('waiting for selector')) {
            console.log('Tentando novamente...');
            await adicionarBotWhatsApp(); // Tentar novamente
        }
    } finally {
        // Fecha o navegador
        if (browser) {
            await browser.close();
        }
    }
}

// Iniciar a função para adicionar o bot como novo dispositivo
adicionarBotWhatsApp()
    .then(() => {
        console.log('Instalação concluída com sucesso!');
        process.exit(0); // Encerra o processo com sucesso
    })
    .catch((err) => {
        console.error('Erro durante a instalação:', err);
        process.exit(1); // Encerra o processo com erro
    });
