# Steam Deck stuff

> **Warning:** Everything in this repo is untested. It may not work or may cause
> issues. Use at your own risk.

Custom guides and configs for the Steam Deck.

## Contents

- [eXoDOS + EmuDeck: play 7,600+ DOS games from Gaming Mode](exodos-emudeck.md)
- [setup-dos.sh](setup-dos.sh) — automated setup script (companion to the guide
  above)
- [Makefile](Makefile) — `make all` renders HTML and runs tests
- [test/](test/) — containerized test harness for `setup-dos.sh`
  - [Dockerfile](test/Dockerfile) — SteamOS-based test image
  - [setup.sh](test/setup.sh) — test suite (5 phase tests)
  - [run.sh](test/run.sh) — one-command test runner

## Testing

```bash
make all    # render HTML + run tests
make test   # tests only
make html   # render HTML only (via pattern rule %.html: %.md)
```

The test suite builds a SteamOS Docker container, runs `setup-dos.sh` through
all phases with mocked preconditions, and verifies each phase produces the
expected output and state transitions.
