"""does not work yet"""

import IPython
import nbformat
from nbformat.v4 import new_notebook, new_code_cell
import subprocess
import os


def ipy_session_to_gh_gist():
    # 1. Capture current IPython session
    ip = IPython.get_ipython()
    history = ip.history_manager.get_tail(
        n=None, include_latest=True
    )  # Get all commands
    cells = [new_code_cell(cmd[2]) for cmd in history if cmd[2]]  # cmd[2] is input

    # 2. Convert to .ipynb
    nb = new_notebook(cells=cells)
    nb_file = "session.ipynb"
    with open(nb_file, "w") as f:
        nbformat.write(nb, f)

    # 3. Post to private Gist using gh CLI
    result = subprocess.run(
        ["gh", "gist", "create", "--private", nb_file], capture_output=True, text=True
    )

    # Clean up
    os.remove(nb_file)

    return (
        result.stdout.strip() if result.returncode == 0 else "Failed: " + result.stderr
    )
