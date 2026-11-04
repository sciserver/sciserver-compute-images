def setup_ds9():
    out = {
        'command': ['start_supervisor'],
        # IMPORTANT: Point the proxy to the websockify port
        'port': 6080,
        'timeout': 30,
        'mappath': {'/': '/vnc_lite.html'},
        'new_browser_tab': False,
        'launcher_entry': {
            'enabled': True,
            'icon_path': '/opt/ds9.svg',
            'title': 'DS9'
        }
    }
    return out

c.ServerProxy.servers = {  # noqa
    'ds9': setup_ds9()
}
