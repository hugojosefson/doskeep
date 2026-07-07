FROM ianburgwin/steamos:base

RUN pacman -Syu --noconfirm --needed curl bash

COPY doskeep /steamdeck/doskeep
COPY test/setup.sh /test-setup.sh

CMD ["bash", "/test-setup.sh"]
