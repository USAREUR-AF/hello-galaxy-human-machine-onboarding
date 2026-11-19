# Figures

`make-figures.py` draws the figure at the top of the root README, `two-ceremonies`, in a
light and a dark version for a `<picture>` element. Its facts come from
scenarios 01 and 02 (`scenarios/0*/run.sh`): the commands, the node class, the gates and what each mint produces; the build stops if one of them is no longer there.

```
python3 -I docs/figures/make-figures.py           # write the SVG files
python3 -I docs/figures/make-figures.py --check   # exit 1 if a committed SVG is out of date
```

Standard library only. The SVG files are self-contained: no external fonts,
styles or images.
