# https://rich.readthedocs.io/en/stable/introduction.html#rich-inspect
def _ipython_rich_inspect(o):
    import rich

    rich.inspect(o, methods=True, docs=True, private=True)

def _ipython_rich_inspect_all(o):
    import rich

    rich.inspect(o, all=True)

def _ipython_rich_pretty_print(o):
    import rich

    rich.print(o)


def _ipython_simple_pp(o):
    import pprint

    pprint.pprint(o)


# i(a) or i a
get_ipython().user_ns["i"] = _ipython_rich_inspect

# rp(a) or rp a
get_ipython().user_ns["rp"] = _ipython_rich_pretty_print

# rpa (rich print all / verbose)
get_ipython().user_ns["rpa"] = _ipython_rich_inspect_all

# pp(a) or pp a
get_ipython().user_ns["pp"] = _ipython_simple_pp

del _ipython_rich_inspect
del _ipython_rich_pretty_print
del _ipython_simple_pp
del _ipython_rich_inspect_all