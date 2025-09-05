#!/bin/bash

# ===========================
# Diretório do servidor PocketMine
# ===========================
cd /srv/daemon-data/$SERVER_ID || exit

# ===========================
# Função para rodar Playit em background
# ===========================
start_playit() {
    echo "[INFO] Iniciando Playit Agent..."
    ./playit > playit.log 2>&1 &
    PLAYIT_PID=$!
}

# ===========================
# Baixar PHP Binaries se não existir
# ===========================
if [ ! -d "bin" ]; then
    echo "[INFO] Baixando PHP Binaries..."
    wget https://github.com/pmmp/PHP-Binaries/releases/download/pm5-php-8.2-latest/PHP-8.2-Linux-x86_64-PM5.tar.gz -O PHP.tar.gz
    tar -xzf PHP.tar.gz
    rm PHP.tar.gz
    chmod +x ./bin/php7/bin/php
else
    chmod +x ./bin/php7/bin/php
fi

# ===========================
# Baixar PocketMine-MP e start.sh se não existir
# ===========================
if [ ! -f "PocketMine-MP.phar" ]; then
    echo "[INFO] Baixando PocketMine-MP..."
    wget https://github.com/pmmp/PocketMine-MP/releases/download/5.30.1/PocketMine-MP.phar
fi

if [ ! -f "start.sh" ]; then
    echo "[INFO] Baixando start.sh..."
    wget https://github.com/pmmp/PocketMine-MP/releases/download/5.30.1/start.sh
    chmod +x start.sh
fi

# ===========================
# Baixar Playit Agent se não existir
# ===========================
if [ ! -f playit ]; then
    echo "[INFO] Baixando Playit Agent..."
    wget https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -O playit
    chmod +x playit
fi

# ===========================
# Loop para manter o Playit ativo
# ===========================
start_playit
sleep 5  # Espera gerar o link

# ===========================
# Exibir link de claim do Playit
# ===========================
echo "=============================="
echo "[INFO] LINK DE CLAIM DO PLAYIT:"
grep -Eo 'https://playit.gg/claim/[a-zA-Z0-9]+' playit.log
echo "=============================="

# ===========================
# Monitorar e reiniciar Playit se cair
# ===========================
(
while true; do
    if ! kill -0 $PLAYIT_PID 2>/dev/null; then
        echo "[WARN] Playit caiu! Reiniciando..."
        start_playit
    fi
    sleep 10
done
) &

# ===========================
# Iniciar PocketMine-MP usando start.sh
# ===========================
echo "[INFO] Iniciando PocketMine-MP..."
./start.sh
