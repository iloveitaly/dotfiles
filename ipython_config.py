c = get_config()

# https://github.com/willmcgugan/rich/pull/1274/files
c.InteractiveShellApp.extensions.append('rich')

# https://switowski.com/blog/ipython-autoreload
c.InteractiveShellApp.extensions.append('autoreload')
