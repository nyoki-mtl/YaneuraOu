#!/usr/bin/env bash
set -euo pipefail

# 作業ディレクトリをワークスペースに揃える
cd "${containerWorkspaceFolder:-/workspaces/YaneuraOu}" || exit 1

echo "[postCreate] Running apt-get update..."
sudo apt-get update

echo "[postCreate] Installing build dependencies..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y \
  build-essential \
  pkg-config \
  lsb-release \
  wget \
  software-properties-common \
  gnupg

# Install LLVM/Clang with the requested version (defaults to 20)
LLVM_VER="${LLVM_VERSION:-20}"
echo "[postCreate] Installing LLVM/Clang ${LLVM_VER} via apt.llvm.org..."
wget -q https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh "${LLVM_VER}" all
rm -f llvm.sh
sudo update-alternatives --install /usr/bin/clang clang "/usr/bin/clang-${LLVM_VER}" 100
sudo update-alternatives --install /usr/bin/clang++ clang++ "/usr/bin/clang++-${LLVM_VER}" 100

echo "[postCreate] Installing Node CLI tools (claude-code, gemini-cli)..."
npm install -g @anthropic-ai/claude-code @google/gemini-cli @openai/codex

echo "[postCreate] Syncing Python environment with uv (dev group)..."
uv sync --all-extras

echo "[postCreate] Done."
