# https://stackoverflow.com/questions/48203949/backward-search-in-ipython-via-fzf

from prompt_toolkit.enums import DEFAULT_BUFFER
from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import HasFocus, HasSelection

try:
    from pyfzf import pyfzf
except:
    print("pyfzf is not installed. Please install to enable fzf Ctrl-R search")
    # TODO exit isn't working here
    exit()

ipython = get_ipython()
fzf = pyfzf.FzfPrompt()

def is_in_empty_line(buf):
    text = buf.text
    cursor_position = buf.cursor_position
    text = text.split('\n')
    for line in text:
        if len(line) >= cursor_position:
            return not line
        else:
            cursor_position -= len(line) + 1

def fzf_i_search(event):
    history_set = set()
    history_strings = [i[2] for i in ipython.history_manager.get_tail(5000)][::-1]

    history_strings = [s for s in history_strings if not (s in history_set or history_set.add(s))]

    # refresh prompt
    print("", end="\r", flush=True)
    try:
        text = fzf.prompt(history_strings, fzf_options='--no-sort --multi --reverse')
    except:
        return
    buf = event.current_buffer
    if not is_in_empty_line(buf):
        buf.insert_line_below()
    buf.insert_text('\n'.join(text))

# Register the shortcut if IPython is using prompt_toolkit
if getattr(ipython, 'pt_app', None):
    registry = ipython.pt_app.key_bindings
    registry.add_binding(Keys.ControlR,
                     filter=(HasFocus(DEFAULT_BUFFER)
                             & ~HasSelection()))(fzf_i_search)

del DEFAULT_BUFFER, Keys, HasFocus, HasSelection
del fzf_i_search