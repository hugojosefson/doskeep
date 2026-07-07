FROM ianburgwin/steamos:base

RUN pacman -Syu --noconfirm --needed curl bash python python-pip && \
    pip install vdf --break-system-packages

COPY doskeep /steamdeck/doskeep
COPY test/setup.sh /test-setup.sh

CMD ["bash", "/test-setup.sh"]
