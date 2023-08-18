# install: pip install rich ipython_autoimport docrepr

# https://ipython.readthedocs.io/en/stable/config/options/terminal.html
# examples:
#  - https://github.com/YaBoiBurner/dotfiles/blob/dom/.config/ipython/profile_default/ipython_config.py

# get last output
# %history -l 1

c = get_config()

# stop asking me if I really want to c-D
c.TerminalInteractiveShell.confirm_exit = False

c.InteractiveShell.enable_html_pager = True

# requires docrepr
c.InteractiveShell.sphinxify_docstring = True

# # https://github.com/willmcgugan/rich/pull/1274/files
c.InteractiveShellApp.extensions.append('rich')

# DO NOT use `append` here, it hangs ipython
c.InteractiveShellApp.extensions = ['autoreload', 'ipython_autoimport']

# watch filesystem for changes and reload modules
# https://stackoverflow.com/questions/1907993/autoreload-of-modules-in-ipython
# https://ipython.readthedocs.io/en/stable/whatsnew/version8.html#autoreload-3-feature
c.InteractiveShellApp.exec_lines.append('%autoreload 3')

# https://stackoverflow.com/questions/50437791/ipython-magic-print-variables-on-assignment
c.InteractiveShell.ast_node_interactivity = 'last_expr_or_assign'

c.InteractiveShell.auto_match = True

# https://ipython.readthedocs.io/en/stable/interactive/magics.html?highlight=autocall#magic-autocall
c.InteractiveShellApp.exec_lines.append('%autocall 1')

# Enable magic commands to be called without the leading %.
# c.TerminalInteractiveShell.automagic = True

# create alias for `!sys.exc_info()`, this exposes the current exception

# TODO maybe use prettier tracebacks
# cleanup ugly ipython backtraces
# https://cs.github.com/ipython/ipython/blob/46a51ed69cdf41b4333943d9ceeb945c4ede5668/IPython/core/crashhandler.py#L225
# import IPython.core.crashhandler
# IPython.core.crashhandler.crash_handler_lite = lambda one, two, three: None

# TODO there's some sort of completion thing we can do https://github.com/infokiller/config-public/blob/1be3b0887b915a8527f063392afe5cb953c587bd/.config/ipython/profile_default/startup/ext/config.py#L328-L337
# https://github.com/deshaw/pyflyby