#!/bin/bash

# Set colors for better visibility
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
INVERSE='\033[7m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    printf "${BOLD}${INVERSE}$1${NC}\n\n"
}

# Update Fedora packages
print_header "Updating Fedora Packages"
if sudo dnf update -y --refresh --allowerasing; then
    printf "\n${GREEN}${BOLD}Fedora packages updated successfully.${NC}\n\n"
else
    printf "\n${YELLOW}${BOLD}Fedora update encountered issues. Check the output above.${NC}\n\n"
fi

# Update Flatpak applications
print_header "Updating Flatpak Applications"
if flatpak update -y; then
    printf "\n${GREEN}${BOLD}Flatpak applications updated successfully.${NC}\n\n"
else
    printf "\n${YELLOW}${BOLD}Flatpak update encountered issues. Check the output above.${NC}\n\n"
fi

# Clean up DNF cache (optional but good practice)
print_header "Cleaning DNF Cache"
if sudo dnf clean packages --quiet; then
    printf "${CYAN}DNF cache cleaned successfully.${NC}\n\n"
fi

# Remove orphaned packages (optional but good practice)
print_header "Removing Orphaned Packages"
if sudo dnf autoremove -y; then
    printf "${CYAN}Orphaned packages removed successfully.${NC}\n\n"
fi

# Remove old Flatpak runtimes (optional but good practice)
print_header "Cleaning Flatpak Runtimes"
if flatpak uninstall --unused -y; then
    printf "${CYAN}Unused Flatpak runtimes removed successfully.${NC}\n\n"
fi

# Final message
print_header "Update Process Completed"


# #!/bin/bash

# printf "\033[1m\033[7mUpdating Fedora\033[0m"
# printf "\n"
# sudo dnf update -y --refresh --allowerasing

# printf "\033[1m\033[7mUpdating Flatpak\033[0m"
# printf "\n"
# flatpak update -y

# printf "\033[1m\033[7mUpdate completed\033[0m"