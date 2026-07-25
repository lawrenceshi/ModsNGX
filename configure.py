import json5
import os

# The function for writing text
def write_text(read_file_name:str, write_to_file):
    with open(os.path.join("build", f"{read_file_name}.txt"), "r") as text:
        write_to_file.write(text.read())
    return True

def write_replace_text(read_file_name:str, write_to_file, change:dict):
    with open(os.path.join("build", f"{read_file_name}.txt"), "r") as text:
        replace_text = text.read()
        for k,v in change.items():
            replace_text = replace_text.replace(k, v)
        write_to_file.write(replace_text)

def main():
    # The configuration file actually stores all the directions.
    with open("./configure.json5", "r" ) as file:
        config = json5.load(file)

    # List of modules
    modules = []

    # k = key, v = vaule of the items.
    for k,v in config.items():
        # The dir the Containerfile is going be stored in.
        file_dir_path = os.path.join(k)
        # The real path of the Containerfile
        # Rather Dockerfile or Containerfile, either or, changeable
        file_write_path = os.path.join(k, "Containerfile")
        # Create dir
        if not os.path.exists(file_dir_path):
            os.makedirs(file_dir_path)
        # Open the file we are going to generate
        # Write mode to rewrite everything
        with open(file_write_path, "w") as container_file:
            # Some non-usable error test:
            if "alpine" in v["builder_image"] and v["include_corazawaf"]:
                print("This config is Incompatible and not useable")
                exit(1)

            # Write '''DO NOT CHANGE''' warning
            if v["write_warning"]:
                write_text("Warning", container_file)
            
            # Write and replace the From xxx image
            if v["write_base_image"]:
                write_replace_text("Image", container_file, {"$[image_name]": v["builder_image"], "$[stage_name]" : v["builder_stage_name"]})
            
            # Coraza Part
            if v["include_corazawaf"]:
                write_replace_text("Corazawaf", container_file, {"$[Libcoraza_Versio]" : v["libcoraza_version"], "$[Corazawaf_Version]" : v["libcoraza_version"]})
            
            

if __name__ == "__main__":
    main()