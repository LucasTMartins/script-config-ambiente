#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root" >&2
  exit 1
fi

diretorios=("publico" "adm" "ven" "sec") # Define os nomes dos diretórios
grupos=("GRP_ADM" "GRP_VEN" "GRP_SEC") # Define os nomes dos grupos

usuarios_e_grupos=( # Definindo os nomes dos usuários e seus grupos correspondentes
  "carlos:GRP_ADM"
  "maria:GRP_ADM"
  "joao:GRP_ADM"
  "debora:GRP_VEN"
  "sebastiana:GRP_VEN"
  "roberto:GRP_VEN"
  "josefina:GRP_SEC"
  "amanda:GRP_SEC"
  "rogerio:GRP_SEC"
)

# Loop para criar os grupos de usuários
for group_name in "${grupos[@]}"; do
  # Verifica se o grupo já existe
  if grep -q "^$group_name:" /etc/group; then
    echo "O grupo '$group_name' já existe."
  else
    # Cria o grupo
    groupadd "$group_name"
    echo "Grupo '$group_name' criado com sucesso."
  fi
done

# Loop para criar os diretórios
for ((i = 0; i < ${#diretorios[@]}; i++)); do
  dir_name="${diretorios[i]}"
  group_name="${grupos[i]}"

  # Verifica se o diretório já existe
  if [ -d "/$dir_name" ]; then
    echo "O diretório '/$dir_name' já existe."
  else
    # Cria o diretório
    mkdir "/$dir_name"
    # Altera o proprietário, grupo e as permissões do diretório
    if [i != 1]; then
      chown root:"$group_name" "/$dir_name"
      chmod 770 "/$dir_name"
    else
      chown root:root "/$dir_name"
      chmod 777 "/$dir_name"
    fi
    echo "Diretório '/$dir_name' criado com sucesso."
  fi
done

# Loop para criar usuários, atribuir a grupos e definir senha
for user_group in "${usuarios_e_grupos[@]}"; do
  user=$(echo "$user_group" | cut -d ':' -f 1)
  group=$(echo "$user_group" | cut -d ':' -f 2)
  
  # Verifica se o usuário já existe
  if id "$user" &>/dev/null; then
    echo "O usuário '$user' já existe."
  else
    # Cria o usuário e atribui ao grupo
    useradd -m -G "$group" "$user"
    echo "Usuário '$user' criado com sucesso e adicionado ao grupo '$group'."
    
    # Define uma senha para o usuário (neste caso, a senha é definida como "senha123")
    echo "$user:senha123" | chpasswd
    echo "Senha definida para o usuário '$user'."

    # Define a expiração da senha para o primeiro login
    chage -d 0 "$user"
  fi
done
