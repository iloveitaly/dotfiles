from IPython.core.magic import register_line_magic
import importlib

def load_ipython_extension(ipython):
    @register_line_magic
    def override_module(line):
        code = ipython.magic('cpaste -q -r')
        lines = code.splitlines()
        module_name = None
        if lines and lines[0].startswith('# file: '):
            print("Found '# file:' directive.")
            path = lines[0][8:].strip()
            module_name = path.replace('/', '.').replace('\\', '.').removesuffix('.py')
            code = '\n'.join(lines[1:])
        if not module_name:
            module_name = line.strip()
            if not module_name:
                raise ValueError("Specify module name or use '# file: path/to/module.py' in pasted code.")
        module = importlib.import_module(module_name)
        exec(code, module.__dict__)
        print(f"Overrode {module_name}.")
        return module