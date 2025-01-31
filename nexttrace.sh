ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="linux_amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH="linux_arm64"
elif [[ "$ARCH" == "armv7l" ]]; then
    ARCH="linux_arm"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

LATEST_VERSION=$(curl -sL "https://api.github.com/repos/nxtrace/NTrace-core/releases/latest" | grep '"tag_name":' | cut -d '"' -f 4)
DOWNLOAD_URL="https://github.com/nxtrace/NTrace-core/releases/download/${LATEST_VERSION}/nexttrace_${ARCH}"

echo "Downloading NextTrace ${LATEST_VERSION} for ${ARCH}..."
wget -O nexttrace "$DOWNLOAD_URL" && chmod +x nexttrace

echo "Installation complete. Run './nexttrace' to start."