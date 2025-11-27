# Setup Genérico de VPS

Este repositório contém um **script de bootstrap genérico** para configurar rapidamente uma nova VPS, instalar pacotes essenciais, Docker, Zsh/Oh-My-Zsh, aliases e estrutura de pastas para qualquer projeto.

---

## Como usar

### 1. Executar direto via curl

No terminal da VPS, rode:

```bash
curl -s https://raw.githubusercontent.com/netryxdev/bash-setup/setup.sh | bash

O script é interativo e vai perguntar:

Nome do usuário da VPS (padrão: ubuntu)

Nome do projeto (padrão: projeto)

Se nenhum nome for informado, ele cria uma pasta padrão $HOME/projeto.

2. O que o script faz

Atualiza o sistema (apt update && apt upgrade -y)

Instala pacotes essenciais: git, zsh, curl, htop, unzip

Instala Oh-My-Zsh (se ainda não estiver instalado)

Instala Docker e Docker Compose

Configura aliases úteis para o terminal, como:

project → entra na pasta do projeto

logs → logs do Docker Compose

db → acessa container PostgreSQL

ll, gs, gp, gc, dcu, dcd, dcl, cdu, rebuild

helpsetup → mostra todos os comandos disponíveis

Cria pasta ~/scripts para você guardar seus scripts SQL, Bash ou outros

Mensagens explicativas são exibidas em cada etapa para facilitar o acompanhamento

3. Comandos principais após setup
project     # entra na pasta do projeto
helpsetup   # lista todos os aliases e comandos disponíveis


Você também pode usar os aliases de Docker e Git diretamente:

logs        # ver logs do Docker Compose
db          # acessar banco PostgreSQL do container
dcu         # subir containers
dcd         # parar containers
rebuild     # rebuild completo do Docker Compose

4. Estrutura final após setup
$HOME/
 └── projeto/         # pasta do projeto
 └── scripts/         # scripts SQL ou Bash adicionais
 ~/.zshrc / ~/.bashrc # aliases e setup carregados automaticamente

5. Personalização

Se quiser mudar o nome do projeto, basta renomear a pasta criada e atualizar o alias project no arquivo .aliases_projeto.

Você pode adicionar novos aliases no arquivo .aliases_<nome_do_projeto> para organizar melhor comandos específicos de cada projeto.

6. Observações

O script é seguro para rodar várias vezes. Ele verifica se pacotes já estão instalados e pula caso já existam.

Recomendado abrir um novo terminal ou rodar source ~/.zshrc após o setup para ativar todos os aliases.

A pasta scripts é modular e pode ser usada para qualquer tipo de automação futura.