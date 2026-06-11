FROM archlinux

RUN pacman -Syu --noconfirm npm curl \
           wget cargo git gcc pkgconf openssl \
           python3 jq

# Install claude code
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN rm /root/.claude.json
RUN ln -s /root/.claude/.claude.json /root/.claude.json
