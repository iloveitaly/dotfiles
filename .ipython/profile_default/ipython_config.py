"""
%clip - only works on previous evaluated responses
%history -l 1 - get last output
%suggestion 0 | %s - accept the top suggestion

Some example configurations:

- https://github.com/YaBoiBurner/dotfiles/blob/dom/.config/ipython/profile_default/ipython_config.py
"""

import os
from textwrap import dedent

# https://ipython.readthedocs.io/en/stable/config/options/terminal.html

c = get_config()

# stop asking me if I really want to c-D
c.TerminalInteractiveShell.confirm_exit = False

c.InteractiveShell.enable_html_pager = True

# requires docrepr
c.InteractiveShell.sphinxify_docstring = True

# DO NOT use `append` here, it hangs ipython
_EXTENSIONS = (
    "autoreload",
    # %autoimport -lodel
    "ipython_autoimport",
    "ipython_ctrlr_fzf",
    "ipython_copy",
    # TODO https://github.com/Textualize/rich/issues/3317
    # https://github.com/willmcgugan/rich/pull/1274/files
    # TODO consider removing this, it's slowing down large object display
    # https://github.com/Textualize/rich/blob/e1e6d745f670ff3df6b8f47377c0a4006cb74066/rich/pretty.py#L167
    # "rich",
    # https://github.com/mdmintz/pdbp possible better than other pdb drop-ins?
)

# Load extensions manually so failures only emit a single warning.
c.InteractiveShellApp.extensions = []

# exec_lines only accepts Python source strings, not callables, so build the
# loader as code and let IPython execute it during shell startup.
def _build_safe_extension_loader(extensions):
    return dedent(
        f"""
        from IPython import get_ipython
        import sys

        def __load_extensions():
            ip = get_ipython()
            if ip is None:
                return

            for name in {tuple(extensions)!r}:
                try:
                    ip.extension_manager.load_extension(name)
                except ModuleNotFoundError:
                    print(
                        f"warning: skipping missing IPython extension {{name!r}}",
                        file=sys.stderr,
                    )
                except Exception as exc:
                    print(
                        f"warning: failed to load IPython extension {{name!r}}: {{exc}}",
                        file=sys.stderr,
                    )

        __load_extensions()
        del __load_extensions
        """
    ).strip()


_SAFE_EXTENSION_LOADER = _build_safe_extension_loader(_EXTENSIONS)

# Load optional extensions one-by-one so a missing package only produces a
# short warning instead of aborting startup with a traceback.
# watch filesystem for changes and reload modules
# https://stackoverflow.com/questions/1907993/autoreload-of-modules-in-ipython
# https://ipython.readthedocs.io/en/stable/whatsnew/version8.html#autoreload-3-feature
# https://ipython.readthedocs.io/en/stable/config/extensions/autoreload.html

c.InteractiveShellApp.exec_lines = [
    _SAFE_EXTENSION_LOADER,
    "%autoreload 3",
    # https://ipython.readthedocs.io/en/stable/interactive/magics.html?highlight=autocall#magic-autocall
    "%autocall 1",
]

# https://stackoverflow.com/questions/50437791/ipython-magic-print-variables-on-assignment
c.InteractiveShell.ast_node_interactivity = "last_expr_or_assign"

# add parentheses around a function
c.InteractiveShell.auto_match = True

# Enable magic commands to be called without the leading %.
# c.TerminalInteractiveShell.automagic = True

# TODO create alias for `!sys.exc_info()`, this exposes the current exception

# TODO maybe use prettier tracebacks
# cleanup ugly ipython backtraces
# https://cs.github.com/ipython/ipython/blob/46a51ed69cdf41b4333943d9ceeb945c4ede5668/IPython/core/crashhandler.py#L225
# import IPython.core.crashhandler
# IPython.core.crashhandler.crash_handler_lite = lambda one, two, three: None

# TODO there's some sort of completion thing we can do https://github.com/infokiller/config-public/blob/1be3b0887b915a8527f063392afe5cb953c587bd/.config/ipython/profile_default/startup/ext/config.py#L328-L337

# unique history file per directory
c.HistoryManager.hist_file = os.path.join(os.getcwd(), ".ipython_history")

# Now !some_command that fails will actually raise a CalledProcessError instead of silently returning a non-zero code. Perfect for scripting inside IPython.
c.InteractiveShell.system_raise_on_error = True

# built-in autosuggest
c.Completer.policy_overrides = {"allow_auto_import": True}

# respect NO_COLOR environment variable, helpful for debugging
no_color = os.environ.get("NO_COLOR", "").lower()

if no_color in ("1", "true"):
    c.InteractiveShell.colors = "NoColor"
