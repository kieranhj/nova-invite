# nova-invite: start here

The NOVA 2020 online party invite for the BBC Micro (Bitshifters): palette-cycling animations, images and text sequenced from Arkos Tracker 2 event tracks. Released at Outline Online 2020 (2nd in the combined demo compo). 6502, beebasm.

| | |
|---|---|
| GitHub | https://github.com/kieranhj/nova-invite (public) |
| Local path | D:\beeb\mine\nova-invite (moved from OneDrive\BEEB\Repos\nova-invite on 2026-11-22) |
| Branch | master; others: final-version, exo-inline-getbyte, exo-vgm-player, font-plotting, load-tables-lower, new-image-assets, proportional-font, reduced-events-bin, software-bass, switch-to-prev-fx, wip/2026-11-tidy |
| Last commit | 2020-08-12: Fix check for Master Compact |

## What's in here
- `nova-invite.asm`: main code (includes `src/`); `disc-build.asm`: puts the files on the disc.
- `data/`: images, fonts, anims, `music/Acid_demo_NN.aks` (Arkos Tracker songs), `events/` (example event songs).
- `bin/`: tools (beebasm, SongToRaw/SongToYM, exomizer, Python converters).
- `make.bat` (events + code + disc), `make-assets.bat` (images/fonts/anims -> build\), `make-music.bat` / `make-rhino.bat` (music too).
- `build/`, `disc/`: output (ignored).

## Build and run
- `make`: runs `make.bat data\music\Acid_demo_21.aks` (the song added in the final-version commit; override with `make AKS=...`). Other targets: `make assets`, `make music`, `make help`.
- Works (2026-11-22). The Python tools in `bin\` (aks_channel_parse_as_events, png2bbc, png2bbcfont, bbc, png, shellcmd, adf_create, and vgmpacker's modules lz4enc/huffman/vgmparser) were ported to Python 3 on 2026-11-22; their output is byte-identical to the 2020 build (events, all images/fonts/anims, the music .vgc, and `disc\nova-invite.ssd`).
- Tools: `bin\` (SongToRaw/SongToYM, exomizer); `python` (3) on PATH. `bin\beebasm.exe` no longer runs (missing DLL), so `make.bat`/`make-rhino.bat` use `%BEEBASM%`, default `..\..\third-party\beebasm\beebasm.exe` (beebasm 1.11, same output).
- Output: `disc\nova-invite.ssd`. Run: jsbeeb-kieranhj, the local jsbeeb clone it used, was deleted on 2026-11-27 (the fork is on GitHub), and `run.bat` with it; open the disc at https://bbc.xania.org or in b2.

## Local changes
- Uncommitted: `nova-invite.asm` sets `_DEBUG = TRUE` and `disc-build.asm` puts the `DEBUG` file on the disc (a debug build). Also on `wip/2026-11-tidy` (pushed 2026-11-21).

## Status and next steps
- Released and finished (final-version merged 2020-05-26; Compact fix 2020-08-12). The uncommitted change is just debug switched on; probably revert rather than commit.
- Builds again with plain `make` (Python 3 port, 2026-11-22). vgmpacker's `-n` (Huffman) option was not exercised by the build and is untested on Python 3.

## See also
- `README.md`; Arkos Tracker 2: https://www.julien-nevo.com/arkostracker/
