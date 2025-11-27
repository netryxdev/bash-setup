#!/bin/bash
set -euo pipefail

echo "-------------------------------------------"
echo "   Setup interativo genérico para VPS"
echo "-------------------------------------------"

# -------------------------
# 1. Pergunta usuário VPS
# -------------------------
read -rp "Nome do usuário da VPS [ubuntu]: " USER_NAME
USER_NAME=${USER_NAME:-ubuntu}
HOME_DIR="/home/$USER_NAME"

# -------------------------
# 2. Pergunta nome do projeto
# -------------------------
read -rp "Nome do projeto [projeto]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-projeto}
PROJECT_DIR="$HOME_DIR/$PROJECT_NAME"

if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
    echo "Pasta do projeto criada em: $PROJECT_DIR"
else
    echo "Pasta do projeto já existe em: $PROJECT_DIR"
fi

# -------------------------
# Função para instalar se faltar
# -------------------------
install_if_missing() {
    PACKAGE=$1
    if ! dpkg -s "$PACKAGE" &>/dev/null; then
        echo "Instalando $PACKAGE..."
        sudo apt install -y "$PACKAGE"
    else
        echo "$PACKAGE já instalado, pulando."
    fi
}

# -------------------------
# 3. Atualizar sistema
# -------------------------
echo "Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# -------------------------
# 4. Pacotes essenciais
# -------------------------
echo "Instalando pacotes essenciais..."
for pkg in git zsh curl htop unzip; do
    install_if_missing "$pkg"
done

# -------------------------
# 5. Oh-My-Zsh
# -------------------------
if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
    echo "Instalando Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh-My-Zsh já instalado, pulando."
fi

# -------------------------
# 6. Docker e Compose
# -------------------------
if ! command -v docker &>/dev/null; then
    echo "Instalando Docker..."
    curl -fsSL https://get.docker.com | sudo sh
else
    echo "Docker já instalado, pulando."
fi

sudo usermod -aG docker "$USER_NAME"
install_if_missing docker-compose-plugin

# -------------------------
# 7. Aliases
# -------------------------
echo "Configurando aliases..."
ALIASES_FILE="$HOME_DIR/.aliases_$PROJECT_NAME"
cat > "$ALIASES_FILE" <<EOF
# Aliases para projeto $PROJECT_NAME
alias project="cd $PROJECT_DIR"
alias logs="docker-compose logs -f"
alias db="docker exec -it postgres psql -U postgres"
alias ll="ls -lah"
alias gs="git status"
alias gp="git pull"
alias gc="git commit -m"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias cdu="cd /var/www"
alias rebuild="docker compose down && docker compose build && docker compose up -d"
alias helpsetup="echo 'Comandos disponíveis: project, logs, db, ll, gs, gp, gc, dcu, dcd, dcl, cdu, rebuild'"
EOF

grep -qxF "source $ALIASES_FILE" "$HOME_DIR/.zshrc" 2>/dev/null || echo "source $ALIASES_FILE" >> "$HOME_DIR/.zshrc"
grep -qxF "source $ALIASES_FILE" "$HOME_DIR/.bashrc" 2>/dev/null || echo "source $ALIASES_FILE" >> "$HOME_DIR/.bashrc"

# -------------------------
# 8. Pasta scripts
# -------------------------
echo "Criando pasta ~/scripts..."
mkdir -p "$HOME_DIR/scripts"
chmod +x "$HOME_DIR/scripts"

# -------------------------
# Finalização
# -------------------------
echo "---------------------------------------------------"
echo "Setup interativo concluído com sucesso!"
echo "Projeto: $PROJECT_NAME"
echo "Pasta do projeto: $PROJECT_DIR"
echo "Reinicie o terminal ou rode 'source ~/.zshrc' para ativar aliases"
echo "Use 'helpsetup' para listar todos os comandos disponíveis"
echo "---------------------------------------------------"
