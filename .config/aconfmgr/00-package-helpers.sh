# Packages built from PKGBUILDs stored in packages/<package>.
declare -Ag ACONFMGR_LOCAL_PACKAGES=()

AddLocalPackage() {
    local package package_dir

    for package in "$@"; do
        package_dir="$config_dir/packages/$package"
        if [[ ! -f "$package_dir/PKGBUILD" ]]; then
            printf 'AddLocalPackage: PKGBUILD not found: %s\n' \
                "$package_dir/PKGBUILD" >&2
            return 1
        fi

        ACONFMGR_LOCAL_PACKAGES["$package"]="$package_dir"
        AddPackage --foreign "$package"
    done
}

# Preserve aconfmgr's installer for regular AUR packages, then dispatch packages
# declared with AddLocalPackage to their checked-in PKGBUILD instead.
eval "$(declare -f AconfInstallForeign |
    sed '1s/^AconfInstallForeign /AconfInstallForeignFromRepository /')"

AconfInstallForeign() {
    local asdeps=false
    local -a asdeps_arg=() repository_packages=()
    local package

    if [[ "$1" == --asdeps ]]; then
        asdeps=true
        asdeps_arg=(--asdeps)
        shift
    fi

    for package in "$@"; do
        if [[ -v "ACONFMGR_LOCAL_PACKAGES[$package]" ]]; then
            LogEnter 'Building local package %s from %s.\n' \
                "$(Color M %q "$package")" \
                "$(Color C %q "${ACONFMGR_LOCAL_PACKAGES[$package]}")"
            (
                cd "${ACONFMGR_LOCAL_PACKAGES[$package]}"
                makepkg --syncdeps --install --needed --clean --noconfirm \
                    "${asdeps_arg[@]}"
            )
            LogLeave 'Installed.\n'
        else
            repository_packages+=("$package")
        fi
    done

    if ((${#repository_packages[@]})); then
        if $asdeps; then
            AconfInstallForeignFromRepository --asdeps "${repository_packages[@]}"
        else
            AconfInstallForeignFromRepository "${repository_packages[@]}"
        fi
    fi
}
