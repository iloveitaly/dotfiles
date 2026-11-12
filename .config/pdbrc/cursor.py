"""
Open the current location in the stack in cursor

https://stackoverflow.com/questions/77515931/python-debugger-pdb-open-currently-active-python-file-in-editor
"""

import os


def open_in_cursor_from_frame(frame):
    file_path = frame.f_code.co_filename
    line_number = frame.f_lineno
    os.system(f'cursor -g "{file_path}:{line_number}"')


def cursor():
    import inspect

    # Expecting a frame passed in from command line context
    frame = (
        inspect.currentframe().f_back
    )  # Go back one frame to where the function was called

    open_in_cursor_from_frame(frame)
