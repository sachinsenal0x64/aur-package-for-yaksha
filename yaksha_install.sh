#!/bin/sh

pre="vP20240414.f76ff03"
folder="yaksha_${pre}_linux-x86_64"
archive="${folder}.tar.gz"
src="/tmp/${folder}"  

# Ensure the source directory exists
mkdir -p "$src"

# Decompress the archive
tar -xzf "$archive" -C "$src"

# Automatically determine the first directory inside the tarball
inner_folder=$(tar -tzf "$archive" | grep -o '^[^/]*/' | head -1 | cut -d'/' -f1)


# Check if inner_folder has been set and is not just the root of src
if [ -n "$inner_folder" ] && [ -d "$src/$inner_folder" ]; then
    # Move all contents of the inner directory to the parent directory
    mv "$src/$inner_folder"/* "$src/"
    # Remove the now empty inner directory
    rmdir "$src/$inner_folder"
fi


# Move into the directory
cd "$src"


sudo sh -c '
    echo "Installing binaries and libraries..."

    # Copy files and set execute permissions
    cp -r bin/yaksha bin/hammer bin/carpntr bin/zig /usr/local/bin/
    chmod +x /usr/local/bin/yaksha /usr/local/bin/hammer /usr/local/bin/carpntr /usr/local/bin/zig

    # Move other directories
    cp -r runtime libs /usr/local/
    cp -r bin/lib /usr/local/lib
    cp -r bin/doc /usr/local/doc

'

# Create a test Yaksha script
echo "# Example Yaksha Code
def main() -> int:
    println(\"Hello World\")
    return 0" > test.yaka


# Build the Yaksha script
yaksha build -R test.yaka

# Clean up: remove the extracted folder
rm -rf "$src"

echo "Installation and test build complete. Done!"

yaksha 
