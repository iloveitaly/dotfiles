import os
from IPython.core.magic import register_line_cell_magic
import json
import tempfile
import subprocess


@register_line_cell_magic
def generate_typeddict(line, cell=None):
    "A line-cell magic that generates TypedDict from a Python dictionary."

    # Evaluate the cell content or the line content as Python code to get the dictionary
    dict_data = (
        eval(cell.strip())
        if cell is not None and cell.strip()
        else eval(line.strip()) if line.strip() else None
    )

    if dict_data is None or not isinstance(dict_data, dict):
        print("Error: No valid Python dictionary provided.")
        return

    try:
        # Create a temporary JSON file from the dictionary
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".json") as tmp:
            json.dump(dict_data, tmp)
            tmp_path = tmp.name

        # Call datamodel-code-generator CLI to generate code
        result = subprocess.run(
            [
                "datamodel-codegen",
                "--input",
                tmp_path,
                "--input-file-type",
                "json",
                "--output",
                "-",
            ],
            capture_output=True,
            text=True,
        )

        # Check for errors in subprocess execution
        if result.returncode != 0:
            print("Error in code generation:")
            print(result.stderr)
        else:
            print("Generated TypedDict code:")
            # Output the generated code
            print(result.stdout)

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
