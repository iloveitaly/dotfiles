import json


def to_json(d):
    # assumption here is input is a dict, let's check
    if not isinstance(d, dict) and not isinstance(d, list):
        raise ValueError("Input is not a dictionary")

    json_str = json.dumps(d, indent=4)

    # return outputs the variable value in a way that can be copied
    return json_str


# TODO not available as a magic
get_ipython().user_ns["to_json"] = to_json
