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
# Criar aliases globais
# ----------------------------
echo "⚙️ Configurando aliases globais..."

cat << 'EOF' > $ALIAS_FILE
alias logs="docker compose logs -f"
alias db="docker exec -it postgres psql -U postgres"
alias ll="ls -lah"
alias gs="git status"
alias gp="git pull"
alias gc="git commit -m"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias cdu="cd /home/ubuntu"
alias rebuild="docker compose down && docker compose build && docker compose up -d"

# Comando de ajuda do setup
helpsetup() {
    echo ""
    echo "========== 🛠 AJUDA DO SETUP DA VPS =========="
    echo ""
    echo "Comandos disponíveis:"
    echo "  ll        → ls -lah"
    echo "  gs        → git status"
    echo "  gp        → git pull"
    echo "  dcu       → docker compose up -d"
    echo "  dcd       → docker compose down"
    echo "  dcl       → docker compose logs -f"
    echo "  logs      → docker compose logs -f"
    echo "  rebuild   → derruba, builda e sobe containers"
    echo "  cdu       → volta para /home/ubuntu"
    echo ""
    echo "📁 Scripts da VPS ficam em: /home/ubuntu/sh_scripts"
    echo ""
    echo "💡 COMO CRIAR UM ALIAS GLOBAL:"
    echo "  Basta editar este arquivo:"
    echo "      sudo nano /etc/profile.d/custom_aliases.sh"
    echo ""
    echo "  E adicionar uma linha no formato:"
    echo "      alias meucomando=\"comando aqui\""
    echo ""
    echo "=============================================="
    echo ""
}
EOF

chmod +x $ALIAS_FILE

echo "source /etc/profile.d/custom_aliases.sh" >> /root/.bashrc
echo "source /etc/profile.d/custom_aliases.sh" >> /home/ubuntu/.bashrc
echo "source /etc/profile.d/custom_aliases.sh" >> /home/ubuntu/.zshrc

echo "✅ Aliases configurados GLOBALMENTE para Bash, Zsh e Fish."

# ----------------------------
# Criar pasta para scripts .sh
# ----------------------------
echo "📁 Criando pasta de scripts customizados..."
mkdir -p $SCRIPTS_DIR
chown ubuntu:ubuntu $SCRIPTS_DIR

# ----------------------------
# Mensagem final
# ----------------------------
echo ""
echo "🎉 Setup finalizado!"
echo "📌 Seus scripts ficarão em: $SCRIPTS_DIR"
echo "📌 Rode: helpsetup   → para ver lista de comandos"
echo ""
echo "✨ Tudo pronto para usar!"
