# install: pip install rich ipython_autoimport docrepr

# https://ipython.readthedocs.io/en/stable/config/options/terminal.html
# examples:
#  - https://github.com/YaBoiBurner/dotfiles/blob/dom/.config/ipython/profile_default/ipython_config.py

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
c.InteractiveShellApp.exec_lines.append('%autoreload 2')

# https://stackoverflow.com/questions/50437791/ipython-magic-print-variables-on-assignment
c.InteractiveShell.ast_node_interactivity = 'last_expr_or_assign'

#%autocall
