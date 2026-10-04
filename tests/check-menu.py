#!/usr/bin/env python3
"""Drive wizard.sh through a pty and check the single-screen menu end to end."""
import os, pty, select, shutil, signal, sys, tempfile, termios, time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UP, DOWN, RIGHT, LEFT = "\x1b[A", "\x1b[B", "\x1b[C", "\x1b[D"
ALT_ON, ALT_OFF = b"\x1b[?1049h", b"\x1b[?1049l"
BASE_RC = 'ZSH_THEME="x"\nsource $ZSH/oh-my-zsh.sh\n'
failures = []


def expect(name, cond, detail=""):
    print(("ok   " if cond else "FAIL ") + name + ("" if cond else "  " + detail))
    if not cond:
        failures.append(name)


def settle(fd, timeout=0.4):
    out = b""
    while select.select([fd], [], [], timeout)[0]:
        try:
            chunk = os.read(fd, 65536)
        except OSError:
            break
        if not chunk:
            break
        out += chunk
    return out


def reap(pid):
    for _ in range(40):  # wizard must exit by itself; never hang the suite
        try:
            done, status = os.waitpid(pid, os.WNOHANG)
        except ChildProcessError:
            return -2
        if done:
            return os.WEXITSTATUS(status) if os.WIFEXITED(status) else -1
        time.sleep(0.1)
    os.kill(pid, signal.SIGKILL)
    os.waitpid(pid, 0)
    return -1


def run(keys, rc=BASE_RC, term="xterm", extra_env=None):
    home = tempfile.mkdtemp()
    os.makedirs(home + "/custom/themes")
    with open(home + "/.zshrc", "w") as f:
        f.write(rc)
    env = dict(os.environ, HOME=home, TERM=term, ZSH_CUSTOM=home + "/custom", LANG="en_US.UTF-8")
    env.update(extra_env or {})
    env.pop("LC_ALL", None)
    env.pop("LC_MESSAGES", None)
    pid, fd = pty.fork()
    if pid == 0:
        os.execvpe("bash", ["bash", os.path.join(ROOT, "wizard.sh"), "--lang=en"], env)
    transcript = settle(fd, 1.0)
    for k in keys:
        os.write(fd, k.encode())
        transcript += settle(fd)
    status = reap(pid)
    transcript += settle(fd, 0.1)
    try:
        lflag = termios.tcgetattr(fd)[3]  # tty modes the wizard left behind
    except termios.error:
        lflag = None
    with open(home + "/.zshrc") as f:
        result = f.read()
    shutil.rmtree(home, ignore_errors=True)
    return transcript, status, result, lflag


# 1. Full flow: jump around freely, no restart. Hidden row skipped. Edit colors seeds from monokai.
keys = [
    DOWN, DOWN, RIGHT,        # row 2 Capsule style: round -> bracket (fill row now hidden)
    DOWN, RIGHT,              # skips hidden fill row -> Layout: two-line -> single
    UP, UP, UP, RIGHT,        # back up to Color scheme (row 0): night -> monokai
    DOWN, "\n",               # Edit colors (opens editor, seeded from monokai)
    DOWN, RIGHT, RIGHT, "\n",  # PATH: 81 -> 0 -> 1, Enter = back to menu
    "s", "\n", "n\n",         # save, apply (default Y), do not reload
]
t, status, rc, lf = run(keys)
on, off, summ = t.find(ALT_ON), t.find(ALT_OFF), t.find(b"Configuration Summary")
expect("flow: exit status 0", status == 0, str(status))
expect("flow: alternate screen entered first", on != -1 and on < off, f"on={on} off={off}")
expect("flow: summary printed after leaving alt screen", off != -1 and off < summ, f"off={off} summ={summ}")
for line in [
    'export MODERN_DARK_PRO_VARIANT="custom"',
    'export MODERN_DARK_PRO_PILL_STYLE="bracket"',
    'export MODERN_DARK_PRO_PILL_COLOR_STYLE="solid"',
    'export MODERN_DARK_PRO_PROMPT_LAYOUT="single"',
    'export MODERN_DARK_PRO_COLOR_PATH="1"',
    'export MODERN_DARK_PRO_COLOR_CONNECTOR="101"',
    'export MODERN_DARK_PRO_COLOR_GIT_BRANCH="148"',
]:
    expect("flow: wrote " + line.split("MODERN_DARK_PRO_")[1], line in rc, rc)

