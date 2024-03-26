from IPython.core.magic import register_line_cell_magic
import json
import tempfile
import subprocess


@register_line_cell_magic
def generate_typeddict(line, cell=None):
    "A line-cell magic that generates TypedDict from JSON."

    # Use the cell content as JSON or the line content if cell is None
    json_data = cell if cell is not None else line
    try:
        # Parse to ensure it's valid JSON
        parsed_json = json.loads(json_data)

        # Create a temporary JSON file
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".json") as tmp:
            json.dump(parsed_json, tmp)
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

        # Output the generated code
        print(result.stdout)

    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
    finally:
        # Clean up the temporary file
        if tmp_path and os.path.exists(tmp_path):
            os.remove(tmp_path)


def load_ipython_extension(ipython):
    # This method is called by IPython when this extension is loaded.
    pass


def unload_ipython_extension(ipython):
    # This method is called by IPython when this extension is unloaded.
    pass
