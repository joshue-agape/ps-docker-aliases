# 🚀 Docker Command Aliases – Documentation  

![GitHub repo size](https://img.shields.io/github/repo-size/joshue-agape/ps-docker-aliases)
![GitHub stars](https://img.shields.io/github/stars/joshue-agape/ps-docker-aliases?style=social)
![GitHub forks](https://img.shields.io/github/forks/joshue-agape/ps-docker-aliases?style=social)
![GitHub issues](https://img.shields.io/github/issues/joshue-agape/ps-docker-aliases)
![License](https://img.shields.io/github/license/joshue-agape/ps-docker-aliases)
![PowerShell](https://img.shields.io/badge/PowerShell-Ready-blue?logo=powershell)

Welcome to this documentation for setting up Git command aliases using PowerShell to boost your command-line productivity.  

## ⚙️ PowerShell Profile Setup  

Before using the aliases, you need to configure your PowerShell profile.  

### Check if the profile exists  

```bash
Test-Path $PROFILE
```

True → the profile already exists  
False → proceed to the next step  

### Create the profile

```bash
New-Item -Path $PROFILE -ItemType File -Force
```

### Open and edit the profile  

- Using Notepad:  

```bash
New-Item -Path $PROFILE -ItemType File -Force
```

- Or using VS Code:  

```bash
code $PROFILE
```

## 📦 Install Docker Aliases  

### Clone the repository  

```bash
git clone https://github.com/joshue-agape/ps-docker-aliases.git docker-commandes
```

### Copy alias files to config directory  

```bash
cp docker-commandes "$HOME\.config\alias\"
```

💡 Make sure the directory exists, otherwise create it:

```bash
mkdir -p "$HOME\.config\alias\"
```

### Import aliases into PowerShell  

Add the following line to your PowerShell profile  

```bash
. "$HOME\.config\alias\docker-commandes\index.ps1"
```

### Apply changes  

Reload your profile  

```bash
. $PROFILE
```

### ✅ Result  

Your Docker aliases are now active 🎉  
You can start using them directly in your terminal to speed up your workflow.  

💡 Tips  
Restart PowerShell if needed  
Double-check paths if aliases don’t work  
Customize your aliases in docker-commandes  
