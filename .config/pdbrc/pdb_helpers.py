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

def find_first_project_frame(frame, debug=False):
    cwd = os.path.abspath(os.getcwd())
    venv_path = os.environ.get('VIRTUAL_ENV')
    if venv_path:
        venv_path = os.path.abspath(venv_path)

    if debug:
        print(f"DEBUG: cwd = {cwd}")
        print(f"DEBUG: venv_path = {venv_path}")

    frames = inspect.getouterframes(frame)
    if debug:
        print(f"DEBUG: Found {len(frames)} frames")
    
    for i, frame_info in enumerate(reversed(frames)):  # Start from innermost to outermost
        filename = frame_info.filename
        if debug:
            print(f"DEBUG: Frame {i}: {filename}")
        
        if filename.startswith('<'):  # Skip non-file frames like <string> or <module>
            if debug:
                print(f"DEBUG: Skipping non-file frame: {filename}")
            continue
        
        abs_filename = os.path.abspath(filename)
        if debug:
            print(f"DEBUG: abs_filename = {abs_filename}")
        
        if venv_path and abs_filename.startswith(venv_path):
            if debug:
                print(f"DEBUG: Skipping venv frame: {abs_filename}")
            continue
        
        if abs_filename.startswith(cwd):
            if debug:
                print(f"DEBUG: Found project frame: {abs_filename}")
            return frame_info.frame
    
    # If no matching frame found, return the original frame
    if debug:
        print("DEBUG: No matching frame found, returning original frame")
    return frame