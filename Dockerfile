FROM registry.hub.docker.com/archlinux/archlinux

RUN grep jp/ /etc/pacman.d/mirrorlist.pacnew | tr -d '#' > /etc/pacman.d/mirrorlist
RUN pacman -Sy
RUN pacman -S --noconfirm --needed \
    base-devel \
    iverilog \
    verilator \
    riscv64-elf-gcc \
    riscv64-elf-newlib
USER nobody
RUN curl https://aur.archlinux.org/cgit/aur.git/snapshot/yosys-git.tar.gz | tar xzf - -C /tmp/
USER root
RUN source /tmp/yosys-git/PKGBUILD && \
    pacman -S --noconfirm --needed --asdeps "${makedepends[@]}" "${depends[@]}" "${checkdepends[@]}"
USER nobody
RUN cd /tmp/yosys-git; \
    MAKEFLAGS="-j$(nproc)" makepkg
USER root
RUN pacman -U --noconfirm /tmp/yosys-git/yosys-git-*.pkg.*
RUN rm -rf /tmp/yosys-git
RUN pacman -Sc --noconfirm
