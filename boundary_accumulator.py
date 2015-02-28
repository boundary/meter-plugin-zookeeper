__data = dict()


def accumulate(key, new_value):
    global __data

    try:
        old_value = __data[key]
    except KeyError:
        old_value = new_value

    diff = new_value - old_value
    __data[key] = new_value
    return diff


def reset(key):
    global __data

    try:
        del __data[key]
    except KeyError:
        pass


def reset_all():
    global __data
    __data = {}
