"""
Add copy to clipboard from IPython!

To install, just copy it to your profile/startup directory, typically:

    ~/.ipython/profile_default/startup/

Example usage:

    %clip hello world
    # will store "hello world"
    a = [1, 2, 3]
    %clip a
    # will store "[1, 2, 3]"

You can also use it with cell magic

    In [1]: %%clip
       ...: Even multi
       ...: lines
       ...: work!
       ...:

If you don't have a variable named 'clip' you can rely on automagic:

    clip hey man
    a = [1, 2, 3]
    clip a


This version removes the dependency of AppKit, but maintains compatibility with linux and osx.
using ideas from: https://gist.github.com/vpontis/46e5d3154cda92ce3e0f
It also provides infrastructure to easily add further platforms (function _get_implementation).

different from this, copies content in front of the cursor
https://pypi.org/project/IPythonClipboard/#usage
"""

import sys
from subprocess import Popen, PIPE

from IPython.core.magic import register_line_cell_magic


def _get_implementation():
    platform = sys.platform if not sys.platform.startswith("linux") else "linux"

    try:
        _get_implementation.impls
    except AttributeError:
        # clever! adds state to the function to avoid having to use a `global`
        _get_implementation.impls = {}

        if platform == "linux":

            def _clip(arg):
                p = Popen(["xsel", "-pi"], stdin=PIPE)
                p.communicate(arg)

        elif platform == "darwin":

            def _clip(arg):
                p = Popen("pbcopy", env={"LANG": "en_US.UTF-8"}, stdin=PIPE)
                p.communicate(arg.encode("utf-8"))

        else:
            raise ImportError(
                "Clip magic doesn't work on your platform: '{}'".format(sys.platform)
            )

        _get_implementation.impls[platform] = _clip

    return _get_implementation.impls[platform]


# TODO how I can get this exposed to the ipython structure?
def _copy_to_clipboard(arg):
    arg = str(globals().get(arg) or arg)

    _get_implementation()(arg)

    print("Copied to clipboard!")


@register_line_cell_magic
def copy(line, cell=None):
    if line and cell:
        cell = "\n".join((line, cell))

    _copy_to_clipboard(cell or line)


# We delete it to avoid name conflicts for automagic to work
del copy
