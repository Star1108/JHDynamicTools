#!/usr/bin/python

# -*- coding: utf-8 -*-

import sys,os
import shutil
import re

ignore_files = [
".git"
]

replace_exts = [
'.c',
'.gitignore',
'.m',
'.mm',
'.h',
'.pbxproj',
'.plist',
'.json',
'.py',
'.txt',
'.spec',
'.md',
'.pch',
'.xcscheme',
'config.json'
]

def filetext_replace(filepath, plugin_name, template):
    if (not os.path.isfile(filepath) or os.path.islink(filepath)):
        return

    filecontent = None
    with open(filepath, "r") as f:
        filecontent = f.read()
        filecontent = re.sub(template, plugin_name, filecontent)

    with open(filepath, 'w') as f:
        f.write(filecontent)

def rename_plugin(plugin_folder, plugin_name, template):
    for root, dirs, filenames in os.walk(plugin_folder):
        for filename in filenames:
            newfilename = re.sub(template, plugin_name, filename)
            if (newfilename != filename):
                os.rename(os.path.join(root, filename), os.path.join(root, newfilename))
                print("rename " + os.path.join(root, filename) + " -> " + os.path.join(root, newfilename))

            if filename in ignore_files:
                continue
            if not os.path.splitext(filename)[1] in replace_exts:
                continue

            filetext_replace(os.path.join(root, newfilename), plugin_name, template)

    for root, dirs, filenames in os.walk(plugin_folder, topdown=False):
        for dirname in dirs:
            newdirname = re.sub(template, plugin_name, dirname)
            if (newdirname != dirname):
                os.rename(os.path.join(root, dirname), os.path.join(root, newdirname))
                print("rename " + os.path.join(root, dirname) + " -> " + os.path.join(root, newdirname))


def create_plugin(plugin_root, plugin_name, template):
    if not plugin_name.startswith('JHToolsSDK_'):
        plugin_name = 'JHToolsSDK_' + plugin_name

    new_plugin_path = os.path.join(plugin_root, plugin_name)
    
    if template != None and template != "":
        if not template.startswith('JHToolsSDK_'):
            template = 'JHToolsSDK_' + template
    else:
        template = "JHToolsSDK_CommonSDK_Template"

    template_plugin_path = os.path.join(plugin_root, template)

    if os.path.exists(new_plugin_path):
        print("The plugin already exists!")
        return

    shutil.copytree(template_plugin_path, new_plugin_path)

    rename_plugin(new_plugin_path, plugin_name, template)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: %s <plugin_name> <template_type>"%sys.argv[0])
        sys.exit(1)

    create_plugin(os.path.dirname(sys.argv[0]), sys.argv[1], (len(sys.argv) > 2 and sys.argv[2] or None))
