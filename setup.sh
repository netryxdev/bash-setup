#!/bin/bash

# ----------------------------
# Setup Genérico de VPS
# ----------------------------

echo "🚀 Iniciando setup genérico da VPS..."

# ----------------------------
# Perguntas iniciais
# ----------------------------
read -p "Nome do usuário da VPS (padrão: ubuntu): " USER_NAME
USER_NAME=${USER_NAME:-ubuntu}

read -p "Nome do projeto (padrão: projeto): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-projeto}

PROJECT_DIR="$HOME/$PROJECT_NAME"

echo "📂 Diretório do projeto definido como: $PROJECT_DIR"

# ----------------------------
# Atualização do sistema
# ----------------------------
echo "🔄 Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# ----------------------------
# Instalação de pacotes essenciais
# ----------------------------
ESSENTIALS=(git zsh curl htop unzip)
for pkg in "${ESSENTIALS[@]}"; do
    if ! dpkg -s $pkg >/dev/null 2>&1; then
        echo "📦 Instalando $pkg..."
        sudo apt install -y $pkg
    else
        echo "✅ $pkg já instalado, pulando."
    fi
done

# ----------------------------
# Instalação Oh-My-Zsh
# ----------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💎 Instalando Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh-My-Zsh já instalado, pulando."
fi

# ----------------------------
# Docker & Docker Compose
# ----------------------------
if ! command -v docker >/dev/null 2>&1; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $USER_NAME
else
    echo "✅ Docker já instalado, pulando."
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    echo "🛠 Instalando Docker Compose plugin..."
    sudo apt install docker-compose-plugin -y
else
    echo "✅ Docker Compose já instalado, pulando."
fi

# ----------------------------
# Criar estrutura de pastas
# ----------------------------
mkdir -p "$PROJECT_DIR"
mkdir -p "$HOME/scripts"
chmod +x "$HOME/scripts"
echo "📂 Estrutura de pastas criada: $PROJECT_DIR e ~/scripts"

# ----------------------------
# Criar arquivo de aliases
# ----------------------------
ALIAS_FILE="$HOME/.aliases_$PROJECT_NAME"

cat > "$ALIAS_FILE" <<EOF
# Aliases principais
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
alias cdu="cd /home/ubuntu"
alias cdp="cd /var/www"
alias rebuild="docker compose down && docker compose build && docker compose up -d"

# Deploy
alias deploy="$PROJECT_DIR/deploy.sh -y"
alias helpsetup="cat $ALIAS_FILE"
EOF

# Carrega aliases
echo "source $ALIAS_FILE" >> ~/.zshrc
echo "✅ Aliases criados e carregados em ~/.zshrc"

# ----------------------------
# Criar deploy.sh
# ----------------------------
if [ ! -f "$PROJECT_DIR/deploy.sh" ]; then
    cat > "$PROJECT_DIR/deploy.sh" <<'EOF'
#!/bin/bash
CURRENT_DIR=$(pwd)

if [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ docker-compose.yml não encontrado em $CURRENT_DIR."
    echo "Certifique-se de estar na pasta correta do projeto."
    exit 1
fi

echo "🚀 Atualizando código do Git..."
git pull origin main

echo "🛑 Parando containers existentes..."
docker-compose down

echo "📦 Rebuild e start dos containers..."
docker-compose up -d --build

echo "✅ Deploy finalizado com sucesso!"
EOF
    chmod +x "$PROJECT_DIR/deploy.sh"
    echo "✅ deploy.sh criado e pronto para uso."
else
    echo "ℹ️ deploy.sh já existe em $PROJECT_DIR, pulando criação."
fi

# ----------------------------
# Mensagem final
# ----------------------------
echo "🎉 Setup finalizado!"
echo "Use 'project' para entrar na pasta do projeto."
echo "Use 'helpsetup' para ver todos os aliases e comandos disponíveis."
echo "A pasta ~/scripts está pronta para seus scripts adicionais."
