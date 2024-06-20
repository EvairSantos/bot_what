#!/bin/bash

################################################################################
# Script para Gerar e Escanear automaticamente o QR Code do WhatsApp Web na VPS #
# Este script gera o QR Code diretamente no terminal da VPS e inicia o WhatsApp #
# Web automaticamente após escanear o código QR.                               #
#                                                                              #
# Requisitos:                                                                  #
# - Node.js e npm instalados                                                  #
# - Pacote qrcode-terminal para gerar o QR Code na linha de comando            #
# - Pacote axios para fazer requisições HTTP                                   #
#                                                                              #
# Uso: ./instalar_bot.sh                                                       #
################################################################################

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

# Instala o pacote qrcode-terminal e axios
print_status "Instalando os pacotes necessários..."
sudo npm install --quiet -g qrcode-terminal axios

# Função para gerar e exibir o QR Code
generate_qr_code() {
    print_status "Gerando o código QR para escanear..."
    node <<EOF
const qrcode = require('qrcode-terminal');

console.log('Escaneie o código QR com seu dispositivo móvel para continuar...');
qrcode.generate('https://web.whatsapp.com');
EOF
}

# Função para escanear o QR Code automaticamente
scan_qr_code() {
    generate_qr_code

    print_status "Aguardando escaneamento do QR Code..."
    # Inicia um loop para verificar se o QR Code foi escaneado
    while true; do
        # Verifica se o WhatsApp Web foi acessado
        local whatsapp_status
        whatsapp_status=$(curl -sIL https://web.whatsapp.com | grep HTTP/1.1 | awk {'print $2'})

        if [[ "$whatsapp_status" == "200" ]]; then
            print_status "QR Code escaneado com sucesso!"
            break
        fi

        sleep 2
    done
}

# Executa a função para escanear o QR Code
scan_qr_code

# Finaliza o script
print_status "Script concluído."
exit 0
