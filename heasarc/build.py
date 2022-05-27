#!/usr/bin/env python3

import argparse
import glob
import subprocess
import os
import json
import time
import logging
import sys


# image names in their dependency order
IMAGES = [
    'sciserver-base',
    'sciserver-jupyter',
    'sciserver-anaconda',
    'heasoft',
    'ciao',
    'fermi',
    'xmmsas',
    'heasarc'
]


    
def parse_input(**kwargs):
    """Parse input an prepare a list of images to build"""

    logging.debug('Processing the input')
    images_in = kwargs.get('images', ['heasarc'])
    
    image_order = {i:v for i,v in enumerate(IMAGES)}
    
    images = []
    for im in images_in:
        if not im in IMAGES:
            logging.info(f'Unrecognized image: {im}')
            continue
        images.append(im)
    # include dependencies
    tobuild = []
    for im in images:
        for i,v in image_order.items():
            if not v in tobuild: tobuild.append(v)
            if v == im:
                break
    return tobuild
    

def build_images(images, dryrun=False):
    """call 'docker build' on each element in images
    
    images: a list of images to build. e.g ['heasoft', 'ciao'].
        Usually the output of parse_input
        
    """
    logging.debug('The following will be built: ' + (', '.join(images)))    
    
    # read build.json file for versions and other details
    jsonfile = 'build.json'
    if not os.path.exists(jsonfile):
        logging.error(f'No descriptor file {jsonfile} found. Stopping ...')
        sys.exit(1)
    info = json.load(open(jsonfile))
    
    
    # loop through requested images
    for image in images:
        
        logging.debug(f'Working on image {image} ...')
        folder = None
        for k in ['', 'sciserver-', 'sciserver_']:
            folder = f'{k}{image}'
            if os.path.exists(folder) and os.path.exists(f'{folder}/Dockerfile'):
                logging.debug(f'\tFound {image} in ./{folder}')
                break
        if folder is None:    
            logging.error(f'No image folder found for {image}')
            sys.exit(1)
        
        im_info = info.get(image, {'version': '1.0'})
        
        image_name  = im_info.get('name', image)
        image_vers  = im_info.get('version', '1.0')
        image_label = im_info.get('label', f'v{image_vers}')
        
        # build the image #
        logging.debug(f'\tBuilding {image_name}')
        cmd = ['docker', 'build', '--network=host', '-t', 
               f'{image_name}:{image_label}', 
               f'--build-arg', f'version={image_vers}', 
               f'./{folder}']
        logging.debug('\t' + (' '.join(cmd)))
        
        if not dryrun:
            out = subprocess.call(cmd)
            if out: 
                logging.error('\tError encountered.')
                sys.exit(1)
        
        # tag the image as latest #
        logging.debug(f'\tBuilding {image_name}')
        cmd = ['docker', 'tag', f'{image_name}:{image_label}', 
               f'{image_name}:latest']
        logging.debug('\t' + (' '.join(cmd)))
        if not dryrun:
            out = subprocess.call(cmd)
            if out: 
                logging.error('\tError encountered.')
                sys.exit(1)
        
        # remove any dangling images
        cmd = 'docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi -f'
        logging.debug('\t' + cmd)
        if not dryrun:
            out = subprocess.check_call(cmd, shell=True)
            if out: 
                logging.error('\tError encountered.')
                sys.exit(1)
    
      
        


if __name__ == '__main__':
    
    
    ap = argparse.ArgumentParser()
    ap.add_argument('--verbose', '-v', action='count', default=0)
    ap.add_argument('--dryrun', action='store_true')
    ap.add_argument('images', nargs='*', help='images to build', default=['heasarc'])
    args = ap.parse_args()
    

    logging.basicConfig(format='%(asctime)s|%(levelname)5s| %(message)s',
                        datefmt='%Y-%m-%d|%H:%M:%S')
    logging.getLogger().setLevel(logging.INFO - 10*args.verbose)
    
    images = parse_input(**vars(args))
    build_images(images, args.dryrun)
    
    