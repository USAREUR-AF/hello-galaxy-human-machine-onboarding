"""Draw the README figure from the scenarios it shows.

    python3 -I docs/figures/make-figures.py           # write docs/figures/*.svg
    python3 -I docs/figures/make-figures.py --check   # exit 1 if a committed figure is out of date

Each figure is written twice, `<name>-light.svg` and `<name>-dark.svg`, for a
`<picture>` element. Every command, class and minted item in the figure is
checked against the scenario script it comes from, and the build stops if one
is no longer there. Standard library only; the output is deterministic.
"""

import os
import re
import sys
from xml.sax.saxutils import escape

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))

THEMES = {
    "light": {
        "paper": "#ffffff", "panel": "#f6f8fa", "ink": "#1f2328", "quiet": "#59636e", "rule": "#d1d9e0",
        "line": "#818b98", "accent": "#0969da", "accent_soft": "#ddf4ff", "on_accent": "#ffffff",
        "good": "#1a7f37", "good_bg": "#dafbe1", "crit": "#cf222e", "crit_bg": "#ffebe9",
        "warn": "#9a6700", "warn_bg": "#fff8c5", "mute": "#6e7781",
    },
    "dark": {
        "paper": "#0d1117", "panel": "#161b22", "ink": "#e6edf3", "quiet": "#9198a1", "rule": "#3d444d",
        "line": "#7d8590", "accent": "#4493f8", "accent_soft": "#132c4c", "on_accent": "#0d1117",
        "good": "#3fb950", "good_bg": "#12261e", "crit": "#f85149", "crit_bg": "#2f1517",
        "warn": "#d29922", "warn_bg": "#2e2510", "mute": "#8b949e",
    },
}
SANS = "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif"
MONO = "ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace"
W = 880          # every figure's width; a README column shows it at about 830 px
KIND = {"plain": ("panel", "rule"), "accent": ("accent_soft", "accent"), "good": ("good_bg", "good"),
        "crit": ("crit_bg", "crit"), "warn": ("warn_bg", "warn")}


def n(v):
    return ("%.1f" % v).rstrip("0").rstrip(".")


def tw(s, size, mono=False, bold=False):
    """Text width estimate; the browser lint confirms it."""
    if mono:
        return len(s) * size * 0.61
    w = 0.0
    for c in s:
        if c in "il.,:;|!'`·1 ":
            w += 0.30
        elif c in "ft()[]/-":
            w += 0.36
        elif c in "mwMW@%":
            w += 0.86
        elif c.isupper() or c in "0123456789≤≥²→":
            w += 0.64
        else:
            w += 0.55
    return w * size * (1.06 if bold else 1.0)


def wrap(s, width, size, mono=False, bold=False):
    out, line = [], ""
    for word in s.split(" "):
        t = word if not line else line + " " + word
        if tw(t, size, mono, bold) <= width or not line:
            line = t
        else:
            out.append(line)
            line = word
    if line:
        out.append(line)
    return out


class SVG:
    def __init__(self, w, h, title, desc):
        self.w, self.h, self.title, self.desc = w, h, title, desc
        self.items = []

    def add(self, s):
        self.items.append(s)

    def rect(self, x, y, w, h, fill="panel", stroke="rule", rx=8, sw=1, dash=None):
        d = ' stroke-dasharray="%s"' % dash if dash else ""
        self.add('<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="{%s}" stroke="{%s}" stroke-width="%s"%s/>'
                 % (n(x), n(y), n(w), n(h), n(rx), fill, stroke, n(sw), d))

    def text(self, x, y, s, size=14, fill="ink", anchor="start", bold=False, mono=False):
        self.add('<text x="%s" y="%s" font-size="%s" fill="{%s}" text-anchor="%s"%s%s>%s</text>'
                 % (n(x), n(y), n(size), fill, anchor, ' font-weight="600"' if bold else "",
                    ' font-family="%s"' % MONO if mono else "", escape(s)))

    def line(self, x1, y1, x2, y2, stroke="line", sw=1.5, dash=None, arrow=False):
        d = ' stroke-dasharray="%s"' % dash if dash else ""
        m = ' marker-end="url(#arrow-%s)"' % stroke if arrow else ""
        self.add('<line x1="%s" y1="%s" x2="%s" y2="%s" stroke="{%s}" stroke-width="%s"%s%s/>'
                 % (n(x1), n(y1), n(x2), n(y2), stroke, n(sw), d, m))

    def box(self, x, y, w, h, title, rows=(), kind="plain", dash=None, size=14, mono_rows=(), title_fill="ink"):
        """A box with a bold title and wrapped rows; rows whose index is in mono_rows are set in mono."""
        fill, stroke = KIND[kind]
        self.rect(x, y, w, h, fill=fill, stroke=stroke, sw=1.5, dash=dash)
        self.text(x + 14, y + 26, title, 15, bold=True, fill=title_fill)
        yy = y + 50
        for i, r in enumerate(rows):
            mono = i in mono_rows
            fill_r = "ink"
            if isinstance(r, tuple):
                r, fill_r = r
            for ln in wrap(r, w - 28, size if not mono else 13, mono=mono):
                self.text(x + 14, yy, ln, size if not mono else 13, fill=fill_r, mono=mono)
                yy += 20
        return yy

    def render(self, theme):
        t = THEMES[theme]
        body = "\n".join(self.items)
        for k, v in t.items():
            body = body.replace("{%s}" % k, v)
        markers = "".join(
            '<marker id="arrow-%s" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" '
            'orient="auto-start-reverse"><path d="M0,0L10,5L0,10z" fill="%s"/></marker>' % (k, t[k])
            for k in ("line", "accent", "good", "crit"))
        return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d" role="img" '
                'aria-labelledby="t d" font-family="%s">\n<title id="t">%s</title>\n<desc id="d">%s</desc>\n'
                '<defs>%s</defs>\n<rect width="100%%" height="100%%" rx="12" fill="%s"/>\n%s\n</svg>\n'
                % (self.w, self.h, self.w, self.h, SANS.replace("'", "&apos;"), escape(self.title),
                   escape(self.desc), markers, t["paper"], body))


