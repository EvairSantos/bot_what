try {
    browser = await puppeteer.launch({
        headless: false,
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--display=:99']
    });
    const page = await browser.newPage();

    console.log('Navegando para o WhatsApp Web...');
    await page.goto('https://web.whatsapp.com', { waitUntil: 'networkidle0' });

    while (true) {
        await page.waitForSelector('div._akau', { timeout: 60000 });
        const qrContent = await page.evaluate(() => {
            const qrElement = document.querySelector('div._akau');
            return qrElement ? qrElement.getAttribute('data-ref') : null;
        });

        if (qrContent) {
            console.log('QR code capturado, exibindo no terminal...');
            qrcode.generate(qrContent, { small: true });

            await page.waitForSelector('._2Uw-r', { timeout: 120000 }); // Aumentar para 120 segundos
            console.log('Código QR escaneado com sucesso! WhatsApp Web conectado.');

            const isQRCodeRead = await page.evaluate(() => {
                const statusElement = document.querySelector('._2Uw-r');
                return statusElement ? statusElement.textContent.includes('Conectado') : false;
            });

            if (isQRCodeRead) {
                console.log('Bot adicionado como novo dispositivo!');
                break;
            } else {
                console.log('Aguardando o QR code ser lido novamente...');
                await page.waitForTimeout(5000); // Aguardar 5 segundos e verificar novamente
            }
        } else {
            throw new Error('Não foi possível capturar o QR code.');
        }
    }
} catch (error) {
    console.error('Erro ao adicionar o bot como novo dispositivo:', error);
} finally {
    if (browser) {
        await browser.close();
    }
}