# 2. Quit with changes asks; 'n' stays, 'y' leaves; nothing written.
t, status, rc, lf = run([DOWN] * 4 + [RIGHT, "q", "n", "q", "y"])
expect("quit: exit 0", status == 0, str(status))
expect("quit: asked twice", t.count(b"Discard changes? [y/N]") == 2, str(t.count(b"Discard changes? [y/N]")))
expect("quit: nothing written", rc == BASE_RC, rc)
expect("quit: alt screen left", ALT_OFF in t)
expect("quit: no summary", b"Configuration Summary" not in t)

# 3. Quit without changes does not ask.
t, status, rc, lf = run(["q"])
expect("quit clean: exit 0", status == 0, str(status))
expect("quit clean: no prompt", b"Discard changes?" not in t)
expect("quit clean: nothing written", rc == BASE_RC, rc)

# 4. Ctrl-C restores the screen, exits 130, writes nothing.
t, status, rc, lf = run(["\x03"])
expect("ctrl-c: exit 130", status == 130, str(status))
expect("ctrl-c: alt screen left", ALT_OFF in t)
expect("ctrl-c: cursor shown again", b"\x1b[?25h" in t)
expect("ctrl-c: nothing written", rc == BASE_RC, rc)

def tty_sane(lf):
    return lf is not None and bool(lf & termios.ECHO) and bool(lf & termios.ICANON)


expect("ctrl-c: tty echo + canonical mode restored", tty_sane(lf), f"lflag={lf}")

# 4b. Ctrl-C inside the color editor: same guarantees, and the editor never erases scrollback.
t, status, rc, lf = run([DOWN, "\n", "\x03"])
expect("ctrl-c in editor: exit 130", status == 130, str(status))
expect("ctrl-c in editor: alt screen left", ALT_OFF in t)
expect("ctrl-c in editor: tty echo + canonical mode restored", tty_sane(lf), f"lflag={lf}")
expect("editor opened", b"CONNECTOR" in t)
expect("editor never erases scrollback (no ESC[3J)", b"\x1b[3J" not in t)
expect("ctrl-c in editor: nothing written", rc == BASE_RC, rc)

# 4c. The preview follows the selected Color scheme (truecolor blues: night 100;181;246, monokai 102;217;239).
NIGHT_BLUE, MONOKAI_BLUE = b"38;2;100;181;246", b"38;2;102;217;239"
TC = {"COLORTERM": "truecolor"}
last_frame = lambda t: t.split(b"\x1b[H\x1b[2J")[-1]
t, status, rc, lf = run(["\x03"], extra_env=TC)
f = last_frame(t)
expect("scheme night: preview shows night", NIGHT_BLUE in f and MONOKAI_BLUE not in f)
t, status, rc, lf = run([RIGHT, "\x03"], extra_env=TC)
f = last_frame(t)
expect("scheme -> monokai: preview switches to monokai", MONOKAI_BLUE in f and NIGHT_BLUE not in f)
t, status, rc, lf = run([RIGHT, LEFT, "\x03"], extra_env=TC)
f = last_frame(t)
expect("scheme -> monokai -> night: preview back to night", NIGHT_BLUE in f and MONOKAI_BLUE not in f)

# 5. Starts from current settings.
t, status, rc, lf = run(["q"], rc=BASE_RC + 'export MODERN_DARK_PRO_VARIANT="monokai"\nexport MODERN_DARK_PRO_PILL_STYLE="none"\n')
expect("loads current: variant shown", b"< monokai >" in t)
expect("loads current: style shown", b"< none >" in t)
expect("loads current: hidden fill row", b"Capsule fill" not in t)

# 6. Dumb terminal.
t, status, rc, lf = run([], term="dumb")
expect("dumb TERM: exit 1", status == 1, str(status))
expect("dumb TERM: message", b"interactive terminal" in t)
expect("dumb TERM: nothing written", rc == BASE_RC, rc)

sys.exit(1 if failures else 0)
