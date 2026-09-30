#!/bin/bash

# Cobalt Downloader for macOS - Terminal UI
# Permite pegar un link y abrirlo en Cobalt automáticamente.
# No instala dependencias ni requiere Node.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║       COBALT DOWNLOADER FOR MACOS - TERMINAL           ║"
    echo "║                                                        ║"
    echo "║         Download media by link in one click ✨         ║"
    echo "║                                                        ║"
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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_menu() {
    print_header
    print_section "Opciones"
    echo -e "${WHITE}1)${NC} Descargar desde link"
    echo -e "${WHITE}2)${NC} Abrir Cobalt en el navegador"
    echo -e "${WHITE}3)${NC} Salir"
    echo -n -e "\n${CYAN}Selecciona una opción: ${NC}"
    read -r choice
    case "$choice" in
        1) download_link ;;
        2) open_cobalt ;;
        3) exit 0 ;;
        *) print_error "Opción inválida"; sleep 1; show_menu ;;
    esac
}

open_cobalt() {
    print_section "Abriendo Cobalt"
    print_info "Abriendo la web oficial de Cobalt..."
    open "https://cobalt.tools"
    print_success "Cobalt abierto en tu navegador"
    sleep 2
    show_menu
}

download_link() {
    print_section "Descargar por link"
    echo -n -e "${CYAN}Pega el link aquí: ${NC}"
    read -r LINK

    if [ -z "$LINK" ]; then
        print_error "No ingresaste ningún link"
        sleep 1
        show_menu
        return
    fi

    print_info "Preparando enlace para Cobalt..."
    open "https://cobalt.tools/#$LINK"
    print_success "Enlace enviado a Cobalt"
    print_info "Ahora solo sigue el proceso dentro del navegador"
    sleep 2
    show_menu
}

main() {
    show_menu
}

main
