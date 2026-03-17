"""IPython startup extension that hot-patches an imported module from pasted code.

Usage in IPython:
1. Run `%override_module some.module.name` and paste replacement code, then EOF.
2. Or paste code whose first line is `# file: path/to/module.py` to infer the module
    automatically (for example, `# file: mypkg/utils/helpers.py`).

How it works:
- Imports the target module with `importlib.import_module(...)`.
- Compiles the pasted code with a useful filename for better tracebacks.
- Executes the pasted code against a temporary module namespace and only commits the
  changes if execution succeeds.
- Existing names in the module can be replaced in-place for fast, interactive tweaks.
"""

import sys
import importlib


def load_ipython_extension(ipython):
    def override_module(line):
        """Override objects in an already-importable module using pasted Python code."""
        print("Paste the code, end with Ctrl+D (Unix/Mac) or Ctrl+Z+Enter (Windows).")
        code = sys.stdin.read().strip()
        if not code:
            raise ValueError("No code was provided.")

        lines = code.splitlines()
        module_name = None
        source_name = None

        if lines and lines[0].startswith("# file: "):
            print("Found '# file:' directive.")
            path = lines[0][8:].strip()
            module_name = path.replace("/", ".").replace("\\", ".").removesuffix(".py")
            source_name = path
            code = "\n".join(lines[1:])

        if not module_name:
            module_name = line.strip()
            if not module_name:
                raise ValueError(
                    "Specify module name or use '# file: path/to/module.py' in pasted code."
                )

        if not code.strip():
            raise ValueError("No code was provided after the optional '# file:' directive.")

        module = importlib.import_module(module_name)
        source_name = source_name or getattr(module, "__file__", module_name)
        compiled = compile(code, source_name, "exec")

        original_keys = set(module.__dict__)
        updated_namespace = module.__dict__.copy()
        exec(compiled, updated_namespace)

        removed_keys = original_keys - set(updated_namespace)
        for key in removed_keys:
            module.__dict__.pop(key, None)

        module.__dict__.update(updated_namespace)
        print(f"Overrode {module_name}.")
        return module

    ipython.register_magic_function(override_module, "line")
