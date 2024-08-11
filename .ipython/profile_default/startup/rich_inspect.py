# https://rich.readthedocs.io/en/stable/introduction.html#rich-inspect
def _ipython_rich_inspect(o):
    import rich

    rich.inspect(o, methods=True, docs=True, private=True)


# i(a) or i a
get_ipython().user_ns["i"] = _ipython_rich_inspect

del _ipython_rich_inspect
