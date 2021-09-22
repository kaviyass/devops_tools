#!/usr/bin/env bash

set -eo pipefail
source ${BASH_SOURCE%/*}/../_functions.sh


# Terraform and Terrqgrunt
## terraenv
folder=$(downloadTar https://github.com/aaratn/terraenv/releases/latest/download/terraenv_linux_x64.tar.gz)
mv $folder/terraenv $HOME/bin/terraenv
if ! rg TERRA_PATH ~/.zshrc &>/dev/null; then
  echo 'export TERRA_PATH="$HOME/.terraenv"' >> ~/.zshrc
fi
## TODO: needs to be fixed with a PR
# Install Terraform
sudo TERRA_PATH="/home/carlosjgp/.terraenv" terraenv terraform install $(terraenv terraform list remote | tail -1)
# Install
sudo TERRA_PATH="/home/carlosjgp/.terraenv" terraenv terragrunt install $(terraenv terragrunt list remote | tail -1)

# Install tfsec
getLatestGithubBinary liamg/tfsec tfsec-linux-amd64 tfsec
getLatestGithubBinary liamg/tfsec tfsec-checkgen-linux-amd64 tfsec-checkgen

# Install TFLint
getLatestGithubZip terraform-linters/tflint _linux_amd64.zip tflint

# Install run
getLatestGithubTarGZ TekWizely/run _linux_amd64.tar.gz run

# Install sops
downloadBinary $(latestGithubReleaseURI mozilla/sops linux) sops

# Install trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Install pre-commit git hook
pip install --upgrade --force pre-commit

# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install
folder=$(downloadZip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)
sudo $folder/aws/install

downloadBinary $(latestGithubReleaseURI 99designs/aws-vault aws-vault-linux-amd64) aws-vault

if ! cliExists docker; then
  echo Install Docker CE
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
  # Edge is required for Ubuntu 18.04
  sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     edge"
  sudo apt update
  sudo apt install -y docker-ce
  sudo usermod -aG docker $USER
fi

shutdown -r 0
