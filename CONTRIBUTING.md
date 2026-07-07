# Contributing

## Development

- [Makefile](Makefile) — `make all` renders HTML and runs tests
- [test/](test/) — containerized test harness for `doskeep`

## Testing

```bash
make all    # render HTML + run tests
make test   # tests only
make html   # render HTML only (via pattern rule %.html: %.md)
```

The test suite builds a SteamOS Docker container, runs `doskeep` through
all phases with mocked preconditions, and verifies each phase produces the
expected output and state transitions.
