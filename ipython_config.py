# https://ipython.readthedocs.io/en/stable/config/options/terminal.html
# examples:
#  - https://github.com/YaBoiBurner/dotfiles/blob/dom/.config/ipython/profile_default/ipython_config.py

c = get_config()

c.TerminalIPythonApp.extensions.append('rich')

c.InteractiveShell.enable_html_pager = True

# requires docrepr
c.InteractiveShell.sphinxify_docstring = True

# https://github.com/willmcgugan/rich/pull/1274/files
c.InteractiveShellApp.extensions.append('rich')

# https://switowski.com/blog/ipython-autoreload
c.InteractiveShellApp.extensions.append('autoreload')

# https://stackoverflow.com/questions/50437791/ipython-magic-print-variables-on-assignment
c.InteractiveShell.ast_node_interactivity = 'last_expr_or_assign'

#%autocall
