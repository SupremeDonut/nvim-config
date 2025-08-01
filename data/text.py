import requests
import re
import json


def write_to_file(data, filename):
    with open(filename, "w", encoding="utf-8") as f:
        f.write(json.dumps(data))


def get_emoji_source():
    text = requests.get("https://www.unicode.org/Public/emoji/15.1/emoji-test.txt").text
    group = ""
    skin = {"🏻", "🏼", "🏽", "🏾", "🏿", "🦰", "🦱", "🦳", "🦲", "‍"}
    mod = []
    for line in text.splitlines():
        if line.startswith("# group: "):
            group = line[9:]
        elif "; fully-qualified" in line and not any(s in line for s in skin):
            m = re.match(r".*# (.+?)\s+E[0-9]*.[0-9] (.*)", line)
            if m:
                mod.append([m.group(1), group, m.group(2)])
    write_to_file(mod, "emoji.json")


def get_math_source():
    url = "https://raw.githubusercontent.com/latex3/unicode-math/refs/heads/master/unicode-math-table.tex"
    mod = []
    for line in requests.get(url).text.splitlines():
        m = re.match(
            r"^\\UnicodeMathSymbol\{\"([0-9A-Fa-f]+)}{([^ ]*) *}.*\{(.+)}%$", line
        )
        if m:
            mod.append([chr(int(m.group(1), 16)), m.group(2), m.group(3)])
    write_to_file(mod, "math.json")


def get_typst_source():
    url = "https://raw.githubusercontent.com/typst/codex/refs/heads/main/src/modules/sym.txt"
    group = ""
    mod = []
    top = ""
    deprecated = False
    for line in requests.get(url).text.splitlines():
        if line.startswith("// "):
            group = line[3:-1]
            if line.startswith("// See "):
                group = "Hebrew"
        elif line and not deprecated:
            line = line.strip()
            if line.startswith("@deprecated"):
                deprecated = True
                continue
            elif line.startswith("gender"):
                break

            symbol = ""
            if " " not in line:
                top = line
                continue

            sub, code = line.split()
            if sub[0] == ".":
                symbol = top + sub
            else:
                top = sub
                symbol = top

            m = re.match(r"\\u{(.*)}", code)
            if m:
                code = chr(int(m.group(1), 16))
            mod.append([code, group, symbol])

        deprecated = False

    write_to_file(mod, "typst.json")


def get_nerd_source():
    base = "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/refs/heads/master/bin/scripts/lib/"
    files = [
        ("i_cod.sh", "Codicons"),
        ("i_dev.sh", "Devicons"),
        ("i_extra.sh", "Extra"),
        ("i_fa.sh", "Font Awesome"),
        ("i_fae.sh", "Font Awesome Extension"),
        ("i_iec.sh", "IEC Power Symbols"),
        ("i_logos.sh", "Logos"),
        ("i_md.sh", "Material Design"),
        ("i_oct.sh", "Octicons"),
        ("i_ple.sh", "Powerline Extra Symbols"),
        ("i_pom.sh", "Pomicons"),
        ("i_seti.sh", "Seti-UI"),
        ("i_weather.sh", "Weather Icons"),
    ]
    mod = []
    for fname in files:
        lines = requests.get(base + fname[0]).text.splitlines()
        current = ""
        current_names = ""
        for line in lines:
            if current:
                if m := re.match(r"^\s+(.+)=\$i$", line):
                    current_names += " " + re.sub(
                        r"^i_([^_]*)_", r"nf-\1-", m.group(1), 1
                    )
                    continue
                mod.append([current, fname[1], current_names])
                current = ""
                current_names = ""

            m = re.match(r"i='([^']+)'\s*(.+)=\$i", line)
            if not m:
                continue
            current = m.group(1)
            current_names = re.sub(r"^i_([^_]*)_", r"nf-\1-", m.group(2), 1)
        mod.append([current, fname[1], current_names])
    write_to_file(mod, "nerd.json")


get_emoji_source()
get_math_source()
get_typst_source()
get_nerd_source()
