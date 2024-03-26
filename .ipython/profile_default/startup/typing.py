# import json
# from dict_typer import get_type_definitions

# # https://stackoverflow.com/questions/58392596/how-to-run-ipython-line-magic-from-a-script


# def to_typed_dict(obj):
#     json_str = json.dumps(obj, indent=4, sort_keys=True, default=str)
#     get_ipython().find_line_magic("sc")("a = pbpaste | dict-typer | pbcopy")
#     return json.loads(json_str)
#     # pip install dict-typer
