const puppeteer = require('puppeteer');
const qrcode = require('qrcode-terminal');
const readlineSync = require('readline-sync');

async function adicionarBotWhatsApp() {
    const browser = await puppeteer.launch({
        headless: false,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-gpu',
            `--display=${process.env.DISPLAY || ':99'}`, // Defina o DISPLAY para o Xvfb se necessário
        ],
        executablePath: '/usr/bin/chromium-browser', // Caminho para o executável do Chromium
    });

    const page = await browser.newPage();

    try {
        console.log('Navegando para o WhatsApp Web...');
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        // Função para exibir QR code e aguardar confirmação ou nova geração
        async function waitForCommands() {
            while (true) {
                const command = readlineSync.keyIn('', { hideEchoBack: true, mask: '', limit: 'yn' });

                if (command === 'y') {
                    console.log('Bot adicionado com sucesso!');
                    break;
                } else if (command === 'n') {
                    console.log('Gerando um novo QR code...');
                    await page.reload();
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
                    } else {
                        throw new Error('Não foi possível capturar o QR code.');
                    }
                } else {
                    console.log('Opção inválida. Digite "y" para confirmar ou "n" para gerar um novo QR code.');
                }
            }
        }

        // Iniciar a função para aguardar comandos
        waitForCommands();

    } catch (error) {
        console.error('Erro ao adicionar o bot como novo dispositivo:', error);

        if (error.message.includes('waiting for selector')) {
            console.log('Tentando novamente...');
            await page.reload();
            await adicionarBotWhatsApp(); // Tentar novamente
        }
    } finally {
        // Fecha o navegador
        await browser.close();
    }
}

adicionarBotWhatsApp();
