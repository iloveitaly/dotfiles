# TODO finish implementing https://grok.com/share/bGVnYWN5_c789c219-7867-44f3-a611-deda13a8fe24

import inspect
import os
import sys
import bdb


def print_stack(frame):
    current_frame = frame
    for i, frame_info in enumerate(reversed(inspect.getouterframes(current_frame))):
        frame = frame_info.frame
        filename = frame.f_code.co_filename
        lineno = frame.f_lineno
        func_name = frame.f_code.co_name
        indicator = "=> " if frame is current_frame else "   "
        print(f"{indicator}#{i} {filename}:{lineno} in {func_name}")


def open_in_vscode_from_frame(frame):
    filename = frame.f_code.co_filename
    lineno = frame.f_lineno
    cmd = f"code -g {filename}:{lineno}"
    os.system(cmd)


def pytest_quit():
    if "pytest" in sys.modules:
        import pytest

        pytest.exit("stop all")
    raise bdb.BdbQuit
