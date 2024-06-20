#!/bin/bash

################################################################################
# Script de Instalação do Projeto whatsapp-pre-atendimento                      #
# Este script automatiza a instalação e configuração do projeto whatsapp-pre-  #
# atendimento na VPS.                                                          #
#                                                                              #
# Requisitos:                                                                  #
# - Node.js e npm instalados                                                  #
# - Acesso à internet para clonar o repositório do GitHub                      #
# - Pacote qrcode-terminal para gerar o QR Code na linha de comando            #
#                                                                              #
# Uso: ./install.sh                                                            #
################################################################################

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Diretório onde o script está sendo executado
base_dir=$(pwd)

# Download e extração do repositório bot_what
print_status "Baixando e extraindo o repositório..."
curl -fsSL https://github.com/EvairSantos/bot_what/archive/master.zip -o bot_what.zip
unzip -q bot_what.zip
project_dir="$base_dir/bot_what-master"

# Navegar até o diretório do projeto
cd "$project_dir" || exit

# Verificar se o diretório bot já existe, se não, criar
if [ ! -d "bot" ]; then
    mkdir bot
fi

# Copiar todos os arquivos da pasta bot do repositório para o diretório bot
print_status "Copiando arquivos para o diretório bot..."
yes | cp -rf bot_what-master/bot/. bot/

# Instalar as dependências do projeto
print_status "Instalando as dependências..."
npm install

# Configurar o arquivo .env (exemplo: definindo a porta)
print_status "Configurando o arquivo .env..."
echo "PORT=3000" > .env

# Gerar o QR Code na tela da VPS
print_status "Gerando o código QR para escanear..."
npm install qrcode-terminal

# Script para gerar o QR Code na linha de comando
node <<EOF
const qrcode = require('qrcode-terminal');

console.log('Escaneie o código QR com seu dispositivo móvel para continuar...');
qrcode.generate('https://web.whatsapp.com');
EOF

print_status "Instalação concluída com sucesso!"
