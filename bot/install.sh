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

# Instala o módulo qrcode-terminal localmente
install_qrcode_terminal() {
    if [ ! -d "./node_modules/qrcode-terminal" ]; then
        print_status "Instalando o módulo qrcode-terminal localmente..."
        npm install qrcode-terminal
    else
        print_status "Atualizando o módulo qrcode-terminal localmente..."
        npm update qrcode-terminal
    fi
}

# Instala os pacotes necessários localmente
print_status "Instalando os pacotes necessários localmente..."
npm install axios

# Instala ou atualiza o qrcode-terminal localmente
install_qrcode_terminal

# Gera e exibe o QR Code
print_status "Gerando o código QR para escanear..."
node -e "const qrcode = require('qrcode-terminal'); qrcode.generate('https://web.whatsapp.com');"
