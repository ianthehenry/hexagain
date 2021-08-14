# Hexagain

It's a website? I guess?

Deployed to https://hexagain.com.

## Building the site

*Most* of the dependencies are enumerated in `shell.nix`, so you can do this to
get a working copy of the website:

```bash
$ nix-shell
[nix-shell]$ hugo server
```

But the OCaml stuff is separate:

```bash
cd app/
opam switch import deps --assume-depexts --switch .
eval $(opam env --switch .)
```

The `--assume-depexts` is necessary because `opam` doesn't detect that things
are installed if you install them with Nix, for some reason.

Wow! Everything worked and you got no errors! Great. No further questions. Let's
get to work.

**Note that every time you interact with this project, you will need to start
with `eval $(opam env)` from the `app/` subdirectory, or else everything will
be bad.** Unless you configured the auto-hook-switchy thing when you set up
opam.

To rebuild the JavaScript, `cd` into the `app/` subdirectory and run:

```bash
dune build --profile=production client/hexagain_client.bc.js
```

Or, in development:

```bash
dune build --watch client/hexagain_client.bc.js
```

Before committing, make sure you run:

```bash
dune build --auto-promote @fmt
dune runtest --auto-promote
```

There is a server but it's not really a thing that... works. Just ignore that
for now.

I've been using this really janky one-liner to move the build artifact into the
hugo assets directory (also from the `app/` subdirectory):

```bash
while true; do if cmp -s _build/default/client/hexagain_client.bc.js ../assets/main.js; then : ; else echo update $(date); cp _build/default/client/hexagain_client.bc.js ../assets/main.js; fi; sleep 1; done
```

There's probably some real way to do this.
