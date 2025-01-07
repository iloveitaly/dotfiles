"""
https://stackoverflow.com/questions/77515931/python-debugger-pdb-open-currently-active-python-file-in-editor
"""

import os


def open_in_vscode_from_frame(frame):
    file_path = frame.f_code.co_filename
    line_number = frame.f_lineno
    os.system(f'code -g "{file_path}:{line_number}"')


def vscode():
    import inspect

    # Expecting a frame passed in from command line context
    frame = (
        inspect.currentframe().f_back
    )  # Go back one frame to where the function was called
    open_in_vscode_from_frame(frame)
