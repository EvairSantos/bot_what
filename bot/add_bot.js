const puppeteer = require('puppeteer');
const qrcode = require('qrcode-terminal');
const readlineSync = require('readline-sync');

async function adicionarBotWhatsApp() {
    const browser = await puppeteer.launch({
        headless: false, // Define se o navegador será exibido ou não (true para não exibir)
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--display=:99'] // Argumentos adicionais
    });

    const page = await browser.newPage();

    try {
        console.log('Navegando para o WhatsApp Web...');
        await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

        // Aguardar a presença do QR code e capturar o conteúdo do data-ref
        await page.waitForSelector('div._akau', { timeout: 60000 });
        const qrContent = await page.evaluate(() => {
            const qrElement = document.querySelector('div._akau');
            return qrElement ? qrElement.getAttribute('data-ref') : null;
        });

        if (qrContent) {
            console.log('QR code capturado, exibindo no terminal...');
            console.log(qrContent); // Mostra o QR code no terminal

            // Aguardar até que a sessão seja iniciada
            await page.waitForSelector('._2Uw-r', { timeout: 60000 });
            console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');

            // Função para aguardar e processar comandos do usuário
            async function waitForCommands() {
                while (true) {
                    const command = readlineSync.keyIn('', { hideEchoBack: true, mask: '', limit: 'y\n' });

                    if (command === 'y') {
                        console.log('Bot adicionado com sucesso!');
                        break;
                    } else if (command === 'n') {
                        console.log('Gerando um novo QR code...');
                        await page.reload();
                        await page.waitForSelector('div._akau', { timeout: 60000 });
                        const newQrContent = await page.evaluate(() => {
                            const qrElement = document.querySelector('div._akau');
                            return qrElement ? qrElement.getAttribute('data-ref') : null;
                        });

                        if (newQrContent) {
                            console.log('Novo QR code gerado:');
                            console.log(newQrContent);
                            console.log('Escaneie o novo QR code e aguarde...');
                            await page.waitForSelector('._2Uw-r', { timeout: 60000 });
                            console.log('Código QR escaneado com sucesso! WhatsApp Web conectado novamente.');
                        } else {
                            throw new Error('Não foi possível gerar um novo QR code.');
                        }
                    } else {
                        console.log('Opção inválida. Digite "y" para confirmar ou "n" para gerar um novo QR code.');
                    }
                }
            }

            // Iniciar a função para aguardar comandos
            await waitForCommands();
        } else {
            throw new Error('Não foi possível capturar o QR code.');
        }

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
