# Discord

[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://docs.cdg.dev/Discord.jl)
[![Build Status](https://travis-ci.com/christopher-dG/Discord.jl.svg?branch=master)](https://travis-ci.com/christopher-dG/Discord.jl)
[![Discord](https://img.shields.io/badge/discord-join-7289da.svg)](https://discord.gg/ng9TjYd)

Write [Discord](https://discord.com) bots in [Julia](https://julialang.org).

### Status

This package is in the early stages.
Currently, the full REST API is available, but the gateway interface has not been implemented.

### History

[Xh4H](https://github.com/Xh4H) and I previously implemented [another Discord.jl package](https://github.com/Xh4H/Discord.jl), but it was never published in a Julia registry for several reasons.
This fresh implementation aims to keep things as simple as possible and minimize extra features in order to maximize maintainability as the Discord API changes.
It also aims to be easily extensible, so that packages providing extra features can be written on top of it.
