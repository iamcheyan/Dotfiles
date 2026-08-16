#!/usr/bin/env python3
"""opencode-config — curses TUI for opencode.json configuration.

Usage:
    opencode-config.py                          # Default config path
    opencode-config.py /path/to/opencode.json   # Custom path
"""

import curses
import json
import os
import shutil
import sys
from datetime import datetime
from copy import deepcopy

CONFIG_PATH = os.path.expanduser("~/.config/opencode/opencode.json")

# ── Colors ─────────────────────────────────────────────────

CP_DEFAULT  = 0
CP_HEADER   = 1
CP_SELECTED = 2
CP_DIM      = 3
CP_ACTION   = 4
CP_ERROR    = 5
CP_SUCCESS  = 6
CP_FIELD    = 7

def init_colors():
    try:
        curses.init_pair(1, curses.COLOR_CYAN, -1)         # header
        curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_WHITE)  # selected
        curses.init_pair(3, curses.COLOR_BLACK, curses.COLOR_WHITE)
        curses.init_pair(4, curses.COLOR_YELLOW, -1)       # action
        curses.init_pair(5, curses.COLOR_RED, -1)           # error
        curses.init_pair(6, curses.COLOR_GREEN, -1)         # success
        curses.init_pair(7, curses.COLOR_MAGENTA, -1)       # field label
    except Exception:
        pass

# ── Helpers ────────────────────────────────────────────────

def timestamp():
    return datetime.now().strftime("%Y%m%d_%H%M%S")

def load_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_file(path, data):
    bak = path + f".{timestamp()}.bak"
    if os.path.exists(path):
        shutil.copy2(path, bak)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    return bak

# ── Config data model ──────────────────────────────────────

class Config:
    def __init__(self, path=None):
        self.path = path or CONFIG_PATH
        if os.path.exists(self.path):
            try:
                self.data = load_file(self.path)
            except Exception:
                self.data = {"$schema": "https://opencode.ai/config.json", "provider": {}}
        else:
            self.data = {"$schema": "https://opencode.ai/config.json", "provider": {}}
        self._orig = json.dumps(self.data, sort_keys=True)

    def is_dirty(self):
        return json.dumps(self.data, sort_keys=True) != self._orig

    def mark_saved(self):
        self._orig = json.dumps(self.data, sort_keys=True)

    def save(self):
        os.makedirs(os.path.dirname(self.path), exist_ok=True)
        bak = save_file(self.path, self.data)
        self.mark_saved()
        return bak

    def reload(self):
        if os.path.exists(self.path):
            self.data = load_file(self.path)
        self.mark_saved()

    # providers
    def provider_keys(self):
        provs = self.data.get("provider")
        if isinstance(provs, dict):
            return sorted(provs.keys())
        return []

    def get_provider(self, key):
        provs = self.data.get("provider")
        if isinstance(provs, dict):
            return provs.get(key, {})
        return {}

    def set_provider(self, key, old_key, provider):
        provs = self.data.setdefault("provider", {})
        if not isinstance(provs, dict):
            provs = {}
            self.data["provider"] = provs
        if old_key and old_key != key and old_key in provs:
            del provs[old_key]
        provs[key] = provider

    def delete_provider(self, key):
        provs = self.data.get("provider")
        if isinstance(provs, dict) and key in provs:
            del provs[key]

    def clone_provider(self, source_key, new_key):
        src = self.get_provider(source_key)
        if src:
            new_prov = deepcopy(src)
            self.set_provider(new_key, None, new_prov)
            return new_prov
        return None

    # models
    def model_keys(self, provider_key):
        prov = self.get_provider(provider_key)
        models = prov.get("models")
        if isinstance(models, dict):
            return sorted(models.keys())
        return []

    def get_model(self, provider_key, model_key):
        prov = self.get_provider(provider_key)
        models = prov.get("models")
        if isinstance(models, dict):
            return models.get(model_key, {})
        return {}

    def set_model(self, provider_key, model_key, old_key, model):
        provs = self.data.setdefault("provider", {})
        if not isinstance(provs, dict):
            provs = {}
            self.data["provider"] = provs
        prov = provs.setdefault(provider_key, {})
        if not isinstance(prov, dict):
            prov = {}
            provs[provider_key] = prov
        models = prov.setdefault("models", {})
        if not isinstance(models, dict):
            models = {}
            prov["models"] = models
        if old_key and old_key != model_key and old_key in models:
            del models[old_key]
        models[model_key] = model

    def delete_model(self, provider_key, model_key):
        prov = self.get_provider(provider_key)
        models = prov.get("models")
        if isinstance(models, dict) and model_key in models:
            del models[model_key]

    def clone_model(self, provider_key, source_model_key, new_model_key):
        src = self.get_model(provider_key, source_model_key)
        if src:
            new_model = deepcopy(src)
            new_model["id"] = new_model_key
            if "name" in new_model and new_model["name"]:
                new_model["name"] = f"{new_model['name']} (Copy)"
            else:
                new_model["name"] = new_model_key
            self.set_model(provider_key, new_model_key, None, new_model)
            return new_model
        return None

    # settings
    def get_setting(self, path):
        parts = path.split('.')
        curr = self.data
        for p in parts:
            if isinstance(curr, dict) and p in curr:
                curr = curr[p]
            else:
                return ""
        return curr if not isinstance(curr, (dict, list)) else json.dumps(curr)

    def set_setting(self, path, val):
        parts = path.split('.')
        curr = self.data
        for p in parts[:-1]:
            curr = curr.setdefault(p, {})
        last = parts[-1]
        v_str = str(val).strip()
        if v_str.lower() == "true":
            curr[last] = True
        elif v_str.lower() == "false":
            curr[last] = False
        elif v_str.isdigit():
            curr[last] = int(v_str)
        else:
            try:
                curr[last] = json.loads(v_str)
            except Exception:
                curr[last] = v_str

    def get_permission(self):
        return self.get_setting("permission.external_directory")

    def set_permission(self, val):
        self.set_setting("permission.external_directory", val)

    def get_schema(self):
        return self.get_setting("$schema")

    def set_schema(self, val):
        self.set_setting("$schema", val)


