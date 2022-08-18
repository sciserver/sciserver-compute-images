from fastapi import FastAPI, Request
from fastapi.responses import RedirectResponse, HTMLResponse
from subprocess import Popen
import requests
import time
import os
import glob

app = FastAPI()

port_maps = {'': {'port': 9000, 'proc': 0}}
timeout = 10

def get_annotations_file():
    persistent = glob.glob('/home/idies/workspace/Storage/*/persistent')
    annotations_dir = '/tmp/cellxgene_annotations'
    if persistent:
        annotations_dir = f'{persistent[0]}/cellxgene_annotations'
    os.makedirs(annotations_dir, exist_ok = True)
    return f"{annotations_dir}/sciserver-cellxgene-annotations"

def get_base_url(request):
    root = request.scope.get('root_path', '')
    proto = request.headers.get('X-Forwarded-Proto', request.url.scheme)
    port = request.headers.get('X-Forwarded-Port', 8888)
    host = request.headers.get('X-Forwarded-Host', request.url.hostname)
    return f"{proto}://{host}:{port}{root}"

@app.get("/d/{data:path}")
async def main_page(request: Request, data: str):
    print('root path is', request.scope.get('root_path'))
    url = f"{get_base_url(request)}/load/{data}"
    return HTMLResponse(f'''
<html>
<head>
<script>
function cellxgeneload() {{
  document.getElementById("loadscreen").remove();
}}
</script>
</head>
<body>
<iframe
  onload="cellxgeneload()"
  style="position: absolute; top:0px; left:0px; width:100%; height:100%; border:0px;"
  src="{url}">
</iframe>
<div
  id="loadscreen"
  style="position: absolute; top:0px; left:0px; width:100%; height:100%; border:0px; padding-top: 20%; text-align:center">
  <div style="font-size:large"> loading cellxgene explorer... </div>
</div>
</body>
</html>
''', 200)

@app.get("/load/{data:path}")
async def redirect_typer(request: Request, data: str):
    if not os.path.exists(data):
        data = f'/{data}'
    if not os.path.exists(data):
        raise Exception(f'can not find data {data}')
    print('loading', data)
    port = None
    if data in port_maps:
        if port_maps[data]['proc'].poll() is None: # process is still running
            port = port_maps[data]['port']
    if not port:
        port = max([i['port'] for i in port_maps.values()]) + 1
        print('starting cellxgene at port', port)
        p = Popen(['cellxgene', 'launch', '--port', str(port), '--host', '0.0.0.0', '--annotations-file', get_annotations_file(), '-v', data])
        port_maps[data] = {'port': port, 'proc': p}
        for i in range(timeout):
            time.sleep(1)
            try:
                r = requests.get(f'http://localhost:{port}')
                if r.status_code == 200:
                    print('cellxgene started!')
                    break
            except:
                print('waiting on cellxgene')
    return RedirectResponse(f"{get_base_url(request)}/cellxgene/{port}/")
