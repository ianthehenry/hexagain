# Hexagain

It's a website? I guess?

Deployed to https://hexagain.com.

## Building the site

Building the site requires `hugo` and `postcss-cli`. Install `hugo` with your system package manager, and `postcss-cli` with `yarn`:

```bash
$ yarn global add postcss-cli
$ yarn install
```

It doesn't need to be installed globally, if you add `./node_modules/.bin` to your `PATH`.

After that, you should be able to just run:

```bash
$ hugo server
```

And everything should work, because the generated JavaScript is checked in to the assets directory.

## Changing the JavaScript

This is trickier. You'll need `opam` and `dune`, but you'll also need to pin a custom [`incr_dom`](https://github.com/ianthehenry/incr_dom) and a custom [`async_extra`](https://github.com/ianthehenry/async_extra).

To rebuild the JavaScript, run:

```bash
$ dune build --profile=production client/hexagain_client.bc.js
```

Or, in development:

```bash
$ dune build --watch client/hexagain_client.bc.js
```

From the `client/` subdirectory.

Before committing, make sure you run:

```bash
$ dune build --auto-promote @fmt
$ dune runtest --auto-promote
```

There is a server but it's not really a thing that... works. Just ignore that for now.

I've been using this really janky one-liner to move the build artifact into the hugo assets directory (also from the `client/` subdirectory):

```bash
$ while true; do if cmp -s _build/default/client/hexagain_client.bc.js ../assets/main.js; then : ; else echo update $(date); cp _build/default/client/hexagain_client.bc.js ../assets/main.js; fi; sleep 1; done
```

There's probably some real way to do this.
