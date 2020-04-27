# Hexagain

It's a website? I guess?

Deployed to https://hexagain.com.

## Building the site

Building the site requires `hugo` and `postcss-cli`. Install `hugo` with your
system package manager, and `postcss-cli` with `yarn`:

```bash
$ yarn global add postcss-cli
$ yarn install
```

It doesn't need to be installed globally, if you add `./node_modules/.bin` to
your `PATH`.

After that, you should be able to just run:

```bash
$ hugo server
```

And everything should work, because the generated JavaScript is checked in to
the assets directory.

## Changing the JavaScript

This is trickier.

You'll need to install `opam` with your system package manager, and probably run
things like `opam init` and the environment configuration stuff. Then set up a
"switch," a local package sandbox, for Hexagain.

```bash
$ cd client/
$ opam switch create . 4.10.0
$ eval $(opam env)
$ opam switch import deps
```

Wow! Everything worked and you got no errors! Great. No further questions. Lets
get to work.

**Note that every time you interact with this project, you will need to start
with `eval $(opam env)` from the `client/` subdirectory, or else everything will
be bad.** Unless you configured the auto-hook-switchy thing when you set up
opam.

To rebuild the JavaScript, `cd` into the `client/` subdirectory and run:

```bash
$ dune build --profile=production client/hexagain_client.bc.js
```

Or, in development:

```bash
$ dune build --watch client/hexagain_client.bc.js
```

Before committing, make sure you run:

```bash
$ dune build --auto-promote @fmt
$ dune runtest --auto-promote
```

There is a server but it's not really a thing that... works. Just ignore that
for now.

I've been using this really janky one-liner to move the build artifact into the
hugo assets directory (also from the `client/` subdirectory):

```bash
$ while true; do if cmp -s _build/default/client/hexagain_client.bc.js ../assets/main.js; then : ; else echo update $(date); cp _build/default/client/hexagain_client.bc.js ../assets/main.js; fi; sleep 1; done
```

There's probably some real way to do this.
