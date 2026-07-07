FROM ianburgwin/steamos:base

RUN pacman -Syu --noconfirm --needed curl bash

COPY dosdeck /steamdeck/dosdeck
COPY test/setup.sh /test-setup.sh

CMD ["bash", "/test-setup.sh"]
