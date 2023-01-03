
def setup_ds9():

    out = {
        'command': ['start_supervisor'],
        'port': 5901,
        'timeout': 30,
        'mappath': {'/': '/vnc_lite.html'},
        'new_browser_window': False,
        'launcher_entry': {
            'enabled': True,
            'icon_path': '/opt/ds9.svg',
            'title': 'DS9'
        }
    }
    return out


c.ServerProxy.servers = {
    'ds9': setup_ds9()
}




