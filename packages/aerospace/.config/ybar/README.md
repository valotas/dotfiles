# YBar (Tokyo Night overlay)

Trying [YBar](https://github.com/NineFiveB/YBar) with the shipped **tokyonight**
look: a floating rounded island in Tokyo Night blues and purples. `topmost=off`
so the native menu bar draws on top. Sketchybar configs under
`~/.config/sketchybar*` stay untouched until this is a keeper.

## Layout

- Floating island (`margin=12`, `y_offset=8`, `corner_radius=14`)
- AeroSpace workspace numbers pinned to the monitor that owns the workspace
- Front-app (and now-playing) in the center cluster
- Input source (`en` / `gr`) on the right
- Date: right on the built-in panel, center on the external
- Wifi / volume / battery as accent text on the right

YBar.app should be `~/Applications/YBar.app` (`make app`). The Homebrew keg currently ships a bundle without `YBar_YBarKit.bundle`.

## Switch back to sketchybar

In `aerospace.toml`, restore the `sketchybar_main` / `sketchybar_alternative`
startup lines, comment the `start-ybar` line, then:

```sh
ybar --exit
aerospace reload-config
```
