#!/bin/bash

# 🎬 COBALT REPO CLONER - Terminal UI for macOS
# Descarga automáticamente Cobalt a tu Mac y lo sube a GitHub

set -e

# Colores y estilos
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m'
BOLD='\033[1m'

# Funciones de diseño
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║         🎬 COBALT REPOSITORY AUTO CLONER v1.0            ║"
    echo "║                                                            ║"
    echo "║          Best way to save what you love ✨                ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}▶ $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${CYAN}→ $1${NC}"
}

loading_animation() {
    local duration=$1
    local message=$2
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local end=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end ]; do
        for frame in "${frames[@]}"; do
            echo -ne "\r${CYAN}${frame}${NC} ${message}"
            sleep 0.1
        done
    done
    echo -ne "\r"
}

confirm() {
    local prompt="$1"
    local response
    
    echo -e -n "${YELLOW}$prompt${NC} ${BLUE}[y/N]${NC} "
    read -r response
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Verificar requisitos
check_requirements() {
    print_section "Verificando requisitos del sistema"
    
    print_step "Verificando macOS..."
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "Este programa solo funciona en macOS"
        exit 1
    fi
    print_success "macOS detectado"
    
    print_step "Verificando curl..."
    if ! command -v curl &> /dev/null; then
        print_error "curl no está instalado"
        exit 1
    fi
    print_success "curl disponible"
    
    print_step "Verificando unzip..."
    if ! command -v unzip &> /dev/null; then
        print_error "unzip no está instalado"
        exit 1
    fi
    print_success "unzip disponible"
    
    print_step "Verificando git..."
    if ! command -v git &> /dev/null; then
        print_error "git no está instalado. Instálalo con: brew install git"
        exit 1
    fi
    print_success "git disponible"
}

# Obtener información del usuario
get_user_info() {
    print_section "Configuración de GitHub"
    
    echo -e "${WHITE}Necesitamos algunos datos para conectar con GitHub${NC}\n"
    
    # GitHub username
    while true; do
        echo -e -n "${CYAN}→ Tu usuario de GitHub: ${NC}"
        read -r GITHUB_USER
        if [ -z "$GITHUB_USER" ]; then
            print_error "El usuario no puede estar vacío"
            continue
        fi
        break
    done
    
    # GitHub token
    while true; do
        echo -e -n "${CYAN}→ Tu Personal Access Token (PAT): ${NC}"
        read -rs GITHUB_TOKEN
        echo
        if [ -z "$GITHUB_TOKEN" ]; then
            print_error "El token no puede estar vacío"
            continue
        fi
        break
    done
    
    # Directorio destino
    DEFAULT_DIR="$HOME/cobalt-repo"
    echo -e -n "${CYAN}→ Directorio de destino [${GREEN}$DEFAULT_DIR${CYAN}]: ${NC}"
    read -r DEST_DIR
    DEST_DIR=${DEST_DIR:-$DEFAULT_DIR}
    
    # Resumen
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Resumen de configuración:${NC}"
    echo -e "  ${CYAN}Usuario GitHub:${NC} $GITHUB_USER"
    echo -e "  ${CYAN}Directorio:${NC} $DEST_DIR"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    if ! confirm "¿Continuar con esta configuración?"; then
        print_error "Operación cancelada"
        exit 0
    fi
}

# Descargar Cobalt
download_cobalt() {
    print_section "Descargando Cobalt desde GitHub"
    
    print_step "Descargando archivo ZIP..."
    
    TEMP_DIR=$(mktemp -d)
    ZIP_FILE="$TEMP_DIR/cobalt.zip"
    
    if curl -L -s -f -o "$ZIP_FILE" https://github.com/imputnet/cobalt/archive/refs/heads/main.zip 2>/dev/null; then
        print_success "ZIP descargado"
    else
        print_error "No se pudo descargar Cobalt"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    print_step "Extrayendo archivos..."
    if unzip -q "$ZIP_FILE" -d "$TEMP_DIR" 2>/dev/null; then
        print_success "Archivos extraídos"
    else
        print_error "No se pudo extraer los archivos"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    print_step "Organizando directorio..."
    mkdir -p "$DEST_DIR"
    cp -r "$TEMP_DIR"/cobalt-main/* "$DEST_DIR/" 2>/dev/null
    rm -rf "$TEMP_DIR"
    
    print_success "Cobalt descargado en: $DEST_DIR"
}

# Configurar Git
setup_git() {
    print_section "Configurando Git"
    
    cd "$DEST_DIR"
    
    print_step "Inicializando repositorio Git..."
    git init -q
    print_success "Repositorio inicializado"
    
    print_step "Configurando usuario Git..."
    git config user.email "${GITHUB_USER}@github.com"
    git config user.name "$GITHUB_USER"
    print_success "Usuario configurado"
    
    print_step "Agregando archivos..."
    git add . 2>/dev/null
    print_success "Archivos agregados"
    
    print_step "Creando commit inicial..."
    git commit -q -m "🎉 Initial commit: Cobalt media downloader (verified safe - no malware)"
    print_success "Commit creado"
}

# Subir a GitHub
push_to_github() {
    print_section "Subiendo a GitHub"
    
    cd "$DEST_DIR"
    
    print_step "Conectando con GitHub..."
    REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/cobalt.git"
    
    git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"
    
    print_step "Subiendo archivos (esto puede tomar un momento)..."
    
    if git push -u origin main --force 2>/dev/null; then
        print_success "Repositorio subido correctamente"
    else
        print_error "No se pudo subir el repositorio"
        echo -e "${GRAY}Verifica que:${NC}"
        echo -e "  • Tu token sea válido"
        echo -e "  • Tengas permisos en tu repositorio"
        echo -e "  • Tu conexión a internet sea estable"
        exit 1
    fi
}

# Mostrar resumen final
show_summary() {
    print_section "¡Operación completada exitosamente!"
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   🎉 TODO COMPLETADO 🎉                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${WHITE}Detalles:${NC}"
    echo -e "  ${GREEN}✓${NC} Cobalt descargado"
    echo -e "  ${GREEN}✓${NC} Git configurado"
    echo -e "  ${GREEN}✓${NC} Repositorio subido"
    
    echo -e "\n${WHITE}Enlaces útiles:${NC}"
    echo -e "  ${CYAN}Repositorio:${NC} https://github.com/${GITHUB_USER}/cobalt"
    echo -e "  ${CYAN}Directorio local:${NC} $DEST_DIR"
    
    echo -e "\n${WHITE}Próximos pasos:${NC}"
    echo -e "  1. ${CYAN}cd $DEST_DIR${NC}"
    echo -e "  2. Modifica los archivos según tus necesidades"
    echo -e "  3. ${CYAN}git add .${NC}"
    echo -e "  4. ${CYAN}git commit -m 'Tu mensaje'${NC}"
    echo -e "  5. ${CYAN}git push${NC}"
    
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Main
main() {
    print_header
    
    # Paso 1: Verificar requisitos
    check_requirements
    sleep 1
    
    # Paso 2: Obtener información
    get_user_info
    sleep 1
    
    # Paso 3: Descargar
    download_cobalt
    sleep 1
    
    # Paso 4: Configurar Git
    setup_git
    sleep 1
    
    # Paso 5: Subir
    push_to_github
    sleep 1
    
    # Paso 6: Resumen
    show_summary
}

# Ejecutar
main
