#!/usr/bin/env bash
# Local PyBLOCK installer for development/testing (Bitcoin-only mode).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${ROOT_DIR}/.venv"
PYBITBLOCK="${ROOT_DIR}/pybitblock"
CONFIG_DIR="${PYBITBLOCK}/config"
LAUNCHER="${HOME}/.local/bin/pyblock"

echo "==> PyBLOCK local install"
echo "    Project: ${ROOT_DIR}"

if [[ ! -d "${VENV_DIR}" ]]; then
    echo "==> Creating virtualenv..."
    python3 -m venv "${VENV_DIR}" --system-site-packages
fi

echo "==> Installing Python dependencies (this may take a minute)..."
"${VENV_DIR}/bin/pip" install --upgrade pip -q

# Install without building pillow (use system python-pillow via --system-site-packages).
REQS=(
    typer typer-cli rich psutil requests simplejson qrcode art numpy textual urwid
    plotext embit python-gnupg python-cfonts html2text pdfminer pdf2text pdf2txt
    protobuf googleapis-common-protos termcolor pycoingecko sseclient-py xmltodict
    chardet idna certifi urllib3 vanity-address==0.1.4 jq blessings click shellingham
    typing-extensions markdown-it-py mdurl pygments linkify-it-py uc-micro-py wcwidth six
    pyparsing kiwisolver fonttools cycler contourpy python-dateutil packaging
    colorama pyfiglet SQLAlchemy greenlet natsort pycryptodome
)
"${VENV_DIR}/bin/pip" install --no-deps "${REQS[@]}" -q
"${VENV_DIR}/bin/pip" install --no-deps robohash bitcoinlib matplotlib asciimatics term-image fastecdsa ecdsa base58 -q

mkdir -p "${CONFIG_DIR}"

if [[ ! -f "${CONFIG_DIR}/intro.conf" ]]; then
    echo '"B"' > "${CONFIG_DIR}/intro.conf"
    echo "==> Created intro.conf (Bitcoin-only mode)"
fi

if [[ ! -f "${CONFIG_DIR}/bclock.conf" ]]; then
    cat > "${CONFIG_DIR}/bclock.conf" <<'EOF'
{
  "ip_port": "",
  "rpcuser": "",
  "rpcpass": "",
  "bitcoincli": "bitcoin-cli"
}
EOF
    echo "==> Created bclock.conf (local bitcoin-cli)"
fi

if [[ ! -f "${CONFIG_DIR}/oraclevision.conf" ]]; then
    cp "${CONFIG_DIR}/oraclevision.conf.example" "${CONFIG_DIR}/oraclevision.conf"
    echo "==> Created oraclevision.conf"
fi

if [[ ! -f "${CONFIG_DIR}/pyblocksettings.conf" ]]; then
    cp "${CONFIG_DIR}/pyblocksettings.conf.example" "${CONFIG_DIR}/pyblocksettings.conf"
    echo "==> Created pyblocksettings.conf"
fi

mkdir -p "$(dirname "${LAUNCHER}")"
cat > "${LAUNCHER}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
cd "${PYBITBLOCK}"
exec "${VENV_DIR}/bin/python3" PyBlock.py "\$@"
EOF
chmod +x "${LAUNCHER}"

echo ""
echo "==> Installation complete!"
echo "    Run: pyblock"
echo "    OracleVision: B. Bitcoin -> OV. OracleVision"
echo "    Full TUI (E): launches ~/.local/bin/oraculovision"
echo ""
echo "    Branch: $(git -C "${ROOT_DIR}" branch --show-current 2>/dev/null || echo 'unknown')"