# ── Text field editor ──────────────────────────────────────

def edit_field(win, y, x, width, initial="", ftype="text"):
    """Inline edit a field with horizontal scrolling and non-truncating buffer.
    Returns (new_text, confirmed) or (None, False) on cancel.
    """
    max_y, max_x = win.getmaxyx()
    if y >= max_y:
        y = max_y - 1
    if x >= max_x:
        x = max_x - 1
    actual_width = max(5, min(width, max_x - x))

    try:
        ew = win.derwin(1, actual_width, y, x)
    except curses.error:
        return None, False

    ew.keypad(True)
    text = list(str(initial or ""))
    pos = len(text)
    view_offset = 0

    try:
        curses.curs_set(1)
    except curses.error:
        pass

    def redraw():
        nonlocal view_offset
        if pos < view_offset:
            view_offset = pos
        elif pos >= view_offset + actual_width:
            view_offset = pos - actual_width + 1

        view_offset = max(0, min(view_offset, max(0, len(text) - actual_width + 1)))

        disp_chars = text[view_offset : view_offset + actual_width]
        if ftype == "masked":
            disp_chars = ['*'] * len(disp_chars)
        disp_str = ''.join(disp_chars).ljust(actual_width)

        ew.erase()
        try:
            ew.addnstr(0, 0, disp_str, actual_width)
        except curses.error:
            pass

        cursor_x = max(0, min(actual_width - 1, pos - view_offset))
        try:
            ew.move(0, cursor_x)
        except curses.error:
            pass

    redraw()

    while True:
        ch = ew.getch()
        if ch in (27, 7):  # Esc / Ctrl+G
            try:
                curses.curs_set(0)
            except curses.error:
                pass
            return None, False
        elif ch in (10, 13, 9):  # Enter / Tab
            try:
                curses.curs_set(0)
            except curses.error:
                pass
            return ''.join(text), True
        elif ch in (127, curses.KEY_BACKSPACE, 8):
            if pos > 0:
                pos -= 1
                text.pop(pos)
        elif ch == curses.KEY_DC:
            if pos < len(text):
                text.pop(pos)
        elif ch in (curses.KEY_LEFT, 2):  # Left / Ctrl+B
            if pos > 0:
                pos -= 1
        elif ch in (curses.KEY_RIGHT, 6):  # Right / Ctrl+F
            if pos < len(text):
                pos += 1
        elif ch in (curses.KEY_HOME, 1):  # Home / Ctrl+A
            pos = 0
        elif ch in (curses.KEY_END, 5):  # End / Ctrl+E
            pos = len(text)
        elif ch == 21:  # Ctrl+U
            text.clear()
            pos = 0
        elif 32 <= ch <= 126:
            c = chr(ch)
            if ftype == "number" and not (c.isdigit() or c in ".-"):
                continue
            text.insert(pos, c)
            pos += 1

        redraw()


# ── Form helpers ──────────────────────────────────────────

class FormField:
    def __init__(self, label, key, ftype="text", width=40):
        self.label = label
        self.key = key
        self.ftype = ftype
        self.width = width
        self.value = ""
        self.changed = False


