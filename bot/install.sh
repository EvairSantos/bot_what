#!/bin/bash

# Função para exibir mensagens de status
print_status() {
    echo ">>> $1"
}

# Verificar se o Node.js e npm estão instalados e na versão correta (>= 18)
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null || [[ $(node -v | cut -d'.' -f1 | awk '{print $1}') -lt 18 ]]; then
    print_status "Instalando Node.js e npm (versão 18.x)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install 18
    nvm use 18
fi

# Verificar se o Git está instalado
if ! command -v git &> /dev/null; then
    print_status "Instalando Git..."
    sudo apt update
    sudo apt install -y git
fi

# Instalar dependências do Chromium para Puppeteer
print_status "Instalando dependências do Chromium..."
sudo apt update
sudo apt install -y \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxkbcommon-x11-0 \
    libgbm1 \
    libasound2 \
    xdg-utils

# Instalar Xvfb para emular um servidor X
print_status "Instalando Xvfb..."
sudo apt install -y xvfb

# Encerrar qualquer instância existente do Xvfb e remover o arquivo de bloqueio
print_status "Finalizando instâncias anteriores do Xvfb..."
pkill Xvfb || true
rm -f /tmp/.X99-lock

# Diretório onde o script está sendo executado
base_dir=$(pwd)

# Pasta onde o repositório será clonado
project_dir="$base_dir/bot_what-main/bot"

# Navegar até o diretório do projeto
cd "$project_dir" || exit

# Instalar as dependências do projeto
print_status "Instalando as dependências do projeto..."
npm install

# Instalar qrcode-terminal localmente para exibir o QR code no terminal
print_status "Instalando qrcode-terminal..."
npm install qrcode-terminal

# Instalar readline-sync para captura de entrada do usuário
print_status "Instalando readline-sync..."
npm install readline-sync

# Configurar o arquivo .env
print_status "Configurando o arquivo .env..."
echo "PORT=3000" > .env

# Abrir o WhatsApp Web para escanear o código QR usando Puppeteer
print_status "Abrindo o WhatsApp Web para escanear o código QR..."

# Instalar Puppeteer na versão compatível
print_status "Instalando Puppeteer..."
npm install puppeteer@10

# Executar o script Node.js separadamente
print_status "Executando o script Node.js para adicionar o bot como novo dispositivo..."

# Chamada para o script Node.js que lida com Puppeteer e readline-sync
node "$project_dir/add_bot.js"

print_status "Instalação concluída com sucesso!"
