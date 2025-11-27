#!/bin/bash

echo "🚀 Iniciando setup genérico da VPS..."

USER_NAME="ubuntu"
ALIAS_FILE="/etc/profile.d/custom_aliases.sh"
SCRIPTS_DIR="/home/ubuntu/sh_scripts"

# ----------------------------
# Atualização do sistema
# ----------------------------
echo "🔄 Atualizando sistema..."
apt update && apt upgrade -y

# ----------------------------
# Pacotes Essenciais
# ----------------------------
ESSENTIALS=(git zsh curl htop unzip nginx)
for pkg in "${ESSENTIALS[@]}"; do
    if ! dpkg -s $pkg >/dev/null 2>&1; then
        echo "📦 Instalando $pkg..."
        apt install -y $pkg
    else
        echo "✅ $pkg já instalado."
    fi
done

# ----------------------------
# Instalar Fish Shell
# ----------------------------
if ! command -v fish >/dev/null 2>&1; then
    echo "🐟 Instalando Fish Shell..."
    apt install -y fish
else
    echo "✅ Fish já instalado."
fi

# ----------------------------
# Docker
# ----------------------------
if ! command -v docker >/dev/null 2>&1; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $USER_NAME
else
    echo "✅ Docker já instalado."
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    echo "🛠 Instalando Docker Compose plugin..."
    apt install docker-compose-plugin -y
else
    echo "✅ Docker Compose já instalado."
fi

# ----------------------------
# Mensagem final
# ----------------------------
echo ""
echo "🎉 Setup finalizado!"
echo "✨ Tudo pronto para usar!"
