import os
import json
import tempfile
import subprocess
from IPython.core.magic import register_line_cell_magic


@register_line_cell_magic
def generate_typeddict(line, cell=None):
    "A line-cell magic that generates TypedDict from a Python dictionary."

    # Determine if debug mode is on based on the environment variable
    debug_mode = os.getenv("IPYTHON_TYPEDDICT_DEBUG", "False").lower() in (
        "true",
        "1",
        "t",
    )

    breakpoint()
    # Evaluate the Python dictionary from the input
    dict_data = (
        eval(cell)
        if cell is not None and isinstance(cell, str)
        else eval(line) if line is not None and isinstance(line, str) else None
    )

    if dict_data is None or not isinstance(dict_data, dict):
        print("Error: No valid Python dictionary provided.")
        return

    try:
        # Serialize the dictionary to a temporary JSON file
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".json") as tmp:
            json.dump(dict_data, tmp)
            tmp_path = tmp.name

        # Prepare the command for datamodel-codegen
        command = [
            "datamodel-codegen",
            "--input",
            tmp_path,
            "--input-file-type",
            "json",
            "--output",
            "-",
        ]

        if debug_mode:
            print(f"Debug: Running command: {' '.join(command)}")

        # Execute the command
        result = subprocess.run(command, capture_output=True, text=True)

        # Check for errors
        if result.returncode != 0 or result.stderr:
            print("Error in code generation:")
            print(result.stderr.strip())
        else:
            # Output the generated code
            print(result.stdout.strip())

    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Clean up the temporary file
        if os.path.exists(tmp_path):
            os.remove(tmp_path)


def load_ipython_extension(ipython):
    # This method is called by IPython when this extension is loaded.
    pass


def unload_ipython_extension(ipython):
    # This method is called by IPython when this extension is unloaded.
    pass