def run_form(stdscr, title, fields, delete_allowed=True):
    """Run a full-screen form. Returns 'save', 'delete', 'back'."""
    sel = 0
    running = True
    result = "back"

    while running:
        stdscr.clear()
        h, w = stdscr.getmaxyx()

        # Title header
        t = f" {title} "
        try:
            stdscr.addstr(0, max(0, (w - len(t)) // 2), t[:w-1], curses.A_REVERSE | curses.A_BOLD)
        except curses.error:
            pass

        max_lbl = max((len(f.label) for f in fields), default=10)
        val_x = min(w - 15, max(24, max_lbl + 4))
        avail = max(10, w - val_x - 3)

        y = 2
        for i, f in enumerate(fields):
            if y >= h - 2:
                break
            label = f.label
            if len(label) > val_x - 4:
                label = label[:val_x - 7] + "..."

            try:
                stdscr.addstr(y, 2, label, curses.A_BOLD)
            except curses.error:
                pass

            val_str = str(f.value)
            if isinstance(f.value, bool):
                val_str = "true" if f.value else "false"
            elif f.ftype == "masked":
                val_str = '*' * len(str(f.value))

            disp = val_str[:avail].ljust(avail)
            attr = curses.A_REVERSE if i == sel else curses.A_NORMAL

            try:
                stdscr.addstr(y, val_x, disp[:avail], attr)
            except curses.error:
                pass
            y += 1

        # Footer
        footer = " [Enter/Space] Edit  [Tab/\u2191\u2193] Navigate  [s] Save"
        if delete_allowed:
            footer += "  [d] Delete"
        footer += "  [Esc] Back "
        try:
            stdscr.addstr(h - 1, 0, footer[:w - 1], curses.A_REVERSE)
        except curses.error:
            pass

        ch = stdscr.getch()
        if ch == 27:  # Esc
            dirty = any(f.changed for f in fields)
            if dirty:
                if confirm_dialog(stdscr, "Discard changes?", default_no=True):
                    result = "back"
                    running = False
            else:
                result = "back"
                running = False

        elif ch in (curses.KEY_DOWN, 9, ord('j')):  # Down / Tab / j
            sel = (sel + 1) % len(fields)
        elif ch in (curses.KEY_UP, curses.KEY_BTAB, ord('k')):  # Up / Shift+Tab / k
            sel = (sel - 1) % len(fields)

        elif ch in (10, 13, 32):  # Enter / Space → edit field
            f = fields[sel]
            if f.ftype == "boolean":
                f.value = not bool(f.value)
                f.changed = True
            else:
                y_pos = 2 + sel
                init = str(f.value)
                edit_type = "text" if f.ftype == "masked" else f.ftype
                new_val, ok = edit_field(stdscr, y_pos, val_x, avail, init, edit_type)
                if ok:
                    if f.ftype == "number":
                        try:
                            if "." in new_val:
                                f.value = float(new_val)
                            else:
                                f.value = int(new_val)
                        except ValueError:
                            pass
                    else:
                        f.value = new_val
                    f.changed = True

        elif ch in (ord('s'), ord('S')):
            if not str(fields[0].value).strip():
                msg_dialog(stdscr, f"{fields[0].label} cannot be empty!")
                continue
            result = "save"
            running = False
        elif ch in (ord('d'), ord('D')) and delete_allowed:
            if confirm_dialog(stdscr, "Delete this item?", default_no=True):
                result = "delete"
                running = False

    stdscr.clear()
    return result


def msg_dialog(stdscr, msg):
    """Show a message, wait for key."""
    h, w = stdscr.getmaxyx()
    lines = msg.split('\n')
    height = min(len(lines) + 4, h - 2)
    width = min(max(len(l) for l in lines) + 6, w - 4)
    y = max(0, (h - height) // 2)
    x = max(0, (w - width) // 2)
    try:
        win = curses.newwin(height, width, y, x)
        win.bkgd(' ', curses.A_REVERSE)
        win.border()
        for i, l in enumerate(lines[:height - 3]):
            win.addstr(1 + i, 2, l[:width - 4])
        win.addstr(height - 2, 2, "Press any key...")
        stdscr.refresh()
        win.getch()
        del win
    except curses.error:
        pass
    stdscr.touchwin()
    stdscr.refresh()


def confirm_dialog(stdscr, msg, default_no=False):
    """Yes/No dialog. Returns True for yes, False for no."""
    h, w = stdscr.getmaxyx()
    msg_clean = msg.replace('\n', ' ')
    width = min(len(msg_clean) + 14, w - 4)
    height = 5
    y = max(0, (h - height) // 2)
    x = max(0, (w - width) // 2)
    try:
        win = curses.newwin(height, width, y, x)
        win.bkgd(' ', curses.A_REVERSE)
        win.border()
        win.addstr(1, 2, msg_clean[:width - 4])
        if default_no:
            win.addstr(3, 2, "  [Y] Yes      [N] No (default)  "[:width - 4])
        else:
            win.addstr(3, 2, "  [Y] Yes (default)   [N] No  "[:width - 4])
        stdscr.refresh()
        while True:
            ch = win.getch()
            if ch in (10, 13, ord('y'), ord('Y')):
                del win
                stdscr.touchwin()
                stdscr.refresh()
                return True
            if ch in (27, ord('n'), ord('N')):
                del win
                stdscr.touchwin()
                stdscr.refresh()
                return False
    except curses.error:
        return False


def edit_setting_dialog(stdscr, label, current=""):
    """Dialog for editing a single setting value. Returns new string or None."""
    h, w = stdscr.getmaxyx()
    dlg_h = 6
    dlg_w = min(70, w - 4)
    y = max(0, (h - dlg_h) // 2)
    x = max(0, (w - dlg_w) // 2)

    try:
        win = curses.newwin(dlg_h, dlg_w, y, x)
        win.bkgd(' ', curses.A_REVERSE)
        win.border()
        win.addstr(0, 2, f" Edit {label} ", curses.A_BOLD)
        win.addstr(1, 2, f"Setting: {label}"[:dlg_w - 4])
        win.addstr(4, 2, " [Enter] Confirm   [Esc] Cancel "[:dlg_w - 4])
        stdscr.refresh()

        input_w = dlg_w - 4
        new_val, ok = edit_field(win, 2, 2, input_w, current, "text")
        del win
        stdscr.touchwin()
        stdscr.refresh()
        if ok:
            return new_val
    except curses.error:
        pass
    return None


# ── Provider form ──────────────────────────────────────────

def edit_provider(stdscr, cfg, pkey=None):
    """Add (pkey=None) or edit a provider. Returns 'save','delete','back'."""
    if pkey:
        orig_key = pkey
        prov = deepcopy(cfg.get_provider(pkey))
    else:
        orig_key = None
        prov = {"api": "openai", "name": "", "options": {"apiKey": "", "baseURL": ""}, "models": {}}

    def pack():
        nonlocal prov
        prov["api"] = fields[1].value.strip() or "openai"
        prov["name"] = fields[2].value.strip() or fields[0].value.strip()
        opts = prov.setdefault("options", {})
        if not isinstance(opts, dict):
            opts = {}
            prov["options"] = opts
        opts["apiKey"] = fields[3].value
        opts["baseURL"] = fields[4].value.strip()

    def unpack():
        fields[0].value = orig_key or ""
        fields[1].value = prov.get("api", "openai")
        fields[2].value = prov.get("name", "")
        opts = prov.get("options") or {}
        fields[3].value = opts.get("apiKey", "")
        fields[4].value = opts.get("baseURL", "")

    key_field = FormField("Key", "key", "text", 30)
    api_field = FormField("API Type", "api", "text", 30)
    name_field = FormField("Name", "name", "text", 30)
    key_secret = FormField("API Key", "apiKey", "masked", 30)
    url_field = FormField("Base URL", "baseURL", "text", 30)

    fields = [key_field, api_field, name_field, key_secret, url_field]
    unpack()

    title = f"Edit Provider: {orig_key}" if orig_key else "Add Provider"
    result = run_form(stdscr, title, fields, delete_allowed=bool(orig_key))

    if result == "save":
        key = fields[0].value.strip()
        if key:
            pack()
            cfg.set_provider(key, orig_key, prov)

    if result == "delete" and orig_key:
        cfg.delete_provider(orig_key)

    return result


# ── Model form & Model Manager ────────────────────────────

def edit_model(stdscr, cfg, pkey, mkey=None):
    """Add or edit a model. Returns 'save','delete','back'."""
    if mkey:
        orig_key = mkey
        model = deepcopy(cfg.get_model(pkey, mkey))
    else:
        orig_key = None
        model = {"id": "", "name": "", "family": "", "tool_call": True, "reasoning": False,
                 "limit": {"context": 128000, "output": 8192}}

    def pack():
        new_id = fields[0].value.strip()
        model["id"] = new_id
        model["name"] = fields[1].value.strip() or new_id
        model["family"] = fields[2].value.strip()
        model["tool_call"] = bool(fields[3].value)
        model["reasoning"] = bool(fields[4].value)
        limits = model.setdefault("limit", {})
        if not isinstance(limits, dict):
            limits = {}
            model["limit"] = limits
        try:
            limits["context"] = int(fields[5].value)
        except ValueError:
            limits["context"] = 128000
        try:
            limits["output"] = int(fields[6].value)
        except ValueError:
            limits["output"] = 8192

        temp_str = str(fields[7].value).strip()
        if temp_str:
            try:
                model["temperature"] = float(temp_str)
            except ValueError:
                model.pop("temperature", None)
        else:
            model.pop("temperature", None)

    def unpack():
        fields[0].value = model.get("id") or orig_key or ""
        fields[1].value = model.get("name", "")
        fields[2].value = model.get("family", "")
        fields[3].value = model.get("tool_call", True)
        fields[4].value = model.get("reasoning", False)
        limits = model.get("limit") or {}
        fields[5].value = str(limits.get("context", 128000))
        fields[6].value = str(limits.get("output", 8192))
        fields[7].value = str(model.get("temperature", "")) if model.get("temperature") is not None else ""

    id_f = FormField("Model ID", "id", "text", 30)
    name_f = FormField("Display Name", "name", "text", 30)
    fam_f = FormField("Family Group", "family", "text", 20)
    tc_f = FormField("Tool Call", "tool_call", "boolean", 10)
    rs_f = FormField("Reasoning / Thinking", "reasoning", "boolean", 10)
    ctx_f = FormField("Context Limit", "context", "number", 12)
    out_f = FormField("Output Limit", "output", "number", 12)
    temp_f = FormField("Temperature (Optional)", "temperature", "text", 10)

    fields = [id_f, name_f, fam_f, tc_f, rs_f, ctx_f, out_f, temp_f]
    unpack()

    title = f"Model: {orig_key} ({pkey})" if orig_key else f"Add Model to ({pkey})"
    result = run_form(stdscr, title, fields, delete_allowed=bool(orig_key))

    if result == "save":
        new_key = fields[0].value.strip()
        if new_key:
            pack()
            cfg.set_model(pkey, new_key, orig_key, model)

    if result == "delete" and orig_key:
        cfg.delete_model(pkey, orig_key)

    return result


def manage_models_dialog(stdscr, cfg, pkey):
    """Dedicated full-screen model manager for a provider."""
    sel = 0
    running = True

    while running:
        stdscr.clear()
        h, w = stdscr.getmaxyx()

        prov = cfg.get_provider(pkey)
        prov_name = prov.get("name", pkey)
        mkeys = cfg.model_keys(pkey)

        # Title
        title = f" Models for Provider: {prov_name} [{pkey}] ({len(mkeys)} models) "
        try:
            stdscr.addstr(0, max(0, (w - len(title)) // 2), title[:w-1], curses.A_REVERSE | curses.A_BOLD)
        except curses.error:
            pass

        # Table Header
        hdr = "  ID                         Name                   Family   Tools  Reason  Context  Output"
        try:
            stdscr.addstr(2, 0, hdr[:w-1], curses.A_BOLD | curses.A_UNDERLINE)
        except curses.error:
            pass

        if not mkeys:
            try:
                stdscr.addstr(4, 4, "(No models configured for this provider. Press 'a' to add one.)")
            except curses.error:
                pass
        else:
            if sel >= len(mkeys):
                sel = max(0, len(mkeys) - 1)

            for i, mk in enumerate(mkeys):
                y = 3 + i
                if y >= h - 2:
                    break
                m = cfg.get_model(pkey, mk)
                mname = m.get("name", mk)
                fam = m.get("family", "")
                tc = "Yes" if m.get("tool_call", True) else "No"
                rs = "Yes" if m.get("reasoning", False) else "No"
                limits = m.get("limit") or {}
                ctx = str(limits.get("context", ""))
                out = str(limits.get("output", ""))

                row_str = f"  {mk:<26} {mname:<22} {fam:<8} {tc:<6} {rs:<7} {ctx:<8} {out:<6}"
                attr = curses.A_REVERSE if i == sel else curses.A_NORMAL
                try:
                    stdscr.addstr(y, 0, row_str[:w-1], attr)
                except curses.error:
                    pass

        # Footer
        footer = " [Enter/e] Edit  [a] Add  [c] Clone  [d] Delete  [Esc/q] Back "
        try:
            stdscr.addstr(h - 1, 0, footer[:w-1], curses.A_REVERSE)
        except curses.error:
            pass

        ch = stdscr.getch()
        if ch in (27, ord('q'), ord('Q')):
            running = False
        elif ch in (curses.KEY_DOWN, ord('j')):
            if mkeys:
                sel = (sel + 1) % len(mkeys)
        elif ch in (curses.KEY_UP, ord('k')):
            if mkeys:
                sel = (sel - 1) % len(mkeys)
        elif ch in (10, 13, ord('e'), ord('E')):
            if mkeys and sel < len(mkeys):
                mkey = mkeys[sel]
                edit_model(stdscr, cfg, pkey, mkey)
        elif ch in (ord('a'), ord('A')):
            edit_model(stdscr, cfg, pkey, None)
        elif ch in (ord('c'), ord('C')):
            if mkeys and sel < len(mkeys):
                source_mkey = mkeys[sel]
                clone_key = f"{source_mkey}-copy"
                cfg.clone_model(pkey, source_mkey, clone_key)
                edit_model(stdscr, cfg, pkey, clone_key)
        elif ch in (ord('d'), ord('D'), curses.KEY_DC):
            if mkeys and sel < len(mkeys):
                mkey = mkeys[sel]
                if confirm_dialog(stdscr, f"Delete model '{mkey}'?", default_no=True):
                    cfg.delete_model(pkey, mkey)
                    if sel >= len(mkeys) - 1:
                        sel = max(0, sel - 1)

    stdscr.clear()


# ── Main list view ─────────────────────────────────────────

SECTION   = 0
PROVIDER  = 1
MODEL     = 2
ACTION    = 3
SETTING   = 4
BLANK     = 5

class Row:
    __slots__ = ('kind', 'label', 'data', 'level', 'expanded')
    def __init__(self, kind, label="", data=None, level=0, expanded=False):
        self.kind = kind
        self.label = label
        self.data = data or {}
        self.level = level
        self.expanded = expanded


def build_rows(cfg, search=""):
    rows = []
    rows.append(Row(SECTION, "Providers"))
    providers = cfg.data.get("provider") or {}
    if not isinstance(providers, dict) or not providers:
        rows.append(Row(BLANK, "  (no providers)"))

    if isinstance(providers, dict):
        for pkey in sorted(providers.keys()):
            prov = providers[pkey] or {}
            name = prov.get("name", pkey)
            models = prov.get("models") or {}
            mcount = len(models) if isinstance(models, dict) else 0
            label = f"{name} ({mcount} model{'s' if mcount != 1 else ''}) [{pkey}]"
            if search:
                s_low = search.lower()
                has_match = s_low in pkey.lower() or s_low in name.lower()
                if not has_match and isinstance(models, dict):
                    has_match = any(
                        s_low in mk.lower() or s_low in str(mv.get("name", "")).lower()
                        for mk, mv in models.items() if isinstance(mv, dict)
                    )
                if not has_match:
                    continue
            rows.append(Row(PROVIDER, label, {"key": pkey}))

    rows.append(Row(BLANK))
    rows.append(Row(ACTION, "  [a] Add Provider", {"action": "add_provider"}))
    rows.append(Row(BLANK))

    # Settings
    rows.append(Row(SECTION, "Settings"))

    schema_val = cfg.get_schema()
    rows.append(Row(SETTING, "$schema", {"key": "$schema", "value": str(schema_val)}))

    perm_val = cfg.get_permission()
    rows.append(Row(SETTING, "permission.external_directory",
                    {"key": "permission.external_directory", "value": str(perm_val)}))

    for k, v in cfg.data.items():
        if k in ("provider", "$schema", "permission"):
            continue
        if isinstance(v, dict):
            for sub_k, sub_v in v.items():
                fk = f"{k}.{sub_k}"
                rows.append(Row(SETTING, fk, {"key": fk, "value": str(sub_v)}))
        else:
            rows.append(Row(SETTING, k, {"key": k, "value": str(v)}))

    return rows


class MainView:
    def __init__(self, stdscr, cfg):
        self.stdscr = stdscr
        self.cfg = cfg
        self._provider_expanded = {}  # key -> bool
        self.top = 0
        self.sel = 0
        self.search = ""
        self.searching = False
        self._flat = []

    def get_flat(self):
        """Build flat interactive list with expanded models."""
        rows = build_rows(self.cfg, self.search)
        flat = []

        for row in rows:
            flat.append(row)
            if row.kind == PROVIDER:
                key = row.data.get("key", "")
                if self._provider_expanded.get(key, False):
                    prov = self.cfg.get_provider(key)
                    models = prov.get("models") or {}
                    if isinstance(models, dict):
                        for mk in sorted(models.keys()):
                            mv = models[mk] or {}
                            mname = mv.get("name", mk)
                            label = f"  - {mk} ({mname})"
                            flat.append(Row(MODEL, label, {"key": mk, "provider_key": key}))
                    flat.append(Row(ACTION, "    [m] Add Model",
                                    {"action": "add_model", "provider_key": key}))
        self._flat = flat
        return flat

    def refresh_rows(self):
        self._flat = self.get_flat()

    def interactive_indices(self):
        return [i for i, r in enumerate(self._flat)
                if r.kind in (PROVIDER, MODEL, ACTION, SETTING)]

    def clamp_sel(self):
        ii = self.interactive_indices()
        if not ii:
            self.sel = 0
            return
        if self.sel not in ii:
            above = [i for i in ii if i <= self.sel]
            self.sel = above[-1] if above else ii[0]

    def select_target(self, target_kind, target_key=None, provider_key=None):
        self.refresh_rows()
        for idx, r in enumerate(self._flat):
            if r.kind == target_kind:
                if target_kind == PROVIDER and r.data.get("key") == target_key:
                    self.sel = idx
                    return
                elif target_kind == MODEL and r.data.get("key") == target_key and r.data.get("provider_key") == provider_key:
                    self.sel = idx
                    return
                elif target_kind == SETTING and r.data.get("key") == target_key:
                    self.sel = idx
                    return
                elif target_kind == ACTION and r.data.get("action") == target_key:
                    if provider_key and r.data.get("provider_key") != provider_key:
                        continue
                    self.sel = idx
                    return
        self.clamp_sel()

    def render(self):
        self.refresh_rows()
        h, w = self.stdscr.getmaxyx()
        self.stdscr.clear()

        dirty = self.cfg.is_dirty()
        title = " opencode.json Configurator "
        if dirty:
            title += " [*] "
        try:
            self.stdscr.addstr(0, max(0, (w - len(title)) // 2), title[:w-1], curses.A_REVERSE | curses.A_BOLD)
        except curses.error:
            pass

        body_h = h - 2
        self.clamp_sel()

        if self.sel < self.top:
            self.top = max(0, self.sel - 1)
        if self.sel >= self.top + body_h - 1:
            self.top = max(0, self.sel - body_h + 2)

        y = 1
        for idx, row in enumerate(self._flat):
            if idx < self.top:
                continue
            if y >= h - 1:
                break

            is_sel = (idx == self.sel)
            attr = curses.A_REVERSE if is_sel else curses.A_NORMAL

            try:
                if row.kind == SECTION:
                    s_attr = curses.A_BOLD | curses.A_UNDERLINE
                    if is_sel:
                        s_attr |= curses.A_REVERSE
                    self.stdscr.addstr(y, 0, row.label[:w - 1], s_attr)
                elif row.kind == PROVIDER:
                    icon = "▶" if self._provider_expanded.get(row.data.get("key", ""), False) else "▷"
                    display = f" {icon} {row.label}"
                    self.stdscr.addstr(y, 0, display[:w - 1], attr)
                elif row.kind == MODEL:
                    self.stdscr.addstr(y, 2, row.label[:w - 3], attr)
                elif row.kind == ACTION:
                    self.stdscr.addstr(y, 0, row.label[:w - 1], attr)
                elif row.kind == SETTING:
                    label = row.label
                    val = row.data.get("value", "")
                    display = f"  {label}:  {val}" if val != "" else f"  {label}:  <empty>"
                    self.stdscr.addstr(y, 0, display[:w - 1], attr)
                elif row.kind == BLANK:
                    if row.label:
                        self.stdscr.addstr(y, 0, row.label[:w - 1], attr)
            except curses.error:
                pass
            y += 1

        if self.searching:
            try:
                self.stdscr.addstr(h - 1, 0, f"  /{self.search}"[:w-1], curses.A_REVERSE)
            except curses.error:
                pass
        else:
            footer = " [Enter/e] Edit  [m] Manage Models  [c] Clone  [d] Delete  [s] Save  [q] Quit "
            try:
                self.stdscr.addstr(h - 1, 0, footer[:w - 1], curses.A_REVERSE)
            except curses.error:
                pass

    def handle_key(self, ch):
        ii = self.interactive_indices()
        if not ii:
            self.sel = 0
            return True

        if self.searching:
            if ch == 27:  # Esc
                self.searching = False
                self.search = ""
            elif ch in (10, 13):  # Enter
                self.searching = False
            elif ch in (127, curses.KEY_BACKSPACE, 8):
                self.search = self.search[:-1]
            elif 32 <= ch <= 126:
                self.search += chr(ch)
            return True

        if ch == ord('/'):
            self.searching = True
            self.search = ""
            return True

        idx = self.sel
        row = self._flat[idx] if idx < len(self._flat) else None

        if ch in (curses.KEY_DOWN, ord('j')):
            if idx in ii:
                pos = ii.index(idx)
                if pos + 1 < len(ii):
                    self.sel = ii[pos + 1]
        elif ch in (curses.KEY_UP, ord('k')):
            if idx in ii:
                pos = ii.index(idx)
                if pos > 0:
                    self.sel = ii[pos - 1]
        elif ch in (curses.KEY_RIGHT, ord('l'), 32):  # Right / l / Space
            if row and row.kind == PROVIDER:
                key = row.data.get("key", "")
                self._provider_expanded[key] = not self._provider_expanded.get(key, False)
        elif ch in (curses.KEY_LEFT, ord('h')):  # Left / h
            if row:
                if row.kind == PROVIDER:
                    key = row.data.get("key", "")
                    self._provider_expanded[key] = False
                elif row.kind == MODEL:
                    pkey = row.data.get("provider_key", "")
                    if pkey:
                        self._provider_expanded[pkey] = False
                        self.select_target(PROVIDER, pkey)

        elif ch in (10, 13, ord('e'), ord('E')):  # Enter / e
            if row:
                if row.kind == PROVIDER:
                    key = row.data.get("key", "")
                    edit_provider(self.stdscr, self.cfg, key)
                    self.select_target(PROVIDER, key)
                elif row.kind == MODEL:
                    pkey = row.data.get("provider_key", "")
                    mkey = row.data.get("key", "")
                    edit_model(self.stdscr, self.cfg, pkey, mkey)
                    self.select_target(MODEL, mkey, pkey)
                elif row.kind == ACTION:
                    action = row.data.get("action", "")
                    if action == "add_provider":
                        edit_provider(self.stdscr, self.cfg, None)
                    elif action == "add_model":
                        pkey = row.data.get("provider_key", "")
                        edit_model(self.stdscr, self.cfg, pkey, None)
                    self.select_target(PROVIDER, row.data.get("provider_key"))
                elif row.kind == SETTING:
                    key = row.data.get("key", "")
                    current = str(row.data.get("value", ""))
                    new_val = edit_setting_dialog(self.stdscr, row.label, current)
                    if new_val is not None:
                        self.cfg.set_setting(key, new_val)
                    self.select_target(SETTING, key)

        elif ch in (ord('m'), ord('M')):
            # Open dedicated Model Manager
            if row:
                pkey = row.data.get("provider_key") or row.data.get("key")
                if pkey and pkey in self.cfg.provider_keys():
                    manage_models_dialog(self.stdscr, self.cfg, pkey)
                    self._provider_expanded[pkey] = True
                    self.select_target(PROVIDER, pkey)

        elif ch in (ord('a'), ord('A')):
            if row and (row.kind in (PROVIDER, MODEL) or (row.kind == ACTION and row.data.get("provider_key"))):
                pkey = row.data.get("provider_key") or row.data.get("key")
                edit_model(self.stdscr, self.cfg, pkey, None)
                self._provider_expanded[pkey] = True
                self.select_target(PROVIDER, pkey)
            else:
                edit_provider(self.stdscr, self.cfg, None)
                self.clamp_sel()

        elif ch in (ord('c'), ord('C')):
            if row:
                if row.kind == MODEL:
                    pkey = row.data.get("provider_key", "")
                    mkey = row.data.get("key", "")
                    clone_key = f"{mkey}-copy"
                    self.cfg.clone_model(pkey, mkey, clone_key)
                    edit_model(self.stdscr, self.cfg, pkey, clone_key)
                    self.select_target(MODEL, clone_key, pkey)
                elif row.kind == PROVIDER:
                    pkey = row.data.get("key", "")
                    clone_key = f"{pkey}-copy"
                    self.cfg.clone_provider(pkey, clone_key)
                    edit_provider(self.stdscr, self.cfg, clone_key)
                    self.select_target(PROVIDER, clone_key)

        elif ch in (ord('d'), ord('D'), curses.KEY_DC):
            if row:
                if row.kind == PROVIDER:
                    pkey = row.data.get("key", "")
                    if confirm_dialog(self.stdscr, f"Delete provider '{pkey}'?", default_no=True):
                        self.cfg.delete_provider(pkey)
                        self.clamp_sel()
                elif row.kind == MODEL:
                    pkey = row.data.get("provider_key", "")
                    mkey = row.data.get("key", "")
                    if confirm_dialog(self.stdscr, f"Delete model '{mkey}'?", default_no=True):
                        self.cfg.delete_model(pkey, mkey)
                        self.select_target(PROVIDER, pkey)

        elif ch in (ord('s'), ord('S')):
            if self.cfg.is_dirty():
                bak = self.cfg.save()
                msg_dialog(self.stdscr, f"Saved successfully.\nBackup: {os.path.basename(bak)}")
            else:
                msg_dialog(self.stdscr, "No changes to save.")
        elif ch in (ord('r'), ord('R')):
            if self.cfg.is_dirty():
                if confirm_dialog(self.stdscr, "Reload from disk? (Unsaved changes will be lost)"):
                    self.cfg.reload()
                    self._provider_expanded = {}
            else:
                self.cfg.reload()
                self._provider_expanded = {}
        elif ch in (ord('q'), ord('Q')):
            if self.cfg.is_dirty():
                if confirm_dialog(self.stdscr, "Quit without saving?", default_no=True):
                    return False
                else:
                    return True
            return False

        return True


# ── Main App ───────────────────────────────────────────────

def app(stdscr):
    try:
        curses.curs_set(0)
    except curses.error:
        pass
    curses.use_default_colors()
    init_colors()

    path = CONFIG_PATH
    if len(sys.argv) > 1:
        path = os.path.expanduser(sys.argv[1])

    if not os.path.exists(path):
        if confirm_dialog(stdscr, f"Config file not found:\n{path}\nCreate default config?"):
            try:
                os.makedirs(os.path.dirname(path), exist_ok=True)
                with open(path, "w", encoding="utf-8") as f:
                    json.dump({"$schema": "https://opencode.ai/config.json", "provider": {}}, f, indent=2)
            except Exception as e:
                msg_dialog(stdscr, f"Failed to create config:\n{e}")
                return
        else:
            return

    cfg = Config(path)
    view = MainView(stdscr, cfg)
    stdscr.keypad(True)

    running = True
    while running:
        view.render()
        ch = stdscr.getch()
        if ch == -1:
            continue
        result = view.handle_key(ch)
        if result is False:
            running = False


def main():
    try:
        curses.wrapper(app)
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
