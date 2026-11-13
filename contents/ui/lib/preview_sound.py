"""Preview a theme sound or local audio file using the desktop sound service."""
import configparser
import ctypes
import ctypes.util
import os
from pathlib import Path
import sys
import time


def play(sound):
    library = ctypes.util.find_library('canberra')
    if not library:
        raise RuntimeError('The system sound library (libcanberra) is unavailable')
    api = ctypes.CDLL(library)
    context = ctypes.c_void_p()
    api.ca_context_create.argtypes = [ctypes.POINTER(ctypes.c_void_p)]
    api.ca_context_destroy.argtypes = [ctypes.c_void_p]
    api.ca_context_play.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
    api.ca_context_playing.argtypes = [ctypes.c_void_p, ctypes.c_uint32, ctypes.POINTER(ctypes.c_int)]
    api.ca_strerror.restype = ctypes.c_char_p
    result = api.ca_context_create(ctypes.byref(context))
    if result < 0:
        raise RuntimeError(api.ca_strerror(result).decode())
    try:
        config = configparser.ConfigParser(interpolation=None, strict=False)
        config.read(Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config')) / 'kdeglobals')
        theme = config.get('Sounds', 'Theme', fallback='ocean')
        key = b'media.filename' if os.path.isabs(sound) else b'event.id'
        result = api.ca_context_play(context, 1, key, sound.encode(),
            b'canberra.xdg-theme.name', theme.encode(), b'media.role', b'event', None)
        if result < 0:
            raise RuntimeError(api.ca_strerror(result).decode())
        deadline = time.monotonic() + 30
        while time.monotonic() < deadline:
            active = ctypes.c_int()
            result = api.ca_context_playing(context, 1, ctypes.byref(active))
            if result < 0 or not active.value:
                break
            time.sleep(0.05)
    finally:
        api.ca_context_destroy(context)


if __name__ == '__main__':
    try:
        play(sys.argv[1])
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
