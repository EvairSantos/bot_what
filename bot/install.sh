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

# Função para instalar ou atualizar o módulo qrcode-terminal globalmente
install_qrcode_terminal() {
    if npm list -g qrcode-terminal &> /dev/null; then
        print_status "Atualizando o módulo qrcode-terminal..."
        sudo npm update -g qrcode-terminal
    else
        print_status "Instalando o módulo qrcode-terminal..."
        sudo npm install -g qrcode-terminal
    fi
}

# Instala os pacotes necessários globalmente
print_status "Instalando os pacotes necessários..."
sudo npm install -g axios

# Instala ou atualiza o qrcode-terminal
install_qrcode_terminal

# Gera e exibe o QR Code
print_status "Gerando o código QR para escanear..."
node -e "const qrcode = require('qrcode-terminal'); qrcode.generate('https://web.whatsapp.com');"
