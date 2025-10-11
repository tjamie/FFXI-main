# This script transfers this directory's target addon to Windower's addon location

import os
import sys
import shutil
import json

def validate(arg) -> bool:
    ignored: list = [
        ".git",
    ]
    if arg.lower() not in ignored and arg.lower() in get_folders():
        return True
    return False

def get_folders() -> list:
    dir = os.getcwd()
    folders = []
    for entry in os.listdir(dir):
        full_path = os.path.join(dir, entry)
        if os.path.isdir(full_path):
            folders.append(entry.lower())
    return folders

def copy_addon_folder(addon_name) -> None:
    addon_dir = ""
    with open("settings.json", "r") as jf:
        data = json.load(jf)
        addon_dir = data["addonDir"]
    if len(addon_dir) > 2:
        source = os.path.join(os.getcwd(), addon_name)
        destination = os.path.join(addon_dir, addon_name)
        print(f"source: {source}")
        print(f"destination: {destination}")

        if os.path.exists(destination):
            try:
                shutil.copytree(source, destination, dirs_exist_ok=True)
                print(f"Contents of {addon_name} copied to Windower's addon folder")
            except shutil.Error as e:
                print(f"Merge error: {e}")
        else:
            try:
                shutil.copytree(source, destination)
                print(f"Contents of {addon_name} copied to Windower's addon folder")
            except shutil.Error as e:
                print("Merge error: {e}")


if __name__ == "__main__":
    args = sys.argv
    if len(args) > 1: #update.py is arg 0
        if not validate(args[1]):
             print("Invalid argument")
        else:
             try:
                  copy_addon_folder(args[1])
             except Exception as e:
                  print(f"Exception: {e}")
    else:
        print("Insufficient args")