def header(f, title, sub):
    f.text(24, 38, title, 20, bold=True)
    f.text(24, 62, sub, 14, fill="quiet")


def read(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
        return fh.read()


def need(rel, *needles):
    """Fail the build if a fact the figure prints is no longer in the file it comes from."""
    text = read(rel)
    missing = [s for s in needles if s not in text]
    if missing:
        sys.exit("make-figures: %s no longer contains %s; update the figure" % (rel, ", ".join(map(repr, missing))))


def main(figures, argv):
    check = "--check" in argv
    stale = []
    for name, fn in figures:
        fig = fn()
        for theme in THEMES:
            p = os.path.join(HERE, "%s-%s.svg" % (name, theme))
            out = fig.render(theme)
            if check:
                if not os.path.isfile(p) or open(p, encoding="utf-8").read() != out:
                    stale.append(os.path.relpath(p, ROOT))
            else:
                with open(p, "w", encoding="utf-8") as fh:
                    fh.write(out)
                print(os.path.relpath(p, ROOT))
    if stale:
        print("out of date: " + ", ".join(stale) + "; run python3 -I docs/figures/make-figures.py", file=sys.stderr)
        return 1
    return 0


# ---------------------------------------------------------------- the hero
HUMAN = "scenarios/01-onboard-a-human/run.sh"
MACHINE = "scenarios/02-onboard-a-machine/run.sh"


def fig_two_ceremonies():
    need(HUMAN, "admin invite", "--machine-quota 5", "sponsor-approve", "queue approve",
         "an Ory login, and the .cbor bundle")
    need(MACHINE, "machine enroll", "--node-class SENSOR-FEED", "SINGLE-USE setup key",
         "did NOT mint a .cbor or an Ory login")
    title = "A person passes two human gates; their machine passes none"
    f = SVG(W, 460, title,
            "Scenario 01: a sponsor invites a person and sets their machine quota, the person submits the one-time "
            "link, the sponsor vouches, a different admin approves, and the person is minted a NetBird key, a Zenoh "
            "slot and certificate, an Ory login and a .cbor bundle. Scenario 02: the custodian runs goat machine "
            "enroll with node class SENSOR-FEED; the quota set at the invite is the pre-authorization, so there is "
            "no human gate, and the machine is minted its own slot, a Zenoh certificate and a single-use NetBird "
            "key, with no Ory login and no .cbor bundle.")
    header(f, title, "One identity grammar and one registry; the gates are the difference.")
    gap, cols = 22, 5
    bw = (W - 48 - gap * (cols - 1)) / cols
    xs = [24 + i * (bw + gap) for i in range(cols)]
    bh = 132

    def lane(y, label, boxes):
        f.text(24, y, label, 15, bold=True)
        top = y + 12
        for (i, span, ttl, rows, kind, mono) in boxes:
            w = bw * span + gap * (span - 1)
            f.box(xs[i], top, w, bh, ttl, rows, kind=kind, mono_rows=mono)
        for (i, span, *_), (j, *_) in zip(boxes, boxes[1:]):
            x1 = xs[i] + bw * span + gap * (span - 1)
            f.line(x1 + 1, top + bh / 2, xs[j] - 2, top + bh / 2, arrow=True)
        return top

    t1 = lane(96, "Person, scenario 01: a stranger to prove", [
        (0, 1, "Invite", ["a sponsor sends a one-time link and sets tier and machine quota"], "plain", ()),
        (1, 1, "Submit", ["the candidate fills in the link: an inert proposal"], "plain", ()),
        (2, 1, "Gate 1: vouch", ["the sponsor approves the proposal"], "warn", ()),
        (3, 1, "Gate 2: approve", ["a different admin approves it"], "warn", ()),
        (4, 1, "Mint", ["NetBird key, Zenoh slot and cert, Ory login, .cbor bundle"], "accent", ()),
    ])
    t2 = lane(270, "Machine, scenario 02: property of a vetted person", [
        (0, 1, "Quota", ["the custodian's machine quota, from the invite"], "plain", ()),
        (1, 3, "goat machine enroll", ["--node-class SENSOR-FEED",
                                       "no human gate: the quota set at the person's invite is the "
                                       "pre-authorization, so the custodian enrolls their own machine"], "good", (0,)),
        (4, 1, "Mint", ["own slot, Zenoh cert, NetBird key", ("no Ory login", "quiet"), ("no .cbor bundle", "quiet")], "accent", ()),
    ])
    f.text(24, 446, "Run it yourself: bin/hg-onboard all --offline", 14, fill="quiet")
    return f


if __name__ == "__main__":
    sys.exit(main([("two-ceremonies", fig_two_ceremonies)], sys.argv[1:]))
