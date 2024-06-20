#!/bin/bash

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Verifica se o Node.js está instalado
if ! command -v node &> /dev/null; then
    print_status "Node.js não encontrado. Instalando Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Verifica se o npm está instalado
if ! command -v npm &> /dev/null; then
    print_status "npm não encontrado. Instalando npm..."
    sudo apt-get install -y npm
fi

# Instala o módulo qrcode-terminal localmente se ainda não estiver instalado
install_qrcode_terminal() {
    if [ ! -d "./node_modules/qrcode-terminal" ]; then
        print_status "Instalando o módulo qrcode-terminal localmente..."
        npm install qrcode-terminal
    else
        print_status "Módulo qrcode-terminal já está instalado."
    fi
}

# Instala os pacotes necessários localmente
print_status "Instalando os pacotes necessários localmente..."
npm install axios

# Instala ou verifica se o qrcode-terminal está instalado
install_qrcode_terminal

# Função para gerar e exibir o QR Code do WhatsApp Web
generate_qr_code() {
    print_status "Gerando o código QR do WhatsApp Web..."
    node -e "const qrcode = require('qrcode-terminal'); qrcode.generate('https://web.whatsapp.com');"
}

# Gerar e exibir o QR Code
generate_qr_code

# Aguardar até que o QR Code seja escaneado
print_status "Aguardando escaneamento do QR Code..."
while true; do
    # Verificar se o arquivo .qr.png existe (assumindo que o nome do arquivo seja .qr.png)
    if [ -f ".qr.png" ]; then
        print_status "QR Code escaneado com sucesso!"
        break
    fi
    sleep 5  # Esperar 5 segundos antes de verificar novamente
done

print_status "Instalação e configuração concluídas."
